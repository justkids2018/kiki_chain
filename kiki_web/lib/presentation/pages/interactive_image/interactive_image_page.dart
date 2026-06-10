import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../../core/speech/audio_playback_component.dart';
import '../../../domain/entities/interactive_region.dart';
import 'interactive_image_controller.dart';
import 'interactive_image_view.dart';
import 'models/character_cell.dart';
import 'widgets/bubble_animation_layer.dart';
import 'widgets/character_stroke_grid.dart';
import 'widgets/english_four_line_grid.dart';
import 'widgets/glass_star_bar.dart';
import 'widgets/star_fly_animation.dart';
import '../../widgets/app_loading_widget.dart';
import '../../widgets/glass_back_button.dart';

class InteractiveImagePage extends StatefulWidget {
  const InteractiveImagePage({Key? key}) : super(key: key);

  @override
  State<InteractiveImagePage> createState() => _InteractiveImagePageState();
}

class _InteractiveImagePageState extends State<InteractiveImagePage> {
  final GlobalKey _effectLayerKey = GlobalKey();
  final ScreenDiffusionController _diffusionController =
      ScreenDiffusionController();
  bool _isHandlingBackNavigation = false;

  // 3 颗星星的 GlobalKey（用于飞翔动画定位目标坐标）
  final List<GlobalKey> _starKeys = List.generate(3, (_) => GlobalKey());

  // 飞翔动画控制器
  final StarFlyAnimationController _starFlyController =
      StarFlyAnimationController();

  // 最近一次点击的全局坐标（作为星星飞翔起点）
  Offset _lastTapPosition = Offset.zero;

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
    _starFlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final controller = Get.isRegistered<InteractiveImageController>()
        ? Get.find<InteractiveImageController>()
        : Get.put(InteractiveImageController());

    // 监听星星奖励事件，触发飞翔动画
    ever(controller.starRewardEvent, (StarRewardEvent? event) {
      if (event == null) return;
      _launchStarFlyAnimation(context, controller, event.starIndex);
      // 消费事件，防止重复触发
      Future.microtask(() => controller.starRewardEvent.value = null);
    });

