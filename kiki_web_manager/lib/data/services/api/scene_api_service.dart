import '../../../config/env_config.dart';
import '../../../core/network/http_client.dart';
import '../../mock/mock_categories.dart';
import '../../mock/mock_scenes.dart';

/// 场景 API 服务
///
/// 负责场景相关的所有 API 调用
/// 支持 Mock 模式和真实 API 模式切换
class SceneApiService {
  final HttpClient? _httpClient;

  SceneApiService({HttpClient? httpClient}) : _httpClient = httpClient;

  /// 获取一级分类列表
  ///
  /// 对应 API: GET /scene/categories
  /// Mock: MockCategories.getCategoriesResponse()
  Future<Map<String, dynamic>> getCategories() async {
    if (EnvConfig.useMock) {
      // Mock 模式：返回本地数据
      await Future.delayed(const Duration(milliseconds: 300)); // 模拟网络延迟
      return MockCategories.getCategoriesResponse();
    }

    // 真实 API 模式
    return await _httpClient!.get('/scene/categories');
  }

  /// 获取某分类下的场景列表
  ///
  /// 对应 API: GET /scene/categories/{categoryId}/scenes
  /// Mock: MockScenes.getScenesByCategoryResponse(categoryId)
  ///
  /// [categoryId] 分类ID
  Future<Map<String, dynamic>> getScenesByCategory(String categoryId) async {
    if (EnvConfig.useMock) {
      // Mock 模式
      await Future.delayed(const Duration(milliseconds: 300));
      return MockScenes.getScenesByCategoryResponse(categoryId);
    }

    // 真实 API 模式
    return await _httpClient!.get('/scene/categories/$categoryId/scenes');
  }

  /// 获取场景详情
  ///
  /// 对应 API: GET /scene/scenes/{sceneId}
  /// Mock: MockScenes.getSceneDetailResponse(sceneId)
  ///
  /// [sceneId] 场景ID
  Future<Map<String, dynamic>?> getSceneDetail(String sceneId) async {
    if (EnvConfig.useMock) {
      // Mock 模式
      await Future.delayed(const Duration(milliseconds: 300));
      return MockScenes.getSceneDetailResponse(sceneId);
    }

    // 真实 API 模式
    return await _httpClient!.get('/scene/scenes/$sceneId');
  }

  /// 搜索场景
  ///
  /// 对应 API: GET /scene/search?keyword=xxx&page=1&pageSize=20
  ///
  /// [keyword] 搜索关键词
  /// [page] 页码（默认1）
  /// [pageSize] 每页数量（默认20）
  Future<Map<String, dynamic>> searchScenes({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (EnvConfig.useMock) {
      // Mock 模式：简单实现搜索
      await Future.delayed(const Duration(milliseconds: 300));

      // 模拟搜索结果
      return {
        "code": 200,
        "message": "成功",
        "data": {
          "total": 0,
          "page": page,
          "pageSize": pageSize,
          "scenes": [],
        }
      };
    }

    // 真实 API 模式
    return await _httpClient!.get(
      '/scene/search',
      queryParameters: {
        'keyword': keyword,
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  /// 获取推荐场景
  ///
  /// 对应 API: GET /scene/recommendations?limit=10
  ///
  /// [limit] 推荐数量（默认10）
  Future<Map<String, dynamic>> getRecommendations({int limit = 10}) async {
    if (EnvConfig.useMock) {
      // Mock 模式
      await Future.delayed(const Duration(milliseconds: 300));

      return {
        "code": 200,
        "message": "成功",
        "data": {
          "reason": "热门场景推荐",
          "scenes": []
        }
      };
    }

    // 真实 API 模式
    return await _httpClient!.get(
      '/scene/recommendations',
      queryParameters: {'limit': limit},
    );
  }
}
