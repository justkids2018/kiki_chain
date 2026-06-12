# Hi Kiki - 场景接口API文档（核心）

> 版本：v1.0 | 日期：2026-01-18 | Base URL: `http://127.0.0.1:8080/api`

**重点说明**：本文档是Hi Kiki应用的核心API，包含**双层场景结构**（一级分类 + 二级场景）

---

## 数据结构说明

### 层级关系
```
一级分类（Category）
├─ 春节场景 🎉
│  ├─ 回家（Scene）
│  ├─ 除夕（Scene）
│  ├─ 初一拜年（Scene）
│  ├─ 游园（Scene）
│  └─ 元宵节（Scene）
│
├─ 24节气 🌸
│  ├─ 立春（Scene）
│  ├─ 雨水（Scene）
│  └─ ... (共24个)
│
└─ 日常生活 🏠
   ├─ 上学（Scene）
   ├─ 吃饭（Scene）
   └─ 书房一角（Scene）
```

---

## 1. 获取一级分类列表

### 接口信息
- **URL**: `GET /scene/categories`
- **说明**: 获取所有一级分类（主页展示）
- **需要Token**: 否（未登录也可浏览）

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "total": 4,
    "categories": [
      {
        "id": "cat_001",
        "name": "春节场景",
        "icon": "🎉",
        "coverImage": "https://cdn.example.com/categories/spring_festival.jpg",
        "description": "体验中国传统春节文化",
        "sceneCount": 5,              // 包含的子场景数
        "totalItemCount": 75,         // 该分类下所有物品总数
        "order": 1,                   // 排序权重（越小越靠前）
        "isNew": true,                // 是否新分类
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
        "totalItemCount": 95,
        "order": 4,
        "isNew": false,
        "createdAt": "2026-01-01T00:00:00Z"
      }
    ]
  }
}
```

---

## 2. 获取某分类下的场景列表

### 接口信息
- **URL**: `GET /scene/categories/{categoryId}/scenes`
- **说明**: 获取某一级分类下的所有二级场景（二级页面展示）
- **需要Token**: 否

### 路径参数
- `categoryId`: 一级分类ID

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "category": {
      "id": "cat_001",
      "name": "春节场景",
      "icon": "🎉"
    },
    "total": 5,
    "scenes": [
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
        "isNew": false,
        "createdAt": "2026-01-01T00:00:00Z"
      }
      // ... 其他场景
    ]
  }
}
```

---

## 3. 获取场景详情

### 接口信息
- **URL**: `GET /scene/scenes/{sceneId}`
- **说明**: 获取单个场景的完整信息（进入学习页面时调用）
- **需要Token**: 否

