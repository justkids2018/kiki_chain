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
  static const double _viewportFraction = 0.52;
  // Keep face overlap around 10-20dp. Slightly increase inter-card distance by
  // reducing overlap 10dp from previous 14dp to 4dp.
  static const double _targetCardOverlap = 4.0;
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
      init: SceneListController(category: widget.category),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. 高斯模糊背景（当前选中场景的封面图）
              _buildBlurredBackground(controller),

              // 2. 深色遮罩
              Container(color: Colors.black.withOpacity(0.35)),

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
        return Container(color: Colors.grey[900]);
      }
      final idx = _toRealIndex(_currentPage.round(), controller.scenes.length);
      final scene = controller.scenes[idx];
      final imageUrl = scene.coverImage;

      if (imageUrl.isEmpty ||
          (!imageUrl.startsWith('http://') &&
              !imageUrl.startsWith('https://'))) {
        return Container(color: Colors.grey[900]);
      }

      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => Container(color: Colors.grey[900]),
          errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
        ),
      );
    });
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
        return const Center(
          child: Text('暂无场景',
              style: TextStyle(fontSize: 16, color: Colors.white70)),
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
        final maxCardHeight =
            ((availableHeight - titleHeight) * 0.68).clamp(280.0, 520.0);
        // Card is intentionally wider so neighboring cards overlap each other.
        final maxCardWidth = (availableWidth * 0.66).clamp(240.0, 440.0);
        final cardWidth = maxCardWidth;
        final cardHeight = (cardWidth / (7 / 9)).clamp(280.0, maxCardHeight);
        final pageSpacing = availableWidth * _viewportFraction;

        return Stack(
          children: [
            // 卡片列表
            Positioned.fill(
              top: titleHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: controller.scenes.length <= 1
                    ? controller.scenes.length
                    : controller.scenes.length * _virtualLoopMultiplier,
                itemBuilder: (context, index) {
                  final realIndex =
                      _toRealIndex(index, controller.scenes.length);
                  final scene = controller.scenes[realIndex];
                  return _buildCardItem(
                    scene: scene,
                    index: index,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    pageSpacing: pageSpacing,
                    onTap: () => controller.navigateToSceneDetail(scene),
                  );
                },
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
    required double pageSpacing,
    required VoidCallback onTap,
  }) {
    final difference = index - _currentPage;
    final absDifference = difference.abs();
    final scale = 1.0 - (absDifference * 0.10).clamp(0.0, 0.22);
    final opacity = 1.0 - (absDifference * 0.16).clamp(0.0, 0.38);
    final verticalOffset = absDifference * 14.0;
    // PageView already moves each page by pageSpacing. We apply an extra
    // correction so adjacent card faces overlap by about _targetCardOverlap.
    final targetCenterDistance = cardWidth - _targetCardOverlap;
    final horizontalOffset = difference * (targetCenterDistance - pageSpacing);
    final rotateZ = (difference * 0.10).clamp(-0.14, 0.14);

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateZ(rotateZ)
          ..scale(scale)
          ..translate(horizontalOffset, verticalOffset, 0.0),
        alignment: Alignment.center,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: SceneCard(scene: scene, onTap: onTap),
          ),
        ),
      ),
    );
  }
}
