import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_client.dart';

class SubscriptionApiService {
  final HttpClient? _httpClient;

  SubscriptionApiService({HttpClient? httpClient}) : _httpClient = httpClient;

  Future<Map<String, dynamic>> resolveChannel({
    required String region,
    required String platform,
    String? distributionChannel,
    List<String> clientCapabilities = const [],
  }) async {
    return await _httpClient!.post(
      ApiEndpoints.subscriptionChannelResolve,
      data: {
        'region': region,
        'platform': platform,
        'distribution_channel': distributionChannel,
        'client_capabilities': clientCapabilities,
      },
    );
  }

  Future<Map<String, dynamic>> getProducts({
    required String region,
    required String platform,
    String? distributionChannel,
  }) async {
    return await _httpClient!.get(
      ApiEndpoints.subscriptionProducts,
      queryParameters: {
        'region': region,
        'platform': platform,
        if (distributionChannel != null)
          'distribution_channel': distributionChannel,
      },
    );
  }

  Future<Map<String, dynamic>> getEntitlement() async {
    return await _httpClient!.get(ApiEndpoints.subscriptionEntitlement);
  }

  Future<Map<String, dynamic>> createOrder({
    required String productId,
    required String region,
    required String platform,
    String? distributionChannel,
  }) async {
    return await _httpClient!.post(
      ApiEndpoints.subscriptionOrders,
      data: {
        'product_id': productId,
        'region': region,
        'platform': platform,
        'distribution_channel': distributionChannel,
      },
    );
  }

  Future<Map<String, dynamic>> confirmOrder({
    required String orderId,
    String? purchaseToken,
    bool sandbox = true,
  }) async {
    return await _httpClient!.post(
      ApiEndpoints.subscriptionOrderConfirm(orderId),
      data: {
        'purchase_token': purchaseToken,
        'sandbox': sandbox,
      },
    );
  }
}
