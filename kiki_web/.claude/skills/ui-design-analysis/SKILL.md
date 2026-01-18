---
name: ui-design-analysis
description: |
  Analyze UI design images (screenshots, Figma exports, mockups) and generate Flutter Widget code.
  Extracts UI elements, colors, dimensions, and produces Dart code with GetX integration and
  responsive design using ScreenUtil.

  Triggers: design image provided, "分析设计稿", "生成布局", UI mockup
---

# UI Design Analysis Skill (Flutter)

## When to Use

自动激活条件：
- 用户提供设计稿图片（截图、Figma 导出、手绘稿）
- 用户询问"如何实现这个设计"、"生成布局"
- 用户提供 Figma/蓝狐链接
- `/dev` 工作流 Phase 3: UI Design

## Core Patterns

### 1. UI 设计分析流程

```
图片输入 → 元素识别 → 布局分析 → 颜色提取 → 尺寸计算 → Widget代码生成
```

### 2. 支持的输入方式

#### ✅ 方式 1：设计稿图片（推荐）
```bash
用户："这是登录页面设计 [拖拽图片]，帮我实现"

我的分析步骤：
1. 查看图片，识别所有 UI 元素
2. 分��布局结构（Column/Row/Stack/ListView）
3. 提取颜色值（目测或从设计规范）
4. 估算尺寸和间距（根据设计规范）
5. 生成 Flutter Widget 代码
6. 生成颜色常量和样式
7. 生成 GetX Controller 骨架
```

#### ✅ 方式 2：Figma/蓝狐链接
```bash
用户："这是 Figma 设计：https://figma.com/file/xxx"

我的处理：
1. 尝试使用 WebFetch 获取内容
2. 如果无法访问，提示用户截图
3. 分析设计规范和元素
```

#### ✅ 方式 3：手绘草图
```bash
用户："这是手绘的界面草图 [图片]"

我的处理：
1. 理解草图意图
2. 询问细节（颜色、尺寸、交互）
3. 生成标准化的 Flutter Widget
```

### 3. UI 元素识别清单

分析图片时，系统化识别以下元素：

#### 布局容器
- [ ] **根布局**：Scaffold/Column/Row/Stack
- [ ] **滚动容器**：SingleChildScrollView/ListView/GridView
- [ ] **容器层级**：父子关系、嵌套结构

#### 基础组件
- [ ] **Text**：标题、正文、标签、提示文字
- [ ] **TextField**：输入框、搜索框、密码框
- [ ] **ElevatedButton/TextButton/OutlinedButton**：按钮
- [ ] **Image**：图片、图标、头像、背景图
- [ ] **Icon**：Material Icons、自定义图标

#### 复杂组件
- [ ] **ListView/GridView**：列表、网格
- [ ] **PageView**：轮播图、多页切换
- [ ] **TabBar/TabBarView**：标签页
- [ ] **BottomNavigationBar**：底部导航
- [ ] **AppBar**：顶部导航栏
- [ ] **FloatingActionButton**：悬浮按钮
- [ ] **Card**：卡片容器

#### 自定义组件（项目特有）
- [ ] **自定义 Widget**：项目特有的复杂组件
- [ ] **GetX 响应式组件**：需要状态管理的组件

### 4. 颜色提取规范

#### 识别颜色类型
```dart
// 从设计稿中识别的颜色
- 主题色 (Primary)
- 强调色 (Accent)
- 背景色 (Background)
- 文字颜色 (Text Primary/Secondary)
- 分割线颜色 (Divider)
- 错误提示色 (Error)
- 成功提示色 (Success)
```

#### 生成颜色常量
```dart
// config/app_color.dart
class AppColors {
  // 主题色
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFFC8E6C9);

  // 强调色
  static const Color accent = Color(0xFFFF4081);

  // 背景色
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF5F5F5);

  // 文字颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // 功能色
  static const Color divider = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
}
```

### 5. 尺寸计算规范（ScreenUtil）

#### 识别尺寸
```dart
// ✅ 项目设计稿基准（横屏）
- 设计稿分辨率：1024x768 (iPad 横屏标准)
- 使用 ScreenUtil 自适应不同屏幕
- 配置：splitScreenMode: true, ensureScreenSize: true

// 常用尺寸（横屏优化）
- 页面边距：24.w (横屏空间更大)
- 元素间距：12.w, 16.w, 24.w
- 按钮高度：48.h
- 输入框高度：56.h
- 标题字体：24.sp, 28.sp (横屏可以稍大)
- 正文字体：16.sp, 18.sp
```