### 路径参数
- `sceneId`: 场景ID

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "scene": {
      "id": "scene_001",
      "categoryId": "cat_001",
      "categoryName": "春节场景",
      "name": "回家（春运）",
      "coverImage": "https://cdn.example.com/scenes/go_home_cover.jpg",
      "interactiveImage": "https://cdn.example.com/scenes/go_home_main.jpg",
      "description": "体验春运回家的场景",
      "itemCount": 15,
      "createdAt": "2026-01-01T00:00:00Z"
    },

    // 互动热区配置（直接返回，无需再请求JSON文件）
    "interactiveItems": [
      {
        "id": "item_001",
        "type": "chinese",
        "index": 1,
        "text": "行李箱",
        "textPinyin": "xíng lǐ xiāng",
        "textEnglish": "Suitcase",
        "coordinates": [
          {"x": 100, "y": 200},
          {"x": 200, "y": 200},
          {"x": 200, "y": 300},
          {"x": 100, "y": 300}
        ]
      },
      {
        "id": "item_002",
        "type": "chinese",
        "index": 2,
        "text": "火车票",
        "textPinyin": "huǒ chē piào",
        "textEnglish": "Train Ticket",
        "coordinates": [
          {"x": 300, "y": 150},
          {"x": 400, "y": 150},
          {"x": 400, "y": 250},
          {"x": 300, "y": 250}
        ]
      }
      // ... 共15个物品
    ],

    // 用户学习进度（仅已登录时返回）
    "userProgress": {
      "learnedItems": ["item_001", "item_003", "item_005"],  // 已学习物品ID列表
      "learnedItemCount": 3,
      "progress": 0.2,
      "studyTime": 300,
      "lastStudyAt": "2026-01-17T10:00:00Z",
      "isFavorited": true
    }
  }
}
```

---

## 4. 搜索场景

### 接口信息
- **URL**: `GET /scene/search`
- **说明**: 搜索场景（按名称搜索）
- **需要Token**: 否

### 请求参数（Query）
```
?keyword=春节&page=1&pageSize=20
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 搜索关键词 |
| page | int | 否 | 页码，默认1 |
| pageSize | int | 否 | 每页数量，默认20 |

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "total": 3,
    "page": 1,
    "pageSize": 20,
    "scenes": [
      {
        "id": "scene_001",
        "categoryName": "春节场景",
        "name": "回家（春运）",
        "coverImage": "https://cdn.example.com/scenes/go_home_cover.jpg",
        "itemCount": 15,
        "matchType": "name"  // 匹配类型：name/description
      },
      {
        "id": "scene_002",
        "categoryName": "春节场景",
        "name": "除夕",
        "coverImage": "https://cdn.example.com/scenes/new_year_eve_cover.jpg",
        "itemCount": 18,
        "matchType": "name"
      }
    ]
  }
}
```

---

## 5. 获取推荐场景

### 接口信息
- **URL**: `GET /scene/recommendations`
- **说明**: 获取推荐场景（基于用户学习记录智能推荐，未登录返回热门场景）
- **需要Token**: 否（未登录返回默认推荐）

### 请求参数（Query）
```
?limit=10
```

### 响应示例（已登录）
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "reason": "根据你的学习记录推荐",
    "scenes": [
      {
        "id": "scene_003",
        "categoryName": "春节场景",
        "name": "初一拜年",
        "coverImage": "https://cdn.example.com/scenes/new_year_visit_cover.jpg",
        "itemCount": 12,
        "recommendReason": "你已经学完了"除夕"，不妨继续了解春节文化"
      }
    ]
  }
}
```

### 响应示例（未登录）
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "reason": "热门场景推荐",
    "scenes": [
      {
        "id": "scene_005",
        "categoryName": "日常生活",
        "name": "上学",
        "coverImage": "https://cdn.example.com/scenes/go_to_school_cover.jpg",
        "itemCount": 15,
        "recommendReason": "最受欢迎的场景"
      }
    ]
  }
}
```

---

## 6. 获取场景统计信息（管理后台用）

### 接口信息
- **URL**: `GET /scene/stats`
- **说明**: 获取场景库的统计信息（总分类数、总场景数、总物品数等）
- **需要Token**: 是（管理员权限）

### 响应示例
```json
{
  "code": 200,
  "message": "成功",
  "data": {
    "totalCategories": 4,
    "totalScenes": 42,
    "totalItems": 530,
    "categoryStats": [
      {
        "categoryId": "cat_001",
        "categoryName": "春节场景",
        "sceneCount": 5,
        "itemCount": 75
      },
      {
        "categoryId": "cat_002",
        "categoryName": "24节气",
        "sceneCount": 24,
        "itemCount": 240
      }
    ]
  }
}
```

---

## 前端集成示例

### 1. 加载主页（一级分类列表）

```dart
class HomeController extends GetxController {
  final categories = <SceneCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final response = await dio.get('/scene/categories');
    final data = response.data['data'];

    categories.value = (data['categories'] as List)
        .map((item) => SceneCategory.fromJson(item))
        .toList();
  }
}
```

### 2. 加载二级场景列表

```dart
class CategoryDetailController extends GetxController {
  final scenes = <Scene>[].obs;

  Future<void> loadScenes(String categoryId) async {
    // Step 1: 加载场景列表（快速展示）
    final response = await dio.get('/scene/categories/$categoryId/scenes');
    final data = response.data['data'];

    scenes.value = (data['scenes'] as List)
        .map((item) => Scene.fromJson(item))
        .toList();

    // Step 2: 如果已登录，异步加载用户进度（UI异步刷新星级）
    if (Get.find<AuthController>().isLoggedIn.value) {
      await _loadUserProgress();
    }
  }

