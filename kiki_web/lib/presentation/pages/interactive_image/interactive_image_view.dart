import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/interactive_region.dart';

class InteractiveImageView extends StatelessWidget {
  final String imagePath;
  final double originalWidth;
  final double originalHeight;
  final List<InteractiveRegion> regions;
  final Function(InteractiveRegion) onRegionTap;

  const InteractiveImageView({
    Key? key,
    required this.imagePath,
    required this.originalWidth,
    required this.originalHeight,
    required this.regions,
    required this.onRegionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('InteractiveImageView dimensions - $originalWidth x $originalHeight');
    
    if (originalWidth <= 0 || originalHeight <= 0) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 64),
              const SizedBox(height: 16),
              Text(
                'Invalid image dimensions: ${originalWidth}x${originalHeight}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }
    
    final aspectRatio = originalWidth / originalHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        AppLogger.verbose('LayoutBuilder constraints - ${constraints.maxWidth} x ${constraints.maxHeight}');
        
        // Calculate the display size to contain the image within constraints
        double displayWidth = constraints.maxWidth;
        double displayHeight = constraints.maxWidth / aspectRatio;

        if (displayHeight > constraints.maxHeight) {
          displayHeight = constraints.maxHeight;
          displayWidth = constraints.maxHeight * aspectRatio;
        }

        AppLogger.verbose('Calculated display size - $displayWidth x $displayHeight');

        final scaleX = displayWidth / originalWidth;
        final scaleY = displayHeight / originalHeight;

        return Center(
          child: SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: Stack(
              children: [
                // Layer 1: Image with error handling (supports local and network)
                Positioned.fill(
                  child: _buildImage(imagePath, context),
                ),
                // Layer 2: Interactive Regions
                ...regions
                    .map((region) => _buildRegion(region, scaleX, scaleY)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建图片组件，支持本地和网络图片
  Widget _buildImage(String imagePath, BuildContext context) {
    return imagePath.startsWith('http://') || imagePath.startsWith('https://')
        ? Image.network(
            imagePath,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(context, imagePath);
            },
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(context, imagePath);
            },
          );
  }

  /// 构建错误提示组件
  Widget _buildErrorWidget(BuildContext context, String imagePath) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              imagePath,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegion(InteractiveRegion region, double scaleX, double scaleY) {
    if (region.coordinates.isEmpty) return const SizedBox();

    final xValues = region.coordinates.map((e) => e.x).toList();
    final yValues = region.coordinates.map((e) => e.y).toList();

    final minX = xValues.reduce(min);
    final maxX = xValues.reduce(max);
    final minY = yValues.reduce(min);
    final maxY = yValues.reduce(max);

    final left = minX * scaleX;
    final top = minY * scaleY;
    final width = (maxX - minX) * scaleX;
    final height = (maxY - minY) * scaleY;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => onRegionTap(region),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
