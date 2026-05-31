import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../../../domain/entities/interactive_region.dart';
import 'interactive_image_controller.dart';
import 'interactive_image_view.dart';
import 'models/character_cell.dart';
import 'widgets/character_stroke_grid.dart';
import 'widgets/english_four_line_grid.dart';
import 'widgets/bubble_animation_layer.dart';
import '../../widgets/glass_back_button.dart';
import '../../widgets/app_loading_widget.dart';

class InteractiveImagePage extends StatefulWidget {
  const InteractiveImagePage({Key? key}) : super(key: key);

  @override
  State<InteractiveImagePage> createState() => _InteractiveImagePageState();
}

class _InteractiveImagePageState extends State<InteractiveImagePage> {
  final GlobalKey _effectLayerKey = GlobalKey();
  final ScreenDiffusionController _diffusionController =
      ScreenDiffusionController();

  // Platform-specific sizing
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  double get _englishFontSizeTablet => _isAndroid ? 14.0 : 24.0;
  double get _englishGridHeight => _isAndroid ? 56.0 : 74.0;
  double get _chineseCellSizeTablet => _isAndroid ? 74.0 : 110.0;
  double get _chineseCellSizePhone => _isAndroid ? 58.0 : 68.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _diffusionController.dispose();
    super.dispose();
  }

  void _triggerScreenDiffusion(Offset globalPosition) {
    final context = _effectLayerKey.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final localPosition = renderObject.globalToLocal(globalPosition);
    _diffusionController.trigger(localPosition);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InteractiveImageController>()
        ? Get.find<InteractiveImageController>()
        : Get.put(InteractiveImageController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Only allow back navigation via the back button, not gestures
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Blurred background image
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: _buildBackgroundImage(controller.imagePath),
                ),
              ),
            ),

            // 2. Darker overlay
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),

            // 3. Reactive content: loading spinner OR main layout
            Obx(() {
              if (!controller.isLoaded.value) {
                return AppLoadingWidget(
                  message: '加载中...',
                  progress: null,
                );
              }

              final imageWidth = controller.imageWidth.value;
              final imageHeight = controller.imageHeight.value;
              final aspectRatio = imageWidth > 0 && imageHeight > 0
                  ? imageWidth / imageHeight
                  : 1.0;

              return Stack(
                children: [
                  // Main content — vertically centered below status bar
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: ScreenDiffusionLayer(
                        controller: _diffusionController,
                        child: Container(
                          key: _effectLayerKey,
                          alignment: Alignment.center,
                          child: _buildUnifiedLandscapeLayout(
                            context,
                            controller,
                            aspectRatio,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating TopBar (always on top layer)
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: _buildFloatingTopBar(context),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Unified landscape layout: left image + right learning panel.
  Widget _buildUnifiedLandscapeLayout(
    BuildContext context,
    InteractiveImageController controller,
    double aspectRatio,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final mediaPadding = MediaQuery.of(context).padding;

    final isCompactLandscape = screenSize.shortestSide < 700;
    final horizontalPadding = isCompactLandscape ? 8.0 : 24.0;
    final panelGap = isCompactLandscape ? 10.0 : 20.0;

    // 右侧固定尺寸：避免在移动端被拉成整宽，整体保持近似方形。
    final double panelWidthPreset = isCompactLandscape ? 300.0 : 320.0;

    final availableWidth = (screenSize.width - horizontalPadding * 2)
        .clamp(360.0, double.infinity);

    final panelMaxWidth = (availableWidth - panelGap - 160).clamp(240.0, 360.0);
    final panelWidth = panelWidthPreset.clamp(240.0, panelMaxWidth);

    final imageMaxWidth =
        (availableWidth - panelGap - panelWidth).clamp(160.0, double.infinity);

    final maxLayoutHeight =
        (screenSize.height - mediaPadding.top - mediaPadding.bottom - 30)
            .clamp(320.0, double.infinity);

    // 左图优先放大，尽量吃满剩余区域；保持方形以保证视觉稳定。
    final imageSize = imageMaxWidth.clamp(160.0, maxLayoutHeight);
    final panelHeight = imageSize;
    final groupWidth = imageSize + panelGap + panelWidth;
    final layoutHeight = imageSize;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        height: layoutHeight,
        width: double.infinity,
        child: Center(
          child: SizedBox(
            width: groupWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: _buildLargeImageContainer(
                    controller: controller,
                  ),
                ),
                SizedBox(width: panelGap),
                // Right: fixed panel size in centered group.
                SizedBox(
                  width: panelWidth,
                  height: panelHeight,
                  child: _buildCompactCharacterPanel(controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build large image container — square (1:1) aspect ratio
  Widget _buildLargeImageContainer({
    required InteractiveImageController controller,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Strong edge shadow for floating effect
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 60,
              offset: const Offset(0, 30),
              spreadRadius: -10,
            ),
            // Mid-range shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
            // Close shadow for depth
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
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
              onRegionTapDown: _triggerScreenDiffusion,
            ),
          ),
        ),
      ),
    );
  }

  /// Build right panel with character display and controls (Compact for Tablet)
  Widget _buildCompactCharacterPanel(InteractiveImageController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.42),
          width: 1,
        ),
        boxShadow: [
          // Softer shadow to reduce heavy "solid card" feeling.
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00C37D),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
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
                          color:
                              const Color(0xFF00C37D).withValues(alpha: 0.08),
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
                        '开始学习',
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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildLearningInfoSection(
                      controller,
                      region,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.withValues(alpha: 0.35),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '笔顺练习',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildReadChinesePlayButton(controller, region),
                    ),
                    const SizedBox(height: 10),
                    _buildCharacterGrid(controller, region),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReadChinesePlayButton(
    InteractiveImageController controller,
    InteractiveRegion region,
  ) {
    return Obx(() {
      final isSpeaking = controller.isSpeaking.value;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => controller.speakChinesePhrase(region),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF00C37D).withValues(
                alpha: isSpeaking ? 0.16 : 0.10,
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF00C37D).withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.volume_up_rounded,
                  size: 14,
                  color: Color(0xFF00C37D),
                ),
                const SizedBox(width: 4),
                const Text(
                  '播放',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00C37D),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBackgroundImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
    );
  }

  Widget _buildFloatingTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back Button
          const GlassBackButton(),
          // TODO: Settings button temporarily removed to simplify UI.
          // Speed adjustment is low-frequency feature. Consider adding to main page or dedicated settings.
        ],
      ),
    );
  }

  Widget _buildCharacterGrid(
    InteractiveImageController controller,
    InteractiveRegion region,
  ) {
    final characters = region.text
        .split('')
        .where((char) => char.trim().isNotEmpty)
        .toList(growable: false);

    controller.initializeCharacterProgress(region.text);

    return Obx(() {
      final visibleCount = controller.visibleCharCount.value;
      final activeIndex = controller.currentCharIndex.value;
      final speed = controller.animationSpeed.value; // 响应速度变化
      final int total = characters.length;
      final int unlocked = visibleCount.clamp(0, total);

      final cells = List<CharacterCell>.generate(total, (index) {
        CharacterCellStatus status;

        if (index >= unlocked) {
          status = CharacterCellStatus.pending;
        } else if (activeIndex < 0) {
          status = CharacterCellStatus.completed;
        } else if (unlocked == total) {
          status = index == activeIndex
              ? CharacterCellStatus.active
              : CharacterCellStatus.completed;
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
          cellSize: MediaQuery.of(context).size.shortestSide < 600
              ? _chineseCellSizePhone
              : _chineseCellSizeTablet,
          animationSpeed: speed,
          onCharacterComplete: controller.onCharacterAnimationComplete,
          onCharacterTap: (index, character) {
            controller.speakChineseChar(region, index, character);
          },
        ),
      );
    });
  }

  Widget _buildLearningInfoSection(
    InteractiveImageController controller,
    InteractiveRegion region,
  ) {
    final english = region.textEnglish.trim();
    final phonetic = region.textPhonetic.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (english.isNotEmpty) ...[
          GestureDetector(
            onTap: () => controller.speakEnglishWord(region),
            child: EnglishFourLineGrid(
              text: english,
              fontSize: _englishFontSizeTablet,
              fontColor: Colors.black87,
              height: _englishGridHeight,
              markVowels: true,
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (phonetic.isNotEmpty) ...[
          _buildPronunciationChip(
            value: phonetic,
            onTap: () => controller.speakEnglishWord(region),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _buildPronunciationChip({
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        splashColor: const Color(0xFF66A9D9).withValues(alpha: 0.14),
        highlightColor: const Color(0xFF66A9D9).withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE6EBEF), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A6B7B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.volume_up_rounded,
                size: 15,
                color: Color(0xFF66A9D9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
