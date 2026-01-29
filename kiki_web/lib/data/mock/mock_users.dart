/// Mock 数据 - 用户认证与学习进度
///
/// 对应 API:
/// - POST /auth/register
/// - POST /auth/login
/// - GET /user/profile
/// - GET /user/learning-progress

class MockUsers {
  /// Mock 用户数据库（模拟真实数据库）
  static final List<Map<String, dynamic>> _users = [
    {
      "id": "usr_test_001",
      "phone": "13800138000",
      "password": "test123",  // 实际应该是加密后的密码
      "nickname": "测试用户1",
      "avatar": "https://cdn.example.com/avatars/avatar1.jpg",
      "createdAt": "2026-01-01T00:00:00Z",
      "lastLoginAt": "2026-01-18T10:00:00Z"
    },
    {
      "id": "usr_test_002",
      "phone": "13900139000",
      "password": "test456",
      "nickname": "测试用户2",
      "avatar": "https://cdn.example.com/avatars/avatar2.jpg",
      "createdAt": "2026-01-05T00:00:00Z",
      "lastLoginAt": "2026-01-17T14:00:00Z"
    }
  ];

  /// Mock 学习记录数据库
  static final Map<String, List<Map<String, dynamic>>> _learningRecords = {
    "usr_test_001": [
      {
        "sceneId": "scene_002",
        "learnedItems": ["scene_002_item_001", "scene_002_item_002"],
        "totalItems": 18,
        "progress": 0.67,
        "starCount": 2,
        "studyTime": 600,
        "lastStudyAt": "2026-01-18T10:00:00Z",
        "isFavorited": true
      },
      {
        "sceneId": "scene_101",
        "learnedItems": ["scene_101_item_001"],
        "totalItems": 15,
        "progress": 0.33,
        "starCount": 1,
        "studyTime": 300,
        "lastStudyAt": "2026-01-17T14:00:00Z",
        "isFavorited": false
      }
    ],
    "usr_test_002": []
  };

  /// 注册新用户（模拟 API: POST /auth/register）
  static Map<String, dynamic> registerResponse(
      String phone, String password, String nickname) {
    // 检查手机号是否已存在
    final exists = _users.any((u) => u['phone'] == phone);
    if (exists) {
      return {
        "code": 400,
        "message": "手机号已注册",
        "data": null
      };
    }

    // 创建新用户
    final newUser = {
      "id": "usr_${DateTime.now().millisecondsSinceEpoch}",
      "phone": phone,
      "password": password,
      "nickname": nickname,
      "avatar": null,
      "createdAt": DateTime.now().toIso8601String(),
      "lastLoginAt": DateTime.now().toIso8601String(),
    };

    _users.add(newUser);
    _learningRecords[newUser['id']!] = [];

    return {
      "code": 200,
      "message": "注册成功",
      "data": {
        "user": {
          "id": newUser['id'],
          "phone": newUser['phone'],
          "nickname": newUser['nickname'],
          "avatar": newUser['avatar'],
        },
        "token": "mock_token_${newUser['id']}",
        "expiresAt": DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String(),
      }
    };
  }

  /// 用户登录（模拟 API: POST /auth/login）
  static Map<String, dynamic> loginResponse(String phone, String password) {
    // 查找用户
    final user = _users.firstWhere(
      (u) => u['phone'] == phone && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      return {
        "code": 401,
        "message": "手机号或密码错误",
        "data": null
      };
    }

    // 更新最后登录时间
    user['lastLoginAt'] = DateTime.now().toIso8601String();

    return {
      "code": 200,
      "message": "登录成功",
      "data": {
        "user": {
          "id": user['id'],
          "phone": user['phone'],
          "nickname": user['nickname'],
          "avatar": user['avatar'],
        },
        "token": "mock_token_${user['id']}",
        "expiresAt": DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String(),
      }
    };
  }

  /// 获取用户信息（模拟 API: GET /user/profile）
  static Map<String, dynamic> getUserProfileResponse(String userId) {
    final user = _users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {},
    );

    if (user.isEmpty) {
      return {
        "code": 404,
        "message": "用户不存在",
        "data": null
      };
    }

    // 统计学习数据
    final records = _learningRecords[userId] ?? [];
    final learnedScenes =
        records.where((r) => r['progress'] >= 0.9).length;
    final totalStudyTime =
        records.fold(0, (sum, r) => sum + (r['studyTime'] as int));
    final favoriteScenes =
        records.where((r) => r['isFavorited'] == true).length;

