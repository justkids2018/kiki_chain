/// Mock 数据 - 一级分类（场景分类）
///
/// 对应 API: GET /scene/categories
/// 提供 4 个一级分类：春节场景、24节气、日常生活、游乐场景

class MockCategories {
  static final List<Map<String, dynamic>> categories = [
    {
      "id": "cat_001",
      "name": "春节场景",
      "icon": "🎉",
      "coverImage": "https://cdn.example.com/categories/spring_festival.jpg",
      "description": "体验中国传统春节文化",
      "sceneCount": 5,
      "totalItemCount": 80,
      "order": 1,
      "isNew": true,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "cat_002",
      "name": "24节气",
      "icon": "🌸",
      "coverImage": "https://cdn.example.com/categories/solar_terms.jpg",
      "description": "认识24个传统节气",
      "sceneCount": 24,
      "totalItemCount": 240,
      "order": 2,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "cat_003",
      "name": "日常生活",
      "icon": "🏠",
      "coverImage": "https://cdn.example.com/categories/daily_life.jpg",
      "description": "贴近生活的日常场景",
      "sceneCount": 8,
      "totalItemCount": 120,
      "order": 3,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "cat_004",
      "name": "游乐场景",
      "icon": "🎢",
      "coverImage": "https://cdn.example.com/categories/amusement.jpg",
      "description": "探索有趣的游乐世界",
      "sceneCount": 5,
      "totalItemCount": 75,
      "order": 4,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    }
  ];

  /// 获取所有分类（模拟 API 响应）
  static Map<String, dynamic> getCategoriesResponse() {
    return {
      "code": 200,
      "message": "成功",
      "data": {
        "total": categories.length,
        "categories": categories,
      }
    };
  }

  /// 根据 ID 获取单个分类
  static Map<String, dynamic>? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat['id'] == categoryId);
    } catch (e) {
      return null;
    }
  }
}
