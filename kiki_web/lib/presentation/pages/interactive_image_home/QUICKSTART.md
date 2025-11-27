# 🚀 互动图片首页 - 快速开始指南

## 📌 3 分钟快速开始

### 第 1 步：导入页面

在你的 `main.dart` 中：

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kiki_chain/presentation/pages/interactive_image_home/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '奇奇满有',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InteractiveImageHomePage(),  // 👈 设置为首页
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### 第 2 步：运行

```bash
flutter pub get
flutter run
```

✅ 完成！你现在可以看到互动图片首页了。

---

## 🎯 核心功能演示

### 分类选择
```
👨‍🏫 教师 | 📦 物资 | 🏠 生活 | 🍎 水果
          ↓
      显示该分类的图片
```

### 点击卡片
```
[图片卡片]
    ↓
导航到 InteractiveImagePage 详情页
    ↓
进入交互式图片浏览模式
```

---

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| `interactive_image_home_page.dart` | 主界面（380+ 行）|
| `interactive_image_home_controller.dart` | 状态管理（60 行）|
| `index.dart` | 导出入口 |
| `README.md` | 详细文档 |
| `SUMMARY.md` | 功能总结 |

---

## 🎨 界面组成

```
┌─────────────────────────────────┐
│  AppBar: "互动图片"             │
├─────────────────────────────────┤
│ [教师] [物资] [生活] [水果] →  │ ← 分类选择
├─────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐     │
│  │ 图片  │  │ 图片  │     │
│  │ 标题  │  │ 标题  │     │
│  └─────────┘  └─────────┘     │ ← 图片卡片
│  ┌─────────┐  ┌─────────┐     │
│  │ 图片  │  │ 图片  │     │
│  │ 标题  │  │ 标题  │     │
│  └─────────┘  └─────────┘     │
└─────────────────────────────────┘
```

---

## 🔌 集成现有代码

### 连接 InteractiveImagePage

确保在路由配置中有 `/interactive-image` 的定义：

```dart
// lib/routes/app_routes.dart
GetPage(
  name: '/interactive-image',
  page: () => const InteractiveImagePage(),
  binding: BindingsBuilder(() {
    Get.put(InteractiveImageController());
  }),
)
```

点击卡片时会自动导航：
```dart
Get.toNamed('/interactive-image', arguments: {
  'imageItem': imageItem,
  'images': images.value,
})
```

---

## 🛠️ 常见定制

### 修改分类

编辑 `ImageCategory` 枚举：

```dart
enum ImageCategory {
  category1,  // 新分类
  category2,
  // ...
}
```

### 加载真实数据

替换 `ImageDataSource.getItems()`：

```dart
static List<ImageItem> getItems() {
  // 从 API 调用
  // final response = await api.getImages();
  // return response.map((e) => ImageItem.fromJson(e)).toList();
}
```

### 改变网格列数

在 `_buildImageGrid()` 中：

```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,  // 改为 3 列
  // ...
)
```

---

## 📊 数据结构

```dart
class ImageItem {
  final String id;              // "teacher_1"
  final String title;           // "李老师"
  final String imagePath;       // "assets/images/..."
  final ImageCategory category; // ImageCategory.teacher
  final String description;     // "一年级语文老师"
  final DateTime createdAt;     // 创建时间
}
```

---

## ⚙️ 状态管理 (GetX)

```dart
class InteractiveImageHomeController extends GetxController {
  final Rx<ImageCategory?> selectedCategory;  // 选中分类
  final Rx<List<ImageItem>> images;           // 图片列表
  final Rx<bool> isLoading;                   // 加载状态

  void selectCategory(ImageCategory category) {
    // 切换分类
  }

  void navigateToImage(ImageItem imageItem) {
    // 导航到详情页
  }
}
```

---

## 🔍 调试技巧

### 查看选中的分类

在控制器中添加：
```dart
Get.put(InteractiveImageHomeController())
  .selectedCategory.listen((value) {
    print('Selected: $value');
  });
```

### 查看图片列表

```dart
final controller = Get.find<InteractiveImageHomeController>();
print('Images: ${controller.images.value}');
```

### 手动切换分类

```dart
Get.find<InteractiveImageHomeController>()
  .selectCategory(ImageCategory.teacher);
```

---

## 📱 响应式设计

页面自动适配：
- ✅ 小屏幕 (手机)
- ✅ 中等屏幕 (平板)
- ✅ 大屏幕 (桌面)

网格会自动调整列数和间距。

---

## 🐛 故障排除

### 问题：图片不显示
**解决**：检查 `pubspec.yaml` 中是否声明了 assets
```yaml
flutter:
  assets:
    - assets/images/
```

### 问题：导航失败
**解决**：确保 `/interactive-image` 路由已注册

### 问题：分类按钮不响应
**解决**：查看 Console 是否有错误，确保 GetX 正确初始化

### 问题：数据不更新
**解决**：使用 Hot Restart 而不是 Hot Reload（修改数据源时）

---

## 📚 进阶用法

### 从 JSON 加载数据
```dart
final json = jsonDecode(await rootBundle.loadString('assets/data.json'));
final items = (json as List)
  .map((e) => ImageItem.fromJson(e))
  .toList();
```

### 添加搜索
```dart
final searchQuery = ''.obs;
final filteredImages = images.where(
  (item) => item.title.contains(searchQuery.value)
).toList().obs;
```

### 本地缓存
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setStringList('favorites', favoriteIds);
```

---

## 🎉 现在就开始使用吧！

```dart
// 在任何地方导航到首页
Get.toNamed('/interactive-image-home');

// 或直接打开
Get.to(() => const InteractiveImageHomePage());
```

---

有问题？查看 `README.md` 了解更详细的文档。
