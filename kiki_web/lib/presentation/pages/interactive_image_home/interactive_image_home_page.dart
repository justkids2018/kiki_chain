import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/category_card.dart';
import '../scene_list_page.dart';

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
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return CategoryCard(
            category: category,
            onTap: () {
              // 导航到场景列表页
              Get.to(
                () => SceneListPage(category: category),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
          );
        },
      );
    });
  }
}
