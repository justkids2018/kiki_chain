import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../core/logging/app_logger.dart';

class StrokeOrderService {
  static final StrokeOrderService _instance = StrokeOrderService._internal();
  factory StrokeOrderService() => _instance;
  StrokeOrderService._internal();

  final Dio _dio = Dio();
  final Map<String, String> _cache = {};
  Directory? _cacheDirectory;

  /// Fetch stroke order data for a character
  /// Returns the JSON string required by stroke_order_animator
  Future<String?> getStrokeOrderData(String character) async {
    if (character.isEmpty) return null;

    // Check cache first
    if (_cache.containsKey(character)) {
      return _cache[character];
    }

    final localData = await _readFromDisk(character);
    if (localData != null) {
      _cache[character] = localData;
      return localData;
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
        await _writeToDisk(character, data);
        return data;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch stroke order for $character: $e');
    }
    return null;
  }

  Future<String?> _readFromDisk(String character) async {
    if (kIsWeb) return null;
    try {
      final file = await _characterFile(character);
      if (file == null || !await file.exists()) {
        return null;
      }
      return await file.readAsString();
    } catch (e) {
      AppLogger.warning(
          'Failed to read cached stroke order for $character: $e');
      return null;
    }
  }

  Future<void> _writeToDisk(String character, String data) async {
    if (kIsWeb) return;
    try {
      final file = await _characterFile(character);
      if (file == null) return;
      await file.writeAsString(data, flush: true);
    } catch (e) {
      AppLogger.warning(
          'Failed to cache stroke order for $character locally: $e');
    }
  }

  Future<File?> _characterFile(String character) async {
    final directory = await _ensureCacheDirectory();
    if (directory == null) return null;
    final fileName = character.runes
        .map((codePoint) => codePoint.toRadixString(16).padLeft(4, '0'))
        .join('_');
    return File(path.join(directory.path, '$fileName.json'));
  }

  Future<Directory?> _ensureCacheDirectory() async {
    if (kIsWeb) return null;
    if (_cacheDirectory != null) {
      return _cacheDirectory;
    }

    try {
      final baseDir = await getApplicationSupportDirectory();
      final directory = Directory(path.join(baseDir.path, 'stroke_cache'));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      _cacheDirectory = directory;
      return _cacheDirectory;
    } catch (e) {
      AppLogger.warning('Unable to prepare local stroke cache directory: $e');
      return null;
    }
  }
}
