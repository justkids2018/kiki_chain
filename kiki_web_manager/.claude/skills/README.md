# Flutter 项目 Claude Code Skills 能力清单

本文档总结了针对 **kikichain** Flutter 跨平台项目的 Claude Code Skills 配置，涵盖需求开发、代码审查、Bug 分析等核心能力。

---

## 📚 Skills 概览

### ✅ 当前配置的 Skills（5个）

| Skill | 说明 | 适用场景 | 自动触发 | 状态 |
|-------|------|---------|---------|------|
| **requirement-clarification** | 需求澄清 | 需求分析、功能规格 | 手动 | ✅ Flutter 适配 |
| **ui-design-analysis** | UI 设计分析 | 设计稿→Widget代码 | 图片输入时 | ✅ Flutter 专项（已重写） |
| **code-implementation** | 代码实现规范 | 编写代码、实现功能 | 手动 | ✅ Flutter/Dart/GetX 专项（已重写） |
| **code-review** | 代码审查 | 质量检查、规范审查 | ✅ 自动 | ✅ Flutter 检查清单 |
| **bug-analysis** | Bug 分析和诊断 | 崩溃分析、问题定位 | 手动 | ✅ Flutter 专项 |

> **自动化流程**: `requirement-clarification` → 提供设计稿 → `ui-design-analysis` → `code-implementation` → **自动触发** `code-review` → 发现 bug 时手动调用 `bug-analysis`

---

## 🎯 核心能力详解

### 1. Requirement Clarification（需求澄清）

**触发条件：**
- 收到新需求
- 需求不明确
- 功能规格定义

**核心能力：**
1. **需求分析** - 识别模糊点和缺失信息
2. **拆解任务** - 分解成可执行的开发步骤
3. **评估技术方案** - 基于项目架构提供建议
4. **创建实施计划** - 包含优先级和依赖关系

**专项 Prompts**：
- `flutter-page-feature.md` - Flutter 页面功能需求澄清
- `flutter-widget-feature.md` - 自定义 Widget 需求澄清
- `getx-state-feature.md` - GetX 状态管理需求澄清

---

### 2. UI Design Analysis（UI 设计分析）✨ Flutter 专项

**触发条件：**
- 用户提供设计稿图片
- 用户询问"如何实现这个设计"、"生成布局"
- `/dev` 工作流 Phase 3: UI Design

**核心能力：**
1. **图片分析**
   - 识别 UI 元素（Text、TextField、Button 等）
   - 分析布局结构（Column/Row/Stack/ListView）
   - 提取颜色值（#RRGGBB）
   - 估算尺寸和间距（使用 ScreenUtil）

2. **代码生成**
   - Flutter Widget 代码
   - AppColors 颜色常量
   - AppDimens 尺寸常量
   - GetX Controller 骨架

3. **支持输入方式**
   - 设计稿截图（推荐）
   - Figma 链接
   - 手绘草图

**使用示例：**
```bash
用户："这是登录页面设计 [拖拽图片]，帮我实现"

我："✅ 分析完成：
布局：Column + SingleChildScrollView
元素：Logo (Image.asset 120x120.w)
      手机号 (TextField, keyboardType: phone)
      密码 (TextField, obscureText: true)
      登录按钮 (ElevatedButton, 主题色)
颜色：Primary #4CAF50, Text #212121

正在生成：
1. login_page.dart (Flutter Widget)
2. login_controller.dart (GetX Controller)
3. AppColors 常量"
```

**输出文件：**
- UI 分析报告（Widget 清单、颜色、尺寸）
- Flutter Widget 代码
- GetX Controller 代码
- 颜色和尺寸常量

---

### 3. Code Implementation（代码实现）✨ Flutter 专项

**触发条件：**
- 准备编写代码
- 架构设计已完成
- 用户询问"如何实现"、"写代码"

**核心能力：**
1. **Flutter Clean Architecture**
   - 三层架构（Presentation/Domain/Data）
   - Repository 模式
   - UseCase 设计

2. **GetX 状态管理**
   - Controller 生命周期（onInit/onReady/onClose）
   - 响应式变量（.obs / Rxn）
   - 响应式 UI（Obx / GetBuilder）
   - Controller 注册（Get.put / Get.lazyPut）

3. **Dart 语言规范**
   - 命名规范（类、文件、变量、函数）
   - Null Safety（`?.`, `??`, `!`, `late`）
   - 异步编程（async/await / Future / Stream）
   - 错误处理（try-catch-finally）

4. **Widget 生命周期**
   - StatelessWidget（const 构造函数）
   - StatefulWidget（initState/dispose）
   - 防止内存泄漏（检查 mounted）

5. **性能优化**
   - 使用 `const` Widget
   - `ListView.builder` 而非 `ListView`
   - 避免在 build 中创建对象

