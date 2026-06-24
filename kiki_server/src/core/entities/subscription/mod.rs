use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RegionCode {
    Cn,
    Global,
}

impl RegionCode {
    pub fn parse(value: &str) -> Self {
        match value.to_lowercase().as_str() {
            "global" | "overseas" | "foreign" => Self::Global,
            _ => Self::Cn,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ClientPlatform {
    Ios,
    Android,
    Web,
    WechatMiniprogram,
    H5,
    Unknown,
}

impl ClientPlatform {
    pub fn parse(value: &str) -> Self {
        match value.to_lowercase().as_str() {
            "ios" => Self::Ios,
            "android" => Self::Android,
            "web" => Self::Web,
            "wechat_miniprogram" | "miniprogram" | "wechat" => Self::WechatMiniprogram,
            "h5" => Self::H5,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum DistributionChannel {
    AppStore,
    GooglePlay,
    Wechat,
    DirectApk,
    Web,
    Unknown,
}

impl DistributionChannel {
    pub fn parse(value: Option<&str>) -> Self {
        match value.unwrap_or("unknown").to_lowercase().as_str() {
            "app_store" | "appstore" => Self::AppStore,
            "google_play" | "googleplay" => Self::GooglePlay,
            "wechat" => Self::Wechat,
            "direct_apk" | "apk" => Self::DirectApk,
            "web" | "h5" => Self::Web,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum PaymentChannel {
    AppleIap,
    WechatPay,
    GooglePlayBilling,
    ApplePay,
    Unsupported,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LoginProvider {
    Apple,
    Wechat,
    Google,
    Phone,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SubscriptionPeriod {
    Monthly,
    Yearly,
}

impl SubscriptionPeriod {
    pub fn parse(value: &str) -> Self {
        match value.to_lowercase().as_str() {
            "yearly" | "year" => Self::Yearly,
            _ => Self::Monthly,
        }
    }

    pub fn duration_days(self) -> i64 {
        match self {
            Self::Monthly => 30,
            Self::Yearly => 365,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SubscriptionOrderStatus {
    Pending,
    Paid,
    Failed,
    Cancelled,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChannelResolution {
    pub payment_channel: PaymentChannel,
    pub login_providers: Vec<LoginProvider>,
    pub supported: bool,
    pub reason: String,
    pub message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubscriptionProduct {
    pub product_id: String,
    pub title: String,
    pub period: SubscriptionPeriod,
    pub price_cents: i32,
    pub currency: String,
    pub display_price: String,
    pub trial_days: i32,
    pub is_recommended: bool,
    pub enabled: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubscriptionOrder {
    pub order_id: String,
    pub user_id: String,
    pub product_id: String,
    pub payment_channel: PaymentChannel,
    pub amount_cents: i32,
    pub currency: String,
    pub status: SubscriptionOrderStatus,
    pub purchase_token: Option<String>,
    pub vip_expire_at: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VipEntitlement {
    pub is_vip: bool,
    pub vip_expire_at: Option<DateTime<Utc>>,
    pub source: String,
    pub server_time: DateTime<Utc>,
}
