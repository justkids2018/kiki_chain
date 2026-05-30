import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/scene_list_controller.dart';
import '../widgets/scene_card.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/app_loading_widget.dart';
import '../../domain/entities/scene_category.dart';
import '../../domain/entities/scene.dart';
import '../../design_ui/kiki_ui_kit.dart';

/// 场景列表页面 — 层叠式卡片布局 + 高斯模糊背景
class SceneListPage extends StatefulWidget {
  final SceneCategory category;

  const SceneListPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<SceneListPage> createState() => _SceneListPageState();
}

class _SceneListPageState extends State<SceneListPage> {
  // Narrower page slots to get a true stacked/overlapped deck feel.
  static const double _viewportFraction = 0.56;
  // Larger overlap so neighboring cards visually sit on top of each other.
  static const double _targetCardOverlap = 64.0;
  static const int _virtualLoopMultiplier = 500;
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    // Start from the middle for smooth bi-direction infinite loop.
    const initialPage = _virtualLoopMultiplier ~/ 2;
    _pageController = PageController(
      // Make each page slot narrower than card width to create overlap.
      viewportFraction: _viewportFraction,
      initialPage: initialPage,
    );
    _currentPage = initialPage.toDouble();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SceneListController>(
      tag: widget.category.id,
      init: SceneListController(category: widget.category),
      global: false,
      autoRemove: true,
      builder: (controller) {
        return Scaffold(
          backgroundColor: KikiUiColors.pageBackground,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. 高斯模糊背景（当前选中场景的封面图）
              _buildBlurredBackground(controller),

              // 2. 深色遮罩
              Obx(() {
                final hasScenes = controller.scenes.isNotEmpty;
                return Container(
                  color: Colors.black.withOpacity(hasScenes ? 0.35 : 0.0),
                );
              }),

              // 3. 主内容
              SafeArea(child: _buildBody(controller)),

              // 4. 悬浮返回按钮 + 标题
              SafeArea(child: _buildFloatingTopBar()),
            ],
          ),
        );
      },
    );
  }

  /// 高斯模糊背景
  Widget _buildBlurredBackground(SceneListController controller) {
    return Obx(() {
      if (controller.scenes.isEmpty) {
        return Container(decoration: KikiUiDecor.pageBackgroundDecor);
      }

      final scenes = controller.scenes;
      if (scenes.length == 1) {
        return _buildBlurredBackgroundLayer(scenes.first.coverImage, 1.0);
      }

      final floorPage = _currentPage.floor();
      final nextPage = floorPage + 1;
      final progress = (_currentPage - floorPage).clamp(0.0, 1.0);

      final fromScene = scenes[_toRealIndex(floorPage, scenes.length)];
      final toScene = scenes[_toRealIndex(nextPage, scenes.length)];

      // Near page boundaries, render only one layer to avoid a final "flash"
      // caused by dual-layer rebuild at settle time.
      if (progress < 0.03) {
        return _buildBlurredBackgroundLayer(fromScene.coverImage, 1.0);
      }
      if (progress > 0.97) {
        return _buildBlurredBackgroundLayer(toScene.coverImage, 1.0);
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          _buildBlurredBackgroundLayer(fromScene.coverImage, 1.0 - progress),
          _buildBlurredBackgroundLayer(toScene.coverImage, progress),
        ],
      );
    });
  }

  Widget _buildBlurredBackgroundLayer(String imageUrl, double opacity) {
    if (opacity <= 0) {
      return const SizedBox.shrink();
    }

    final isValid = imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    if (!isValid) {
      return Opacity(
        opacity: opacity,
        child: Container(decoration: KikiUiDecor.pageBackgroundDecor),
      );
    }

    return Opacity(
      opacity: opacity,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          useOldImageOnUrlChange: true,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (_, __) => const SizedBox.expand(),
          errorWidget: (_, __, ___) =>
              Container(decoration: KikiUiDecor.pageBackgroundDecor),
        ),
      ),
    );
  }

  /// 悬浮返回按钮（左上角）
  Widget _buildFloatingTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Align(
        alignment: Alignment.topLeft,
        child: GlassBackButton(),
      ),
    );
  }

  Widget _buildBody(SceneListController controller) {
    return Obx(() {
      if (controller.isLoadingScenes.value) {
        return const AppLoadingWidget(message: '加载中...');
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              Text('加载失败',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text(controller.errorMessage.value,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => controller.refreshScenes(),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        );
      }

      if (controller.scenes.isEmpty) {
        return Center(
          child: Text(
            '暂无场景',
            style: TextStyle(
              fontSize: 16,
              color: KikiUiColors.textSecondary.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      return _buildStackedCardList(controller);
    });
  }

  /// 层叠式卡片列表（3D 效果）+ 标题在选中卡片上方
  Widget _buildStackedCardList(SceneListController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        // 为标题预留空间（标题高度约 60px）
        const titleHeight = 60.0;
        final cardSize = (availableWidth * 0.62).clamp(210.0, 400.0).toDouble();
        final maxAllowedByHeight = ((availableHeight - titleHeight) * 0.74)
            .clamp(220.0, 520.0)
            .toDouble();
        final finalCardSize =
            cardSize > maxAllowedByHeight ? maxAllowedByHeight : cardSize;
        final cardWidth = finalCardSize;
        final cardHeight = finalCardSize;

        return Stack(
          children: [
            // 滑动手势层（透明）：负责横向滚动与分页状态
            Positioned.fill(
              top: titleHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final idx = _toRealIndex(
                      _currentPage.round(), controller.scenes.length);
                  controller.navigateToSceneDetail(controller.scenes[idx]);
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: controller.scenes.length <= 1
                      ? controller.scenes.length
                      : controller.scenes.length * _virtualLoopMultiplier,
                  itemBuilder: (context, index) => const SizedBox.expand(),
                ),
              ),
            ),
            // 视觉层（穿透指针）：控制叠层、亮暗、层级顺序
            Positioned.fill(
              top: titleHeight,
              child: IgnorePointer(
                child: _buildVisualDeck(
                  controller: controller,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              ),
            ),
            // 标题在当前选中卡片上方
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: titleHeight,
              child: Center(
                child: Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _toRealIndex(int index, int length) {
    if (length <= 0) return 0;
    return index % length;
  }

  Widget _buildCardItem({
    required Scene scene,
    required int index,
    required double cardWidth,
    required double cardHeight,
  }) {
    final difference = index - _currentPage;
    final absDifference = difference.abs();
    final distance = absDifference.clamp(0.0, 4.0);

    final scale = (1.0 - (distance * 0.11)).clamp(0.60, 1.0);
    final opacity = (1.0 - (distance * 0.14)).clamp(0.35, 1.0);

    // 所有卡片保持同一水平基线，不做上下错位
    final isCenterCard = absDifference < 0.5;
    const verticalOffset = 0.0;

    final targetCenterDistance = cardWidth - _targetCardOverlap;
    final horizontalOffset = difference * targetCenterDistance;

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..translate(horizontalOffset, verticalOffset, 0.0)
          ..scale(scale),
        alignment: Alignment.center,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              children: [
                SceneCard(scene: scene, isActive: isCenterCard),
                if (!isCenterCard)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: Colors.black.withOpacity(0.34),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualDeck({
    required SceneListController controller,
    required double cardWidth,
    required double cardHeight,
  }) {
    final scenes = controller.scenes;
    if (scenes.isEmpty) {
      return const SizedBox.shrink();
    }

    final base = _currentPage.round();
    // 大屏下也保持 5-9 张的可见卡片量，避免看起来只有 3 张。
    const radius = 4;
    final virtualIndices =
        List<int>.generate(radius * 2 + 1, (i) => base - radius + i);

    // 远处先画，近处后画；中间卡最后画，始终在最上层。
    virtualIndices.sort((a, b) {
      final da = (a - _currentPage).abs();
      final db = (b - _currentPage).abs();
      return db.compareTo(da);
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        for (final virtualIndex in virtualIndices)
          _buildCardItem(
            scene: scenes[_toRealIndex(virtualIndex, scenes.length)],
            index: virtualIndex,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
          ),
      ],
    );
  }
}
