# Hi Kiki - 用户接口API文档

> 版本：v1.0 | 日期：2026-01-18 | Base URL: `http://127.0.0.1:8080/api`

---

## 1. 获取用户信息

### 接口信息
- **URL**: `GET /user/profile`
- **说明**: 获取当前登录用户的详细信息
- **需要Token**: 是

### 请求头
```
Authorization: Bearer {token}
```

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "user": {
      "id": "usr_1a2b3c4d",
      "phone": "13800138000",
      "nickname": "小明",
      "avatar": "https://cdn.example.com/avatars/user1.jpg",
      "createdAt": "2026-01-18T10:30:00Z",
      "lastLoginAt": "2026-01-18T12:00:00Z"
    },
    "stats": {
      "totalScenes": 50,              // 场景总数
      "learnedScenes": 12,            // 已学习场景数
      "totalStudyTime": 7200,         // 总学习时长（秒）
      "favoriteScenes": 5,            // 收藏场景数
      "continuousDays": 7             // 连续学习天数
    }
  }
}
```

---

## 2. 更新用户信息

### 接口信息
- **URL**: `PUT /user/profile`
- **说明**: 更新用户昵称和头像
- **需要Token**: 是

### 请求参数
```json
{
  "nickname": "新昵称",  // 可选，2-20字符
  "avatar": "https://cdn.example.com/avatars/new.jpg"  // 可选，头像URL
}
```

### 响应示例
```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "user": {
      "id": "usr_1a2b3c4d",
      "phone": "13800138000",
      "nickname": "新昵称",
      "avatar": "https://cdn.example.com/avatars/new.jpg",
      "createdAt": "2026-01-18T10:30:00Z",
      "lastLoginAt": "2026-01-18T12:00:00Z"
    }
  }
}
```

---

## 3. 批量获取用户进度（重要！新增）⭐

### 接口信息
- **URL**: `GET /user/learning-progress`
- **说明**: 批量获取多个场景的用户学习进度（用于场景列表页异步加载星级）
- **需要Token**: 是

### 请求参数（Query）
```
?sceneIds=scene_001,scene_002,scene_003
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sceneIds | string | 是 | 场景ID列表，逗号分隔，最多50个 |

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "progress": {
      "scene_001": {
        "learnedItems": 10,
        "totalItems": 15,
        "progress": 0.67,
        "starCount": 2,
        "studyTime": 600,
        "lastStudyAt": "2026-01-17T10:00:00Z",
        "isFavorited": true
      },
      "scene_002": {
        "learnedItems": 18,
        "totalItems": 18,
        "progress": 1.0,
        "starCount": 3,
        "studyTime": 900,
        "lastStudyAt": "2026-01-16T14:00:00Z",
        "isFavorited": false
      },
      "scene_003": null  // 该场景未学习过
    }
  }
}
```

### 前端使用示例
```dart
// Step 1: 加载场景列表（快速展示）
final scenesResponse = await dio.get('/scene/categories/cat_001/scenes');
scenes.value = parseScenesFromResponse(scenesResponse);

// Step 2: 如果已登录，异步加载用户进度
if (AuthService.isLoggedIn) {
  final sceneIds = scenes.map((s) => s.id).join(',');
  final progressResponse = await dio.get('/user/learning-progress?sceneIds=$sceneIds');

  // 更新场景的进度数据（UI自动刷新星级）
  final progressMap = progressResponse.data['data']['progress'];
  for (var scene in scenes) {
    scene.userProgress = progressMap[scene.id];
  }
}
```

---

## 4. 获取学习记录列表

### 接口信息
- **URL**: `GET /user/learning-records`
- **说明**: 获取用户的学习记录列表（「我的」→「学习记录」页面使用）
- **需要Token**: 是

### 请求参数（Query）
```
?page=1&pageSize=20&sortBy=lastStudyAt&order=desc
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认1 |
| pageSize | int | 否 | 每页数量，默认20 |
| sortBy | string | 否 | 排序字段：`lastStudyAt`/`progress`，默认`lastStudyAt` |
| order | string | 否 | 排序方向：`asc`/`desc`，默认`desc` |

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "total": 12,
    "page": 1,
    "pageSize": 20,
    "records": [
      {
        "sceneId": "scene_daily_001",
        "sceneName": "上学",
        "categoryName": "日常生活",
        "coverImage": "https://cdn.example.com/covers/go_to_school.jpg",
        "totalItems": 15,
        "learnedItems": 12,
        "progress": 0.8,              // 完成度 0-1
        "studyTime": 600,             // 学习时长（秒）
        "lastStudyAt": "2026-01-18T10:00:00Z",
        "starCount": 2                // 星级 0-3
      },
      {
        "sceneId": "scene_festival_002",
        "sceneName": "除夕",
        "categoryName": "春节场景",
        "coverImage": "https://cdn.example.com/covers/new_year_eve.jpg",
        "totalItems": 18,
        "learnedItems": 18,
        "progress": 1.0,
        "studyTime": 900,
        "lastStudyAt": "2026-01-17T14:00:00Z",
        "starCount": 3
      }
    ]
  }
}
```

---

## 4. 更新学习记录

### 接口信息
- **URL**: `POST /user/learning-records`
- **说明**: 记录用户学习某个场景的进度（每次退出场景时调用）
- **需要Token**: 是

### 请求参数
```json
{
  "sceneId": "scene_daily_001",
  "learnedItems": [                  // 已学习的物品ID列表
    "item_001",
    "item_002",
    "item_003"
  ],
  "studyTime": 120                   // 本次学习时长（秒）
}
```

### 响应示例
```json
{
  "code": 200,
  "message": "学习记录已保存",
  "data": {
    "sceneId": "scene_daily_001",
    "totalItems": 15,
    "learnedItems": 3,
    "progress": 0.2,
    "studyTime": 120,
    "lastStudyAt": "2026-01-18T12:00:00Z"
  }
}
```

---

## 5. 获取我的收藏

### 接口信息
- **URL**: `GET /user/favorites`
- **说明**: 获取用户收藏的场景列表
- **需要Token**: 是

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "total": 5,
    "scenes": [
      {
        "sceneId": "scene_daily_001",
        "sceneName": "上学",
        "categoryName": "日常生活",
        "coverImage": "https://cdn.example.com/covers/go_to_school.jpg",
        "itemCount": 15,
        "favoritedAt": "2026-01-17T10:00:00Z"
      },
      {
        "sceneId": "scene_festival_005",
        "sceneName": "元宵节",
        "categoryName": "春节场景",
        "coverImage": "https://cdn.example.com/covers/lantern.jpg",
        "itemCount": 15,
        "favoritedAt": "2026-01-16T14:00:00Z"
      }
    ]
  }
}
```

