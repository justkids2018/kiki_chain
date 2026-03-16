import '../../../config/env_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_client.dart';
import '../../mock/mock_categories.dart';
import '../../mock/mock_scenes.dart';

/// 场景 API 服务
///
/// 对接 kiki_server /api/v1/mobile/scene/... 路由
/// 支持 Mock 模式和真实 API 模式切换
class SceneApiService {
  final HttpClient? _httpClient;

  SceneApiService({HttpClient? httpClient}) : _httpClient = httpClient;

  /// 获取一级分类列表
  ///
  /// API: GET /api/v1/mobile/scene/categories
  Future<Map<String, dynamic>> getCategories() async {
    if (EnvConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockCategories.getCategoriesResponse();
    }
    return await _httpClient!.get(ApiEndpoints.sceneCategories);
  }

  /// 获取某分类下的场景列表
  ///
  /// API: GET /api/v1/mobile/scene/categories/{categoryId}/scenes
  Future<Map<String, dynamic>> getScenesByCategory(String categoryId) async {
    if (EnvConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockScenes.getScenesByCategoryResponse(categoryId);
    }
    return await _httpClient!.get(ApiEndpoints.sceneByCategoryId(categoryId));
  }

  /// 获取场景详情
  ///
  /// API: GET /api/v1/mobile/scene/{sceneId}
  Future<Map<String, dynamic>?> getSceneDetail(String sceneId) async {
    if (EnvConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockScenes.getSceneDetailResponse(sceneId);
    }
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
    if (EnvConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        "success": true,
        "message": "成功",
        "data": {
          "total": 0,
          "page": page,
          "page_size": pageSize,
          "scenes": [],
        }
      };
    }
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
    if (EnvConfig.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        "success": true,
        "message": "成功",
        "data": {
          "reason": "热门场景推荐",
          "scenes": []
        }
      };
    }
    return await _httpClient!.get(
      ApiEndpoints.sceneRecommendations,
      queryParameters: {'limit': limit},
    );
  }
}
