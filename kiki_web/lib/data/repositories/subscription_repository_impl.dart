import '../../core/logging/app_logger.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../services/api/subscription_api_service.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final SubscriptionApiService _apiService;

  SubscriptionRepositoryImpl({required SubscriptionApiService apiService})
      : _apiService = apiService;

  @override
  Future<ChannelResolution> resolveChannel({
    required String region,
    required String platform,
    String? distributionChannel,
    List<String> clientCapabilities = const [],
  }) async {
    final response = await _apiService.resolveChannel(
      region: region,
      platform: platform,
      distributionChannel: distributionChannel,
      clientCapabilities: clientCapabilities,
    );
    _ensureSuccess(response);
    return ChannelResolution.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProductsResult> getProducts({
    required String region,
    required String platform,
    String? distributionChannel,
  }) async {
    final response = await _apiService.getProducts(
      region: region,
      platform: platform,
      distributionChannel: distributionChannel,
    );
    _ensureSuccess(response);
    return ProductsResult.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VipEntitlement> getEntitlement() async {
    final response = await _apiService.getEntitlement();
    _ensureSuccess(response);
    return VipEntitlement.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SubscriptionOrder> createOrder({
    required String productId,
    required String region,
    required String platform,
    String? distributionChannel,
  }) async {
    final response = await _apiService.createOrder(
      productId: productId,
      region: region,
      platform: platform,
      distributionChannel: distributionChannel,
    );
    _ensureSuccess(response);
    return SubscriptionOrder.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<VipEntitlement> confirmOrder({
    required String orderId,
    String? purchaseToken,
    bool sandbox = true,
  }) async {
    final response = await _apiService.confirmOrder(
      orderId: orderId,
      purchaseToken: purchaseToken,
      sandbox: sandbox,
    );
    _ensureSuccess(response);
    final data = response['data'] as Map<String, dynamic>;
    return VipEntitlement.fromJson({
      'is_vip': data['is_vip'],
      'vip_expire_at': data['vip_expire_at'],
      'source': 'subscription',
      'server_time': DateTime.now().toIso8601String(),
    });
  }

  void _ensureSuccess(Map<String, dynamic> response) {
    if (response['success'] != true) {
      final message = response['message']?.toString() ?? '订阅请求失败';
      AppLogger.warning('Subscription request failed: $message');
      throw Exception(message);
    }
  }
}