**示例输出：**
```dart
// ✅ 标准 GetX Controller 结构
class UserController extends GetxController {
  // 响应式变量
  final userName = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final data = await repository.getData();
      userName.value = data.name;
    } catch (e) {
      AppLogger.e('UserController', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // 清理资源
    super.onClose();
  }
}
```

**完成后自动触发** → `code-review` skill

---

### 4. Code Review（代码审查）

**自动触发：**
- ✅ 使用 Write/Edit 工具后自动激活
- 代码提交前
- 用户明确要求"Review代码"

**审查维度（Flutter 专项，15 项）：**
1. ✅ 功能完整性 - 所有需求已实现
2. ✅ 代码规范 - 遵循 Dart/Flutter 规范
3. ✅ GetX 最佳实践 - Controller 正确使用
4. ✅ Null Safety - 空安全正确处理
5. ✅ Widget 性能 - const、ListView.builder
6. ✅ 一致性 - 代码风格统一
7. ✅ 设计合理性 - 无过度设计
8. ✅ 错误处理 - 异常捕获完整
9. ✅ 内存管理 - 资源正确清理
10. ✅ 注释文档 - 复杂逻辑有说明
11. ✅ 性能优化 - 无性能瓶颈
12. ✅ 用户体验 - 加载/错误提示
13. ✅ 多平台适配 - ScreenUtil、响应式布局
14. ✅ 项目规范 - 使用 AppLogger、AppColors
15. ✅ Git 提交 - 提交信息清晰

**评分标准：**
- 优秀（90%+）：13-15 项通过 → 可以合并
- 良好（70%-89%）：11-12 项通过 → 修复小问题后合并
- 需改进（<70%）：<11 项通过 → 需要重构

---

### 5. Bug Analysis（Bug 分析）✨ Flutter 专项

**触发条件：**
- 崩溃日志出现
- 用户报告 "bug"、"崩溃"、"不工作"
- Stack Trace 包含 Exception

**核心能力：**
1. **快速定位**
   - 解析 Flutter Stack Trace
   - 定位崩溃代码位置（文件:行号）
   - 追溯变量来源

2. **根因分析**
   - **Null check operator used on a null value** - 空指针
   - **setState() called after dispose()** - 生命周期问题
   - **GetX Controller not found** - 未注册
   - **RenderBox was not laid out** - 布局约束问题
   - **Vertical viewport given unbounded height** - ListView 高度问题

3. **修复方案**
   - 提供多个修复方案（推荐 + 备选）
   - 包含完整 Dart 代码示例
   - 说明优缺点和适用场景

4. **验证检查清单**
   - 编译验证
   - 测试验证
   - 回归测试
   - 类似问题排查

**示例输出：**
```markdown
## Bug 分析报告

### 📋 问题概述
- **错误类型**：Null check operator used on a null value
- **崩溃位置**：`user_controller.dart:45`
- **根本原因**：user.value 为 null 时强制解包

### 🛠️ 修复方案
#### 方案 1（推荐）
```dart
// ❌ 错误
final name = user.value!.name;

// ✅ 正确
final name = user.value?.name ?? 'Unknown';
```

### ✅ 已修复并验证
- [x] 编译通过
- [x] 手动测试通过
```

---

## 🔧 Flutter 专项最佳实践

### 1. GetX 状态管理规范
- 使用 `.obs` 创建响应式变量
- 使用 `Obx(() => ...)` 构建响应式 UI
- 在 `onClose()` 中清理资源
- 避免在 build 方法中使用 `Get.find()`

### 2. Null Safety（空安全）
- 优先使用 `?.` 安全调用
- 使用 `??` 提供默认值
- 避免使用 `!` 强制解包（除非绝对安全）
- 正确使用 `late` 延迟初始化

### 3. Widget 生命周期管理
- StatefulWidget 提供 `initState()` 和 `dispose()`
- 在 `dispose()` 清理资源（Controller、Subscription、AnimationController）
- 异步操作中检查 `mounted` 状态
- 使用 `const` 构造函数优化性能

### 4. 性能优化
- 使用 `const` Widget（不会重建）
- 使用 `ListView.builder`（按需创建）
- 避免在 build 方法中创建对象
- 图片使用缓存（cached_network_image）

### 5. 多平台适配
- 使用 ScreenUtil 适配不同屏幕（.w / .h / .sp / .r）
- 使用 LayoutBuilder 或 MediaQuery 响应式布局
- Pad/Mobile 分别设计布局（>600 宽度判断）
- 考虑 iOS/Android 平台差异

---

## 📝 Skills 使用指南

### 自动激活规则

