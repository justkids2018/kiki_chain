import '../../../domain/entities/interactive_region.dart';

abstract class IInteractiveImageRepository {
  /// Load interactive regions from JSON data file
  /// If [jsonPath] is not provided, defaults to 'assets/data/kiki_zhiwuyuan.json'
  Future<List<InteractiveRegion>> loadRegions({String? jsonPath});

  /// Load image dimensions
  Future<Map<String, double>> loadImageDimensions(String imagePath);
}
