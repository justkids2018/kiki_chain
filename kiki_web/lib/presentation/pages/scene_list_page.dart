import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../controllers/scene_list_controller.dart';
import '../widgets/scene_card.dart';
import '../../domain/entities/scene_category.dart';

/// 场景列表页面
///
/// 显示某个分类下的所有场景
class SceneListPage extends StatelessWidget {
  final SceneCategory category;

  const SceneListPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SceneListController>(
      init: SceneListController(category: category),
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
                      category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      localizations.scenesCount(category.sceneCount),
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

  /// 构建页面主体
  Widget _buildBody(SceneListController controller) {
    return Obx(() {
      // 加载中状态
      if (controller.isLoadingScenes.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // 错误状态
      if (controller.errorMessage.value.isNotEmpty) {
        return Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.loadFailed,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshScenes(),
                    icon: const Icon(Icons.refresh),
                    label: Text(localizations.retry),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

      // 空状态
      if (controller.scenes.isEmpty) {
        return Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noScenes,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

      // 场景网格列表
      return _buildSceneGrid(controller);
    });
  }

  /// 构建场景网格
  Widget _buildSceneGrid(SceneListController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据屏幕宽度动态计算列数
        // 卡片宽度: 350, 间距: 16
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;

        if (screenWidth >= 1200) {
          // 大屏设备 (iPad Pro 横屏): 3列
          crossAxisCount = 3;
        } else if (screenWidth >= 800) {
          // 中等屏幕 (iPad 竖屏): 2列
          crossAxisCount = 2;
        } else {
          // 小屏设备 (iPhone): 1列
          crossAxisCount = 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 7 / 9, // 350 / 450 = 7:9
            crossAxisSpacing: 20,
            mainAxisSpacing: 24,
          ),
          itemCount: controller.scenes.length,
          itemBuilder: (context, index) {
            final scene = controller.scenes[index];
            return SceneCard(
              scene: scene,
              onTap: () => controller.navigateToSceneDetail(scene),
            );
          },
        );
      },
    );
  }
}
