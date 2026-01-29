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

      // Check response code
      if (response['code'] != 200) {
        throw Exception(response['message'] ?? 'Failed to fetch categories');
      }

      // Parse categories from response
      final data = response['data'] as Map<String, dynamic>;
      final categoriesJson = data['categories'] as List<dynamic>;

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

      // Check response code
      if (response['code'] != 200) {
        throw Exception(response['message'] ?? 'Failed to fetch scenes');
      }

      // Parse scenes from response
      final data = response['data'] as Map<String, dynamic>;
      final scenesJson = data['scenes'] as List<dynamic>;

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

  @override
  Future<Map<String, dynamic>> getSceneDetail(String sceneId) async {
    try {
      AppLogger.info('📦 Fetching scene detail: $sceneId');

      final response = await _apiService.getSceneDetail(sceneId);

      if (response == null) {
        throw Exception('Scene not found');
      }

      // Check response code
      if (response['code'] != 200) {
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

      // Check response code
      if (response['code'] != 200) {
        throw Exception(response['message'] ?? 'Failed to search scenes');
      }

      // Parse search results
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
