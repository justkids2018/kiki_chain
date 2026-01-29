import '../entities/scene_category.dart';

/// Scene Repository Interface
///
/// Defines the contract for scene-related data operations
abstract class ISceneRepository {
  /// Get all scene categories
  ///
  /// Returns a list of first-level categories (e.g., Daily Life, Playground)
  /// Throws an exception if the request fails
  Future<List<SceneCategory>> getCategories();

  /// Get scenes by category ID
  ///
  /// Returns a list of scenes belonging to the specified category
  /// Throws an exception if the request fails
  Future<List<dynamic>> getScenesByCategory(String categoryId);

  /// Get scene detail by scene ID
  ///
  /// Returns detailed information about a specific scene including interactive items
  /// Throws an exception if the request fails
  Future<Map<String, dynamic>> getSceneDetail(String sceneId);

  /// Search scenes by keyword
  ///
  /// Returns a list of scenes matching the search keyword
  /// Supports pagination with page and pageSize parameters
  Future<List<dynamic>> searchScenes({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  });
}
