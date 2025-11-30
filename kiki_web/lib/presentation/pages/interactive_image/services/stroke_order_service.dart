import 'package:dio/dio.dart';

import '../../../../core/logging/app_logger.dart';

class StrokeOrderService {
  static final StrokeOrderService _instance = StrokeOrderService._internal();
  factory StrokeOrderService() => _instance;
  StrokeOrderService._internal();

  final Dio _dio = Dio();
  final Map<String, String> _cache = {};

  /// Fetch stroke order data for a character
  /// Returns the JSON string required by stroke_order_animator
  Future<String?> getStrokeOrderData(String character) async {
    if (character.isEmpty) return null;

    // Check cache first
    if (_cache.containsKey(character)) {
      return _cache[character];
    }

    try {
      // Using hanzi-writer-data from jsdelivr
      // Use @latest to ensure we get the best data
      // Note: For hanzi-writer-data@latest, the files are in the root, not /data/
      final url =
          'https://cdn.jsdelivr.net/npm/hanzi-writer-data@latest/$character.json';

      // Always request plain text to avoid Dio parsing JSON into Map
      // because StrokeOrder expects a JSON string.
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data.toString();
        _cache[character] = data;
        return data;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch stroke order for $character: $e');
    }
    return null;
  }
}
