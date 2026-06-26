use serde::{Deserialize, Serialize};

use crate::core::entities::subscription::{
    ChannelResolution, PaymentChannel, SubscriptionOrder, SubscriptionOrderStatus,
    SubscriptionProduct, VipEntitlement,
};

#[derive(Debug, Deserialize)]
pub struct ResolveChannelRequest {
    pub region: String,
    pub platform: String,
    pub distribution_channel: Option<String>,
    #[serde(default)]
    pub client_capabilities: Vec<String>,
}

#[derive(Debug, Deserialize)]
pub struct ProductsQuery {
    pub region: Option<String>,
    pub platform: Option<String>,
    pub distribution_channel: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct CreateOrderRequest {
    pub product_id: String,
    pub region: String,
    pub platform: String,
    pub distribution_channel: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct ConfirmOrderRequest {
    pub purchase_token: Option<String>,
    #[serde(default)]
    pub sandbox: bool,
}

#[derive(Debug, Serialize)]
pub struct ProductsResponse {
    pub payment_channel: PaymentChannel,
    pub products: Vec<SubscriptionProduct>,
}

#[derive(Debug, Serialize)]
pub struct OrderResponse {
    pub order_id: String,
    pub product_id: String,
    pub payment_channel: PaymentChannel,
    pub status: SubscriptionOrderStatus,
    pub amount_cents: i32,
    pub currency: String,
    pub payment_payload: serde_json::Value,
}

#[derive(Debug, Serialize)]
pub struct ConfirmOrderResponse {
    pub order_id: String,
    pub status: SubscriptionOrderStatus,
    pub is_vip: bool,
    pub vip_expire_at: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct EntitlementResponse {
    pub is_vip: bool,
    pub vip_expire_at: Option<String>,
    pub source: String,
    pub server_time: String,
}

impl From<ChannelResolution> for serde_json::Value {
    fn from(value: ChannelResolution) -> Self {
        serde_json::json!({
            "payment_channel": value.payment_channel,
            "login_providers": value.login_providers,
            "supported": value.supported,
            "reason": value.reason,
            "message": value.message,
        })
    }
}

impl From<SubscriptionOrder> for OrderResponse {
    fn from(order: SubscriptionOrder) -> Self {
        Self {
            order_id: order.order_id,
            product_id: order.product_id,
            payment_channel: order.payment_channel,
            status: order.status,
            amount_cents: order.amount_cents,
            currency: order.currency,
            payment_payload: serde_json::json!({
                "mode": "sandbox",
                "provider": order.payment_channel,
            }),
        }
    }
}

impl From<VipEntitlement> for EntitlementResponse {
    fn from(entitlement: VipEntitlement) -> Self {
        Self {
            is_vip: entitlement.is_vip,
            vip_expire_at: entitlement.vip_expire_at.map(|dt| dt.to_rfc3339()),
            source: entitlement.source,
            server_time: entitlement.server_time.to_rfc3339(),
        }
    }
}
