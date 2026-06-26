use async_trait::async_trait;
use chrono::{DateTime, NaiveDateTime, Utc};
use sqlx::{PgPool, Row};

use crate::core::entities::subscription::{
    PaymentChannel, SubscriptionOrder, SubscriptionOrderStatus, SubscriptionPeriod,
    SubscriptionProduct,
};
use crate::core::errors::{DomainError, Result};
use crate::core::ports::SubscriptionRepository;

#[derive(Clone)]
pub struct PostgresSubscriptionRepository {
    pool: PgPool,
}

impl PostgresSubscriptionRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    fn default_products() -> Vec<SubscriptionProduct> {
        vec![
            SubscriptionProduct {
                product_id: "kiki_vip_monthly".to_string(),
                title: "连续包月".to_string(),
                period: SubscriptionPeriod::Monthly,
                price_cents: 990,
                currency: "CNY".to_string(),
                display_price: "¥9.9/月".to_string(),
                trial_days: 0,
                is_recommended: false,
                enabled: true,
            },
            SubscriptionProduct {
                product_id: "kiki_vip_yearly".to_string(),
                title: "连续包年".to_string(),
                period: SubscriptionPeriod::Yearly,
                price_cents: 8800,
                currency: "CNY".to_string(),
                display_price: "¥88/年".to_string(),
                trial_days: 3,
                is_recommended: true,
                enabled: true,
            },
        ]
    }

    fn payment_channel_to_str(channel: PaymentChannel) -> &'static str {
        match channel {
            PaymentChannel::AppleIap => "apple_iap",
            PaymentChannel::WechatPay => "wechat_pay",
            PaymentChannel::GooglePlayBilling => "google_play_billing",
            PaymentChannel::ApplePay => "apple_pay",
            PaymentChannel::Unsupported => "unsupported",
        }
    }

    fn payment_channel_from_str(value: &str) -> PaymentChannel {
        match value {
            "apple_iap" => PaymentChannel::AppleIap,
            "wechat_pay" => PaymentChannel::WechatPay,
            "google_play_billing" => PaymentChannel::GooglePlayBilling,
            "apple_pay" => PaymentChannel::ApplePay,
            _ => PaymentChannel::Unsupported,
        }
    }

    fn status_to_str(status: SubscriptionOrderStatus) -> &'static str {
        match status {
            SubscriptionOrderStatus::Pending => "pending",
            SubscriptionOrderStatus::Paid => "paid",
            SubscriptionOrderStatus::Failed => "failed",
            SubscriptionOrderStatus::Cancelled => "cancelled",
        }
    }

    fn status_from_str(value: &str) -> SubscriptionOrderStatus {
        match value {
            "paid" => SubscriptionOrderStatus::Paid,
            "failed" => SubscriptionOrderStatus::Failed,
            "cancelled" => SubscriptionOrderStatus::Cancelled,
            _ => SubscriptionOrderStatus::Pending,
        }
    }

    fn naive_to_utc(value: NaiveDateTime) -> DateTime<Utc> {
        DateTime::from_naive_utc_and_offset(value, Utc)
    }

    fn map_order(row: &sqlx::postgres::PgRow) -> SubscriptionOrder {
        let vip_expire_at = row
            .try_get::<NaiveDateTime, _>("vip_expire_at")
            .ok()
            .map(Self::naive_to_utc);
        let created_at = Self::naive_to_utc(row.get("created_at"));
        let updated_at = Self::naive_to_utc(row.get("updated_at"));
        let payment_channel: String = row.get("payment_channel");
        let status: String = row.get("status");

        SubscriptionOrder {
            order_id: row.get("order_id"),
            user_id: row.get("user_id"),
            product_id: row.get("product_id"),
            payment_channel: Self::payment_channel_from_str(&payment_channel),
            amount_cents: row.get("amount_cents"),
            currency: row.get("currency"),
            status: Self::status_from_str(&status),
            purchase_token: row.try_get("purchase_token").ok(),
            vip_expire_at,
            created_at,
            updated_at,
        }
    }
}