#### 标准尺寸常量
```dart
// core/constants/app_constants.dart
class AppDimens {
  // 间距（横屏优化）
  static double spacingTiny = 4.w;
  static double spacingSmall = 12.w;
  static double spacingNormal = 24.w;  // 横屏增大
  static double spacingLarge = 32.w;
  static double spacingXLarge = 48.w;

  // 文字大小（横屏优化）
  static double textSizeTitle = 28.sp;     // 横屏可以更大
  static double textSizeSubtitle = 20.sp;
  static double textSizeBody = 16.sp;
  static double textSizeCaption = 14.sp;

  // 组件尺寸
  static double buttonHeight = 48.h;
  static double inputHeight = 56.h;
  static double appBarHeight = 64.h;  // 横屏稍高

  // 圆角
  static double radiusSmall = 4.r;
  static double radiusNormal = 8.r;
  static double radiusLarge = 16.r;
}
```

### 6. Widget 生成策略

#### 选择合适的布局 Widget

**Column（垂直布局）**
- ✅ 适用于垂直排列的元素
- ✅ 常用于表单、列表项内部

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('标题', style: TextStyle(fontSize: 24.sp)),
    SizedBox(height: 8.h),
    Text('副标题', style: TextStyle(fontSize: 16.sp)),
  ],
)
```

**Row（水平布局）**
- ✅ 适用于水平排列的元素
- ✅ 常用于图标+文字、按钮组

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Icon(Icons.star, size: 24.w),
    SizedBox(width: 8.w),
    Text('收藏'),
  ],
)
```

**Stack（堆叠布局）**
- ✅ 适用于重叠的元素
- ✅ 常用于背景图+文字、徽章

```dart
Stack(
  children: [
    Image.network(imageUrl),
    Positioned(
      top: 16.h,
      right: 16.w,
      child: Icon(Icons.favorite),
    ),
  ],
)
```

**ListView.builder（列表）**
- ✅ 适用于动态列表
- ✅ 按需创建，性能好

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
    );
  },
)
```

### 7. 输出格式

#### 完整输出包含

1. **UI 分析报告**
```markdown
## UI 设计分析报告

### 1. 布局结构
- 根布局：Scaffold
- Body：Column
- 层级：3 层
- 元素数量：8 个

### 2. UI 元素清单
| Widget | 说明 | 尺寸 |
|--------|------|------|
| AppBar | 顶部导航栏 | 56.h |
| Text | 标题 | 24.sp |
| TextField | 手机号输入 | 56.h |
| ElevatedButton | 登录按钮 | 48.h |

### 3. 颜色方案
- 主题色：#4CAF50（绿色）
- 背景色：#FFFFFF（白色）
- 文字色：#212121（深灰）

### 4. 间距规范
- 页面边距：16.w
- 元素间距：12.w
- 按钮高度：48.h
```

2. **Flutter Widget 代码**
```dart
// presentation/pages/login/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kikichain/config/app_color.dart';
import 'package:kikichain/presentation/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120.w,
                height: 120.h,
              ),
            ),
            SizedBox(height: 48.h),

            // 手机号输入
            TextField(
              controller: controller.phoneController,
              decoration: InputDecoration(
                labelText: '手机号',
                hintText: '请输入手机号',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),

            // 密码输入
            Obx(() => TextField(
              controller: controller.passwordController,
              obscureText: controller.isPasswordHidden.value,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            )),
            SizedBox(height: 24.h),

            // 登录按钮
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
            )),
          ],
        ),
      ),
    );
  }
}
```

3. **GetX Controller 代码**
```dart
// presentation/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/core/logging/app_logger.dart';

class LoginController extends GetxController {
  // Controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // 响应式变量
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  // 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // 登录
  Future<void> login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    // 验证
    if (phone.isEmpty || password.isEmpty) {
      Get.snackbar('提示', '请输入手机号和密码');
      return;
    }

