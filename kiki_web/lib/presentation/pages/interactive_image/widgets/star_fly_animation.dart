import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// 独立的星星奖励动画组件（可供全局任意页面/场景轻松调用）
///
/// 使用方式：
/// ```dart
/// StarRewardAnimator.play(
///   context: context,
///   startPosition: tapPosition,
///   targetPosition: targetStarPosition,
///   onArrived: () {
///     // 动画落地回调
///   },
/// );
/// ```
class StarRewardAnimator {
  static OverlayEntry? _activeEntry;

  /// 播放星星飞翔动画
  ///
  /// [context]：调用上下文，用于获取 Overlay
  /// [startPosition]：起点（全局坐标，如点击处）
  /// [targetPosition]：终点（全局坐标，如右上角星星框中心）
  /// [onArrived]：到达终点时的回调
  static void play({
    required BuildContext context,
    required Offset startPosition,
    required Offset targetPosition,
    required VoidCallback onArrived,
  }) {
    // 移除当前正在播放的动画（防止多星连击重叠）
    cancel();

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _StarFlyWidget(
        startPosition: startPosition,
        targetPosition: targetPosition,
        onArrived: () {
          onArrived();
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  /// 取消当前播放的动画
  static void cancel() {
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _StarFlyWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset targetPosition;
  final VoidCallback onArrived;

  const _StarFlyWidget({
    required this.startPosition,
    required this.targetPosition,
    required this.onArrived,
  });

  @override
  State<_StarFlyWidget> createState() => _StarFlyWidgetState();
}

class _StarFlyWidgetState extends State<_StarFlyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const double _starSize = 34.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      // 1800ms：包含起飞到中心、中心悬浮旋转放大、快速落袋三个阶段
      duration: const Duration(milliseconds: 1800),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onArrived();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 计算二次贝塞尔曲线上的点
  Offset _bezier(Offset p0, Offset p1, Offset p2, double t) {
    final double mt = 1.0 - t;
    return p0 * (mt * mt) + p1 * (2.0 * mt * t) + p2 * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final centerPos = Offset(screenSize.width / 2, screenSize.height / 2);

    // 计算第一阶段弧度控制点（起点到中心点连线上方）
    final double c1Y = math.min(widget.startPosition.dy, centerPos.dy) - 140.0;
    final Offset control1 = Offset(
      (widget.startPosition.dx + centerPos.dx) / 2,
      c1Y.clamp(40.0, screenSize.height),
    );

    // 计算第二阶段弧度控制点（中心点到终点连线上方）
    final double c2Y = math.min(centerPos.dy, widget.targetPosition.dy) - 100.0;
    final Offset control2 = Offset(
      (centerPos.dx + widget.targetPosition.dx) / 2,
      c2Y.clamp(40.0, screenSize.height),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        Offset position;
        double scale;
        double rotation;
        double opacity = 1.0;

        if (t <= 0.35) {
          // ─── 阶段 1：从小变大飞向屏幕中心 (0.0 -> 0.35) ───
          final double progress = (t / 0.35).clamp(0.0, 1.0);
          position = _bezier(widget.startPosition, control1, centerPos, progress);
          // 尺寸从小到大：0.0 -> 3.0 (带回弹效果，更显张力)
          scale = Curves.easeOutBack.transform(progress) * 3.0;
          // 一次螺旋上升旋转：自转 1 圈 (2 * pi)
          rotation = progress * (2 * math.pi);
        } else if (t <= 0.70) {
          // ─── 阶段 2：屏幕中心脉动旋转 (0.35 -> 0.70) ───
          final double progress = ((t - 0.35) / 0.35).clamp(0.0, 1.0);
          position = centerPos;
          // 心跳脉动效果：3.0 -> 2.2 -> 3.6 -> 2.5
          if (progress <= 0.3) {
            final double p = (progress / 0.3).clamp(0.0, 1.0);
            scale = lerpDouble(3.0, 2.2, Curves.easeInOut.transform(p))!;
          } else if (progress <= 0.7) {
            final double p = ((progress - 0.3) / 0.4).clamp(0.0, 1.0);
            scale = lerpDouble(2.2, 3.6, Curves.elasticOut.transform(p))!;
          } else {
            final double p = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
            scale = lerpDouble(3.6, 2.5, Curves.easeInOut.transform(p))!;
          }
          // 保持第一阶段旋转后的朝向 (不再自转)
          rotation = 2 * math.pi;
        } else {
          // ─── 阶段 3：从中心快速飞向目标点并变小 (0.70 -> 1.0) ───
          final double progress = ((t - 0.70) / 0.30).clamp(0.0, 1.0);
          position = _bezier(centerPos, control2, widget.targetPosition, progress);
          // 尺寸收缩：2.5 -> 0.8，极速缩回套入目标星框
          scale = lerpDouble(2.5, 0.8, Curves.easeIn.transform(progress))!;
          // 保持朝向 (不再自转)
          rotation = 2 * math.pi;
          // 落地前 20% 时间内淡出，避免与亮起的星发生突兀重叠
          if (progress >= 0.8) {
            opacity = lerpDouble(1.0, 0.0, ((progress - 0.8) / 0.2).clamp(0.0, 1.0))!;
          }
        }

        return Positioned(
          left: position.dx - _starSize / 2,
          top: position.dy - _starSize / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: const _GradientStarIcon(
                    icon: Icons.star_rounded,
                    size: _starSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 3D 渐变金色星星组件
class _GradientStarIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _GradientStarIcon({
    Key? key,
    required this.icon,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEA79), // 亮金顶光
            Color(0xFFFFB800), // 饱满金黄
            Color(0xFFE58F00), // 底部暗金阴影
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(bounds);
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // ShaderMask 遮罩基色必须为白色
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 1.5),
            blurRadius: 1.5,
          ),
          Shadow(
            color: const Color(0xFFFFD700).withOpacity(0.35),
            offset: Offset.zero,
            blurRadius: 4.0,
          ),
        ],
      ),
    );
  }
}
