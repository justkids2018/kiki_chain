import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/interactive_region.dart';

class InteractiveImageView extends StatefulWidget {
  final String imagePath;
  final double originalWidth;
  final double originalHeight;
  final List<InteractiveRegion> regions;
  final Function(InteractiveRegion) onRegionTap;
  final ValueChanged<Offset>? onRegionTapDown;
  final VoidCallback? onBlankAreaTap;
  // Debug switch for region frame overlay. Keep default OFF in production.
  // Turn ON temporarily when validating click areas or diagnosing tap issues.
  final bool showRegionDebugFrames;

  const InteractiveImageView({
    Key? key,
    required this.imagePath,
    required this.originalWidth,
    required this.originalHeight,
    required this.regions,
    required this.onRegionTap,
    this.onRegionTapDown,
    this.onBlankAreaTap,
    this.showRegionDebugFrames = false,
  }) : super(key: key);

  @override
  State<InteractiveImageView> createState() => _InteractiveImageViewState();
}

class _InteractiveImageViewState extends State<InteractiveImageView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug(
        'InteractiveImageView dimensions - ${widget.originalWidth} x ${widget.originalHeight}');

    if (widget.originalWidth <= 0 || widget.originalHeight <= 0) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 64),
              const SizedBox(height: 16),
              Text(
                'Invalid image dimensions: ${widget.originalWidth}x${widget.originalHeight}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final aspectRatio = widget.originalWidth / widget.originalHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        AppLogger.verbose(
            'LayoutBuilder constraints - ${constraints.maxWidth} x ${constraints.maxHeight}');

        // Calculate the display size to contain the image within constraints
        double displayWidth = constraints.maxWidth;
        double displayHeight = constraints.maxWidth / aspectRatio;

        if (displayHeight > constraints.maxHeight) {
          displayHeight = constraints.maxHeight;
          displayWidth = constraints.maxHeight * aspectRatio;
        }

        AppLogger.verbose(
            'Calculated display size - $displayWidth x $displayHeight');

        final scaleX = displayWidth / widget.originalWidth;
        final scaleY = displayHeight / widget.originalHeight;

        return Center(
          child: SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Layer 1: Image with error handling (supports local and network)
                  Positioned.fill(
                    child: _buildImage(widget.imagePath, context),
                  ),
                  // Layer 2: Interactive Regions + Bubble touch overlay
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (details) {
                        widget.onRegionTapDown?.call(details.globalPosition);
                        final hitRegion = _findBestRegionAt(
                          details.localPosition,
                          scaleX,
                          scaleY,
                        );
                        if (hitRegion != null) {
                          final rect = _regionRect(hitRegion, scaleX, scaleY);
                          AppLogger.debug(
                              'Region tapped(best-hit): ${hitRegion.text} at (${rect.left}, ${rect.top}) size: ${rect.width}x${rect.height}');
                          widget.onRegionTap(hitRegion);
                        } else {
                          // 点击了空白区域
                          AppLogger.debug('Blank area tapped');
                          widget.onBlankAreaTap?.call();
                        }
                      },
                      child: Stack(
                        children: [
                          if (widget.showRegionDebugFrames)
                            ...widget.regions.map((region) =>
                                _buildRegionFrame(region, scaleX, scaleY)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建图片组件，支持本地和网络图片
  Widget _buildImage(String imagePath, BuildContext context) {
    return imagePath.startsWith('http://') || imagePath.startsWith('https://')
        ? CachedNetworkImage(
            imageUrl: imagePath,
            fit: BoxFit.fill,
            useOldImageOnUrlChange: true,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (_, __) => const SizedBox.expand(),
            errorWidget: (context, url, error) =>
                _buildErrorWidget(context, imagePath),
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

  Widget _buildRegionFrame(
      InteractiveRegion region, double scaleX, double scaleY) {
    if (region.coordinates.isEmpty) return const SizedBox();

    final rect = _regionRect(region, scaleX, scaleY);

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.3 + (_pulseAnimation.value - 0.7) * 0.4,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(
                      alpha: 0.15 + (_pulseAnimation.value - 0.7) * 0.2,
                    ),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Rect _regionRect(InteractiveRegion region, double scaleX, double scaleY) {
    final xValues = region.coordinates.map((e) => e.x).toList();
    final yValues = region.coordinates.map((e) => e.y).toList();

    final minX = xValues.reduce(min);
    final maxX = xValues.reduce(max);
    final minY = yValues.reduce(min);
    final maxY = yValues.reduce(max);

    return Rect.fromLTWH(
      minX * scaleX,
      minY * scaleY,
      (maxX - minX) * scaleX,
      (maxY - minY) * scaleY,
    );
  }

  InteractiveRegion? _findBestRegionAt(
    Offset localPosition,
    double scaleX,
    double scaleY,
  ) {
    final hits = <MapEntry<InteractiveRegion, Rect>>[];

    for (final region in widget.regions) {
      if (region.coordinates.isEmpty) continue;
      final rect = _regionRect(region, scaleX, scaleY);
      if (rect.contains(localPosition)) {
        hits.add(MapEntry(region, rect));
      }
    }

    if (hits.isEmpty) return null;

    // Resolve overlap by preferring the smallest hit area (inner region wins).
    double area(Rect r) => r.width * r.height;
    hits.sort((a, b) => area(a.value).compareTo(area(b.value)));
    return hits.first.key;
  }
}
