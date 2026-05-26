# InteractiveImage 模块

**位置**: lib/presentation/pages/interactive_image/
**日期**: 2025-10-27

---

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| `interactive_image_page.dart` | 页面入口组件，处理 UI 布局 |
| `interactive_image_controller.dart` | GetX 控制器，管理业务逻辑 |
| `interactive_image_view.dart` | 自定义 Widget，渲染交互区域 |
| `services/text_to_speech_service.dart` | TTS 管理服务 |
| `DEBUG.md` | 调试指南和常见问题解决方案 |

---

## 🎯 核心职责

- **Page**: 页面框架、加载状态、缩放平移、错误处理、重试
- **Controller**: 数据加载、音频播放预热、业务编排、诊断信息
- **Widget**: 图片渲染、区域绘制、点击交互、错误显示
- **Service**: 统一音频播放入口，URL 缓存播放 + TTS 回退

---

## 🚀 快速开始

### 导入使用
```dart
import 'package:kikichain/presentation/pages/interactive_image/interactive_image_page.dart';

Get.toNamed(AppConstants.routeInteractiveImage);
```

### 依赖注入
```dart
// 自定义 Repository
final controller = InteractiveImageController(
  repository: CustomRepository(),
  audioPlayback: CustomAudioPlaybackComponent(),
);
```

---

## 📖 加载流程

```
页面初始化
  ↓
Controller.onInit() 调用
  ↓
音频播放预热 (URL 缓存 + TTS 初始化，失败不阻塞)
  ↓
并行加载:
  ├─ JSON 区域数据
  └─ 图片尺寸
  ↓
UI 显示图片和交互区域
```

---

## 🔍 诊断

### 查看诊断信息
```dart
// 在 Console 中查看日志：
// ✓ Loaded XX regions
// ✓ Image dimensions loaded: XXXX x XXXX
// InteractiveImage Diagnostics: ...
```

### 常见问题

1. **图片不显示**
   - 检查 Console 日志中的 "Image dimensions loaded" 信息
   - 确认 `pubspec.yaml` 有 `assets/images/` 配置
   - 运行 `flutter clean && flutter pub get`

2. **区域不可点击**
   - 检查 "Loaded XX regions" 是否显示有数据
   - 验证 JSON 文件格式正确

3. **音频不工作**
   - 这是可选的，不影响图片显示
  - 检查 Console 中的 "audio warmup" / "RemoteAudio" 信息

4. **URL 音频首次播放较慢**
  - 首次会下载并缓存到本地
  - 第二次播放会直接走本地缓存

详见 `DEBUG.md`

---

## 🔗 相关代码

- **数据实体**: `lib/domain/entities/interactive_region.dart`
- **Repository**: `lib/data/repositories/interactive_image/`
- **路由配置**: `lib/config/app_routes.dart`
- **资源数据**: `assets/data/kiki_zhiwuyuan.json`
- **图片资源**: `assets/images/kiki_zhiwuyuan.jpg`

---

## 📝 最近改进

- ✅ 添加详细的日志和诊断信息
- ✅ TTS 初始化失败不再阻塞应用
- ✅ 图片加载失败使用默认尺寸避免显示为空
- ✅ 错误状态显示友好提示和重试按钮
- ✅ 加载进度显示百分比
