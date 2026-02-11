import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'interactive_image_controller.dart';
import 'interactive_image_view.dart';
import 'models/character_cell.dart';
import 'widgets/character_stroke_grid.dart';
import 'widgets/english_stroke_display.dart';

class InteractiveImagePage extends StatefulWidget {
  InteractiveImagePage({Key? key}) : super(key: key);

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

        final imageWidth = controller.imageWidth.value;
        final imageHeight = controller.imageHeight.value;
        final aspectRatio = imageWidth > 0 && imageHeight > 0 
            ? imageWidth / imageHeight 
            : 1.0;

        // Responsive design: default to tablet, only switch to phone if smaller
        final size = MediaQuery.of(context).size;
        final isPhone = size.width < 600; // Only phone layout if width < 600

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

            // 2. Main Content - Responsive layout
            SafeArea(
              child: isPhone
                  ? _buildPhoneLayout(context, controller, aspectRatio)
                  : _buildTabletLayout(context, controller, aspectRatio),
            ),
          ],
        );
      }),
    );
  }

  /// Tablet layout (iPad): Left image, right character panel side by side
  Widget _buildTabletLayout(
    BuildContext context,
    InteractiveImageController controller,
    double aspectRatio,
  ) {
    return Column(
      children: [
        // Top Navigation Bar
        _buildTopBar(context),

        // Main Content Area
        Expanded(
          child: Row(
            children: [
              // Left: Large Interactive Image
              Expanded(
                flex: 3,
                child: _buildLargeImageContainer(
                  controller: controller,
                  aspectRatio: aspectRatio,
                ),
              ),

              // Right: Character Panel (compact)
              Expanded(
                flex: 2,
                child: _buildCompactCharacterPanel(controller),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Phone layout: Full screen image with floating character panel overlay
  Widget _buildPhoneLayout(
    BuildContext context,
    InteractiveImageController controller,
    double aspectRatio,
  ) {
    return Stack(
      children: [
        Column(
          children: [
            // Top Navigation Bar
            _buildTopBar(context),

            // Full screen image
            Expanded(
              child: _buildLargeImageContainer(
                controller: controller,
                aspectRatio: aspectRatio,
              ),
            ),
          ],
        ),

        // Floating character panel overlay (bottom-right corner)
        Positioned(
          bottom: 24,
          right: 24,
          child: _buildFloatingCharacterPanel(controller),
        ),
      ],
    );
  }

  /// Build large image container optimized for touch interaction
  Widget _buildLargeImageContainer({
    required InteractiveImageController controller,
    required double aspectRatio,
  }) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: InteractiveImageView(
                  imagePath: controller.imagePath,
                  originalWidth: controller.imageWidth.value,
                  originalHeight: controller.imageHeight.value,
                  regions: controller.regions,
                  onRegionTap: controller.speakRegion,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build right panel with character display and controls (Compact for Tablet)
  Widget _buildCompactCharacterPanel(InteractiveImageController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
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
      child: Column(
        children: [
          // Character grid (scrollable)
          Expanded(
            child: Obx(() {
              final region = controller.activeRegion.value;
              if (region == null) {
                return Center(
                  child: Icon(
                    Icons.touch_app_outlined,
                    size: 40,
                    color: Colors.grey[300],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Character grid
                    _buildCharacterGrid(controller, region.text),
                    const SizedBox(height: 20),
                    // English translation with animation
                    if (region.textEnglish.isNotEmpty)
                      EnglishStrokeDisplay(
                        text: region.textEnglish,
                        fontSize: 24,
                        fontColor: Colors.black,
                        animationSpeed: 1.0,
                      ),
                  ],
                ),
              );
            }),
          ),

          // Bottom: Play button (circle)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Obx(() {
              final region = controller.activeRegion.value;
              return GestureDetector(
                onTap: region != null
                    ? () => controller.speakRegion(region)
                    : null,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: region != null
                        ? const Color(0xFFFF6B6B)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: region != null
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Floating character panel for phone (bottom-right overlay, collapsible)
  Widget _buildFloatingCharacterPanel(InteractiveImageController controller) {
    return Obx(() {
      final region = controller.activeRegion.value;

      if (region == null) {
        // Minimal state: only show play button
        return GestureDetector(
          onTap: () {}, // No action when no region selected
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.volume_up_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 32,
            ),
          ),
        );
      }

      // Expanded state: show character and play button
      return Container(
        width: 280,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character grid
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Character grid
                    _buildCharacterGrid(controller, region.text),
                    const SizedBox(height: 16),
                    // English translation with animation
                    if (region.textEnglish.isNotEmpty)
                      EnglishStrokeDisplay(
                        text: region.textEnglish,
                        fontSize: 18,
                        fontColor: Colors.blue[700] ?? Colors.blue,
                        animationSpeed: 1.0,
                      ),
                  ],
                ),
              ),
            ),

            // Play button (circle at bottom)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () => controller.speakRegion(region),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
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



  Widget _buildCharacterGrid(
    InteractiveImageController controller,
    String text,
  ) {
    final characters = text
        .split('')
        .where((char) => char.trim().isNotEmpty)
        .toList(growable: false);

    controller.initializeCharacterProgress(text);
    final visibleCount = controller.visibleCharCount.value;
    final activeIndex = controller.currentCharIndex.value;
    final int total = characters.length;
    final int unlocked = visibleCount.clamp(0, total);

    final cells = List<CharacterCell>.generate(total, (index) {
      CharacterCellStatus status;

      if (index >= unlocked) {
        status = CharacterCellStatus.pending;
      } else if (activeIndex < 0) {
        status = CharacterCellStatus.completed;
      } else if (index < activeIndex) {
        status = CharacterCellStatus.completed;
      } else if (index == activeIndex) {
        status = CharacterCellStatus.active;
      } else {
        status = CharacterCellStatus.pending;
      }

      return CharacterCell(
        character: characters[index],
        status: status,
      );
    });

    return Center(
      child: CharacterStrokeGrid(
        cells: cells,
        cellSize: 100,
        onCharacterComplete: controller.onCharacterAnimationComplete,
      ),
    );
  }

}