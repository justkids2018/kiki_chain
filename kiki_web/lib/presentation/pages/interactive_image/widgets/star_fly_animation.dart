import 'package:flutter/material.dart';

/// 星星飞翔动画控制器
///
/// 在 [OverlayEntry] 上绘制一颗从起始位置飞向目标位置的星星。
/// 动画结束后自动销毁 Overlay，并回调 [onArrived]。
class StarFlyAnimationController {
  OverlayEntry? _entry;

  /// 触发一次飞翔动画
  ///
  /// [overlayState]：当前页面的 Overlay（通过 Overlay.of(context) 获取）
  /// [startPosition]：起飞点（全局坐标，词语点击处）
  /// [targetPosition]：降落点（全局坐标，右上角对应星星的中心）
  /// [onArrived]：动画完成时的回调（用于更新 starsEarned 和播放音效）
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

  static const double _starSize = 32.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // 位置：从起点曲线飞向终点（略带弧线，通过 Curves.easeInCubic 模拟）
    _positionAnim = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.targetPosition,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 缩放：从 0.6 放大至 1.0，到达后缩小至 0.8（弹跳感）
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);

    // 透明度：飞行中完全可见，最后 15% 淡出
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 85),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
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
                child: Container(
                  width: _starSize,
                  height: _starSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: _starSize,
                    color: Color(0xFFFFD700),
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
