# 数据流Review - 页面间数据传递

## 📊 导航流程图

```
InteractiveImageHomePage (首页)
         │
         │ arguments: SceneCategory
         ↓
SceneListPage (场景列表)
         │
         │ arguments: Scene
         ↓
SceneDetailPage (场景详情)
         │
         │ arguments: Map {imageItem, images}
         ↓
InteractiveImagePage (互动图片)
```

---

## 🔍 详细数据流分析

### 1. 首页 → 场景列表页

**文件**: `lib/presentation/pages/interactive_image_home/interactive_image_home_page.dart:183-191`

```dart
Get.toNamed(
  AppConstants.routeSceneList,
  arguments: category,  // ✅ 传递 SceneCategory 对象
);
```

**路由配置**: `lib/config/app_routes.dart:56-63`

```dart
GetPage(
  name: AppConstants.routeSceneList,
  page: () {
    final category = Get.arguments;  // ✅ 接收 SceneCategory
    return SceneListPage(category: category);
  },
),
```

**数据类型**: `SceneCategory`
- ✅ **正确**: 直接传递实体对象
- ✅ **类型安全**: SceneListPage 构造函数要求 `required SceneCategory category`

---

### 2. 场景列表页 → 场景详情页

**文件**: `lib/presentation/controllers/scene_list_controller.dart:60-66`

```dart
void navigateToSceneDetail(Scene scene) {
  AppLogger.info('🚀 Navigating to scene detail: ${scene.name}');
  Get.toNamed(
    AppConstants.routeSceneDetail,
    arguments: scene,  // ✅ 传递 Scene 对象
  );
}
```

**路由配置**: `lib/config/app_routes.dart:64-71`

```dart
GetPage(
  name: AppConstants.routeSceneDetail,
  page: () {
    final scene = Get.arguments;  // ✅ 接收 Scene
    return SceneDetailPage(scene: scene);
  },
),
```

**数据类型**: `Scene`
- ✅ **正确**: 直接传递实体对象
- ✅ **类型安全**: SceneDetailPage 构造函数要求 `required Scene scene`

---

### 3. 场景详情页 → 互动图片页

**当前状态**: ⚠️ **未实现**

**预期实现**:

```dart
// 在 SceneDetailController 中添加导航方法
void navigateToInteractiveImage(SceneItem item) {
  Get.toNamed(
    AppConstants.routeInteractiveImage,
    arguments: {
      'imageItem': ImageItem(
        id: item.id,
        title: item.nameCn,
        imagePath: scene.interactiveImage,
        jsonFile: item.dataFile,  // 需要在 SceneItem 中添加此字段
      ),
      'images': [], // 可选：传递场景中的所有物品
    },
  );
}
```

**路由配置需要更新**: `lib/config/app_routes.dart:46-50`

```dart
// ❌ 当前实现 - 不接收参数
GetPage(
  name: AppConstants.routeInteractiveImage,
  page: () => const InteractiveImagePage(),
),

// ✅ 建议实现 - 接收参数
GetPage(
  name: AppConstants.routeInteractiveImage,
  page: () {
    // InteractiveImageController 会从 Get.arguments 中读取参数
    return const InteractiveImagePage();
  },
),
```

**InteractiveImageController 期望的参数格式**:

```dart
Map<String, dynamic> {
  'imageItem': ImageItem,      // 优先使用
  'jsonFile': String,          // 降级方案
  'images': List<ImageItem>,   // 可选
}
```

---

## ⚠️ 发现的问题

### 问题 1: InteractiveImagePage 路由未接收参数

**位置**: `lib/config/app_routes.dart:46-50`

**问题描述**:
- InteractiveImageController 期望从 `Get.arguments` 接收参数
- 但路由配置中使用了 `const InteractiveImagePage()`
- 这会导致参数无法传递

**影响**:
- 如果从其他页面导航到 InteractiveImagePage 并传递参数，参数会被忽略
- InteractiveImageController 会使用默认值

**解决方案**:
```dart
// 移除 const 关键字，允许参数传递
GetPage(
  name: AppConstants.routeInteractiveImage,
  page: () => InteractiveImagePage(),  // 移除 const
),
```

### 问题 2: SceneItem 缺少必要字段

**位置**: `lib/domain/entities/scene_item.dart`

