import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/category_card.dart';
import '../../widgets/app_loading_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../design_ui/kiki_ui_kit.dart';

/// 互动图片首页 - 显示场景分类
class InteractiveImageHomePage extends StatelessWidget {
  const InteractiveImageHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            decoration: KikiUiDecor.pageBackgroundDecor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: _buildFloatingHeader(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: _buildCategoryList(controller),
                  ),
                ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: KikiUiColors.panel.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: KikiUiShadows.floating,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hi Kiki',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: KikiUiColors.brandGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Builder(builder: (context) {
                  final loc = AppLocalizations.of(context)!;
                  return Text(
                    loc.chooseSceneToStart,
                    style: const TextStyle(
                      fontSize: 13,
                      color: KikiUiColors.textSecondary,
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
        return const AppLoadingWidget(message: '加载中...');
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

      // 分类卡片：横向滚动列表，自动适配可用空间
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          // Card aspect ratio: portrait 7:9
          const cardAspectRatio = 7.0 / 9.0;

          // Card height fits in available space (留一些边距)
          double cardHeight = (availableHeight * 0.85).clamp(200.0, 500.0);
          double cardWidth = cardHeight * cardAspectRatio;

          // On wide screens, cap width
          final maxCardWidth = screenWidth * 0.7;
          if (cardWidth > maxCardWidth) {
            cardWidth = maxCardWidth;
            cardHeight = cardWidth / cardAspectRatio;
          }

          return Center(
            child: SizedBox(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25), // 左右边距 25dp
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < controller.categories.length - 1
                          ? 30
                          : 0, // 卡片间距 30dp
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
