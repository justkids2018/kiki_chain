import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../core/logging/app_logger.dart';

class StrokeOrderService {
  static final StrokeOrderService _instance = StrokeOrderService._internal();
  factory StrokeOrderService() => _instance;
  StrokeOrderService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  final Map<String, String> _cache = {};
  Directory? _cacheDirectory;

  // 多个 CDN，按速度顺序尝试（固定版本比 @latest 缓存命中率高）
  static const _cdnUrls = [
    'https://cdn.jsdelivr.net/npm/hanzi-writer-data@2.0.1/',
    'https://unpkg.com/hanzi-writer-data@2.0.1/',
  ];

  /// 批量预加载字符笔画数据（后台静默下载）
  Future<void> preloadCharacters(List<String> characters) async {
    final toFetch = characters
        .where((c) => c.trim().isNotEmpty && !_cache.containsKey(c))
        .toList();
    if (toFetch.isEmpty) return;

    AppLogger.info('Preloading stroke data for ${toFetch.length} characters');
    // 并发预加载，最多 3 个同时请求避免堵塞
    for (var i = 0; i < toFetch.length; i += 3) {
      final batch = toFetch.skip(i).take(3).toList();
      await Future.wait(
        batch.map((c) => getStrokeOrderData(c).catchError((_) => null)),
      );
    }
    AppLogger.info('Preload complete for ${toFetch.length} characters');
  }

  /// 获取某个汉字的笔顺 JSON 字符串
  Future<String?> getStrokeOrderData(String character) async {
    if (character.isEmpty) return null;

    // 1. 内存缓存
    if (_cache.containsKey(character)) return _cache[character];

    // 2. Assets（常用汉字，零延迟）
    final assetData = await _readFromAssets(character);
    if (assetData != null) {
      _cache[character] = assetData;
      return assetData;
    }

    // 3. 磁盘缓存（预加载的）
    final localData = await _readFromDisk(character);
    if (localData != null) {
      _cache[character] = localData;
      return localData;
    }

    // 4. 网络：多 CDN 轮询
    for (final baseUrl in _cdnUrls) {
      try {
        final url = '$baseUrl$character.json';
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
        AppLogger.warning('CDN $baseUrl failed for "$character": $e');
      }
    }
    return null;
  }

  Future<String?> _readFromAssets(String character) async {
    try {
      final fileName = character.runes
          .map((cp) => cp.toRadixString(16).padLeft(4, '0'))
          .join('_');
      final assetPath = 'assets/data/stroke_order/$fileName.json';

      final data = await rootBundle.loadString(assetPath);
      AppLogger.debug('Loaded stroke data from assets for "$character"');
      return data;
    } catch (e) {
      // 文件不存在，返回 null（这是正常情况，不是错误）
      return null;
    }
  }

  Future<String?> _readFromDisk(String character) async {
    if (kIsWeb) return null;
    try {
      final file = await _characterFile(character);
      if (file == null || !await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      AppLogger.warning('Failed to read disk cache for "$character": $e');
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
      AppLogger.warning('Failed to write disk cache for "$character": $e');
    }
  }

  Future<File?> _characterFile(String character) async {
    final directory = await _ensureCacheDirectory();
    if (directory == null) return null;
    final fileName = character.runes
        .map((cp) => cp.toRadixString(16).padLeft(4, '0'))
        .join('_');
    return File(path.join(directory.path, '$fileName.json'));
  }

  Future<Directory?> _ensureCacheDirectory() async {
    if (kIsWeb) return null;
    if (_cacheDirectory != null) return _cacheDirectory;
    try {
      final baseDir = await getApplicationSupportDirectory();
      final dir = Directory(path.join(baseDir.path, 'stroke_cache'));
      if (!await dir.exists()) await dir.create(recursive: true);
      _cacheDirectory = dir;
      return _cacheDirectory;
    } catch (e) {
      AppLogger.warning('Cannot create stroke cache directory: $e');
      return null;
    }
  }
}
