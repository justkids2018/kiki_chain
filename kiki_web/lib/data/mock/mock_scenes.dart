/// Mock 数据 - 二级场景
///
/// 对应 API: GET /scene/categories/{categoryId}/scenes
/// 提供各分类下的具体场景

class MockScenes {
  /// 春节场景（cat_001）
  static final List<Map<String, dynamic>> springFestivalScenes = [
    {
      "id": "scene_001",
      "categoryId": "cat_001",
      "name": "回家（春运）",
      "coverImage": "https://cdn.example.com/scenes/go_home_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/go_home_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/go_home.json",
      "description": "体验春运回家的场景",
      "itemCount": 15,
      "order": 1,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "scene_002",
      "categoryId": "cat_001",
      "name": "除夕",
      "coverImage": "https://cdn.example.com/scenes/new_year_eve_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/new_year_eve_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/new_year_eve.json",
      "description": "团圆的除夕夜",
      "itemCount": 18,
      "order": 2,
      "isNew": true,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "scene_003",
      "categoryId": "cat_001",
      "name": "初一拜年",
      "coverImage": "https://cdn.example.com/scenes/new_year_visit_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/new_year_visit_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/new_year_visit.json",
      "description": "新年拜年习俗",
      "itemCount": 12,
      "order": 3,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "scene_004",
      "categoryId": "cat_001",
      "name": "游园（庙会）",
      "coverImage": "https://cdn.example.com/scenes/temple_fair_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/temple_fair_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/temple_fair.json",
      "description": "热闹的春节庙会",
      "itemCount": 20,
      "order": 4,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "scene_005",
      "categoryId": "cat_001",
      "name": "元宵节",
      "coverImage": "https://cdn.example.com/scenes/lantern_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/lantern_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/lantern.json",
      "description": "元宵节赏灯猜谜",
      "itemCount": 15,
      "order": 5,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    }
  ];

  /// 日常生活场景（cat_003）
  static final List<Map<String, dynamic>> dailyLifeScenes = [
    {
      "id": "scene_101",
      "categoryId": "cat_003",
      "name": "上学",
      "coverImage": "https://cdn.example.com/scenes/go_to_school_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/go_to_school_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/go_to_school.json",
      "description": "上学路上的场景",
      "itemCount": 15,
      "order": 1,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "scene_102",
      "categoryId": "cat_003",
      "name": "吃饭",
      "coverImage": "https://cdn.example.com/scenes/dining_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/dining_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/dining.json",
      "description": "用餐时间",
      "itemCount": 12,
      "order": 2,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    },
    {
      "id": "scene_103",
      "categoryId": "cat_003",
      "name": "书房一角",
      "coverImage": "https://cdn.example.com/scenes/study_room_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/study_room_main.jpg",
      "interactiveJsonUrl": "https://cdn.example.com/configs/study_room.json",
      "description": "学习空间",
      "itemCount": 10,
      "order": 3,
      "isNew": false,
      "createdAt": "2026-01-01T00:00:00Z"
    }
  ];

  /// 所有场景的映射（用于快速查找）
  static final Map<String, List<Map<String, dynamic>>> scenesByCategoryId = {
    "cat_001": springFestivalScenes,
    "cat_003": dailyLifeScenes,
    // 24节气和游乐场景暂时为空，后续添加
    "cat_002": [],
    "cat_004": [],
  };

  /// 获取某分类下的场景列表（模拟 API 响应）
  static Map<String, dynamic> getScenesByCategoryResponse(String categoryId) {
    final scenes = scenesByCategoryId[categoryId] ?? [];

    return {
      "code": 200,
      "message": "成功",
      "data": {
        "category": {
          "id": categoryId,
          "name": _getCategoryName(categoryId),
        },
        "total": scenes.length,
        "scenes": scenes,
      }
    };
  }

  /// 根据场景 ID 获取场景详情（模拟 API 响应）
  static Map<String, dynamic>? getSceneDetailResponse(String sceneId) {
    // 在所有场景中查找
    Map<String, dynamic>? foundScene;

    for (var scenes in scenesByCategoryId.values) {
      try {
        foundScene = scenes.firstWhere((s) => s['id'] == sceneId);
        break;
      } catch (e) {
        continue;
      }
    }

    if (foundScene == null) {
      return {
        "code": 404,
        "message": "场景不存在",
        "data": null
      };
    }

    return {
      "code": 200,
      "message": "成功",
      "data": {
        "scene": foundScene,
        "interactiveItems": _getMockInteractiveItems(sceneId),
        // userProgress 在已登录时才返回，这里暂时为 null
        "userProgress": null,
      }
    };
  }

  /// 获取分类名称（辅助方法）
  static String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case "cat_001":
        return "春节场景";
      case "cat_002":
        return "24节气";
      case "cat_003":
        return "日常生活";
      case "cat_004":
        return "游乐场景";
      default:
        return "未知分类";
    }
  }

  /// 获取 Mock 互动物品（简化版）
  static List<Map<String, dynamic>> _getMockInteractiveItems(String sceneId) {
    // 返回简化的互动物品数据（实际应该从 assets 或后端加载）
    return [
      {
        "id": "${sceneId}_item_001",
        "type": "chinese",
        "index": 1,
        "text": "示例物品1",
        "textPinyin": "shì lì wù pǐn 1",
        "textEnglish": "Sample Item 1",
        "coordinates": [
          {"x": 100, "y": 200},
          {"x": 200, "y": 200},
          {"x": 200, "y": 300},
          {"x": 100, "y": 300}
        ]
      },
      {
        "id": "${sceneId}_item_002",
        "type": "chinese",
        "index": 2,
        "text": "示例物品2",
        "textPinyin": "shì lì wù pǐn 2",
        "textEnglish": "Sample Item 2",
        "coordinates": [
          {"x": 300, "y": 150},
          {"x": 400, "y": 150},
          {"x": 400, "y": 250},
          {"x": 300, "y": 250}
        ]
      }
    ];
  }
}