    try {
      isLoading.value = true;

      // TODO: 调用登录 API
      await Future.delayed(Duration(seconds: 2));

      Get.snackbar('成功', '登录成功');
      // 跳转到首页
      // Get.offNamed('/home');
    } catch (e) {
      AppLogger.e('LoginController', 'Login failed: $e');
      Get.snackbar('错误', '登录失败，请重试');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
```

### 8. 常见 UI 模式识别

#### 模式 1：登录/注册页面
**识别特征：**
- Logo（顶部居中）
- 输入框（用户名/手机号/邮箱）
- 输入框（密码）
- 主按钮（登录/注册）
- 次要操作（忘记密码、第三方登录）

**标准 Widget 结构：**
```dart
Scaffold(
  appBar: AppBar(...),
  body: SingleChildScrollView(
    child: Column(
      children: [
        Image.asset('logo'),         // Logo
        TextField(...),              // 用户名
        TextField(obscureText: true), // 密码
        ElevatedButton(...),         // 登录
        TextButton(...),             // 忘记密码
      ],
    ),
  ),
)
```

#### 模式 2：列表页面
**识别特征：**
- 顶部搜索框或标题
- ListView 列表
- 底部操作按钮（可选）

**标准 Widget 结构：**
```dart
Scaffold(
  appBar: AppBar(...),
  body: Column(
    children: [
      TextField(...),              // 搜索框
      Expanded(
        child: ListView.builder(...), // 列表
      ),
    ],
  ),
  floatingActionButton: FloatingActionButton(...),
)
```

#### 模式 3：详情页面
**识别特征：**
- 顶部大图或 Banner
- 标题和副标题
- 内容区域（ScrollView）
- 底部操作按钮

**标准 Widget 结构：**
```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(
        expandedHeight: 200.h,
        flexibleSpace: FlexibleSpaceBar(
          background: Image.network(imageUrl),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Text('标题', style: ...),
              Text('副标题', style: ...),
              // 详情内容
            ],
          ),
        ),
      ),
    ],
  ),
  bottomNavigationBar: Container(
    child: ElevatedButton(...),
  ),
)
```

#### 模式 4：表单页面
**识别特征：**
- 多个输入框（垂直排列）
- 分组标题
- 提交按钮

**标准 Widget 结构：**
```dart
Scaffold(
  appBar: AppBar(...),
  body: SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('基本信息', style: ...),
          TextField(...),  // 姓名
          TextField(...),  // 年龄
          SizedBox(height: 24.h),
          Text('联系方式', style: ...),
          TextField(...),  // 手机
          TextField(...),  // 邮箱
          SizedBox(height: 32.h),
          ElevatedButton(...), // 提交
        ],
      ),
    ),
  ),
)
```

### 9. 响应式设计（Pad/Mobile）

#### 使用 LayoutBuilder
```dart
class ResponsivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Pad 布局（宽度 > 600）
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              // 左侧导航
              Container(
                width: 200.w,
                child: NavigationRail(...),
              ),
              // 右侧内容
              Expanded(
                child: ContentArea(),
              ),
            ],
          );
        }

        // Mobile 布局
        return Scaffold(
          body: ContentArea(),
          bottomNavigationBar: BottomNavigationBar(...),
        );
      },
    );
  }
}
```

#### 使用 MediaQuery
```dart
class AdaptivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,  // Pad 3列，Mobile 2列
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemBuilder: (context, index) => ItemCard(),
      ),
    );
  }
}
```

### 10. Material Design / Cupertino 适配

#### 自动平台适配
```dart
import 'dart:io';

class PlatformButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PlatformButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // iOS 使用 Cupertino 风格
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    // Android 使用 Material 风格
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

## Anti-Patterns

### ❌ 错误 1：不询问关键信息
```
用户："这是设计稿 [图片]"
我："[直接生成布局，尺寸和颜色全靠猜]"
✗ 问题：尺寸不准确、颜色不匹配
```

**✅ 正确做法：**
```
用户："这是设计稿 [图片]"
我："我看到了设计！请问：
1. 设计稿基准尺寸是多少？（如 375x812）
2. 主题色色值是？（如 #4CAF50）
3. 这是 Mobile 还是 Pad 布局？"
```

### ❌ 错误 2：硬编码尺寸和颜色
```dart
❌ 错误
Container(
  width: 200,
  height: 100,
  color: Color(0xFF4CAF50),
  child: Text(
    '标题',
    style: TextStyle(fontSize: 18),
  ),
)
```