| 场景 | Skills 链 | 触发关键词 |
|------|----------|-----------|
| 需求澄清 → 代码实现 → 代码审查 | requirement-clarification → code-implementation → code-review | 新需求、实现功能 |
| 代码编写完成 → 代码审查 | code-implementation → code-review | Write/Edit 工具使用后 |
| 崩溃分析 | bug-analysis | Exception、null、crash、崩溃 |
| UI设计 → 代码实现 | ui-design-analysis → code-implementation | 提供设计稿图片 |

### 手动调用方式

用户可以通过以下方式手动触发 Skill：

```bash
# 需求澄清
"帮我澄清需求：添加用户列表功能"
"帮我设计：搜索功能"

# UI 设计分析
"[上传设计稿] 帮我实现这个设计"
"这个 Figma 设计怎么用 Flutter 实现？"

# 代码实现
"如何实现这个功能"
"遵循什么规范写代码"

# 代码审查
"Review 一下代码"
"检查代码质量"

# Bug 分析
"帮我分析这个崩溃"
"这个 null 错误是什么原因"
```

---

## 🎯 针对本项目的优化建议

基于 **kikichain** Flutter 项目特点：

### 1. 重点关注领域
- **GetX 状态管理规范** - 项目核心状态管理方案
- **Null Safety** - Dart 强制空安全，需严格遵守
- **Widget 生命周期** - 防止 setState after dispose
- **多平台适配** - 支持 Android/iOS/Web/Desktop

### 2. 项目特定库使用
- ✅ **日志**：使用 `AppLogger`（`lib/core/logging/app_logger.dart`）
- ✅ **网络**：使用 `Dio` + Interceptors
- ✅ **颜色**：使用 `AppColors`（`lib/config/app_color.dart`）
- ✅ **路由**：使用 `Get.toNamed()` 或 `AppConstants.routeXxx`
- ✅ **适配**：使用 `ScreenUtil`（`.w` / `.h` / `.sp`）

### 3. 自动化检查（推荐集成）
```bash
# Dart 分析
flutter analyze

# 代码格式化
flutter format .

# 测试
flutter test

# 构建检查
flutter build apk --debug
flutter build ios --debug
```

---

## 📦 当前状态

### ✅ 已完成

**Skills（5 个）：**
1. **requirement-clarification** - 需求澄清（Flutter 适配）
2. **ui-design-analysis** - UI 设计分析（✨ Flutter 专项，已重写）
3. **code-implementation** - 代码实现规范（✨ Flutter/Dart/GetX 专项，已重写）
4. **code-review** - 代码审查（Flutter 检查清单）
5. **bug-analysis** - Bug 分析和诊断（Flutter 专项）

**Agents（1 个）：**
- **skill-learner** - 自我学习系统（从审查中学习，自动优化 skills）

**Commands（1 个）：**
- **/dev** - 完整开发工作流（需求 → UI → 代码 → 审查 → 学习）

### 🔄 自动化工作流
```
需求澄清 → 提供设计稿 → UI设计分析 → 代码实现 → 代码审查（自动） → 学习优化（自动）
                                                    ↓
                                              使用 AppLogger / AppColors
```

### 📁 完整文件结构
```
.claude/
├── README.md（主文档 - Flutter 版本）
├── agents/
│   └── skill-learner.md（自我学习系统）
├── commands/
│   └── dev.md（/dev 工作流）
├── hooks/
│   └── post-edit.sh（自动格式化 Dart 代码）
├── scripts/
│   ├── create-page.sh（快速生成 Flutter Page）
│   └── create-controller.sh（快速生成 GetX Controller）
└── skills/
    ├── README.md（本文档 v3.0 Flutter 版）
    ├── requirement-clarification/
    │   ├── SKILL.md
    │   └── prompts/
    │       ├── flutter-page-feature.md
    │       ├── flutter-widget-feature.md
    │       └── getx-state-feature.md
    ├── ui-design-analysis/
    │   └── SKILL.md（Flutter Widget 生成）
    ├── code-implementation/
    │   └── SKILL.md（Flutter/Dart/GetX 专项）
    ├── code-review/
    │   └── SKILL.md（Flutter 检查清单）
    └── bug-analysis/
        └── SKILL.md（Flutter 专项）
```

---

## 📚 参考资料

- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言指南](https://dart.dev/guides)
- [GetX 状态管理](https://pub.dev/packages/get)
- [Flutter 性能优化](https://flutter.dev/docs/perf)
- [ScreenUtil 适配库](https://pub.dev/packages/flutter_screenutil)
- 项目文档：README.md

---

**文档版本：** v3.0 (Flutter)
**最后更新：** 2026-01-17
**适用项目：** kikichain (Flutter Multi-Platform Project)
**技术栈：** Flutter + Dart + GetX + Clean Architecture
**Skills 数量：** 5 个
**支持平台：** Android、iOS、Web、macOS、Windows、Linux
