# 🏗️ 互动图片首页 - 架构文档

## 整体架构

```
┌─────────────────────────────────────────────────────────┐
│           InteractiveImageHomePage (UI Layer)            │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────┐        ┌──────────────────────┐   │
│  │ CategorySelector │        │   ImageCardGrid      │   │
│  │   (可滚动)       │        │  (2列网格 + 卡片)    │   │
│  └────────┬─────────┘        └──────────┬───────────┘   │
│           │                             │                │
│           └─────────────────┬───────────┘                │
│                             │                            │
│                        GetBuilder                        │
│                             │                            │
└─────────────────────────────┼────────────────────────────┘
                              │
┌─────────────────────────────┴────────────────────────────┐
│   InteractiveImageHomeController (State Layer)           │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ✓ selectedCategory: Rx<ImageCategory?>                 │
│  ✓ images: Rx<List<ImageItem>>                          │
│  ✓ isLoading: Rx<bool>                                  │
│                                                           │
│  • selectCategory(category)                             │
│  • navigateToImage(imageItem)                           │
│  • _loadImagesByCategory(category)                      │
│  • getCategories()                                      │
│                                                           │
└─────────────────────────────┬────────────────────────────┘
                              │
┌─────────────────────────────┴────────────────────────────┐
│      ImageDataSource / Repository (Data Layer)           │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  • getItems()                      (获取所有图片)       │
│  • getItemsByCategory(category)    (按分类获取图片)     │
│                                                          │
│  [可替换为 API 调用]                                    │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## 数据流

```
用户操作
   │
   ├─→ 点击分类按钮
   │     │
   │     ├─→ controller.selectCategory()
   │     │     │
   │     │     ├─→ selectedCategory.value = category
   │     │     │
   │     │     └─→ _loadImagesByCategory()
   │     │           │
   │     │           ├─→ isLoading.value = true
   │     │           │
   │     │           ├─→ ImageDataSource.getItemsByCategory()
   │     │           │
   │     │           ├─→ images.value = items
   │     │           │
   │     │           └─→ isLoading.value = false
   │     │
   │     └─→ UI 自动更新 (Obx 响应)
   │
   └─→ 点击图片卡片
         │
         └─→ controller.navigateToImage()
               │
               └─→ Get.toNamed('/interactive-image')
```

## 组件层次

```
InteractiveImageHomePage
│
├── Scaffold
│   │
│   ├── AppBar
│   │   └── Text('互动图片')
│   │
│   └── Body (Column)
│       │
│       ├── _buildCategorySelector()
│       │   └── Obx
│       │       └── SingleChildScrollView (Horizontal)
│       │           └── Row
│       │               └── _buildCategoryButton() x N
│       │                   └── Material (InkWell)
│       │
│       └── Expanded
│           └── _buildImageGrid()
│               └── Obx
│                   ├── Loading: CircularProgressIndicator
│                   ├── Empty: Center with Icon
│                   └── GridView.builder
│                       └── _buildImageCard() x N
│                           └── Card
│                               ├── Image
│                               └── Column (Title + Description)
```

## 响应式变量流向

```
Controller 中的响应式变量
│
├── selectedCategory (Rx<ImageCategory?>)
│   │
│   ├─→ _buildCategorySelector()
│   │     (高亮显示选中分类)
│   │
│   └─→ _buildCategoryButton()
│         (判断是否选中，改变样式)
│
├── images (Rx<List<ImageItem>>)
│   │
│   └─→ _buildImageGrid()
│         (显示图片卡片)
│         
│         ├─→ itemCount: images.value.length
│         └─→ itemBuilder: images.value[index]
│
└── isLoading (Rx<bool>)
    │
    └─→ _buildImageGrid()
        (显示加载状态)
```

## 文件职责

### interactive_image_home_page.dart
- 定义 `ImageCategory` 枚举
- 定义 `ImageItem` 数据类
- 定义 `ImageDataSource` 数据源
- 实现 `InteractiveImageHomePage` UI
- 实现所有 UI 构建方法

```
├── ImageCategory (enum)
│   ├── teacher
│   ├── supplies
│   ├── life
│   └── fruits
│
├── ImageItem (class)
│   ├── id: String
│   ├── title: String
│   ├── imagePath: String
│   ├── category: ImageCategory
│   ├── description: String
│   └── createdAt: DateTime
│
├── ImageDataSource (class)
│   ├── getItems()
│   └── getItemsByCategory()
│
└── InteractiveImageHomePage (widget)
    ├── build()
    ├── _buildCategorySelector()
    ├── _buildCategoryButton()
    ├── _buildImageGrid()
    └── _buildImageCard()
