import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/interactive_region.dart';
import 'interactive_image_controller.dart';
import 'interactive_image_view.dart';
import 'widgets/character_stroke_grid.dart';

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
                                  flex: 6,
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
                                  flex:3,
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
            '点击图片上区域可查看笔画',
            style: TextStyle(
              fontSize: 15,
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
            _buildCharacterGrid(region.text),

            const SizedBox(height: 48),

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

  Widget _buildCharacterGrid(String text) {
    final characters = text
        .split('')
        .where((char) => char.trim().isNotEmpty)
        .toList(growable: false);

    return CharacterStrokeGrid(
      characters: characters,
      cellSize: 100,
    );
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