#[async_trait]
impl SubscriptionRepository for PostgresSubscriptionRepository {
    async fn list_products(&self) -> Result<Vec<SubscriptionProduct>> {
        let rows = sqlx::query(
            r#"
            SELECT product_id, title, period, price_cents, currency,
                   display_price, trial_days, is_recommended, enabled
            FROM subscription_products
            WHERE enabled = TRUE
            ORDER BY price_cents ASC
            "#,
        )
        .fetch_all(&self.pool)
        .await;

        match rows {
            Ok(rows) => Ok(rows
                .iter()
                .map(|row| SubscriptionProduct {
                    product_id: row.get("product_id"),
                    title: row.get("title"),
                    period: SubscriptionPeriod::parse(row.get::<String, _>("period").as_str()),
                    price_cents: row.get("price_cents"),
                    currency: row.get("currency"),
                    display_price: row.get("display_price"),
                    trial_days: row.get("trial_days"),
                    is_recommended: row.get("is_recommended"),
                    enabled: row.get("enabled"),
                })
                .collect()),
            Err(_) => Ok(Self::default_products()),
        }
    }

    async fn find_product(&self, product_id: &str) -> Result<Option<SubscriptionProduct>> {
        Ok(self
            .list_products()
            .await?
            .into_iter()
            .find(|product| product.product_id == product_id))
    }

    async fn save_order(&self, order: &SubscriptionOrder) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO subscription_orders (
              order_id, user_id, product_id, payment_channel, amount_cents,
              currency, status, purchase_token, vip_expire_at, created_at, updated_at
            ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
            "#,
        )
        .bind(&order.order_id)
        .bind(&order.user_id)
        .bind(&order.product_id)
        .bind(Self::payment_channel_to_str(order.payment_channel))
        .bind(order.amount_cents)
        .bind(&order.currency)
        .bind(Self::status_to_str(order.status))
        .bind(&order.purchase_token)
        .bind(order.vip_expire_at)
        .bind(order.created_at)
        .bind(order.updated_at)
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("创建订阅订单失败: {}", e)))?;

        Ok(())
    }

    async fn find_order(&self, order_id: &str, user_id: &str) -> Result<Option<SubscriptionOrder>> {
        let row =
            sqlx::query("SELECT * FROM subscription_orders WHERE order_id = $1 AND user_id = $2")
                .bind(order_id)
                .bind(user_id)
                .fetch_optional(&self.pool)
                .await
                .map_err(|e| DomainError::Infrastructure(format!("查询订阅订单失败: {}", e)))?;

        Ok(row.as_ref().map(Self::map_order))
    }

    async fn update_order_paid(
        &self,
        order_id: &str,
        user_id: &str,
        purchase_token: Option<&str>,
        vip_expire_at: DateTime<Utc>,
    ) -> Result<SubscriptionOrder> {
        let row = sqlx::query(
            r#"
            UPDATE subscription_orders
            SET status = 'paid',
                purchase_token = $3,
                vip_expire_at = $4,
                updated_at = CURRENT_TIMESTAMP
            WHERE order_id = $1 AND user_id = $2
            RETURNING *
            "#,
        )
        .bind(order_id)
        .bind(user_id)
        .bind(purchase_token)
        .bind(vip_expire_at)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("确认订阅订单失败: {}", e)))?;

        Ok(Self::map_order(&row))
    }

    async fn update_user_vip(&self, user_id: &str, vip_expire_at: DateTime<Utc>) -> Result<()> {
        sqlx::query(
            r#"
            UPDATE users
            SET is_vip = TRUE,
                vip_expire_at = $2,
                last_login_at = CURRENT_TIMESTAMP
            WHERE id = $1
            "#,
        )
        .bind(user_id)
        .bind(vip_expire_at)
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("更新 VIP 权益失败: {}", e)))?;

        Ok(())
    }
}