```

### interactive_image_home_controller.dart
- 定义状态变量
- 实现状态管理逻辑
- 实现业务方法

```
InteractiveImageHomeController extends GetxController
├── selectedCategory: Rx<ImageCategory?>
├── images: Rx<List<ImageItem>>
├── isLoading: Rx<bool>
│
├── onInit()
├── selectCategory()
├── _loadImagesByCategory()
├── navigateToImage()
└── getCategories()
```

## 状态管理模式

使用 GetX 的响应式编程：

```dart
// 声明
final selectedCategory = Rx<ImageCategory?>(null);

// 修改
selectedCategory.value = ImageCategory.teacher;

// 监听 (自动更新 UI)
Obx(() {
  return Text(selectedCategory.value?.label ?? '');
})
```

## 数据加载流程

```
selectCategory(category)
    │
    └─→ selectedCategory.value = category
        │
        └─→ _loadImagesByCategory(category)
            │
            ├─→ isLoading.value = true
            │
            ├─→ try {
            │       items = ImageDataSource.getItemsByCategory()
            │       images.value = items
            │   }
            │
            ├─→ catch (e) {
            │       images.value = []
            │   }
            │
            └─→ finally {
                    isLoading.value = false
                }
```

## 导航流程

```
用户点击图片卡片
    │
    └─→ _buildImageCard() 的 GestureDetector.onTap
        │
        └─→ controller.navigateToImage(image)
            │
            └─→ Get.toNamed('/interactive-image', arguments: {
                  'imageItem': image,
                  'images': controller.images.value
                })
                │
                └─→ 导航到 InteractiveImagePage
```

## 扩展点 (Extension Points)

### 1. 数据源替换
替换 `ImageDataSource` 或继承 `Controller` 重写 `_loadImagesByCategory()`

### 2. UI 定制
修改 `_buildCategoryButton()` 或 `_buildImageCard()` 的样式参数

### 3. 功能扩展
继承 `InteractiveImageHomeController` 添加新方法：
- 搜索功能
- 收藏功能
- 排序功能
- 历史记录

### 4. 数据转换
在 Controller 中添加数据处理逻辑

```dart
// 示例：过滤和排序
List<ImageItem> getFilteredImages() {
  return images.value
    .where((item) => /* 过滤条件 */)
    .toList()
    ..sort((a, b) => /* 排序逻辑 */);
}
```

## 性能考虑

### GridView.builder
- 使用 `builder` 模式而非 `List`，只构建可见的卡片
- 随着列表增长性能不降低

### 图片缓存
- Flutter 自动缓存网络图片
- 本地资源 Assets 自动优化

### 响应式优化
- 使用 `Obx` 只重新构建需要更新的部分
- 避免整个页面重构

### 列表加载
- 实现虚拟列表 (仅当需要时)
- 实现分页加载 (处理大数据集时)

## 依赖注入

### GetX 方式
```dart
// 在路由中
GetPage(
  name: '/interactive-image-home',
  page: () => const InteractiveImageHomePage(),
  binding: BindingsBuilder(() {
    Get.put(InteractiveImageHomeController());
  }),
)

// 在 Widget 中
GetBuilder<InteractiveImageHomeController>(
  builder: (controller) => /* UI */
)
```

### 手动方式
```dart
final controller = Get.put(InteractiveImageHomeController());
// 使用 controller
```

## 错误处理

```
_loadImagesByCategory()
    │
    ├─→ try
    │   └─→ 正常加载
    │
    ├─→ catch (e)
    │   └─→ 图片列表设为空
    │       └─→ UI 显示"暂无图片"
    │
    └─→ finally
        └─→ 关闭加载状态
```

## 测试考虑

### 单元测试
- 测试 `selectCategory()` 是否正确更新状态
- 测试 `navigateToImage()` 是否正确导航

### Widget 测试
- 测试分类按钮是否正确响应点击
- 测试卡片是否正确显示图片和标题

### Integration 测试
- 测试完整的用户交互流程

---

这个架构设计遵循 Flutter 最佳实践和 Clean Architecture 原则。
