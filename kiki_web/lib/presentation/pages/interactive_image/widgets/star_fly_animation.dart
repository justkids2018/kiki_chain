import 'package:flutter/material.dart';

/// 星星飞翔动画控制器
///
/// 效果：从点击位置飞向屏幕中央悬停并做 3D 脉动缩放，随后快速飞向目标星星栏，
/// 到达后点亮并播放音效。
class StarFlyAnimationController {
  OverlayEntry? _entry;

  /// 触发一次飞翔动画
  ///
  /// [overlayState]：当前页面的 Overlay
  /// [startPosition]：起飞点（全局坐标，词语点击处）
  /// [targetPosition]：降落点（全局坐标，目标星星中心）
  /// [onArrived]：动画完成回调
  void launch({
    required OverlayState overlayState,
    required Offset startPosition,
    required Offset targetPosition,
    required VoidCallback onArrived,
  }) {
    _entry?.remove();
    _entry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _StarFlyWidget(
        startPosition: startPosition,
        targetPosition: targetPosition,
        onArrived: () {
          onArrived();
          entry.remove();
        },
      ),
    );

    _entry = entry;
    overlayState.insert(entry);
  }

  void dispose() {
    _entry?.remove();
    _entry = null;
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
  late final Animation<Offset> _positionAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  static const double _starSize = 28.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      // 1600ms：包含起飞到中心、中心缩放脉动、快速落袋三个阶段
      duration: const Duration(milliseconds: 1600),
    );

    // 计算屏幕中心位置，由多段 TweenSequence 控制运动轨迹
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final screenSize = MediaQuery.of(context).size;
      final centerPos = Offset(screenSize.width / 2, screenSize.height / 2);

      _setupAnimations(centerPos);
      _controller.forward();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onArrived();
      }
    });
  }

  void _setupAnimations(Offset centerPos) {
    // 轨迹：起飞 -> 悬停屏幕中心 -> 快速落到目标点
    _positionAnim = TweenSequence<Offset>([
      // 1. 起飞阶段：从起点飞到屏幕中心 (占 35% 时间)
      TweenSequenceItem(
        tween: Tween<Offset>(begin: widget.startPosition, end: centerPos)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      // 2. 悬停阶段：在屏幕中心悬停做脉动动画 (占 35% 时间)
      TweenSequenceItem(
        tween: ConstantTween<Offset>(centerPos),
        weight: 35,
      ),
      // 3. 落袋阶段：从屏幕中心快速飞向右上角目标星星 (占 30% 时间)
      TweenSequenceItem(
        tween: Tween<Offset>(begin: centerPos, end: widget.targetPosition)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 缩放：起飞变大 -> 中心脉动(缩->放->收缩弹跳) -> 快速落袋变小
    _scaleAnim = TweenSequence<double>([
      // 1. 飞向中心阶段：从 0.5 变大至 2.8 倍，显眼突出
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 2.8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      // 2. 中心脉动阶段：大 -> 小 -> 极大 -> 回弹 (2.8 -> 1.6 -> 3.2 -> 2.0)
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.8, end: 1.6)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.6, end: 3.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 13,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 3.2, end: 2.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      // 3. 落袋阶段：从 2.0 相应缩小到 0.9，完美套入 InlineStarBar 目标框
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 透明度：绝大部分时间完全可见，在落袋最后一瞬间淡出，让位给 InlineStarBar 点亮状态
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 85),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // 在第一帧绘制（未初始化多段动画）前返回空
        if (_controller.value == 0.0 && !(_controller.isAnimating)) {
          return const SizedBox.shrink();
        }

        final pos = _positionAnim.value;
        final scale = _scaleAnim.value;
        final opacity = _opacityAnim.value;

        return Positioned(
          left: pos.dx - _starSize / 2,
          top: pos.dy - _starSize / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: const _GradientStarIcon(
                  icon: Icons.star_rounded,
                  size: _starSize,
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
