# 架构优化：合并 SceneDetailPage 和 InteractiveImagePage

## 问题分析

### 当前架构（冗余）

```
Home → SceneList → SceneDetail → Dialog → InteractiveImage
                      ↓
                  显示场景图片
                  检测热点
                  弹出对话框
                      ↓
                  点击"互动学习"
                      ↓
                  InteractiveImage
                  显示互动图片
                  TTS + 动画
```

**问题：**
1. ❌ SceneDetailPage 和 InteractiveImagePage 功能重复
2. ❌ 用户需要多次点击才能进入学习
3. ❌ 数据传递链路过长
4. ❌ 维护两套相似的代码

### 优化后架构（简洁）

```
Home → SceneList → InteractiveImage
                      ↓
                  直接进入互动学习
                  显示场景图片
                  检测区域
                  TTS + 动画
```

**优势：**
1. ✅ 减少一个页面，代码更简洁
2. ✅ 用户体验更流畅，一步到位
3. ✅ 数据传递更直接
4. ✅ 只维护一套互动逻辑

---

## 实施方案

### 1. 删除 SceneDetailPage

**文件：**
- `lib/presentation/pages/scene_detail_page.dart` ❌ 删除
- `lib/presentation/controllers/scene_detail_controller.dart` ❌ 删除

### 2. 修改 SceneListPage 导航

**修改前：**
```dart
void navigateToSceneDetail(Scene scene) {
  Get.toNamed(
    AppConstants.routeSceneDetail,
    arguments: scene,
  );
}
```

**修改后：**
```dart
void navigateToInteractiveImage(Scene scene) {
  Get.toNamed(
    AppConstants.routeInteractiveImage,
    arguments: {
      'scene': scene,  // 传递整个 Scene 对象
      'jsonFile': scene.dataFile,  // 场景的互动数据文件
    },
  );
}
```

### 3. 增强 InteractiveImagePage

**需要支持两种数据源：**

#### 方式 1: 从 Scene 进入（新增）
```dart
arguments: {
  'scene': scene,           // Scene 对象
  'jsonFile': scene.dataFile,  // 场景互动数据
}
```

#### 方式 2: 从 ImageItem 进入（已有）
```dart
arguments: {
  'imageItem': imageItem,   // ImageItem 对象
  'jsonFile': imageItem.jsonFile,
  'images': imagesList,
}
```

### 4. 修改 InteractiveImageController

**增强参数解析：**

```dart
void _getParametersFromRoute() {
  final arguments = Get.arguments;

  if (arguments != null && arguments is Map) {
    // 方式 1: 从 Scene 进入
    if (arguments['scene'] != null && arguments['scene'] is Scene) {
      final scene = arguments['scene'] as Scene;
      _jsonFilePath = scene.dataFile ?? 'assets/data/default.json';
      _imagePath = scene.interactiveImage;
      _currentScene = scene;
      AppLogger.info('📱 Navigated from Scene: ${scene.name}');
    }
    // 方式 2: 从 ImageItem 进入
    else if (arguments['imageItem'] != null) {
      _currentImageItem = arguments['imageItem'] as ImageItem;
      _jsonFilePath = _currentImageItem!.jsonFile;
      _imagePath = _currentImageItem!.imagePath;
      AppLogger.info('📱 Navigated from ImageItem: ${_currentImageItem!.title}');
    }
    // 方式 3: 直接传递 jsonFile
    else {
      _jsonFilePath = arguments['jsonFile'] ?? 'assets/data/default.json';
      _imagePath = _getImagePathFromJsonFile(_jsonFilePath);
    }

    // 接收图片列表（用于左右滑动切换）
    if (arguments['images'] != null && arguments['images'] is List) {
      _imagesList = arguments['images'] as List<ImageItem>;
    }
  }
}
```

### 5. Scene 实体添加 dataFile 字段

```dart
class Scene {
  final String id;
  final String name;
  final String nameEn;
  final String categoryId;
  final String coverImage;
  final String interactiveImage;
  final String? dataFile;  // 🆕 互动数据文件路径
  final String description;
  final String context;
  final int itemCount;
  final int order;
  final bool isNew;
  final DateTime createdAt;
}
```

### 6. 更新 Mock 数据

```dart
Scene(
  id: 'scene_breakfast',
  name: '早餐时间',
  nameEn: 'Breakfast Time',
  categoryId: 'category_daily_life',
  coverImage: 'assets/images/scenes/breakfast_cover.jpg',
  interactiveImage: 'assets/images/scenes/breakfast_interactive.jpg',
  dataFile: 'assets/data/scenes/breakfast.json',  // 🆕 添加
  description: '小朋友和家人一起吃早餐，桌上摆满了丰盛的早餐食物',
  context: '早上7点，小明坐在餐桌前，妈妈正在准备早餐',
  itemCount: 12,
  order: 1,
  isNew: false,
  createdAt: DateTime(2026, 1, 28),
),
```

### 7. 创建场景互动数据 JSON

