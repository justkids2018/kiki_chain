import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/interactive_region.dart';
import 'i_interactive_image_repository.dart';

class InteractiveImageRepositoryImpl implements IInteractiveImageRepository {
  // Static cache: image path → {width, height}. Survives navigation, eliminates re-decode.
  static final Map<String, Map<String, double>> _dimensionsCache = {};

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final String _dataJsonPath;

  InteractiveImageRepositoryImpl({
    String dataJsonPath = 'assets/data/kiki_zhiwuyuan.json',
  })  : _dataJsonPath = dataJsonPath;

  @override
  Future<List<InteractiveRegion>> loadRegions({String? jsonPath}) async {
    try {
      // 使用提供的路径，否则使用默认路径
      final pathToLoad = jsonPath ?? _dataJsonPath;
      AppLogger.debug('Loading regions from: $pathToLoad');
      
      late String response;
      
      // 判断是远程 URL 还是本地资源
      if (pathToLoad.startsWith('http://') || pathToLoad.startsWith('https://')) {
        // 从网络加载
        AppLogger.debug('Loading JSON from network: $pathToLoad');
        try {
          final httpResponse = await _dio.get(pathToLoad);
          if (httpResponse.statusCode == 200) {
            response = httpResponse.data is String ? httpResponse.data : jsonEncode(httpResponse.data);
          } else {
            throw Exception('HTTP ${httpResponse.statusCode}');
          }
        } on DioException catch (e) {
          AppLogger.error('Network request failed', e);
          rethrow;
        }
      } else {
        // 从本地加载
        AppLogger.debug('Loading JSON from assets: $pathToLoad');
        response = await rootBundle.loadString(pathToLoad);
      }
      
      final List<dynamic> data = json.decode(response);
      
      final regions = data
          .map((e) => InteractiveRegion.fromJson(e as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Successfully loaded ${regions.length} regions');
      return regions;
    } catch (e) {
      AppLogger.error('Error loading interactive regions', e);
      return [];
    }
  }

  @override
  Future<Map<String, double>> loadImageDimensions(String imagePath) async {
    // Return cached dimensions immediately on repeat visits
    if (_dimensionsCache.containsKey(imagePath)) {
      AppLogger.info('Image dimensions from cache: $imagePath');
      return _dimensionsCache[imagePath]!;
    }

    try {
      late ui.Image image;
      
      // 判断是远程 URL 还是本地资源
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // 从网络加载图片
        AppLogger.debug('Loading image dimensions from network URL: $imagePath');
        final imageProvider = NetworkImage(imagePath);
        final stream = imageProvider.resolve(ImageConfiguration.empty);
        final Completer<ui.Image> completer = Completer<ui.Image>();
        late ImageStreamListener listener;

        listener = ImageStreamListener((ImageInfo frame, bool synchronousCall) {
          final ui.Image img = frame.image;
          stream.removeListener(listener);
          if (!completer.isCompleted) {
            completer.complete(img);
          }
        });

        stream.addListener(listener);
        
        image = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            stream.removeListener(listener);
            throw TimeoutException('Network image loading timed out', null);
          },
        );
      } else {
        // 从本地加载图片
        AppLogger.debug('Loading image dimensions from assets: $imagePath');
        final stream = AssetImage(imagePath).resolve(ImageConfiguration.empty);
        final Completer<ui.Image> completer = Completer<ui.Image>();
        late ImageStreamListener listener;

        listener = ImageStreamListener((ImageInfo frame, bool synchronousCall) {
          final ui.Image img = frame.image;
          stream.removeListener(listener);
          if (!completer.isCompleted) {
            completer.complete(img);
          }
        });

        stream.addListener(listener);
        
        image = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            stream.removeListener(listener);
            throw TimeoutException('Asset image loading timed out', null);
          },
        );
      }

      final dims = {
        'width': image.width.toDouble(),
        'height': image.height.toDouble(),
      };
      _dimensionsCache[imagePath] = dims;
      return dims;
    } catch (e) {
      AppLogger.error('Error loading image dimensions', e);
      // Return fallback dimensions
      return {
        'width': 1920.0,
        'height': 1080.0,
      };
    }
  }
}