**问题描述**:
- 要导航到 InteractiveImagePage，需要传递 `jsonFile` 路径
- 当前 SceneItem 可能没有存储数据文件路径

**建议**:
```dart
class SceneItem {
  final String id;
  final String nameCn;
  final String nameEn;
  final String pinyin;
  final String imageUrl;
  final String audioUrl;
  final String dataFile;  // ✅ 添加：互动数据文件路径
  final Map<String, dynamic>? hotspot;
  final int order;

  // ...
}
```

### 问题 3: 类型安全性不足

**位置**: 所有路由配置

**问题描述**:
- `Get.arguments` 返回 `dynamic` 类型
- 没有类型检查和空值检查

**建议改进**:
```dart
// ❌ 当前实现
GetPage(
  name: AppConstants.routeSceneList,
  page: () {
    final category = Get.arguments;  // dynamic 类型
    return SceneListPage(category: category);
  },
),

// ✅ 建议实现
GetPage(
  name: AppConstants.routeSceneList,
  page: () {
    final category = Get.arguments as SceneCategory?;
    if (category == null) {
      AppLogger.error('❌ SceneCategory is null');
      // 返回错误页面或返回首页
      return const ErrorPage(message: 'Invalid navigation');
    }
    return SceneListPage(category: category);
  },
),
```

---

## ✅ 优点

1. **使用实体对象传递**
   - 直接传递 `SceneCategory` 和 `Scene` 对象
   - 避免了序列化/反序列化的开销
   - 类型安全（在构造函数层面）

2. **统一的路由管理**
   - 所有路由集中在 `app_routes.dart`
   - 使用常量定义路由名称
   - 便于维护和修改

3. **清晰的数据流**
   - 单向数据流：首页 → 列表 → 详情 → 互动
   - 每一级只传递必要的数据

---

## 🔧 建议改进

### 1. 添加类型安全检查

创建路由参数包装类：

```dart
// lib/core/routing/route_arguments.dart

class SceneListArguments {
  final SceneCategory category;

  SceneListArguments({required this.category});
}

class SceneDetailArguments {
  final Scene scene;

  SceneDetailArguments({required this.scene});
}

class InteractiveImageArguments {
  final ImageItem? imageItem;
  final String? jsonFile;
  final List<ImageItem>? images;

  InteractiveImageArguments({
    this.imageItem,
    this.jsonFile,
    this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      if (imageItem != null) 'imageItem': imageItem,
      if (jsonFile != null) 'jsonFile': jsonFile,
      if (images != null) 'images': images,
    };
  }
}
```

### 2. 更新路由配置

```dart
// 场景列表页面
GetPage(
  name: AppConstants.routeSceneList,
  page: () {
    final args = Get.arguments;
    if (args is! SceneCategory) {
      AppLogger.error('❌ Invalid arguments for SceneListPage');
      Get.back();
      return const SizedBox.shrink();
    }
    return SceneListPage(category: args);
  },
),

// 互动图片页面
GetPage(
  name: AppConstants.routeInteractiveImage,
  page: () => InteractiveImagePage(),  // 移除 const
),
```

### 3. 更新导航调用

```dart
// 首页 → 场景列表
Get.toNamed(
  AppConstants.routeSceneList,
  arguments: category,  // 直接传递对象
);

// 场景详情 → 互动图片
Get.toNamed(
  AppConstants.routeInteractiveImage,
  arguments: InteractiveImageArguments(
    imageItem: imageItem,
    images: allImages,
  ).toMap(),
);
```

---

## 📝 总结

### 当前状态评分: 7/10

**优点** ✅:
- 使用实体对象传递，避免序列化
- 统一的路由管理
- 清晰的数据流

**需要改进** ⚠️:
1. InteractiveImagePage 路由配置需要移除 `const`
2. 添加类型安全检查和空值处理
3. SceneItem 需要添加 `dataFile` 字段
4. 完善场景详情到互动图片的导航逻辑

**建议优先级**:
1. 🔴 **高**: 修复 InteractiveImagePage 路由配置
2. 🟡 **中**: 添加类型安全检查
3. 🟢 **低**: 创建参数包装类（可选，提升代码质量）

---

**Review日期**: 2026-02-10
**Reviewer**: Claude Code
**状态**: 需要改进