**✅ 正确：使用 ScreenUtil 和颜色常量**
```dart
Container(
  width: 200.w,
  height: 100.h,
  color: AppColors.primary,
  child: Text(
    '标题',
    style: TextStyle(fontSize: 18.sp),
  ),
)
```

### ❌ 错误 3：不使用 const
```dart
❌ 错误
Text('固定文本')  // 每次 rebuild 都创建新对象
```

**✅ 正确：使用 const**
```dart
const Text('固定文本')  // 编译时常量，不会重建
```

### ❌ 错误 4：忽略无障碍
```dart
❌ 错误
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () {},
)
```

**✅ 正确：添加 Semantics**
```dart
IconButton(
  icon: Icon(Icons.delete),
  tooltip: '删除',  // 长按提示
  onPressed: () {},
)
```

## Best Practices

### 1. 分析流程清单

- [ ] **Step 1**：查看完整设计稿，理解整体布局
- [ ] **Step 2**：识别所有 UI 元素（从上到下、从外到内）
- [ ] **Step 3**：询问缺失信息（分辨率、颜色值、尺寸）
- [ ] **Step 4**：选择合适的布局 Widget
- [ ] **Step 5**：绘制 Widget 层级树
- [ ] **Step 6**：生成 Flutter Widget 代码
- [ ] **Step 7**：生成颜色常量和样式
- [ ] **Step 8**：生成 GetX Controller
- [ ] **Step 9**：添加响应式设计（如需要）
- [ ] **Step 10**：提供完整输出（报告 + 代码）

### 2. 询问用户的关键问题

**必问问题：**
1. 设计稿基准尺寸是多少？（用于 ScreenUtil）
2. 主题色的色值是？（#RRGGBB）
3. 这是 Mobile 还是 Pad 布局？

**可选问题：**
1. 是否需要适配暗黑模式？
2. 是否需要适配横屏？
3. 是否需要支持 iOS Cupertino 风格？

### 3. 代码生成规范

**Widget 命名：**
```
页面：XxxPage
组件：XxxWidget / XxxCard / XxxItem
按钮：XxxButton
```

**文件组织：**
```
presentation/pages/xxx/
├── xxx_page.dart       # 页面 Widget
├── xxx_controller.dart # GetX Controller
└── widgets/            # 页面内部组件
    ├── xxx_header.dart
    └── xxx_footer.dart
```

### 4. 性能优化建议

- ✅ 使用 `const` 构造函数
- ✅ 使用 `ListView.builder` 而非 `ListView`
- ✅ 避免在 `build` 方法中创建对象
- ✅ 使用 `Obx` 而非 `GetBuilder`（性能更好）
- ✅ 图片使用 `cached_network_image` 缓存

## Integration with Other Skills

1. **← requirement-clarification**
   - 需求阶段询问是否有设计稿
   - 如果有，进入 UI 设计分析

2. **→ code-implementation**
   - UI 分析完成后，传递给代码实现
   - 按照生成的 Widget 实现业务逻辑

3. **→ code-review**
   - 审查生成的布局是否符合规范
   - 检查性能、命名、响应式设计

## Quick Reference

### 常用 Flutter Widget 速查

| 设计元素 | Flutter Widget | 常用属性 |
|---------|---------------|---------|
| 文本 | Text | style, textAlign, maxLines |
| 输入框 | TextField | decoration, controller, keyboardType |
| 按钮 | ElevatedButton | onPressed, child, style |
| 图片 | Image | fit, width, height |
| 图标 | Icon | size, color |
| 列表 | ListView.builder | itemCount, itemBuilder |
| 滚动 | SingleChildScrollView | child, scrollDirection |
| 卡片 | Card | elevation, shape, child |
| 容器 | Container | width, height, color, decoration |
| 布局 | Column/Row | children, mainAxisAlignment, crossAxisAlignment |

### 常用尺寸速查（ScreenUtil）

| 用途 | 推荐尺寸 |
|------|---------|
| 页面边距 | 16.w - 24.w |
| 元素间距 | 8.w - 16.w |
| 按钮高度 | 48.h |
| 输入框高度 | 56.h |
| AppBar 高度 | 56.h |
| 标题文字 | 20.sp - 24.sp |
| 正文文字 | 14.sp - 16.sp |
| 小字 | 12.sp |
| 圆角 | 4.r - 8.r |

---

**重要提示**：始终询问用户关键信息（分辨率、颜色、布局类型），并使用 ScreenUtil 进行适配！