  Future<void> _loadUserProgress() async {
    final sceneIds = scenes.map((s) => s.id).join(',');
    final response = await dio.get('/user/learning-progress?sceneIds=$sceneIds');
    final progressMap = response.data['data']['progress'];

    // 更新每个场景的进度（触发UI刷新）
    for (var scene in scenes) {
      final progress = progressMap[scene.id];
      if (progress != null) {
        scene.updateProgress(
          learnedItems: progress['learnedItems'],
          totalItems: progress['totalItems'],
          starCount: progress['starCount'],
          isFavorited: progress['isFavorited'],
        );
      }
    }
    scenes.refresh(); // 通知UI更新
  }
}
```

### 3. 加载场景详情（学习页面）

```dart
class InteractiveImageController extends GetxController {
  final scene = Rx<Scene?>(null);
  final interactiveItems = <InteractiveItem>[].obs;
  final learnedItemIds = <String>[].obs;

  Future<void> loadScene(String sceneId) async {
    final response = await dio.get('/scene/scenes/$sceneId');
    final data = response.data['data'];

    scene.value = Scene.fromJson(data['scene']);
    interactiveItems.value = (data['interactiveItems'] as List)
        .map((item) => InteractiveItem.fromJson(item))
        .toList();

    // 恢复用户学习进度
    if (data['userProgress'] != null) {
      learnedItemIds.value = List<String>.from(data['userProgress']['learnedItems']);
    }
  }
}
```

---

## 数据库设计建议

### 表结构

#### scene_categories（一级分类表）
```sql
CREATE TABLE scene_categories (
  id VARCHAR(32) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  icon VARCHAR(10),
  cover_image VARCHAR(255),
  description VARCHAR(200),
  `order` INT DEFAULT 0,
  is_new BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### scenes（二级场景表）
```sql
CREATE TABLE scenes (
  id VARCHAR(32) PRIMARY KEY,
  category_id VARCHAR(32) NOT NULL,
  name VARCHAR(50) NOT NULL,
  cover_image VARCHAR(255),
  interactive_image VARCHAR(255),
  description VARCHAR(200),
  item_count INT DEFAULT 0,
  `order` INT DEFAULT 0,
  is_new BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES scene_categories(id)
);
```

#### scene_items（场景物品表）
```sql
CREATE TABLE scene_items (
  id VARCHAR(32) PRIMARY KEY,
  scene_id VARCHAR(32) NOT NULL,
  type VARCHAR(20) DEFAULT 'chinese',
  `index` INT,
  text VARCHAR(50),
  text_pinyin VARCHAR(100),
  text_english VARCHAR(100),
  coordinates JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (scene_id) REFERENCES scenes(id)
);
```

#### user_learning_records（用户学习记录表）
```sql
CREATE TABLE user_learning_records (
  id VARCHAR(32) PRIMARY KEY,
  user_id VARCHAR(32) NOT NULL,
  scene_id VARCHAR(32) NOT NULL,
  learned_items JSON,  -- 存储已学习物品ID数组
  study_time INT DEFAULT 0,
  last_study_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_scene (user_id, scene_id),
  FOREIGN KEY (scene_id) REFERENCES scenes(id)
);
```

---

## 重点注意事项

### 1. 性能优化
- **CDN加速**：所有图片和JSON配置文件使用CDN
- **缓存策略**：一级分类列表可缓存1小时，场景列表缓存30分钟
- **懒加载**：二级场景列表在点击一级分类时再加载
- **预加载**：用户浏览二级列表时，预加载前3个场景的互动大图

### 2. 数据完整性
- 确保每个场景的JSON配置与`itemCount`字段一致
- 坐标数据必须是多边形（至少3个点）
- 所有中英文字段不能为空

### 3. 兼容性
- 支持从本地assets迁移到远程CDN（`interactiveJsonUrl`可为空，前端fallback到本地）
- 用户进度数据支持离线存储+在线同步

---

**这是最核心的API文档，请仔细review数据结构是否完整！**
