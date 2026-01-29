import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scene_detail_controller.dart';
import '../../domain/entities/scene.dart';

/// 场景详情页面
///
/// 显示场景的互动图片和可点击的物品热点
class SceneDetailPage extends StatelessWidget {
  final Scene scene;

  const SceneDetailPage({
    Key? key,
    required this.scene,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SceneDetailController>(
      init: SceneDetailController(scene: scene),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // 场景背景图片
                _buildSceneImage(controller),

                // 顶部工具栏
                _buildTopBar(context, controller),

                // 加载中状态
                if (controller.isLoading.value)
                  _buildLoadingOverlay(),

                // 错误状态
                if (controller.errorMessage.value.isNotEmpty)
                  _buildErrorOverlay(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建场景图片
  Widget _buildSceneImage(SceneDetailController controller) {
    return Obx(() {
      return Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 3.0,
          child: GestureDetector(
            onTapUp: (details) {
              controller.handleTap(details.localPosition);
            },
            child: Image.asset(
              scene.interactiveImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '图片加载失败',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  /// 构建顶部工具栏
  Widget _buildTopBar(BuildContext context, SceneDetailController controller) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // 返回按钮
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 8),
            // 场景标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    scene.nameEn,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 物品数量
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(() {
                return Text(
                  '${controller.items.length}/${scene.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  /// 构建加载中遮罩
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// 构建错误遮罩
  Widget _buildErrorOverlay(SceneDetailController controller) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
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
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.loadSceneDetail(),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
