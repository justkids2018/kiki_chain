import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/category_card.dart';
import '../../../core/constants/app_constants.dart';

/// 互动图片首页 - 显示场景分类
class InteractiveImageHomePage extends StatelessWidget {
  const InteractiveImageHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8), // 更浅的灰色背景（从EEEEEE改成F8F8F8）
          body: Stack(
            children: [
              // 全屏卡片列表
              _buildCategoryList(controller),
              // 悬浮标题
              SafeArea(
                child: _buildFloatingHeader(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 悬浮毛玻璃标题
  Widget _buildFloatingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3), // 增加不透明度（从0.25改成0.3）
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5), // 增强边框（从0.3改成0.5）
                width: 1.5, // 边框加粗（从1改成1.5）
              ),
              boxShadow: [
                // 添加阴影增强边缘效果
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hi Kiki',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C37D), // 主题绿色
                  ),
                ),
                const SizedBox(width: 8),
                Builder(builder: (context) {
                  final loc = AppLocalizations.of(context)!;
                  return Text(
                    loc.chooseSceneToStart,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280), // 深灰色
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建分类列表
  Widget _buildCategoryList(HomeController controller) {
    return Obx(() {
      // 加载中状态
      if (controller.isLoadingCategories.value) {
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
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshCategories(),
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
      if (controller.categories.isEmpty) {
        return Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noCategories,
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

      // 分类卡片：横向滚动列表，卡片互相挨着
      return LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          // Header height estimate
          final topPadding = MediaQuery.of(context).padding.top;
          final headerHeight = topPadding + 12 + 40 + 32; // top inset + padding + pill + gap below header (增加到32)

          // Bottom margin (增加到32)
          const bottomMargin = 32.0;

          // Available height for cards (between header and bottom)
          final availableHeight = screenHeight - headerHeight - bottomMargin;

          // Card aspect ratio: portrait 7:9
          const cardAspectRatio = 7.0 / 9.0;

          // Card height fits in available space
          double cardHeight = availableHeight;
          double cardWidth = cardHeight * cardAspectRatio;

          // On wide screens, cap width
          final maxCardWidth = screenWidth * 0.75;
          if (cardWidth > maxCardWidth) {
            cardWidth = maxCardWidth;
            cardHeight = cardWidth / cardAspectRatio;
          }

          return Container(
            color: const Color(0xFFF8F8F8), // 与整体背景一致，去掉白色背景
            child: Padding(
              padding: EdgeInsets.only(top: headerHeight, bottom: bottomMargin),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24), // 左右边距增加到24
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < controller.categories.length - 1 ? 20 : 0, // 卡片间距增加到20
                    ),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: CategoryCard(
                        category: category,
                        onTap: () {
                          Get.toNamed(
                            AppConstants.routeSceneList,
                            arguments: category,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    });
  }
}
