import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kikichain/core/constants/app_constants.dart';
import 'package:kikichain/data/models/image_item.dart';

// ==================== Controller ====================

class InteractiveImageHomeController extends GetxController {
  // ========== 数据 ==========

  /// 所有图片数据
  static List<ImageItem> _getAllImages() {
    return [
      // 物资分类 (kiki_zhiwuyuan.json)
      ImageItem(
        id: 'child_0',
        title: '玩具',
        imagePath: 'assets/images/toy/kiki_toy.png',
        category: ImageCategory.child,
        description: '丰富的儿童玩具和设施',
        jsonFile: 'assets/data/toy/kiki_toy.json',
      ),
      ImageItem(
        id: 'child_1',
        title: '动物园',
        imagePath: 'assets/images/kiki_dongwuyuan.jpg',
        category: ImageCategory.child,
        description: '动物园',
        jsonFile: 'assets/data/kiki_dongwuyuan.json',
      ),
      // 生活分类 (kiki_dongwuyuan.json)
      ImageItem(
        id: 'life_1',
        title: '植物园',
        imagePath: 'assets/images/kiki_zhiwuyuan.jpg',
        category: ImageCategory.life,
        description: '丰富的植物种类',
        jsonFile: 'assets/data/kiki_dongwuyuan.json',
      ),
      // 动物分类 (kiki_dongwuyuan.json)
    ];
  }

  // ========== 状态 ==========
  late final Rx<ImageCategory?> selectedCategory;

  // 当前分类的图片列表
  late final Rx<List<ImageItem>> images;

  // 加载状态
  final Rx<bool> isLoading = Rx<bool>(false);

  @override
  void onInit() {
    super.onInit();
    // 初始化响应式变量
    selectedCategory = Rx<ImageCategory?>(ImageCategory.teacher);
    images = Rx<List<ImageItem>>([]);

    // 加载默认分类的图片
    _loadImagesByCategory(ImageCategory.teacher);
  }

  /// 加载指定分类的图片
  void selectCategory(ImageCategory category) {
    selectedCategory.value = category;
    _loadImagesByCategory(category);
  }

  /// 从数据源加载图片
  void _loadImagesByCategory(ImageCategory category) {
    try {
      isLoading.value = true;
      final items =
          _getAllImages().where((item) => item.category == category).toList();
      images.value = items;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading images: $e');
      }
      images.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// 导航到图片详情页，传递 JSON 文件信息
  void navigateToImage(ImageItem imageItem) {
    Get.toNamed(
      AppConstants.routeInteractiveImage,
      arguments: {
        'imageItem': imageItem,
        'jsonFile': imageItem.jsonFile, // 传递对应的 JSON 文件路径
        'images': images.value,
      },
    );
  }

  /// 获取所有分类
  List<ImageCategory> getCategories() {
    return ImageCategory.values;
  }
}