    return WillPopScope(
      // 禁用 Android 返回键 / iOS 左滑手势（旧 API 兼容）
      onWillPop: () async {
        await _handleBackNavigation(context);
        return false;
      },
      child: PopScope(
        // 禁用 iOS 边缘左滑返回（Flutter 3.12+ 新 API）
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await _handleBackNavigation(context);
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              Obx(() {
                if (!controller.isLoaded.value) {
                  return AppLoadingWidget(
                    message: localizations.loading,
                    progress: null,
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${controller.errorMessage.value}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Debug: ${controller.getDiagnostics()}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                final imageWidth = controller.imageWidth.value;
                final imageHeight = controller.imageHeight.value;
                final aspectRatio = imageWidth > 0 && imageHeight > 0
                    ? imageWidth / imageHeight
                    : 1.0;

                return Positioned.fill(
                  child: ScreenDiffusionLayer(
                    controller: _diffusionController,
                    child: Container(
                      key: _effectLayerKey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildUnifiedLandscapeLayout(
                          context,
                          controller,
                          aspectRatio,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // 顶部浮层：返回按钮 + 星星栏
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: _buildFloatingTopBar(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 星星飞翔动画 ─────────────────────────────────────────────

  /// 从词语点击位置飞向右上角对应星星
  void _launchStarFlyAnimation(
    BuildContext context,
    InteractiveImageController controller,
    int starIndex,
  ) {
    final overlay = Overlay.of(context);

    // 目标坐标：右上角对应星星的中心
    Offset? targetPosition;
    final starKey = _starKeys[starIndex];
    final starContext = starKey.currentContext;
    if (starContext != null) {
      final box = starContext.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final offset = box.localToGlobal(Offset.zero);
        targetPosition = offset + Offset(box.size.width / 2, box.size.height / 2);
      }
    }

    if (targetPosition == null) {
      // fallback：右上角固定坐标
      final screenSize = MediaQuery.of(context).size;
      final safePadding = MediaQuery.of(context).padding;
      targetPosition = Offset(
        screenSize.width - 40.0 - starIndex * 34.0,
        safePadding.top + 36,
      );
    }

    _starFlyController.launch(
      overlayState: overlay,
      startPosition: _lastTapPosition,
      targetPosition: targetPosition,
      onArrived: () {
        // 叮咚音效（当前用 star_1.mp3 占位，后续替换为 star_ding.mp3）
        final isFinalStar = controller.starsEarned.value >= 3;
        final audioFile = isFinalStar
            ? 'assets/audio/star_3_complete.mp3'
            : 'assets/audio/star_1.mp3';
        AudioPlaybackComponent().playAudioFile(audioFile).catchError((_) {});
      },
    );
  }

  // ─── 辅助方法 ─────────────────────────────────────────────────

  void _triggerScreenDiffusion(Offset globalPosition) {
    // 同时保存点击坐标作为星星飞翔起点
    _lastTapPosition = globalPosition;

    final context = _effectLayerKey.currentContext;
    if (context == null) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;
    final localPosition = renderObject.globalToLocal(globalPosition);
    _diffusionController.trigger(localPosition);
  }

  Future<void> _handleBackNavigation(BuildContext context) async {
    if (_isHandlingBackNavigation) return;
    _isHandlingBackNavigation = true;
    try {
      final controller = Get.find<InteractiveImageController>();
      await controller.saveProgress();
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } finally {
      _isHandlingBackNavigation = false;
    }
  }

  // ─── 顶部栏（返回按钮 + 星星栏）────────────────────────────────

  Widget _buildFloatingTopBar(
      BuildContext context, InteractiveImageController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            GlassBackButton(
              onTap: () => _handleBackNavigation(context),
            ),
            const Spacer(),
            // 毛玻璃星星栏（响应式更新）
            Obx(() => GlassStarBar(
                  starsEarned: controller.starsEarned.value,
                  starKeys: _starKeys,
                )),
          ],
        ),
      ),
    );
  }

  // ─── 主布局 ───────────────────────────────────────────────────

  Widget _buildUnifiedLandscapeLayout(
    BuildContext context,
    InteractiveImageController controller,
    double aspectRatio,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final mediaPadding = MediaQuery.of(context).padding;

    final isCompactLandscape = screenSize.shortestSide < 700;
    final horizontalPadding = isCompactLandscape ? 8.0 : 24.0;
    final panelGap = (isCompactLandscape ? 10.0 : 20.0) + 15.0;
    final double panelWidthPreset = isCompactLandscape ? 300.0 : 320.0;

    final availableWidth = (screenSize.width - horizontalPadding * 2)
        .clamp(360.0, double.infinity);
    final panelMaxWidth =
        (availableWidth - panelGap - 160).clamp(240.0, 360.0);
    final panelWidth = panelWidthPreset.clamp(240.0, panelMaxWidth);
    final imageMaxWidth =
        (availableWidth - panelGap - panelWidth).clamp(160.0, double.infinity);
    final maxLayoutHeight =
        (screenSize.height - mediaPadding.top - mediaPadding.bottom - 30)
            .clamp(320.0, double.infinity);

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
                  child: _buildLargeImageContainer(controller: controller),
                ),
                SizedBox(width: panelGap),
                SizedBox(
                  width: panelWidth,
                  height: panelHeight,
                  child: _buildCompactCharacterPanel(context, controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeImageContainer({
    required InteractiveImageController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 60,
            offset: const Offset(0, 30),
            spreadRadius: -10,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : constraints.biggest.width;
            final height = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : constraints.biggest.height;
            final side = width > 0 && height > 0
                ? (width < height ? width : height)
                : (width > 0 ? width : height);
            if (side <= 0) return const SizedBox.shrink();
            return InteractiveViewer(
              constrained: false,
              minScale: 0.5,
              maxScale: 4.0,
              child: SizedBox(
                width: side,
                height: side,
                child: InteractiveImageView(
                  imagePath: controller.imagePath,
                  originalWidth: controller.imageWidth.value,
                  originalHeight: controller.imageHeight.value,
                  regions: controller.regions,
                  onRegionTap: controller.speakRegion,
                  onRegionTapDown: _triggerScreenDiffusion,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactCharacterPanel(
      BuildContext context, InteractiveImageController controller) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.42),
          width: 1,
        ),
        boxShadow: [
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
                Expanded(
                  child: Text(
                    localizations.interactiveLearning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00C37D),
                      letterSpacing: 1.2,
                    ),
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
                          color: const Color(0xFF00C37D).withValues(alpha: 0.08),
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
                        localizations.clickItemHint,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        localizations.startLearning,
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
                    _buildLearningInfoSection(controller, region),
                    const SizedBox(height: 12),
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
                            localizations.strokePractice,
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
                    const SizedBox(height: 10),
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
    final localizations = AppLocalizations.of(Get.context!)!;
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
                const Icon(Icons.volume_up_rounded,
                    size: 14, color: Color(0xFF00C37D)),
                const SizedBox(width: 4),
                Text(
                  localizations.playPronunciation,
                  style: const TextStyle(
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
      final speed = controller.animationSpeed.value;
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
        return CharacterCell(character: characters[index], status: status);
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
            onTap: () => controller.speakPinyin(region),
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
              const Icon(Icons.volume_up_rounded,
                  size: 15, color: Color(0xFF66A9D9)),
            ],
          ),
        ),
      ),
    );
  }
}
