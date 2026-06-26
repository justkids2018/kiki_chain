import 'package:flutter/foundation.dart';

import '../../../domain/entities/subscription.dart';

class ClientPaymentContext {
  final String region;
  final String platform;
  final String distributionChannel;
  final List<String> capabilities;

  const ClientPaymentContext({
    required this.region,
    required this.platform,
    required this.distributionChannel,
    required this.capabilities,
  });

  factory ClientPaymentContext.current({String region = 'cn'}) {
    if (kIsWeb) {
      return const ClientPaymentContext(
        region: 'cn',
        platform: 'web',
        distributionChannel: 'web',
        capabilities: ['wechat_pay'],
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ClientPaymentContext(
          region: region,
          platform: 'ios',
          distributionChannel: 'app_store',
          capabilities: const ['apple_iap', 'apple_login'],
        );
      case TargetPlatform.android:
        return ClientPaymentContext(
          region: region,
          platform: 'android',
          distributionChannel:
              region == 'global' ? 'google_play' : 'direct_apk',
          capabilities: region == 'global'
              ? const ['google_play_billing', 'google_login']
              : const ['wechat_pay', 'wechat_login'],
        );
      default:
        return ClientPaymentContext(
          region: region,
          platform: 'web',
          distributionChannel: 'web',
          capabilities: const ['wechat_pay'],
        );
    }
  }
}

class PaymentResult {
  final bool success;
  final String? purchaseToken;
  final String message;

  const PaymentResult({
    required this.success,
    required this.message,
    this.purchaseToken,
  });
}

abstract class PaymentAdapter {
  Future<PaymentResult> pay({
    required SubscriptionOrder order,
    required SubscriptionProduct product,
  });
}

class SandboxPaymentAdapter implements PaymentAdapter {
  final String providerName;

  const SandboxPaymentAdapter(this.providerName);

  @override
  Future<PaymentResult> pay({
    required SubscriptionOrder order,
    required SubscriptionProduct product,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return PaymentResult(
      success: true,
      purchaseToken: 'sandbox_${providerName}_${order.orderId}',
      message: '${product.title} sandbox 支付成功',
    );
  }
}

class UnsupportedPaymentAdapter implements PaymentAdapter {
  const UnsupportedPaymentAdapter();

  @override
  Future<PaymentResult> pay({
    required SubscriptionOrder order,
    required SubscriptionProduct product,
  }) async {
    return const PaymentResult(
      success: false,
      message: '当前渠道暂不支持购买',
    );
  }
}

class PaymentManager {
  PaymentManager({
    Map<PaymentChannel, PaymentAdapter>? adapters,
  }) : _adapters = adapters ?? _defaultAdapters();

  final Map<PaymentChannel, PaymentAdapter> _adapters;

  static Map<PaymentChannel, PaymentAdapter> _defaultAdapters() {
    return {
      PaymentChannel.appleIap: const SandboxPaymentAdapter('apple_iap'),
      PaymentChannel.wechatPay: const SandboxPaymentAdapter('wechat_pay'),
      PaymentChannel.googlePlayBilling:
          const SandboxPaymentAdapter('google_play_billing'),
      PaymentChannel.applePay: const SandboxPaymentAdapter('apple_pay'),
      PaymentChannel.unsupported: const UnsupportedPaymentAdapter(),
    };
  }

  Future<PaymentResult> pay({
    required SubscriptionOrder order,
    required SubscriptionProduct product,
  }) {
    final adapter =
        _adapters[order.paymentChannel] ?? const UnsupportedPaymentAdapter();
    return adapter.pay(order: order, product: product);
  }
}
