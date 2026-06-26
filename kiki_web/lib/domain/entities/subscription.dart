enum PaymentChannel {
  appleIap,
  wechatPay,
  googlePlayBilling,
  applePay,
  unsupported,
}

enum SubscriptionPeriod {
  monthly,
  yearly,
}

enum SubscriptionOrderStatus {
  pending,
  paid,
  failed,
  cancelled,
}

PaymentChannel paymentChannelFromJson(String? value) {
  switch (value) {
    case 'apple_iap':
      return PaymentChannel.appleIap;
    case 'wechat_pay':
      return PaymentChannel.wechatPay;
    case 'google_play_billing':
      return PaymentChannel.googlePlayBilling;
    case 'apple_pay':
      return PaymentChannel.applePay;
    default:
      return PaymentChannel.unsupported;
  }
}

String paymentChannelToJson(PaymentChannel value) {
  switch (value) {
    case PaymentChannel.appleIap:
      return 'apple_iap';
    case PaymentChannel.wechatPay:
      return 'wechat_pay';
    case PaymentChannel.googlePlayBilling:
      return 'google_play_billing';
    case PaymentChannel.applePay:
      return 'apple_pay';
    case PaymentChannel.unsupported:
      return 'unsupported';
  }
}

SubscriptionPeriod subscriptionPeriodFromJson(String? value) {
  return value == 'yearly'
      ? SubscriptionPeriod.yearly
      : SubscriptionPeriod.monthly;
}

SubscriptionOrderStatus subscriptionOrderStatusFromJson(String? value) {
  switch (value) {
    case 'paid':
      return SubscriptionOrderStatus.paid;
    case 'failed':
      return SubscriptionOrderStatus.failed;
    case 'cancelled':
      return SubscriptionOrderStatus.cancelled;
    default:
      return SubscriptionOrderStatus.pending;
  }
}

class ChannelResolution {
  final PaymentChannel paymentChannel;
  final List<String> loginProviders;
  final bool supported;
  final String reason;
  final String message;

  const ChannelResolution({
    required this.paymentChannel,
    required this.loginProviders,
    required this.supported,
    required this.reason,
    required this.message,
  });

  factory ChannelResolution.fromJson(Map<String, dynamic> json) {
    return ChannelResolution(
      paymentChannel:
          paymentChannelFromJson(json['payment_channel'] as String?),
      loginProviders: (json['login_providers'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      supported: json['supported'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class SubscriptionProduct {
  final String productId;
  final String title;
  final SubscriptionPeriod period;
  final int priceCents;
  final String currency;
  final String displayPrice;
  final int trialDays;
  final bool isRecommended;

  const SubscriptionProduct({
    required this.productId,
    required this.title,
    required this.period,
    required this.priceCents,
    required this.currency,
    required this.displayPrice,
    required this.trialDays,
    required this.isRecommended,
  });

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) {
    return SubscriptionProduct(
      productId: json['product_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      period: subscriptionPeriodFromJson(json['period'] as String?),
      priceCents: json['price_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'CNY',
      displayPrice: json['display_price'] as String? ?? '',
      trialDays: json['trial_days'] as int? ?? 0,
      isRecommended: json['is_recommended'] as bool? ?? false,
    );
  }
}

class ProductsResult {
  final PaymentChannel paymentChannel;
  final List<SubscriptionProduct> products;

  const ProductsResult({
    required this.paymentChannel,
    required this.products,
  });

  factory ProductsResult.fromJson(Map<String, dynamic> json) {
    return ProductsResult(
      paymentChannel:
          paymentChannelFromJson(json['payment_channel'] as String?),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((item) => SubscriptionProduct.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}

class SubscriptionOrder {
  final String orderId;
  final String productId;
  final PaymentChannel paymentChannel;
  final SubscriptionOrderStatus status;
  final int amountCents;
  final String currency;
  final Map<String, dynamic> paymentPayload;

  const SubscriptionOrder({
    required this.orderId,
    required this.productId,
    required this.paymentChannel,
    required this.status,
    required this.amountCents,
    required this.currency,
    required this.paymentPayload,
  });

  factory SubscriptionOrder.fromJson(Map<String, dynamic> json) {
    return SubscriptionOrder(
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      paymentChannel:
          paymentChannelFromJson(json['payment_channel'] as String?),
      status: subscriptionOrderStatusFromJson(json['status'] as String?),
      amountCents: json['amount_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'CNY',
      paymentPayload:
          json['payment_payload'] as Map<String, dynamic>? ?? const {},
    );
  }
}

class VipEntitlement {
  final bool isVip;
  final DateTime? vipExpireAt;
  final String source;
  final DateTime serverTime;

  const VipEntitlement({
    required this.isVip,
    required this.vipExpireAt,
    required this.source,
    required this.serverTime,
  });

  factory VipEntitlement.fromJson(Map<String, dynamic> json) {
    final expireAt = json['vip_expire_at'] as String?;
    final serverTime = json['server_time'] as String?;
    return VipEntitlement(
      isVip: json['is_vip'] as bool? ?? false,
      vipExpireAt: expireAt == null ? null : DateTime.tryParse(expireAt),
      source: json['source'] as String? ?? 'subscription',
      serverTime: serverTime == null
          ? DateTime.now()
          : DateTime.tryParse(serverTime) ?? DateTime.now(),
    );
  }
}
