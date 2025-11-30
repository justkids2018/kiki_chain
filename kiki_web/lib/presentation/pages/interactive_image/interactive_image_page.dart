import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stroke_order_animator/stroke_order_animator.dart';
import '../../../domain/entities/interactive_region.dart';
import 'interactive_image_controller.dart';
import 'interactive_image_view.dart';
import 'services/stroke_order_service.dart';

class InteractiveImagePage extends StatefulWidget {
  const InteractiveImagePage({Key? key}) : super(key: key);

  @override
  State<InteractiveImagePage> createState() => _InteractiveImagePageState();
}

class _InteractiveImagePageState extends State<InteractiveImagePage> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InteractiveImageController>()
        ? Get.find<InteractiveImageController>()
        : Get.put(InteractiveImageController());

    return Scaffold(
      body: Obx(() {
        if (!controller.isLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // 1. Blurred Background
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: _buildBackgroundImage(controller.imagePath),
                ),
              ),
            ),

            // 2. Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top Navigation Bar
                  _buildTopBar(context),

                  // Center Content Area
                  Expanded(
                    child: Row(
                      children: [
                        // Main Card
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(48, 16, 16, 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Left: Interactive Image
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.grey[50],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: InteractiveViewer(
                                        minScale: 0.5,
                                        maxScale: 4.0,
                                        child: InteractiveImageView(
                                          imagePath: controller.imagePath,
                                          originalWidth:
                                              controller.imageWidth.value,
                                          originalHeight:
                                              controller.imageHeight.value,
                                          regions: controller.regions,
                                          onRegionTap: controller.speakRegion,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Right: Text Content
                                Expanded(
                                  flex: 4,
                                  child: _buildTextContent(controller),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Sidebar Controls
                        SizedBox(
                          width: 100,
                          child: _buildRightControls(controller),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBackgroundImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 28),
            ),
          ),

          const Spacer(),

          // Progress Bar (Mock)
          Container(
            width: 200,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Hint Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '提示',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(InteractiveImageController controller) {
    return Obx(() {
      final InteractiveRegion? region = controller.activeRegion.value;
      if (region == null) {
        return Center(
          child: Text(
            'Click on the image to start learning',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tian Zi Ge Display
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: region.text.split('').map((char) {
                return TianZiGeChar(
                  character: char,
                  size: 100,
                  animate: true,
                );
              }).toList(),
            ),

            const SizedBox(height: 48),

            // English Text
            if (region.textEnglish.isNotEmpty)
              Text(
                region.textEnglish,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildRightControls(InteractiveImageController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Auto Play Toggle
        _buildControlButton(
          icon: Icons.play_circle_outline,
          label: 'Auto',
          isActive: controller.isAutoPlay.value,
          onTap: () => controller.isAutoPlay.toggle(),
        ),
        const SizedBox(height: 24),

        // Speaker Button
        _buildCircleButton(
          icon: Icons.volume_up_rounded,
          color: const Color(0xFFFF6B6B),
          onTap: () {
            final region = controller.activeRegion.value;
            if (region != null) {
              controller.speakRegion(region);
            }
          },
        ),
        const SizedBox(height: 24),

        // Mic Button
        _buildCircleButton(
          icon: Icons.mic_rounded,
          color: const Color(0xFFFF6B6B),
          onTap: () {
            // TODO: Implement recording
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFF6B6B)
                  : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class TianZiGeChar extends StatefulWidget {
  final String character;
  final double size;
  final bool animate;

  const TianZiGeChar({
    Key? key,
    required this.character,
    this.size = 80,
    this.animate = true,
  }) : super(key: key);

  @override
  State<TianZiGeChar> createState() => _TianZiGeCharState();
}

class _TianZiGeCharState extends State<TianZiGeChar>
    with TickerProviderStateMixin {
  StrokeOrderAnimationController? _strokeController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(TianZiGeChar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character != widget.character) {
      _loadData();
    } else if (oldWidget.animate != widget.animate && widget.animate) {
      _strokeController?.startAnimation();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Reset controller
    _strokeController?.dispose();
    _strokeController = null;

    final json =
        await StrokeOrderService().getStrokeOrderData(widget.character);

    if (mounted) {
      if (json != null) {
        try {
          _strokeController = StrokeOrderAnimationController(
            StrokeOrder(json),
            this,
            onQuizCompleteCallback: (_) {},
          );

          // Hide outline to make it look like writing on blank paper
          _strokeController?.setShowOutline(false);
          _strokeController
              ?.setShowMedian(false); // Also hide median lines if present

          if (widget.animate) {
            // Reset to ensure it starts from blank
            _strokeController?.reset();
            // Start animation immediately
            _strokeController?.startAnimation();
          }
        } catch (e) {
          debugPrint('Error creating stroke controller: $e');
        }
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _strokeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0), // Light paper color
        border: Border.all(color: const Color(0xFFE0C0A0), width: 2),
      ),
      child: Stack(
        children: [
          // Grid Lines
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: TianZiGePainter(),
          ),

          // Character
          Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _strokeController != null
                    ? SizedBox(
                        width: widget.size * 0.85,
                        height: widget.size * 0.85,
                        child: StrokeOrderAnimator(
                          _strokeController!,
                        ),
                      )
                    : Text(
                        widget.character,
                        style: TextStyle(
                          fontSize: widget.size * 0.7,
                          fontFamily: 'KaiTi',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class TianZiGePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0C0A0).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Dashed line helper
    void drawDashedLine(Offset p1, Offset p2) {
      const double dashWidth = 4;
      const double dashSpace = 4;
      double distance = (p2 - p1).distance;
      double startX = p1.dx;
      double startY = p1.dy;
      double dx = (p2.dx - p1.dx) / distance;
      double dy = (p2.dy - p1.dy) / distance;

      double currentDist = 0;
      while (currentDist < distance) {
        canvas.drawLine(
          Offset(startX + dx * currentDist, startY + dy * currentDist),
          Offset(startX + dx * (currentDist + dashWidth),
              startY + dy * (currentDist + dashWidth)),
          paint,
        );
        currentDist += dashWidth + dashSpace;
      }
    }

    // Horizontal center
    drawDashedLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2));

    // Vertical center
    drawDashedLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
