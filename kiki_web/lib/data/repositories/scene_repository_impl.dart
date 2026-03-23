import '../../domain/entities/scene_category.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../services/api/scene_api_service.dart';
import '../../core/logging/app_logger.dart';

/// Scene Repository Implementation
///
/// Implements the ISceneRepository interface using SceneApiService
/// Handles data transformation and error handling
class SceneRepositoryImpl implements ISceneRepository {
  final SceneApiService _apiService;

  SceneRepositoryImpl({required SceneApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<SceneCategory>> getCategories() async {
    try {
      AppLogger.info('📦 Fetching scene categories...');

      final response = await _apiService.getCategories();

      // 检查响应格式 (服务器返回 {success: true, data: [...]})
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch categories');
      }

      // 解析分类数据 (data 是数组，不是嵌套对象)
      final categoriesJson = response['data'] as List<dynamic>;

      final categories = categoriesJson
          .map((json) => SceneCategory.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by order
      categories.sort((a, b) => a.order.compareTo(b.order));

      AppLogger.info('✅ Fetched ${categories.length} categories');

      return categories;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to fetch categories', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Scene>> getScenesByCategory(String categoryId) async {
    try {
      AppLogger.info('📦 Fetching scenes for category: $categoryId');

      final response = await _apiService.getScenesByCategory(categoryId);

      // 检查响应格式 (服务器返回 {success: true, data: [...]})
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch scenes');
      }

      // 解析场景数据 (data 是数组，不是嵌套对象)
      final scenesJson = response['data'] as List<dynamic>;

      final scenes = scenesJson
          .map((json) => Scene.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by order
      scenes.sort((a, b) => a.order.compareTo(b.order));

      AppLogger.info('✅ Fetched ${scenes.length} scenes');

      return scenes;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to fetch scenes', e, stackTrace);
      rethrow;
    }
  }

  /// 获取场景列表（包含原始数据）
  /// 返回 Map，包含 Scene 对象和原始 JSON 数据
  Future<List<Map<String, dynamic>>> getScenesByCategoryWithRawData(String categoryId) async {
    try {
      AppLogger.info('📦 Fetching scenes with raw data for category: $categoryId');

      final response = await _apiService.getScenesByCategory(categoryId);

      // 检查响应格式
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch scenes');
      }

      // 解析场景数据
      final scenesJson = response['data'] as List<dynamic>;

      final scenesWithRawData = scenesJson.map((json) {
        final jsonMap = json as Map<String, dynamic>;
        return {
          'scene': Scene.fromJson(jsonMap),
          'rawData': jsonMap, // 保留原始数据（包含 items_data）
        };
      }).toList();

      // Sort by order
      scenesWithRawData.sort((a, b) =>
        (a['scene'] as Scene).order.compareTo((b['scene'] as Scene).order));

      AppLogger.info('✅ Fetched ${scenesWithRawData.length} scenes with raw data');

      return scenesWithRawData;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to fetch scenes with raw data', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getSceneDetail(String sceneId) async {
    try {
      AppLogger.info('📦 Fetching scene detail: $sceneId');

      final response = await _apiService.getSceneDetail(sceneId);

      if (response == null) {
        throw Exception('Scene not found');
      }

      // 检查响应格式 (服务器返回 {success: true, data: {...}})
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch scene detail');
      }

      final data = response['data'] as Map<String, dynamic>;

      AppLogger.info('✅ Fetched scene detail');

      return data;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to fetch scene detail', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Scene>> searchScenes({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      AppLogger.info('🔍 Searching scenes: $keyword');

      final response = await _apiService.searchScenes(
        keyword: keyword,
        page: page,
        pageSize: pageSize,
      );

      // 检查响应格式 (服务器返回 {success: true, data: {...}})
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to search scenes');
      }

      // 解析搜索结果
      final data = response['data'] as Map<String, dynamic>;
      final scenesJson = data['scenes'] as List<dynamic>;

      final scenes = scenesJson
          .map((json) => Scene.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('✅ Found ${scenes.length} scenes');

      return scenes;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to search scenes', e, stackTrace);
      rethrow;
    }
  }
}
