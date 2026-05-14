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
import '../../widgets/settings_dialog.dart';
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
  double get _englishFontSizePhone => _isAndroid ? 20.0 : 36.0;
  double get _englishGridHeight => _isAndroid ? 56.0 : 74.0;
  double get _chineseCellSize => _isAndroid ? 80.0 : 120.0;

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Permanent blurred background — starts loading immediately, eliminates black flash
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
                child: _buildBackgroundImage(controller.imagePath),
              ),
            ),
          ),

          // 2. Dark overlay (always present)
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),

          // 3. Reactive content: loading spinner OR main layout
          Obx(() {
            if (!controller.isLoaded.value) {
              return AppLoadingWidget(
                message: '加载中...',
                progress: controller.loadingProgress.value > 0
                    ? controller.loadingProgress.value
                    : null,
              );
            }

            final imageWidth = controller.imageWidth.value;
            final imageHeight = controller.imageHeight.value;
            final aspectRatio = imageWidth > 0 && imageHeight > 0
                ? imageWidth / imageHeight
                : 1.0;

            // Responsive design: default to tablet, only switch to phone if smaller
            final size = MediaQuery.of(context).size;
            final isPhone = size.width < 600;

            return Stack(
              children: [
                // Main content — vertically centered below status bar
                Positioned.fill(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 35),
                      child: ScreenDiffusionLayer(
                        controller: _diffusionController,
                        child: Container(
                          key: _effectLayerKey,
                          alignment:
                              isPhone ? Alignment.center : Alignment.center,
                          child: isPhone
                              ? _buildPhoneLayout(
                                  context, controller, aspectRatio)
                              : _buildTabletLayout(
                                  context,
                                  controller,
                                  aspectRatio,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating TopBar (always on top layer)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: _buildFloatingTopBar(context),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Tablet layout (iPad): Left image, right character panel side by side
  Widget _buildTabletLayout(
    BuildContext context,
    InteractiveImageController controller,
    double aspectRatio,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final mediaPadding = MediaQuery.of(context).padding;

    // 计算可用宽度（屏幕宽度 - 左右边距70dp）
    final availableWidth = screenSize.width - 70;

    // 根据图片宽高比计算图片高度
    // 图片区域占据约58%，右侧面板42%
    final imageWidth = availableWidth * 0.58;
    final imageHeight = imageWidth / aspectRatio;

    // 上下各留35dp呼吸空间（SafeArea已处理状态栏）
    final maxLayoutHeight =
        (screenSize.height - mediaPadding.top - mediaPadding.bottom - 70)
            .clamp(380.0, double.infinity);
    final layoutHeight = imageHeight.clamp(0.0, maxLayoutHeight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35), // 左右边距35dp
      child: SizedBox(
        height: layoutHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // 左右两侧拉伸到相同高度
          children: [
            // Left: Square Interactive Image
            Flexible(
              flex: 58,
              child: _buildLargeImageContainer(
                controller: controller,
              ),
            ),

            const SizedBox(width: 24), // 间距24

            // Right: Character Panel (compact)
            Flexible(
              flex: 42,
              child: _buildCompactCharacterPanel(controller),
            ),
          ],
        ),
      ),
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
        // Full screen image
        _buildLargeImageContainer(
          controller: controller,
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

  /// Build large image container — square (1:1) aspect ratio
  Widget _buildLargeImageContainer({
    required InteractiveImageController controller,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                    onRegionTapDown: _triggerScreenDiffusion,
                  ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
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
                        color: Colors.grey[600],
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
                              color: const Color(0xFF00C37D)
                                  .withValues(alpha: 0.08),
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
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildLearningInfoSection(
                          controller,
                          region,
                          false,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[200])),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '笔顺练习',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[200])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildCharacterGrid(controller, region),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Obx(() {
              final region = controller.activeRegion.value;
              final isActive = region != null;
              return Center(
                child: GestureDetector(
                  onTap: isActive ? () => controller.speakRegion(region) : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF00C37D)
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00C37D)
                                        .withValues(alpha: 0.32),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          color: isActive ? Colors.white : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '点击朗读',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? const Color(0xFF00C37D)
                              : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
        // Minimal state: hint pill
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app_outlined,
                  size: 18, color: Color(0xFF00C37D)),
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
              color: Colors.black.withValues(alpha: 0.15),
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
                    _buildLearningInfoSection(
                      controller,
                      region,
                      true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[200])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '笔顺练习',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[200])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Character stroke grid
                    _buildCharacterGrid(controller, region),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C37D),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00C37D).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '点击朗读',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF00C37D),
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

          const Spacer(),

          // Settings Button
          GestureDetector(
            onTap: () => Get.dialog(const SettingsDialog()),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child:
                      const Icon(Icons.settings, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
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
        cellSize: _chineseCellSize,
        onCharacterComplete: controller.onCharacterAnimationComplete,
        onCharacterTap: (index, character) {
          controller.speakChineseChar(region, index, character);
        },
      ),
    );
  }

  Widget _buildLearningInfoSection(
    InteractiveImageController controller,
    InteractiveRegion region,
    bool isPhone,
  ) {
    final english = region.textEnglish.trim();
    final phonetic = region.textPhonetic.trim();
    final pinyin = region.textPinyin.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (english.isNotEmpty) ...[
          GestureDetector(
            onTap: () => controller.speakEnglishWord(region),
            child: EnglishFourLineGrid(
              text: english,
              fontSize:
                  isPhone ? _englishFontSizePhone : _englishFontSizeTablet,
              fontColor: Colors.black87,
              height: _englishGridHeight,
              markVowels: true,
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (phonetic.isNotEmpty) ...[
          _buildPronunciationChip(
            label: '音标',
            value: phonetic,
            onTap: () => controller.speakEnglishWord(region),
          ),
          const SizedBox(height: 8),
        ],
        if (pinyin.isNotEmpty)
          _buildPronunciationChip(
            label: '拼音',
            value: pinyin,
            onTap: () => controller.speakPinyin(region),
          ),
      ],
    );
  }

  Widget _buildPronunciationChip({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
              '$label  ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5A6B7B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.volume_up_rounded,
                size: 15, color: Color(0xFF66A9D9)),
          ],
        ),
      ),
    );
  }
}
