import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/category_card.dart';
import '../../widgets/app_loading_widget.dart';
import '../../widgets/animated_svg/animated_svg.dart';
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
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(15, 20, 10, 20),
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 60, // 向上移动分类列表（配合顶栏上移），使卡片整体上浮并减少中部空白空间
                    child: _buildCategoryList(controller),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          final isPhone = screenWidth < 700;

          // Card aspect ratio: portrait 7:9
          const cardAspectRatio = 7.0 / 9.0;

          // Make cards larger, especially on phone.
          double cardHeight =
              (availableHeight * (isPhone ? 0.93 : 0.88)).clamp(230.0, 540.0);
          cardHeight = (cardHeight - 10.0).clamp(220.0, 530.0);
          double cardWidth = cardHeight * cardAspectRatio;

          // On wide screens, cap width
          final maxCardWidth = screenWidth * 0.7;
          if (cardWidth > maxCardWidth) {
            cardWidth = maxCardWidth;
            cardHeight = cardWidth / cardAspectRatio;
          }

          return Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < controller.categories.length - 1
                          ? (isPhone ? 22 : 28)
                          : 0,
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
