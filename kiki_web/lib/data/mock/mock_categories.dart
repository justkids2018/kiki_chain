import '../../domain/entities/scene_category.dart';

/// Mock数据 - 场景分类
///
/// 包含5个一级分类的Mock数据
/// 对应场景结构定义文档中的分类
class MockCategories {
  static final List<SceneCategory> categories = [
    SceneCategory(
      id: 'category_daily_life',
      name: '日常生活',
      icon: '🏠',
      coverImage: 'assets/images/categories/daily_life_cover.jpg',
      description: '学习日常生活中的常见物品和场景',
      sceneCount: 6,
      totalItemCount: 72,
      order: 1,
      isNew: false,
      createdAt: DateTime(2026, 1, 28),
    ),
    SceneCategory(
      id: 'category_playground',
      name: '游乐场景',
      icon: '🎡',
      coverImage: 'assets/images/categories/playground_cover.jpg',
      description: '探索游乐园、动物园、海洋馆等有趣场所',
      sceneCount: 3,
      totalItemCount: 36,
      order: 2,
      isNew: false,
      createdAt: DateTime(2026, 1, 28),
    ),
    SceneCategory(
      id: 'category_numbers',
      name: '数字认知',
      icon: '🔢',
      coverImage: 'assets/images/categories/numbers_cover.jpg',
      description: '认识数字0-9，学习数字的中英文读写',
      sceneCount: 1,
      totalItemCount: 10,
      order: 3,
      isNew: true,
      createdAt: DateTime(2026, 1, 28),
    ),
    SceneCategory(
      id: 'category_letters',
      name: '字母认知',
      icon: '🔤',
      coverImage: 'assets/images/categories/letters_cover.jpg',
      description: '学习英文字母A-Z，掌握字母发音和书写',
      sceneCount: 2,
      totalItemCount: 24,
      order: 4,
      isNew: true,
      createdAt: DateTime(2026, 1, 28),
    ),
    SceneCategory(
      id: 'category_traditional_festivals',
      name: '传统节日',
      icon: '🏮',
      coverImage: 'assets/images/categories/traditional_festivals_cover.jpg',
      description: '体验中国传统节日，学习春节、端午节和二十四节气',
      sceneCount: 3,
      totalItemCount: 36,
      order: 5,
      isNew: true,
      createdAt: DateTime(2026, 1, 28),
    ),
  ];

  /// 获取所有分类（模拟 API 响应）
  static Map<String, dynamic> getCategoriesResponse() {
    return {
      "code": 200,
      "message": "成功",
      "data": {
        "total": categories.length,
        "categories": categories.map((cat) => cat.toJson()).toList(),
      }
    };
  }

  /// 根据ID获取分类
  static SceneCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有分类
  static List<SceneCategory> getAllCategories() {
    return List.from(categories);
  }

  /// 获取分类数量
  static int getCategoryCount() {
    return categories.length;
  }
}
