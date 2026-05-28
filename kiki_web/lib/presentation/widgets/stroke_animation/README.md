# 笔顺动画组件

独立的笔顺动画播放组件，支持多种速度档位和场景模式。

## 功能特性

- ✅ 预设速度档位：慢速、普通、快速、特快
- ✅ 场景自动匹配：根据使用场景自动选择合适的速度
- ✅ 灵活覆盖：支持手动指定速度覆盖默认值
- ✅ 统一配置：所有速度配置集中管理

## 速度档位

| 档位 | 速度值 | 适用场景 |
|------|--------|----------|
| `StrokeSpeed.slow` | 1.0x | 初学者仔细观察笔顺 |
| `StrokeSpeed.normal` | 1.8x | 点击单字学习 |
| `StrokeSpeed.fast` | 3.0x | 点击图片自动播放 |
| `StrokeSpeed.veryFast` | 4.0x | 快速复习 |

## 场景类型

| 场景 | 默认速度 | 说明 |
|------|----------|------|
| `StrokePlayMode.imageClick` | fast | 点击图片，自动播放所有字 |
| `StrokePlayMode.characterClick` | normal | 点击单个字学习 |
| `StrokePlayMode.writePractice` | slow | 写字练习模式 |
| `StrokePlayMode.review` | veryFast | 快速复习模式 |

## 使用方法

### 1. 基础使用（自动匹配速度）

```dart
// 在 controller 中
import '../../widgets/stroke_animation/stroke_speed_config.dart';

// 点击图片场景 - 自动使用 fast 速度
animationSpeed.value = StrokeSpeedConfig.getSpeedForMode(
  StrokePlayMode.imageClick,
);

// 点击单字场景 - 自动使用 normal 速度
animationSpeed.value = StrokeSpeedConfig.getSpeedForMode(
  StrokePlayMode.characterClick,
);
```

### 2. 手动覆盖速度

```dart
// 使用自定义速度覆盖默认值
animationSpeed.value = StrokeSpeedConfig.getSpeedForModeWithOverride(
  StrokePlayMode.characterClick,
  customSpeed: StrokeSpeed.slow,  // 覆盖为慢速
);
```

### 3. 直接获取速度值

```dart
// 获取指定档位的速度值
double speed = StrokeSpeedConfig.getSpeed(StrokeSpeed.fast);  // 3.0
```

## 配置修改

如需调整速度值，只需修改 `stroke_speed_config.dart` 中的配置：

```dart
static const speeds = {
  StrokeSpeed.slow: 1.0,      // 修改慢速值
  StrokeSpeed.normal: 1.8,    // 修改普通速度值
  StrokeSpeed.fast: 3.0,      // 修改快速值
  StrokeSpeed.veryFast: 4.0,  // 修改特快值
};
```

## 扩展场景

如需添加新场景，在 `StrokePlayMode` 枚举中添加，并在 `modeDefaults` 中配置默认速度：

```dart
enum StrokePlayMode {
  imageClick,
  characterClick,
  writePractice,
  review,
  newScene,  // 新场景
}

static const modeDefaults = {
  // ...
  StrokePlayMode.newScene: StrokeSpeed.normal,  // 配置默认速度
};
```

## 示例

### 完整示例：点击图片播放

```dart
Future<void> speakRegion(InteractiveRegion region) async {
  // 1. 设置速度（自动使用 fast）
  animationSpeed.value = StrokeSpeedConfig.getSpeedForMode(
    StrokePlayMode.imageClick,
  );

  // 2. 更新 UI
  activeRegion.value = region;
  _scheduleCharacterAnimation(region.text);

  // 3. 播放音频
  await _audioPlayback.playRegion(region);
}
```

### 完整示例：点击单字学习

```dart
Future<void> speakChineseChar(String character) async {
  // 1. 设置速度（自动使用 normal）
  animationSpeed.value = StrokeSpeedConfig.getSpeedForMode(
    StrokePlayMode.characterClick,
  );

  // 2. 播放动画和音频
  // ...
}
```

## 文件结构

```
lib/presentation/widgets/stroke_animation/
├── README.md                    # 本文档
├── stroke_speed_config.dart     # 速度配置（核心）
└── (未来扩展)
    ├── stroke_animation_player.dart      # 播放器
    └── stroke_animation_controller.dart  # 控制器
```

## 注意事项

1. **统一使用配置**：所有地方都应该通过 `StrokeSpeedConfig` 获取速度，不要硬编码速度值
2. **场景优先**：优先使用场景类型，让系统自动匹配速度
3. **谨慎覆盖**：只在确实需要时才手动覆盖速度
4. **保持一致**：同一场景在不同地方应该使用相同的速度配置
