import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'interactive_image_controller.dart';
import 'interactive_image_view.dart';
import 'models/character_cell.dart';
import 'widgets/character_stroke_grid.dart';
import 'widgets/english_four_line_grid.dart';
import '../../widgets/settings_dialog.dart';

class InteractiveImagePage extends StatefulWidget {
  InteractiveImagePage({Key? key}) : super(key: key);

  @override
  State<InteractiveImagePage> createState() => _InteractiveImagePageState();
}

class _InteractiveImagePageState extends State<InteractiveImagePage> {
  // Platform-specific sizing
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  double get _englishFontSizeTablet => _isAndroid ? 26.0 : 55.0;
  double get _englishFontSizePhone => _isAndroid ? 24.0 : 50.0;
  double get _englishGridHeight => _isAndroid ? 110.0 : 130.0;
  double get _chineseCellSize => _isAndroid ? 80.0 : 120.0;

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
                flex: 7,  // Changed from 3 to 7 for 70:30 ratio
                child: _buildLargeImageContainer(
                  controller: controller,
                  aspectRatio: aspectRatio,
                ),
              ),

              // Right: Character Panel (compact)
              Expanded(
                flex: 3,  // Changed from 2 to 3 for 70:30 ratio
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
      margin: const EdgeInsets.fromLTRB(8, 24, 24, 24),
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
          // Panel header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C37D),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '互动学习',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Character grid (scrollable)
          Expanded(
            child: Obx(() {
              final region = controller.activeRegion.value;
              if (region == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C37D).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.touch_app_outlined,
                          size: 36,
                          color: Color(0xFF00C37D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '点击图中物品',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '开始互动学习',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Chinese character name — primary label
                    if (region.text.isNotEmpty)
                      Text(
                        region.text,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (region.text.isNotEmpty)
                      const SizedBox(height: 12),

                    // English translation with four-line-three-grid
                    if (region.textEnglish.isNotEmpty)
                      EnglishFourLineGrid(
                        text: region.textEnglish,
                        fontSize: _englishFontSizeTablet,
                        fontColor: Colors.black87,
                        height: _englishGridHeight,
                        markVowels: true,
                      ),
                    if (region.textEnglish.isNotEmpty)
                      const SizedBox(height: 20),

                    // Divider label
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[200])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '笔顺练习',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[200])),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Character stroke grid
                    _buildCharacterGrid(controller, region.text),
                  ],
                ),
              );
            }),
          ),

          // Bottom: Play button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[100]!,
                  width: 1,
                ),
              ),
            ),
            child: Obx(() {
              final region = controller.activeRegion.value;
              final isActive = region != null;
              return GestureDetector(
                onTap: isActive ? () => controller.speakRegion(region) : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00C37D)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00C37D).withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: isActive ? Colors.white : Colors.grey[400],
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '点击朗读',
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? const Color(0xFF00C37D)
                            : Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
        // Minimal state: hint pill
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 18, color: const Color(0xFF00C37D)),
              const SizedBox(width: 6),
              Text(
                '点击物品',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Chinese label
                    if (region.text.isNotEmpty)
                      Text(
                        region.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (region.text.isNotEmpty)
                      const SizedBox(height: 10),
                    // English four-line grid
                    if (region.textEnglish.isNotEmpty)
                      EnglishFourLineGrid(
                        text: region.textEnglish,
                        fontSize: _englishFontSizePhone,
                        fontColor: Colors.black87,
                        height: _englishGridHeight,
                        markVowels: true,
                      ),
                    if (region.textEnglish.isNotEmpty)
                      const SizedBox(height: 16),
                    // Character stroke grid
                    _buildCharacterGrid(controller, region.text),
                  ],
                ),
              ),
            ),

            // Play button
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[100]!, width: 1),
                ),
              ),
              child: GestureDetector(
                onTap: () => controller.speakRegion(region),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C37D),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C37D).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '点击朗读',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF00C37D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

          // Settings Button
          GestureDetector(
            onTap: () => Get.dialog(const SettingsDialog()),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings,
                  color: Colors.white, size: 24),
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
        cellSize: _chineseCellSize, // Platform-specific size
        onCharacterComplete: controller.onCharacterAnimationComplete,
      ),
    );
  }

}