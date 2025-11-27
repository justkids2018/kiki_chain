import 'package:flutter/material.dart';
import '../../../../core/logging/app_logger.dart';

/// Image preloading utility for better performance
class ImagePreloader {
  /// Preload an asset image
  static Future<void> preloadImage(String imagePath) async {
    try {
      final ImageProvider imageProvider = AssetImage(imagePath);
      await precacheImage(imageProvider, _mockContext);
    } catch (e) {
      AppLogger.warning('Failed to preload image: $imagePath', e);
    }
  }

  /// Preload multiple images
  static Future<void> preloadImages(List<String> imagePaths) async {
    await Future.wait(
      imagePaths.map((path) => preloadImage(path)),
    );
  }

  /// Dummy context for precacheImage
  static BuildContext get _mockContext {
    final navigator = Navigator.of(
      navigatorKey.currentContext!,
      rootNavigator: true,
    );
    return navigator.context;
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
