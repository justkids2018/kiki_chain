import '../entities/subscription.dart';

abstract class ISubscriptionRepository {
  Future<ChannelResolution> resolveChannel({
    required String region,
    required String platform,
    String? distributionChannel,
    List<String> clientCapabilities = const [],
  });

  Future<ProductsResult> getProducts({
    required String region,
    required String platform,
    String? distributionChannel,
  });

  Future<VipEntitlement> getEntitlement();

  Future<SubscriptionOrder> createOrder({
    required String productId,
    required String region,
    required String platform,
    String? distributionChannel,
  });

  Future<VipEntitlement> confirmOrder({
    required String orderId,
    String? purchaseToken,
    bool sandbox = true,
  });
}
