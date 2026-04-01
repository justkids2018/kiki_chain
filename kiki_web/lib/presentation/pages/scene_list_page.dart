import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../controllers/scene_list_controller.dart';
import '../widgets/scene_card.dart';
import '../../domain/entities/scene_category.dart';

/// 场景列表页面 — 层叠式卡片布局
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
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75, // 显示部分左右卡片
      initialPage: 0,
    );
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
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Builder(
              builder: (context) {
                final localizations = AppLocalizations.of(context)!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      localizations.scenesCount(widget.category.sceneCount),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(SceneListController controller) {
    return Obx(() {
      if (controller.isLoadingScenes.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Builder(builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(localizations.loadFailed,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(controller.errorMessage.value,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.refreshScenes(),
                  icon: const Icon(Icons.refresh),
                  label: Text(localizations.retry),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
              ],
            ),
          );
        });
      }

      if (controller.scenes.isEmpty) {
        return Builder(builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(localizations.noScenes,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
        });
      }

      return _buildStackedCardList(controller);
    });
  }

  /// 构建层叠式卡片列表（3D 效果）
  Widget _buildStackedCardList(SceneListController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final cardHeight = (availableHeight * 0.7).clamp(300.0, 500.0);
        final cardWidth = cardHeight * (7 / 9);

        return PageView.builder(
          controller: _pageController,
          itemCount: controller.scenes.length,
          itemBuilder: (context, index) {
            final scene = controller.scenes[index];
            return _buildCardItem(
              scene: scene,
              index: index,
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              onTap: () => controller.navigateToSceneDetail(scene),
            );
          },
        );
      },
    );
  }

  /// 构建单个卡片项（带 3D 变换）
  Widget _buildCardItem({
    required scene,
    required int index,
    required double cardWidth,
    required double cardHeight,
    required VoidCallback onTap,
  }) {
    // 计算当前卡片与中心位置的距离
    final difference = index - _currentPage;

    // 缩放效果：中间卡片最大(1.0)，两侧卡片缩小(0.85)
    final scale = 1.0 - (difference.abs() * 0.15).clamp(0.0, 0.15);

    // 透明度效果：中间卡片完全不透明，两侧卡片半透明
    final opacity = 1.0 - (difference.abs() * 0.3).clamp(0.0, 0.5);

    // 垂直位移：两侧卡片略微下沉
    final verticalOffset = difference.abs() * 20.0;

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 透视效果
          ..scale(scale)
          ..translate(0.0, verticalOffset, 0.0),
        alignment: Alignment.center,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: SceneCard(
              scene: scene,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