```json
// assets/data/scenes/breakfast.json
{
  "sceneId": "scene_breakfast",
  "sceneName": "早餐时间",
  "imageWidth": 1920,
  "imageHeight": 1080,
  "imagePath": "assets/images/scenes/breakfast_interactive.jpg",
  "regions": [
    {
      "id": "region_milk",
      "itemId": "item_breakfast_milk",
      "text": "牛奶",
      "textEnglish": "Milk",
      "pinyin": "niú nǎi",
      "audioPath": "assets/audio/items/breakfast/milk.mp3",
      "x": 100,
      "y": 150,
      "width": 80,
      "height": 120
    },
    {
      "id": "region_bread",
      "itemId": "item_breakfast_bread",
      "text": "面包",
      "textEnglish": "Bread",
      "pinyin": "miàn bāo",
      "audioPath": "assets/audio/items/breakfast/bread.mp3",
      "x": 200,
      "y": 180,
      "width": 100,
      "height": 80
    }
    // ... 其他 10 个物品
  ]
}
```

---

## 数据模型对比

### SceneItem vs InteractiveRegion

**SceneItem (旧):**
```dart
class SceneItem {
  final String nameCn;
  final String nameEn;
  final String pinyin;
  final String imageUrl;
  final String audioUrl;
  final Map<String, dynamic>? hotspot;  // 热点坐标
}
```

**InteractiveRegion (新):**
```dart
class InteractiveRegion {
  final String text;           // 对应 nameCn
  final String textEnglish;    // 对应 nameEn
  final String pinyin;
  final String audioPath;      // 对应 audioUrl
  final double x, y, width, height;  // 对应 hotspot
}
```

**结论：** 两者可以完全统一！

---

## 迁移步骤

### 阶段 1: 准备工作（1小时）

1. ✅ 为 Scene 实体添加 `dataFile` 字段
2. ✅ 更新 Scene 的 fromJson/toJson/copyWith
3. ✅ 更新 Mock 数据，添加 dataFile

### 阶段 2: 修改导航（30分钟）

1. 修改 SceneListController.navigateToSceneDetail
2. 更新路由参数传递
3. 删除 routeSceneDetail 路由

### 阶段 3: 增强 InteractiveImagePage（1小时）

1. 修改 InteractiveImageController 参数解析
2. 支持 Scene 对象传入
3. 添加场景信息显示（顶部标题栏）

### 阶段 4: 清理代码（30分钟）

1. 删除 SceneDetailPage
2. 删除 SceneDetailController
3. 删除相关路由配置
4. 更新文档

### 阶段 5: 测试验证（1小时）

1. 测试从场景列表进入
2. 测试互动���能
3. 测试数据加载
4. 测试边界情况

**总计：约 4 小时**

---

## 优化后的完整流程

```
┌─────────────────────────────────────────────────────────────┐
│  HomePage                                                    │
│  └── InteractiveImageHomePage (显示分类)                    │
└─────────────────────────────────────────────────────────────┘
                              ↓ 点击分类
┌─────────────────────────────────────────────────────────────┐
│  SceneListPage                                               │
│  显示：该分类下的所有场景                                     │
│  数据：List<Scene>                                           │
└─────────────────────────────────────────────────────────────┘
                              ↓ 点击场景
┌─────────────────────────────────────────────────────────────┐
│  InteractiveImagePage                                        │
│  显示：场景互动学习界面                                       │
│  数据：Scene + InteractiveRegions                            │
│  功能：                                                       │
│  - 显示场景背景图                                             │
│  - 显示可点击区域（热点）                                     │
│  - 点击区域 → 显示汉字/字母动画                              │
│  - TTS 语音播放                                              │
│  - 笔画顺序动画                                               │
└─────────────────────────────────────────────────────────────┘
```

**用户体验：**
- 点击场景 → 直接进入学习 ✅
- 减少一次点击 ✅
- 流程更流畅 ✅

---

## 代码变更清单

### 删除文件
- ❌ `lib/presentation/pages/scene_detail_page.dart`
- ❌ `lib/presentation/controllers/scene_detail_controller.dart`

### 修改文件
- 📝 `lib/domain/entities/scene.dart` - 添加 dataFile
- 📝 `lib/presentation/controllers/scene_list_controller.dart` - 修改导航
- 📝 `lib/presentation/pages/interactive_image/interactive_image_controller.dart` - 增强参数解析
- 📝 `lib/config/app_routes.dart` - 删除 routeSceneDetail
- 📝 `lib/core/constants/app_constants.dart` - 删除 routeSceneDetail
- 📝 `lib/data/mock/mock_scenes.dart` - 添加 dataFile

### 新增文件
- 🆕 `assets/data/scenes/breakfast.json`
- 🆕 `assets/data/scenes/school_ready.json`
- 🆕 ... (其他场景的 JSON 文件)

---

## 总结

### 优化前
```
3个页面 + 2次点击 + 复杂的数据传递
```

### 优化后
```
2个页面 + 1次点击 + 简洁的数据传递
```

### 收益
- ✅ 减少 33% 的页面代码
- ✅ 减少 50% 的用户点击
- ✅ 提升用户体验
- ✅ 降低维护成本
- ✅ 统一互动逻辑

---

**文档版本：** v1.0
**创建时间：** 2026-02-10
**建议优先级：** 🔴 高