---

## 6. 收藏/取消收藏场景

### 接口信息
- **URL**: `POST /user/favorites/{sceneId}`
- **说明**: 收藏或取消收藏某个场景（Toggle操作）
- **需要Token**: 是

### 路径参数
- `sceneId`: 场景ID

### 响应示例（收藏）
```json
{
  "code": 200,
  "message": "收藏成功",
  "data": {
    "sceneId": "scene_daily_001",
    "isFavorited": true
  }
}
```

### 响应示例（取消收藏）
```json
{
  "code": 200,
  "message": "已取消收藏",
  "data": {
    "sceneId": "scene_daily_001",
    "isFavorited": false
  }
}
```

---

## 7. 游客数据迁移

### 接口信息
- **URL**: `POST /user/migrate-guest-data`
- **说明**: 将游客模式下的学习记录绑定到登录账号
- **需要Token**: 是

### 请求参数
```json
{
  "guestId": "guest_abc123",       // 游客ID（前端生成的UUID）
  "learningRecords": [
    {
      "sceneId": "scene_daily_001",
      "learnedItems": ["item_001", "item_002"],
      "studyTime": 300
    },
    {
      "sceneId": "scene_festival_002",
      "learnedItems": ["item_001", "item_002", "item_003"],
      "studyTime": 450
    }
  ],
  "favorites": ["scene_daily_001", "scene_festival_005"]
}
```

### 响应示例
```json
{
  "code": 200,
  "message": "数据迁移成功",
  "data": {
    "migratedRecords": 2,
    "migratedFavorites": 2
  }
}
```

---

## 8. 获取学习日历

### 接口信息
- **URL**: `GET /user/learning-calendar`
- **说明**: 获取用户的学习日历（用于展示连续打卡）
- **需要Token**: 是

### 请求参数（Query）
```
?year=2026&month=1
```

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "year": 2026,
    "month": 1,
    "days": [
      {
        "date": "2026-01-12",
        "hasStudy": true,
        "studyTime": 600,
        "scenesCount": 3
      },
      {
        "date": "2026-01-13",
        "hasStudy": true,
        "studyTime": 450,
        "scenesCount": 2
      },
      {
        "date": "2026-01-14",
        "hasStudy": false,
        "studyTime": 0,
        "scenesCount": 0
      }
    ],
    "continuousDays": 7,            // 连续学习天数
    "totalStudyDays": 12            // 本月学习天数
  }
}
```

---

## 前端集成示例

### 提交学习记录
```dart
class LearningService {
  final Dio _dio;

  Future<void> submitLearningRecord({
    required String sceneId,
    required List<String> learnedItems,
    required int studyTime,
  }) async {
    await _dio.post('/user/learning-records', data: {
      'sceneId': sceneId,
      'learnedItems': learnedItems,
      'studyTime': studyTime,
    });
  }
}

// 使用示例：退出场景时调用
await learningService.submitLearningRecord(
  sceneId: 'scene_daily_001',
  learnedItems: controller.learnedItemIds,
  studyTime: controller.studyDuration.inSeconds,
);
```

### 收藏场景
```dart
Future<void> toggleFavorite(String sceneId) async {
  final response = await _dio.post('/user/favorites/$sceneId');
  final isFavorited = response.data['data']['isFavorited'];

  if (isFavorited) {
    EasyLoading.showSuccess('收藏成功');
  } else {
    EasyLoading.showInfo('已取消收藏');
  }
}
```

---

**后端实现要点**：
- 学习记录使用增量更新（合并已学习物品列表）
- 学习时长累加计算
- 学习日历按天聚合统计
- 收藏使用Toggle机制（简化前端逻辑）