    return {
      "code": 200,
      "message": "成功",
      "data": {
        "user": {
          "id": user['id'],
          "phone": user['phone'],
          "nickname": user['nickname'],
          "avatar": user['avatar'],
          "createdAt": user['createdAt'],
          "lastLoginAt": user['lastLoginAt'],
        },
        "stats": {
          "totalScenes": 50,
          "learnedScenes": learnedScenes,
          "totalStudyTime": totalStudyTime,
          "favoriteScenes": favoriteScenes,
          "continuousDays": 7,
        }
      }
    };
  }

  /// 批量获取用户学习进度（模拟 API: GET /user/learning-progress）
  static Map<String, dynamic> getUserLearningProgressResponse(
      String userId, List<String> sceneIds) {
    final records = _learningRecords[userId] ?? [];

    final progressMap = <String, dynamic>{};

    for (var sceneId in sceneIds) {
      final record = records.firstWhere(
        (r) => r['sceneId'] == sceneId,
        orElse: () => {},
      );

      if (record.isNotEmpty) {
        progressMap[sceneId] = {
          "learnedItems": (record['learnedItems'] as List).length,
          "totalItems": record['totalItems'],
          "progress": record['progress'],
          "starCount": record['starCount'],
          "studyTime": record['studyTime'],
          "lastStudyAt": record['lastStudyAt'],
          "isFavorited": record['isFavorited'],
        };
      } else {
        progressMap[sceneId] = null;
      }
    }

    return {
      "code": 200,
      "message": "成功",
      "data": {
        "progress": progressMap,
      }
    };
  }

  /// 提交学习记录（模拟 API: POST /user/learning-records）
  static Map<String, dynamic> submitLearningRecordResponse(
      String userId, String sceneId, List<String> learnedItems, int studyTime) {
    final records = _learningRecords[userId] ?? [];

    // 查找已有记录
    final existingIndex =
        records.indexWhere((r) => r['sceneId'] == sceneId);

    if (existingIndex >= 0) {
      // 更新已有记录
      final existing = records[existingIndex];
      final allLearnedItems = Set<String>.from(existing['learnedItems'] as List)
        ..addAll(learnedItems);

      records[existingIndex] = {
        ...existing,
        "learnedItems": allLearnedItems.toList(),
        "progress": allLearnedItems.length / (existing['totalItems'] as int),
        "starCount": _calculateStarCount(
            allLearnedItems.length, existing['totalItems'] as int),
        "studyTime": (existing['studyTime'] as int) + studyTime,
        "lastStudyAt": DateTime.now().toIso8601String(),
      };
    } else {
      // 创建新记录（假设总物品数为 15）
      const totalItems = 15;
      records.add({
        "sceneId": sceneId,
        "learnedItems": learnedItems,
        "totalItems": totalItems,
        "progress": learnedItems.length / totalItems,
        "starCount": _calculateStarCount(learnedItems.length, totalItems),
        "studyTime": studyTime,
        "lastStudyAt": DateTime.now().toIso8601String(),
        "isFavorited": false,
      });
    }

    return {
      "code": 200,
      "message": "学习记录已保存",
      "data": {
        "sceneId": sceneId,
        "learnedItems": learnedItems.length,
      }
    };
  }

  /// 计算星级（辅助方法）
  static int _calculateStarCount(int learnedItems, int totalItems) {
    final progress = learnedItems / totalItems;
    if (progress >= 0.9) return 3;
    if (progress >= 0.6) return 2;
    if (progress >= 0.3) return 1;
    return 0;
  }

  /// 收藏/取消收藏场景（模拟 API: POST /user/favorites/{sceneId}）
  static Map<String, dynamic> toggleFavoriteResponse(
      String userId, String sceneId) {
    final records = _learningRecords[userId] ?? [];

    final recordIndex =
        records.indexWhere((r) => r['sceneId'] == sceneId);

    if (recordIndex >= 0) {
      final isFavorited = !(records[recordIndex]['isFavorited'] as bool);
      records[recordIndex]['isFavorited'] = isFavorited;

      return {
        "code": 200,
        "message": isFavorited ? "收藏成功" : "已取消收藏",
        "data": {
          "sceneId": sceneId,
          "isFavorited": isFavorited,
        }
      };
    }

    // 如果记录不存在，创建新记录并收藏
    records.add({
      "sceneId": sceneId,
      "learnedItems": [],
      "totalItems": 15,
      "progress": 0.0,
      "starCount": 0,
      "studyTime": 0,
      "lastStudyAt": null,
      "isFavorited": true,
    });

    return {
      "code": 200,
      "message": "收藏成功",
      "data": {
        "sceneId": sceneId,
        "isFavorited": true,
      }
    };
  }
}
