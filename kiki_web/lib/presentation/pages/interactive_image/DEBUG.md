# InteractiveImage 调试指南

## 🐛 常见问题诊断

### 问题：图片不显示

**可能的原因和解决方案**：

1. **图片资源未正确加载**
   - 检查 `pubspec.yaml` 中是否有 `assets/images/` 配置
   - 运行 `flutter pub get` 和 `flutter clean` 重新构建
   - 检查 `assets/images/kiki_zhiwuyuan.jpg` 文件是否存在

2. **TTS 初始化阻塞**
   - 新版本已处理 TTS 初始化失败，应该继续加载
   - 检查日志是否有 "TTS initialization error" 信息

3. **图片尺寸为 0**
   - 检查日志输出中的 "Image dimensions" 是否显示非零值
   - 如果显示 "1920 x 1080"（默认值），说明加载失败

4. **JSON 数据未加载**
   - 检查 `assets/data/kiki_zhiwuyuan.json` 是否存在
   - 查看日志中 "Loaded X regions" 的信息

### 📊 调试日志

运行应用时，Console 中会打印以下信息：

```
Controller: Starting initialization
Controller: Initializing TTS
Controller: TTS initialized successfully  // 或 TTS initialization failed
Controller: Starting data loading
Loaded XX regions
Image dimensions: XXXX x XXXX
Controller: Data loading completed
Controller: UI marked as loaded
Interactive Image Diagnostics:
- isLoaded: true
- imageWidth: XXXX
- imageHeight: XXXX
- regions count: XX
- loadingProgress: 100.0%
- error: none
```

### 🔍 检查清单

- [ ] `assets/images/kiki_zhiwuyuan.jpg` 文件存在且有效
- [ ] `assets/data/kiki_zhiwuyuan.json` 文件存在且格式正确
- [ ] `pubspec.yaml` 配置了 `assets/images/` 和 `assets/data/`
- [ ] 运行了 `flutter pub get` 和 `flutter clean`
- [ ] 控制台日志显示 "isLoaded: true" 且 "error: none"
- [ ] 图片尺寸不为 0（如果为 1920x1080 是默认值，表示加载失败）

### 🛠️ 手动测试

在 Flutter 代码中手动测试：

```dart
// 在 main.dart 中测试
import 'package:flutter/services.dart';

void debugTestInteractiveImage() async {
  // 测试 JSON 加载
  try {
    final String response = await rootBundle.loadString('assets/data/kiki_zhiwuyuan.json');
    print("JSON loaded: ${response.length} bytes");
  } catch (e) {
    print("JSON load error: $e");
  }

  // 测试图片加载
  try {
    final data = await rootBundle.load('assets/images/kiki_zhiwuyuan.jpg');
    print("Image loaded: ${data.lengthInBytes} bytes");
  } catch (e) {
    print("Image load error: $e");
  }
}
```

## 更新记录

- 添加详细的日志输出便于诊断
- TTS 初始化失败不再阻塞应用
- 增加错误状态和重试功能
