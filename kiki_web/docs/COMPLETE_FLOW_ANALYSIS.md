# Kiki 漫游 - 完整交互流程分析

## 📋 目录
1. [产品架构概览](#产品架构概览)
2. [完整交互流程](#完整交互流程)
3. [数据模型分析](#数据模型分析)
4. [Mock 数据方案](#mock-数据方案)
5. [实施建议](#实施建议)

---

## 产品架构概览

### 核心概念层级

```
分类 (Category)
  └── 场景 (Scene)
        └── 物品 (SceneItem)
              └── 互动图片 (InteractiveImage)
```

### 页面结构

```
HomePage (底部导航)
  ├── Tab 1: InteractiveImageHomePage (首页 - 显示分类)
  └── Tab 2: ProfileTab (个人中心)
```

---

## 完整交互流程

### 流程图

```
┌─────────────────────────────────────────────────────────────┐
│                         用户启动应用                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  HomePage                                                    │
│  ├── Tab 1: InteractiveImageHomePage (默认)                 │
│  └── Tab 2: ProfileTab                                      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  InteractiveImageHomePage                                    │
│  显示：横向滚动的分类卡片 (CategoryCard)                      │
│  数据：List<SceneCategory>                                   │
│  - 日常生活 🏠                                               │
│  - 游乐场景 🎡                                               │
│  - 数字认知 🔢                                               │
│  - 字母认知 🔤                                               │
│  - 传统节日 🏮                                               │
└─────────────────────────────────────────────────────────────┘
                              ↓ 点击分类卡片
┌─────────────────────────────────────────────────────────────┐
│  SceneListPage                                               │
│  显示：该分类下的所有场景 (SceneCard)                         │
│  数据：List<Scene>                                           │
│  路由：Get.toNamed(routeSceneList, arguments: category)      │
│  示例场景：                                                   │
│  - 早餐时间                                                   │
│  - 准备上学                                                   │
│  - 帮妈妈做饭                                                 │
│  - 看电视时间                                                 │
│  - 睡前准备                                                   │
│  - 周末打扫房间                                               │
└─────────────────────────────────────────────────────────────┘
                              ↓ 点击场景卡片
┌─────────────────────────────────────────────────────────────┐
│  SceneDetailPage                                             │
│  显示：场景的互动图片 + 可点击热点                            │
│  数据：Scene + List<SceneItem>                               │
│  路由：Get.toNamed(routeSceneDetail, arguments: scene)       │
│  功能：                                                       │
│  - 显示场景背景图 (interactiveImage)                         │
│  - 检测用户点击热点区域 (hotspot)                            │
│  - 显示物品数量 (12/12)                                      │
└─────────────────────────────────────────────────────────────┘
                              ↓ 点击热点区域
┌─────────────────────────────────────────────────────────────┐
│  物品信息对话框 (Dialog)                                      │
│  显示：                                                       │
│  - 物品图片 (imageUrl)                                       │
│  - 中文名称 (nameCn)                                         │
│  - 拼音 (pinyin)                                             │
│  - 英文名称 (nameEn)                                         │
│  按钮：                                                       │
│  - 🔊 播放发音 (playAudio)                                   │
│  - 📱 互动学习 (navigateToInteractiveImage) ← 新增！        │
│  - ❌ 关闭                                                    │
└─────────────────────────────────────────────────────────────┘
                              ↓ 点击"互动学习"按钮
┌─────────────────────────────────────────────────────────────┐
│  InteractiveImagePage                                        │
│  显示：互动学习界面                                           │
│  数据：通过 Get.arguments 传递                               │
│  {                                                           │
│    'jsonFile': item.dataFile,  // JSON 数据文件路径          │
│    'imageItem': null,          // ImageItem (可选)           │
│    'images': []                // 图片列表 (可选)            │
│  }                                                           │
│  功能：                                                       │
│  - 显示互动图片 (imagePath)                                  │
│  - 显示可点击区域 (regions)                                  │
│  - 汉字笔画动画                                               │
│  - 英文字母动画                                               │
│  - TTS 语音播放                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 数据模型分析

### 1. SceneCategory (分类)

```dart
class SceneCategory {
  final String id;              // 'category_daily_life'
  final String name;            // '日常生活'
  final String icon;            // '🏠'
  final String coverImage;     // 封面图片路径
  final String description;    // 描述
  final int sceneCount;        // 包含场景数量
  final int totalItemCount;    // 总物品数量
  final int order;             // 排序
  final bool isNew;            // 是否新分类
  final DateTime createdAt;    // 创建时间
}
```

**数据来源：**
- Repository: `SceneRepositoryImpl.getCategories()`
- Mock: `MockCategories.categories`
- API: `GET /api/v1/scenes/categories`

### 2. Scene (场景)

```dart
class Scene {
  final String id;                // 'scene_breakfast'
  final String name;              // '早餐时间'
  final String nameEn;            // 'Breakfast Time'
  final String categoryId;        // 所属分类ID
  final String coverImage;        // 封面图片
  final String interactiveImage; // 互动图片 (带热点)
  final String description;       // 描述
  final String context;           // 场景上下文
  final int itemCount;            // 物品数量
  final int order;                // 排序
  final bool isNew;               // 是否新场景
  final DateTime createdAt;       // 创建时间
}
```

**数据来源：**
- Repository: `SceneRepositoryImpl.getScenesByCategory(categoryId)`
- Mock: `MockScenes.dailyLifeScenes`
- API: `GET /api/v1/scenes?categoryId={id}`

### 3. SceneItem (场景物品)

```dart
class SceneItem {
  final String id;                    // 'item_breakfast_milk'
  final String sceneId;               // 所属场景ID
  final String nameCn;                // '牛奶'
  final String nameEn;                // 'Milk'
  final String pinyin;                // 'niú nǎi'
  final String pronunciation;         // 'niu2 nai3'
  final String imageUrl;              // 物品图片
  final String audioUrl;              // 发音音频
  final String? dataFile;             // 🆕 互动数据文件 (JSON)
  final int order;                    // 排序
  final Map<String, dynamic>? hotspot; // 热点区域坐标
}
```

**热点区域格式：**
```dart
// 矩形热点
{
  'type': 'rect',
  'x': 100.0,
  'y': 150.0,
  'width': 80.0,
  'height': 120.0,
}

// 圆形热点
{
  'type': 'circle',
  'x': 200.0,      // 圆心X
  'y': 200.0,      // 圆心Y
  'radius': 50.0,  // 半径
}
```

**数据来源：**
- Repository: `SceneRepositoryImpl.getSceneDetail(sceneId)`
- Mock: `MockSceneItems.breakfastItems`
- API: `GET /api/v1/scenes/{sceneId}/items`

### 4. InteractiveRegion (互动区域)

```dart
class InteractiveRegion {
  final String id;
  final String text;           // 中文文本
  final String textEnglish;    // 英文文本
  final String pinyin;         // 拼音
  final String audioPath;      // 音频路径
  final double x;              // 区域X坐标
  final double y;              // 区域Y坐标
  final double width;          // 区域宽度
  final double height;         // 区域高度
}
```

**数据来源：**
- JSON 文件：`assets/data/kiki_zhiwuyuan.json`
- 通过 `dataFile` 字段指定

---

## Mock 数据方案

### 当前 Mock 数据结构

```
lib/data/mock/
├── mock_categories.dart      ✅ 已实现 (5个分类)
├── mock_scenes.dart          ✅ 已实现 (15个场景)
├── mock_scene_items.dart     ✅ 已实现 (180个物品)
└── mock_users.dart           ✅ 已实现
```

### 🎯 建议：完全使用 Mock 数据

**优势：**

1. **前后端解耦**
   - 前端开发不依赖后端进度
   - 可以独立测试所有功能
   - 快速迭代 UI/UX

2. **数据一致性**
   - 统一的数据格式
   - 清晰的数据契约
   - 易于维护和更新

3. **开发效率**
   - 无需等待 API 开发
   - 本地数据响应快速
   - 易于调试和测试

4. **灵活切换**
   - 通过环境变量控制
   - 生产环境切换到真实 API
   - 开发环境使用 Mock

### 实施方案

#### 1. 完善 Mock 数据

**需要补充的数据：**

```dart
// lib/data/mock/mock_scene_items.dart
class MockSceneItems {
  static final List<SceneItem> breakfastItems = [
    SceneItem(
      id: 'item_breakfast_milk',
      sceneId: 'scene_breakfast',
      nameCn: '牛奶',
      nameEn: 'Milk',
      pinyin: 'niú nǎi',
      pronunciation: 'niu2 nai3',
      imageUrl: 'assets/images/items/breakfast/milk.png',
      audioUrl: 'assets/audio/items/breakfast/milk.mp3',
      dataFile: 'assets/data/interactive/milk.json', // 🆕 添加
      order: 1,
      hotspot: {
        'type': 'rect',
        'x': 100.0,
        'y': 150.0,
        'width': 80.0,
        'height': 120.0,
      },
    ),
    // ... 其他物品
  ];
}
```

#### 2. 创建互动数据 JSON 文件

```json
// assets/data/interactive/milk.json
{
  "imageWidth": 1920,
  "imageHeight": 1080,
  "imagePath": "assets/images/items/breakfast/milk.png",
  "regions": [
    {
      "id": "region_milk_1",
      "text": "牛",
      "textEnglish": "Milk",
      "pinyin": "niú",
      "audioPath": "assets/audio/characters/niu.mp3",
      "x": 100,
      "y": 150,
      "width": 80,
      "height": 80
    },
    {
      "id": "region_milk_2",
      "text": "奶",
      "textEnglish": "",
      "pinyin": "nǎi",
      "audioPath": "assets/audio/characters/nai.mp3",
      "x": 200,
      "y": 150,
      "width": 80,
      "height": 80
    }
  ]
}
```

#### 3. Repository 层统一接口

```dart
// lib/data/repositories/scene_repository_impl.dart
class SceneRepositoryImpl implements ISceneRepository {
  final bool useMockData = EnvConfig.useMockData; // 环境变量控制

  @override
  Future<Map<String, dynamic>> getCategories() async {
    if (useMockData) {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 300));
      return MockCategories.getCategoriesResponse();
    } else {
      // 真实 API 调用
      final response = await _apiClient.get('/api/v1/scenes/categories');
      return response.data;
    }
  }

  @override
  Future<List<Scene>> getScenesByCategory(String categoryId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockScenes.getScenesByCategory(categoryId);
    } else {
      final response = await _apiClient.get(
        '/api/v1/scenes',
        queryParameters: {'categoryId': categoryId},
      );
      // 解析响应...
    }
  }

  @override
  Future<Map<String, dynamic>> getSceneDetail(String sceneId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockSceneItems.getSceneDetailResponse(sceneId);
    } else {
      final response = await _apiClient.get('/api/v1/scenes/$sceneId/items');
      return response.data;
    }
  }
}
```

#### 4. 环境配置

```dart
// lib/config/env_config.dart
class EnvConfig {
  // 是否使用 Mock 数据
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true, // 默认使用 Mock
  );

  // API 基础 URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8081',
  );
}
```

**运行命令：**
```bash
# 使用 Mock 数据 (开发)
flutter run --dart-define=USE_MOCK_DATA=true

