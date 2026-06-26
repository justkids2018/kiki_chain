use crate::core::entities::subscription::{
    ChannelResolution, ClientPlatform, DistributionChannel, LoginProvider, PaymentChannel,
    RegionCode,
};

#[derive(Debug, Clone)]
pub struct ChannelPolicy;

impl ChannelPolicy {
    pub fn new() -> Self {
        Self
    }

    pub fn resolve(
        &self,
        region: RegionCode,
        platform: ClientPlatform,
        distribution_channel: DistributionChannel,
        _client_capabilities: &[String],
    ) -> ChannelResolution {
        match platform {
            ClientPlatform::Ios => ChannelResolution {
                payment_channel: PaymentChannel::AppleIap,
                login_providers: match region {
                    RegionCode::Cn => vec![LoginProvider::Apple, LoginProvider::Wechat],
                    RegionCode::Global => vec![LoginProvider::Apple],
                },
                supported: true,
                reason: "ios_digital_content_requires_iap".to_string(),
                message: "iOS 数字内容将使用 Apple App 内购".to_string(),
            },
            ClientPlatform::Android => match (region, distribution_channel) {
                (RegionCode::Global, DistributionChannel::GooglePlay) => ChannelResolution {
                    payment_channel: PaymentChannel::GooglePlayBilling,
                    login_providers: vec![LoginProvider::Google],
                    supported: true,
                    reason: "global_android_google_play".to_string(),
                    message: "国外 Android 将使用 Google Play Billing".to_string(),
                },
                (RegionCode::Global, _) => ChannelResolution {
                    payment_channel: PaymentChannel::Unsupported,
                    login_providers: vec![LoginProvider::Google, LoginProvider::Phone],
                    supported: false,
                    reason: "global_android_distribution_not_supported".to_string(),
                    message: "当前国外 Android 渠道暂不支持购买".to_string(),
                },
                (RegionCode::Cn, _) => ChannelResolution {
                    payment_channel: PaymentChannel::WechatPay,
                    login_providers: vec![LoginProvider::Wechat, LoginProvider::Phone],
                    supported: true,
                    reason: "cn_android_wechat_pay".to_string(),
                    message: "国内 Android 将使用微信支付".to_string(),
                },
            },
            ClientPlatform::WechatMiniprogram | ClientPlatform::H5 => ChannelResolution {
                payment_channel: PaymentChannel::WechatPay,
                login_providers: vec![LoginProvider::Wechat],
                supported: true,
                reason: "wechat_ecosystem".to_string(),
                message: "微信生态将使用微信支付".to_string(),
            },
            ClientPlatform::Web => ChannelResolution {
                payment_channel: PaymentChannel::WechatPay,
                login_providers: vec![LoginProvider::Wechat, LoginProvider::Phone],
                supported: true,
                reason: "web_default_wechat_pay".to_string(),
                message: "Web/H5 默认使用微信支付".to_string(),
            },
            ClientPlatform::Unknown => ChannelResolution {
                payment_channel: PaymentChannel::Unsupported,
                login_providers: vec![LoginProvider::Phone],
                supported: false,
                reason: "unknown_platform".to_string(),
                message: "当前渠道暂不支持购买".to_string(),
            },
        }
    }
}
