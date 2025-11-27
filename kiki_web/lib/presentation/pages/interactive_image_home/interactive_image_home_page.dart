import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'interactive_image_home_controller.dart';

// ==================== Page ====================
// 页面层专注 UI 呈现，所有数据和逻辑在 Controller 中管理

/// 互动图片首页
class InteractiveImageHomePage extends StatelessWidget {
  const InteractiveImageHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InteractiveImageHomeController>(
      init: InteractiveImageHomeController(),
      builder: (controller) {
        return Scaffold(
          // appBar: AppBar(
            // title: const Text('互动图片'),
            // elevation: 0,
          // ),
          body: Column(
            children: [
              // 分类选择器 - 固定在顶部中间
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: _buildCategorySelector(controller),
                ),
              ),
              
              // 图片卡片网格
              Expanded(
                child: _buildImageGrid(controller),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector(InteractiveImageHomeController controller) {
    return Obx(
      () => Wrap(
        spacing: 12,
        alignment: WrapAlignment.center,
        children: [
          for (final category in controller.getCategories())
            _buildCategoryButton(
              category: category,
              isSelected: controller.selectedCategory.value == category,
              onTap: () => controller.selectCategory(category),
            ),
        ],
      ),
    );
  }

  /// 分类按钮
  Widget _buildCategoryButton({
    required ImageCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isSelected ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // 缩放效果：选中时缩小到 0.95，未选中时正常 1.0
        final scale = 1.0 - (value * 0.05);
        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建图片网格 (左右滚动，卡片宽度根据图片宽高比自动调整)
  Widget _buildImageGrid(InteractiveImageHomeController controller) {
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.images.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无图片',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              for (int i = 0; i < controller.images.value.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Transform.scale(
                    scale: 0.8,
                    child: _buildImageCard(
                      image: controller.images.value[i],
                      onTap: () => controller.navigateToImage(controller.images.value[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 图片卡片 (圆角卡片，毛玻璃标题，图片大小一模一样)
  Widget _buildImageCard({
    required ImageItem image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 20,
        shadowColor: Colors.black.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // 图片 (按原始宽高比显示，完整显示，不裁剪)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                image.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            
            // 毛玻璃标题层 (底部)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      image.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