# 使用真实 API (生产)
flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=https://api.kiki.com
```

---

## 实施建议

### 阶段 1：完善 Mock 数据 (1-2天)

1. ✅ **已完成**
   - MockCategories (5个分类)
   - MockScenes (15个场景)
   - MockSceneItems (基础数据)

2. 🔨 **需要补充**
   - 为所有 SceneItem 添加 `dataFile` 字段
   - 创建互动数据 JSON 文件 (至少 3-5 个示例)
   - 补充完整的 180 个物品数据

### 阶段 2：Repository 层改造 (1天)

1. 添加环境变量控制
2. 实现 Mock/API 双模式
3. 统一错误处理
4. 添加日志记录

### 阶段 3：测试验证 (1天)

1. 测试完整流程
2. 验证数据传递
3. 检查边界情况
4. 性能测试

### 阶段 4：文档完善 (0.5天)

1. 更新 API 文档
2. 补充数据格式说明
3. 添加使用示例

---

## 数据流总结

### 完整数据流

```
用户操作 → Controller → Repository → Mock/API → 数据解析 → UI 更新
```

### 关键数据传递

1. **Category → SceneList**
   ```dart
   Get.toNamed(routeSceneList, arguments: category)
   ```

2. **Scene → SceneDetail**
   ```dart
   Get.toNamed(routeSceneDetail, arguments: scene)
   ```

3. **SceneItem → InteractiveImage**
   ```dart
   Get.toNamed(routeInteractiveImage, arguments: {
     'jsonFile': item.dataFile,
     'imageItem': null,
     'images': [],
   })
   ```

### 数据依赖关系

```
SceneCategory (id)
  ↓ categoryId
Scene (id)
  ↓ sceneId
SceneItem (dataFile)
  ↓ jsonFile
InteractiveRegion
```

---

## 结论

**推荐方案：完全使用 Mock 数据**

**理由：**
1. ✅ 前后端完全解耦，开发效率高
2. ✅ 数据格式清晰，易于维护
3. ✅ 可以快速迭代和测试
4. ✅ 通过环境变量灵活切换
5. ✅ 为后端提供清晰的数据契约

**下一步行动：**
1. 补充 SceneItem 的 `dataFile` 字段
2. 创建互动数据 JSON 文件示例
3. 实现 Repository 双模式支持
4. 测试完整流程

---

**文档版本：** v1.0
**创建时间：** 2026-02-10
**最后更新：** 2026-02-10
