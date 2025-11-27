# 互动图片首页 (Interactive Image Home)

## 功能概述

这是一个完整的互动图片首页实现，包含：

- ✅ **分类选择器** - 水平滚动的分类按钮（教师、物资、生活、水果）
- ✅ **图片卡片网格** - 显示选中分类的图片缩略图
- ✅ **响应式布局** - 自动适配不同屏幕尺寸
- ✅ **导航集成** - 点击卡片跳转到 InteractiveImagePage 详情页
- ✅ **错误处理** - 图片加载失败时显示占位符
- ✅ **GetX 状态管理** - 集成 GetX 进行状态管理

## 文件结构

```
lib/presentation/pages/interactive_image_home/
├── interactive_image_home_page.dart      # 主页面 UI + 数据模型
├── interactive_image_home_controller.dart # GetX 控制器
└── index.dart                            # 导出文件
```

## 使用方法

### 1. 在路由中注册

在 `lib/routes/app_routes.dart` 或路由配置文件中：

```dart
import 'package:kiki_chain/presentation/pages/interactive_image_home/index.dart';

class AppRoutes {
  static const String interactiveImageHome = '/interactive-image-home';
  static const String interactiveImage = '/interactive-image';

  static List<GetPage> pages = [
    GetPage(
      name: interactiveImageHome,
      page: () => const InteractiveImageHomePage(),
      binding: BindingsBuilder(
        () {
          Get.put(InteractiveImageHomeController());
        },
      ),
    ),
    // ... 其他路由
  ];
}
```

### 2. 导航到首页

```dart
Get.toNamed('/interactive-image-home');
```

### 3. 在 main 中设置首页

```dart
void main() {
  runApp(
    GetMaterialApp(
      home: const InteractiveImageHomePage(),
      // 或
      initialRoute: '/interactive-image-home',
      getPages: AppRoutes.pages,
    ),
  );
}
```

## 数据模型

### ImageCategory 枚举
- `teacher` - 教师（👨‍🏫）
- `supplies` - 物资（📦）
- `life` - 生活（🏠）
- `fruits` - 水果（🍎）

### ImageItem 类
```dart
class ImageItem {
  final String id;              // 唯一标识
  final String title;           // 标题
  final String imagePath;       // 图片路径
  final ImageCategory category; // 所属分类
  final String description;     // 描述
  final DateTime createdAt;     // 创建时间
}
```

### ImageDataSource 类
静态数据源，提供样本数据。你可以：
- 修改 `getItems()` 返回的数据
- 替换为 API 调用
- 从本地 JSON 文件加载数据

## 自定义配置

### 修改分类数据

编辑 `interactive_image_home_page.dart` 中的 `ImageDataSource.getItems()` 方法：

```dart
ImageItem(
  id: 'custom_1',
  title: '自定义标题',
  imagePath: 'assets/images/your_image.jpg',
  category: ImageCategory.teacher,
  description: '自定义描述',
),
```

### 更改网格列数

在 `_buildImageGrid()` 方法中修改：

```dart
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,  // 改为 3 或其他值
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 0.85,
),
```

### 自定义分类选择器样式

修改 `_buildCategoryButton()` 方法中的样式参数：

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    border: Border.all(
      color: isSelected ? Colors.blue : Colors.grey[300]!,
      width: isSelected ? 2 : 1,
    ),
    borderRadius: BorderRadius.circular(24),
    color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
  ),
  // ... 继续修改
)
```

## 集成现有 InteractiveImagePage

当用户点击图片卡片时，会导航到现有的 `InteractiveImagePage`。

确保在路由中配置正确：

```dart
GetPage(
  name: '/interactive-image',
  page: () => const InteractiveImagePage(),
  binding: BindingsBuilder(
    () {
      Get.put(InteractiveImageController());
    },
  ),
),
```

## 扩展功能

### 1. 从 API 加载数据

替换 `_loadImagesByCategory()` 方法：

```dart
void _loadImagesByCategory(ImageCategory category) {
  try {
    isLoading.value = true;
    // 调用 API
    final items = await _imageRepository.getImagesByCategory(category);
    images.value = items;
  } catch (e) {
    print('Error loading images: $e');
    images.value = [];
  } finally {
    isLoading.value = false;
  }
}
```

### 2. 添加搜索功能

在 Controller 中添加：

```dart
final Rx<String> searchQuery = Rx<String>('');

List<ImageItem> getFilteredImages() {
  if (searchQuery.value.isEmpty) {
    return images.value;
  }
  return images.value
      .where((item) => item.title.contains(searchQuery.value))
      .toList();
}
```

### 3. 添加收藏功能

```dart
final Rx<Set<String>> favorites = Rx<Set<String>>({});

void toggleFavorite(ImageItem image) {
  if (favorites.value.contains(image.id)) {
    favorites.value.remove(image.id);
  } else {
    favorites.value.add(image.id);
  }
  favorites.refresh();
}
```

## 常见问题

### Q: 图片不显示？
A: 检查 `imagePath` 是否正确，确保文件存在于 `assets/` 目录。

### Q: 导航到详情页失败？
A: 确保在路由中注册了 `/interactive-image` 路由。

### Q: 分类按钮样式不对？
A: 检查 `_buildCategoryButton()` 中的样式配置。

## 下一步

1. ✅ 替换样本数据为真实数据
2. ✅ 连接到后端 API
3. ✅ 添加图片缓存机制
4. ✅ 实现收藏和历史记录功能
5. ✅ 添加详细的搜索过滤功能
