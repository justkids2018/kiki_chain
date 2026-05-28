/// 笔顺动画速度档位
enum StrokeSpeed {
  slow,      // 慢速 1.0x - 适合初学者仔细观察
  normal,    // 普通 1.8x - 适合点击单字学习
  fast,      // 快速 3.0x - 适合点击图片自动播放
  veryFast,  // 特快 4.0x - 适合快速复习
}

/// 笔顺播放场景类型
enum StrokePlayMode {
  imageClick,      // 点击图片 → 自动用 fast
  characterClick,  // 点击单字 → 自动用 normal
  writePractice,   // 写字练习 → 自动用 slow
  review,          // 快速复习 → 自动用 veryFast
}

/// 笔顺速度配置
class StrokeSpeedConfig {
  /// 速度档位对应的实际速度值
  static const speeds = {
    StrokeSpeed.slow: 1.0,
    StrokeSpeed.normal: 1.8,
    StrokeSpeed.fast: 3.0,
    StrokeSpeed.veryFast: 4.0,
  };

  /// 场景类型对应的默认速度档位
  static const modeDefaults = {
    StrokePlayMode.imageClick: StrokeSpeed.fast,
    StrokePlayMode.characterClick: StrokeSpeed.normal,
    StrokePlayMode.writePractice: StrokeSpeed.slow,
    StrokePlayMode.review: StrokeSpeed.veryFast,
  };

  /// 获取指定档位的速度值
  static double getSpeed(StrokeSpeed speed) {
    return speeds[speed] ?? 1.8;
  }

  /// 获取指定场景的默认速度值
  static double getSpeedForMode(StrokePlayMode mode) {
    final speedLevel = modeDefaults[mode] ?? StrokeSpeed.normal;
    return getSpeed(speedLevel);
  }

  /// 获取指定场景的速度值，支持自定义覆盖
  static double getSpeedForModeWithOverride(
    StrokePlayMode mode, {
    StrokeSpeed? customSpeed,
  }) {
    if (customSpeed != null) {
      return getSpeed(customSpeed);
    }
    return getSpeedForMode(mode);
  }
}
