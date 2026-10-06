import Foundation

/// 支付方式渠道
public enum PaymentChannel: String, Codable {
    case appleIap = "apple_iap"
    case wechatPay = "wechat_pay"
    case alipay = "alipay"
    case unsupported = "unsupported"
}

/// 订阅周期
public enum SubscriptionPeriod: String, Codable {
    case monthly = "monthly"
    case yearly = "yearly"
}

/// 订阅商品模型
public struct SubscriptionProduct: Codable, Identifiable, Hashable {
    public var id: String { productId }
    public let productId: String
    public let title: String
    public let period: SubscriptionPeriod
    public let priceCents: Int
    public let currency: String
    public let displayPrice: String
    public let trialDays: Int
    public let isRecommended: Bool

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case title
        case period
        case priceCents = "price_cents"
        case currency
        case displayPrice = "display_price"
        case trialDays = "trial_days"
        case isRecommended = "is_recommended"
    }

    public init(
        productId: String,
        title: String,
        period: SubscriptionPeriod,
        priceCents: Int,
        currency: String = "CNY",
        displayPrice: String,
        trialDays: Int = 0,
        isRecommended: Bool = false
    ) {
        self.productId = productId
        self.title = title
        self.period = period
        self.priceCents = priceCents
        self.currency = currency
        self.displayPrice = displayPrice
        self.trialDays = trialDays
        self.isRecommended = isRecommended
    }
}

/// VIP 用户权益状态
public struct VipEntitlement: Codable, Hashable {
    public let isVip: Bool
    public let vipExpireAt: String?
    public let source: String

    enum CodingKeys: String, CodingKey {
        case isVip = "is_vip"
        case vipExpireAt = "vip_expire_at"
        case source
    }

    public init(isVip: Bool, vipExpireAt: String? = nil, source: String = "subscription") {
        self.isVip = isVip
        self.vipExpireAt = vipExpireAt
        self.source = source
    }
}

/// 订阅订单响应
public struct SubscriptionOrder: Codable {
    public let orderId: String
    public let productId: String
    public let amountCents: Int
    public let currency: String
    public let status: String

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case productId = "product_id"
        case amountCents = "amount_cents"
        case currency
        case status
    }
}
