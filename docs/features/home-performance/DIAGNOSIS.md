# 首页性能诊断

## Failure Signature

Android 日志持续出现：

```text
BufferQueue / BLASTBufferQueue acquireNextBufferLocked:
Can't acquire next buffer. Already acquired max frames 5 max:3 + 2
```

用户现象：刷新首页后手机过热。

## Root Cause

首页存在多个常驻无限动画：LOGO 浮动、星星脉冲、右侧两个 SVG 按钮浮动。它们在首页停留期间持续驱动 Flutter 帧，叠加分类卡片大图渲染，容易让 Android SurfaceView 消费帧落后，从而出现 BufferQueue 堆积并导致发热。

## Evidence

- `home_page.dart` 中 4 个 `AnimatedSvgWidget` 使用 `animate: true`。
- `animated_svg_stub.dart` 中 `float` 和 `pulse` 动画都通过 `AnimationController.repeat(reverse: true)` 无限循环。
- `category_card.dart` 原先使用 `Image.network` 直接按原图解码，没有按显示尺寸限制 `cacheWidth/cacheHeight`。

## Affected Scope

- `kiki_web/lib/presentation/pages/home_page.dart`
- `kiki_web/lib/presentation/widgets/category_card.dart`

## Patch Plan

1. 关闭首页顶栏常驻动画，保留静态 SVG 视觉。
2. 给分类卡片增加 `RepaintBoundary`，降低父级重建时的重绘扩散。
3. 网络封面图按实际显示尺寸和设备 DPR 设置 `cacheWidth/cacheHeight`，降低解码和纹理压力。
4. 降低加载指示器尺寸，避免大面积 loading 动画。

## Regression Risk

低。改动只降低首页装饰性动效与图片解码尺寸，不影响首页数据加载、点击导航、VIP 锁定逻辑。

## Verification Plan

```bash
cd kiki_web
flutter analyze
flutter test
```

移动端验收：

1. 冷启动进入首页，停留 2 分钟，确认设备温度不再快速上升。
2. 横向滑动分类列表，确认图片清晰度可接受、滚动不卡顿。
3. 点击分类、学习记录、个人中心入口，确认导航正常。
4. 观察 logcat，确认 BufferQueue 错误频率明显下降或消失。
