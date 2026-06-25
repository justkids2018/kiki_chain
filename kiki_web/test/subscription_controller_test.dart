import 'package:flutter_test/flutter_test.dart';
import 'package:kikichain/domain/entities/subscription.dart';
import 'package:kikichain/domain/repositories/i_subscription_repository.dart';
import 'package:kikichain/presentation/features/subscription/controllers/subscription_controller.dart';

void main() {
  test('primary action shows free subscription before 2026-08-01', () {
    final controller = SubscriptionController(
      subscriptionRepository: _FakeSubscriptionRepository(),
      now: () => DateTime(2026, 7, 31, 23, 59),
    );

    controller.selectedProduct.value = _yearlyProduct();

    expect(controller.isFreeSubscriptionPeriod, isTrue);
    expect(controller.primaryActionText, '免费订阅 ¥0');
  });

  test('primary action keeps original payment text from 2026-08-01', () {
    final controller = SubscriptionController(
      subscriptionRepository: _FakeSubscriptionRepository(),
      now: () => DateTime(2026, 8, 1),
    );

    controller.selectedProduct.value = _yearlyProduct();

    expect(controller.isFreeSubscriptionPeriod, isFalse);
    expect(controller.primaryActionText, '确认并支付 ¥88');
  });
}

SubscriptionProduct _yearlyProduct() {
  return const SubscriptionProduct(
    productId: 'kiki_vip_yearly',
    title: '年支付',
    period: SubscriptionPeriod.yearly,
    priceCents: 8800,
    currency: 'CNY',
    displayPrice: '¥88/年',
    trialDays: 0,
    isRecommended: true,
  );
}

class _FakeSubscriptionRepository implements ISubscriptionRepository {
  @override
  Future<VipEntitlement> confirmOrder({
    required String orderId,
    String? purchaseToken,
    bool sandbox = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<SubscriptionOrder> createOrder({
    required String productId,
    required String region,
    required String platform,
    String? distributionChannel,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<VipEntitlement> getEntitlement() async {
    throw UnimplementedError();
  }

  @override
  Future<ProductsResult> getProducts({
    required String region,
    required String platform,
    String? distributionChannel,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ChannelResolution> resolveChannel({
    required String region,
    required String platform,
    String? distributionChannel,
    List<String> clientCapabilities = const [],
  }) async {
    throw UnimplementedError();
  }
}
