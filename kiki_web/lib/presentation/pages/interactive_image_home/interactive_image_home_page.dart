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
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部标题区域
                _buildHeader(),

                // 分类卡片横向滚动列表
                Expanded(
                  child: _buildCategoryList(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建顶部标题
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hi Kiki',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final localizations = AppLocalizations.of(context)!;
              return Text(
                localizations.chooseSceneToStart,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF00C37D),
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
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

      // 分类卡片横向滚动列表
      return LayoutBuilder(
        builder: (context, constraints) {
          // 计算卡片居中显示的垂直padding
          final screenHeight = constraints.maxHeight;
          final cardHeight = 440.0;
          final verticalPadding = (screenHeight - cardHeight) / 2;
          final safePadding = verticalPadding.clamp(20.0, 80.0);

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: safePadding,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < controller.categories.length - 1 ? 20 : 0,
                ),
                child: CategoryCard(
                  category: category,
                  onTap: () {
                    // 导航到场景列表页
                    Get.toNamed(
                      AppConstants.routeSceneList,
                      arguments: category,
                    );
                  },
                ),
              );
            },
          );
        },
      );
    });
  }
}
