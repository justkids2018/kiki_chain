# InteractiveImage 交互式图片功能文档

**日期**: 2025-10-27
**版本**: 1.0
**代码位置**: lib/presentation/pages/interactive_image/

---

## 📋 功能概述

InteractiveImage 是一个交互式图片学习功能，用户可以点击图片上定义好的区域，系统会自动读出中文、拼音和英文发音。该功能特别适合语言学习、知识普及等场景。

**核心特性**:
- 📍 **区域映射**：支持JSON定义的矩形区域与图片的精确对应
- 🔊 **多语言发音**：支持中文、拼音和英文的文字转语音（TTS）
- 🔍 **缩放与平移**：支持交互式图片查看（缩放、拖拽）
- 🎯 **高效加载**：并行加载区域数据和图片维度信息

---

## 🏗️ 架构设计

### 目录结构

```
lib/presentation/pages/interactive_image/
├── interactive_image_page.dart      # 页面入口
├── interactive_image_controller.dart # 业务逻辑
├── interactive_image_view.dart       # UI 组件
└── services/
    └── text_to_speech_service.dart   # TTS 服务

lib/data/repositories/interactive_image/
├── i_interactive_image_repository.dart      # 接口定义
└── interactive_image_repository_impl.dart   # 实现类

lib/domain/entities/
└── interactive_region.dart          # 数据实体
```

### 数据流向

```
Page (InteractiveImagePage)
  ↓
Controller (InteractiveImageController)
  ├→ Repository (数据加载：JSON、图片维度)
  ├→ Service (TTS 发音)
  └→ Widget (UI 渲染)
```

---

## 🔧 核心组件说明

### 1. InteractiveImagePage (页面)
**文件**: `lib/presentation/pages/interactive_image/interactive_image_page.dart`

主页面组件，负责：
- 初始化 Controller
- 包装 InteractiveViewer（提供缩放和平移功能）
- 展示加载状态和交互式图片

### 2. InteractiveImageController (业务逻辑)
**文件**: `lib/presentation/pages/interactive_image/interactive_image_controller.dart`

控制器，负责：
- 数据加载编排（并行加载区域和图片维度）
- TTS 初始化和调用
- 公开区域数据和图片维度供 UI 使用

**核心属性**:
```dart
final regions = <InteractiveRegion>[].obs;           // 交互区域列表
final imageWidth = 1.0.obs;                          // 图片原始宽度
final imageHeight = 1.0.obs;                         // 图片原始高度
final isLoaded = false.obs;                          // 加载完成标志
```

**核心方法**:
```dart
Future<void> speakRegion(InteractiveRegion region)   // 发音区域中文和英文
Future<void> speakPinyin(InteractiveRegion region)   // 只发音拼音
```

### 3. InteractiveImageView (UI 组件)
**文件**: `lib/presentation/pages/interactive_image/interactive_image_view.dart`

自定义 Widget，负责：
- 根据约束条件计算图片显示尺寸
- 渲染背景图片
- 在图片上绘制可交互的区域矩形
- 处理点击事件并回调给 Controller

### 4. TextToSpeechService (TTS 服务)
**文件**: `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`

TTS 管理服务，负责：
- 初始化 Flutter TTS 引擎
- 管理音频类别和优先级
- 提供灵活的发音接口

### 5. IInteractiveImageRepository (数据访问)
**文件**: `lib/data/repositories/interactive_image/i_interactive_image_repository.dart`

Repository 接口，定义数据加载契约：
```dart
Future<List<InteractiveRegion>> loadRegions()        // 从 JSON 加载区域
Future<Map<String, double>> loadImageDimensions()    // 加载图片尺寸
```

---

## 📊 数据模型

### InteractiveRegion
```dart
class InteractiveRegion {
  final String type;              // 区域类型 (如 "chinese")
  final String id;                // 唯一标识 (如 "chinese_pinyin_01")
  final int index;                // 显示顺序
  final String text;              // 中文文本 (如 "大花朵")
  final String textPinyin;        // 拼音 (如 "dà huā duǒ")
  final String textEnglish;       // 英文 (如 "Giant Flower")
  final List<RegionCoordinate> coordinates;  // 矩形四个顶点坐标
}
```

### JSON 格式
```json
[
  {
    "type": "chinese",
    "id": "chinese_pinyin_01",
    "index": 1,
    "text": "大花朵",
    "text_pinyin": "dà huā duǒ",
    "text_english": "Giant Flower",
    "coordinate": [
      { "x": 510, "y": 633 },
      { "x": 726, "y": 633 },
      { "x": 510, "y": 771 },
      { "x": 726, "y": 771 }
    ]
  }
]
```

---

## 🚀 使用指南

### 基础使用

1. **导入页面**
```dart
import 'package:kikichain/presentation/pages/interactive_image/interactive_image_page.dart';
```

2. **添加路由**（已配置在 `lib/config/app_routes.dart`）
```dart
GetPage(
  name: AppConstants.routeInteractiveImage,
  page: () => const InteractiveImagePage(),
)
```

3. **导航到页面**
```dart
Get.toNamed(AppConstants.routeInteractiveImage);
```

### 高级使用

#### 1. 自定义数据源
```dart
class CustomRepository implements IInteractiveImageRepository {
  @override
  Future<List<InteractiveRegion>> loadRegions() async {
    // 从网络或数据库加载
    final response = await http.get('https://api.example.com/regions');
    return (json.decode(response.body) as List)
        .map((e) => InteractiveRegion.fromJson(e))
        .toList();
  }

  @override
  Future<Map<String, double>> loadImageDimensions(String imagePath) async {
    // 自定义逻辑
  }
}

// 在 Controller 初始化时注入
final controller = InteractiveImageController(
  repository: CustomRepository(),
);
```

#### 2. 自定义 TTS 服务
```dart
class CustomTtsService extends TextToSpeechService {
  @override
  Future<void> speakRegion(InteractiveRegion region) async {
    // 自定义发音逻辑（例如调用云端 TTS API）
    await super.speakRegion(region);
  }
}

final controller = InteractiveImageController(
  ttsService: CustomTtsService(),
);
```

---

## 🧪 测试指南

### 单元测试示例

```dart
// test/presentation/pages/interactive_image/controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('InteractiveImageController', () {
    test('should load regions on init', () async {
      final controller = InteractiveImageController();
      await controller.onInit();
      expect(controller.regions, isNotEmpty);
    });
  });
}
```

---

## 📝 常见问题

### Q: 如何修改图片和 JSON 数据源？
**A**: 修改 `InteractiveImageRepositoryImpl` 的构造参数：
```dart
InteractiveImageRepositoryImpl(
  dataJsonPath: 'assets/data/custom_image.json',
)
```

### Q: TTS 在某些语言上不工作？
**A**: 确保设备已安装相应语言的 TTS 数据。参考 [flutter_tts 文档](https://pub.dev/packages/flutter_tts)。

---

## 📚 相关资源

- [Flutter GetX 文档](https://pub.dev/packages/get)
- [Flutter TTS 文档](https://pub.dev/packages/flutter_tts)
- [Flutter InteractiveViewer 文档](https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html)

---

## 更新记录

| 版本 | 日期 | 描述 |
|------|------|------|
| 1.0 | 2025-10-27 | 初始版本，代码简化到 lib/presentation/pages/interactive_image/ |
