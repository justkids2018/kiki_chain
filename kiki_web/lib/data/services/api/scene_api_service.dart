import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_client.dart';

/// 场景 API 服务
///
/// 对接 kiki_server /api/v1/mobile/scene/... 路由
/// 不再使用 Mock 模式，直接调用真实 API
class SceneApiService {
  final HttpClient? _httpClient;

  SceneApiService({HttpClient? httpClient}) : _httpClient = httpClient;

  /// 获取一级分类列表
  ///
  /// API: GET /api/v1/mobile/scene/categories
  Future<Map<String, dynamic>> getCategories() async {
    return await _httpClient!.get(ApiEndpoints.sceneCategories);
  }

  /// 获取某分类下的场景列表
  ///
  /// API: GET /api/v1/mobile/scene/categories/{categoryId}/scenes
  Future<Map<String, dynamic>> getScenesByCategory(String categoryId) async {
    return await _httpClient!.get(ApiEndpoints.sceneByCategoryId(categoryId));
  }

  /// 获取场景详情
  ///
  /// API: GET /api/v1/mobile/scene/{sceneId}
  Future<Map<String, dynamic>?> getSceneDetail(String sceneId) async {
    return await _httpClient!.get(ApiEndpoints.sceneDetail(sceneId));
  }

  /// 搜索场景
  ///
  /// API: GET /api/v1/mobile/scene/search?keyword=xxx&page=1&pageSize=20
  Future<Map<String, dynamic>> searchScenes({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _httpClient!.get(
      ApiEndpoints.sceneSearch,
      queryParameters: {
        'keyword': keyword,
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  /// 获取推荐场景
  ///
  /// API: GET /api/v1/mobile/scene/recommendations?limit=10
  Future<Map<String, dynamic>> getRecommendations({int limit = 10}) async {
    return await _httpClient!.get(
      ApiEndpoints.sceneRecommendations,
      queryParameters: {'limit': limit},
    );
  }
}
