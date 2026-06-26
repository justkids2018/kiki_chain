use chrono::{Duration, Utc};
use std::sync::Arc;
use uuid::Uuid;

use crate::core::entities::subscription::{
    ChannelResolution, ClientPlatform, DistributionChannel, PaymentChannel, RegionCode,
    SubscriptionOrder, SubscriptionOrderStatus, SubscriptionProduct, VipEntitlement,
};
use crate::core::errors::{DomainError, Result};
use crate::core::ports::{SubscriptionRepository, UserRepository};

use super::ChannelPolicy;

pub struct ResolveChannelCommand {
    pub region: String,
    pub platform: String,
    pub distribution_channel: Option<String>,
    pub client_capabilities: Vec<String>,
}

pub struct ProductQuery {
    pub region: String,
    pub platform: String,
    pub distribution_channel: Option<String>,
}

pub struct CreateOrderCommand {
    pub user_id: String,
    pub product_id: String,
    pub region: String,
    pub platform: String,
    pub distribution_channel: Option<String>,
}

pub struct ConfirmOrderCommand {
    pub user_id: String,
    pub order_id: String,
    pub purchase_token: Option<String>,
    pub sandbox: bool,
}

pub struct SubscriptionUseCase {
    subscription_repository: Arc<dyn SubscriptionRepository>,
    user_repository: Arc<dyn UserRepository>,
    channel_policy: ChannelPolicy,
}

impl SubscriptionUseCase {
    pub fn new(
        subscription_repository: Arc<dyn SubscriptionRepository>,
        user_repository: Arc<dyn UserRepository>,
    ) -> Self {
        Self {
            subscription_repository,
            user_repository,
            channel_policy: ChannelPolicy::new(),
        }
    }

    pub fn resolve_channel(&self, command: ResolveChannelCommand) -> ChannelResolution {
        self.channel_policy.resolve(
            RegionCode::parse(&command.region),
            ClientPlatform::parse(&command.platform),
            DistributionChannel::parse(command.distribution_channel.as_deref()),
            &command.client_capabilities,
        )
    }

    pub async fn list_products(
        &self,
        query: ProductQuery,
    ) -> Result<(PaymentChannel, Vec<SubscriptionProduct>)> {
        let resolution = self.resolve_channel(ResolveChannelCommand {
            region: query.region,
            platform: query.platform,
            distribution_channel: query.distribution_channel,
            client_capabilities: vec![],
        });

        if !resolution.supported {
            return Ok((resolution.payment_channel, vec![]));
        }

        let products = self
            .subscription_repository
            .list_products()
            .await?
            .into_iter()
            .filter(|product| product.enabled)
            .collect();

        Ok((resolution.payment_channel, products))
    }

    pub async fn get_entitlement(&self, user_id: &str) -> Result<VipEntitlement> {
        let user = self
            .user_repository
            .find_by_uid(user_id)
            .await?
            .ok_or_else(|| DomainError::NotFound("用户不存在".to_string()))?;

        Ok(VipEntitlement {
            is_vip: user.is_vip_valid(),
            vip_expire_at: user.vip_expire_at(),
            source: "subscription".to_string(),
            server_time: Utc::now(),
        })
    }

    pub async fn create_order(&self, command: CreateOrderCommand) -> Result<SubscriptionOrder> {
        let resolution = self.resolve_channel(ResolveChannelCommand {
            region: command.region,
            platform: command.platform,
            distribution_channel: command.distribution_channel,
            client_capabilities: vec![],
        });

        if !resolution.supported || resolution.payment_channel == PaymentChannel::Unsupported {
            return Err(DomainError::Validation(resolution.message));
        }

        let product = self
            .subscription_repository
            .find_product(&command.product_id)
            .await?
            .ok_or_else(|| DomainError::NotFound("订阅产品不存在".to_string()))?;

        let now = Utc::now();
        let order = SubscriptionOrder {
            order_id: format!(
                "sub_ord_{}_{}",
                now.format("%Y%m%d%H%M%S"),
                &Uuid::new_v4().to_string()[..8]
            ),
            user_id: command.user_id,
            product_id: product.product_id,
            payment_channel: resolution.payment_channel,
            amount_cents: product.price_cents,
            currency: product.currency,
            status: SubscriptionOrderStatus::Pending,
            purchase_token: None,
            vip_expire_at: None,
            created_at: now,
            updated_at: now,
        };

        self.subscription_repository.save_order(&order).await?;
        Ok(order)
    }

    pub async fn confirm_order(&self, command: ConfirmOrderCommand) -> Result<SubscriptionOrder> {
        let order = self
            .subscription_repository
            .find_order(&command.order_id, &command.user_id)
            .await?
            .ok_or_else(|| DomainError::NotFound("订单不存在".to_string()))?;

        if order.status == SubscriptionOrderStatus::Paid {
            return Ok(order);
        }

        if !command.sandbox && command.purchase_token.as_deref().unwrap_or("").is_empty() {
            return Err(DomainError::Validation("缺少支付凭证".to_string()));
        }

        let product = self
            .subscription_repository
            .find_product(&order.product_id)
            .await?
            .ok_or_else(|| DomainError::NotFound("订阅产品不存在".to_string()))?;

        let vip_expire_at = Utc::now() + Duration::days(product.period.duration_days());
        let paid_order = self
            .subscription_repository
            .update_order_paid(
                &order.order_id,
                &order.user_id,
                command
                    .purchase_token
                    .as_deref()
                    .or(Some("sandbox_success")),
                vip_expire_at,
            )
            .await?;

        self.subscription_repository
            .update_user_vip(&order.user_id, vip_expire_at)
            .await?;

        Ok(paid_order)
    }
}
