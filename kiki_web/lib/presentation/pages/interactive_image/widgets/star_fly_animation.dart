import 'package:flutter/material.dart';

/// 星星飞翔动画控制器
///
/// 效果：从点击位置 "嗖" 一下飞向目标星星位置（easeIn 起步快，
/// easeOut 减速落地），落地后回调 [onArrived] 播放叮当声。
class StarFlyAnimationController {
  OverlayEntry? _entry;

  /// 触发一次飞翔动画
  ///
  /// [overlayState]：当前页面的 Overlay
  /// [startPosition]：起飞点（全局坐标，词语点击处）
  /// [targetPosition]：降落点（全局坐标，目标星星中心）
  /// [onArrived]：动画完成回调（播放叮当音效 + 更新状态）
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
      // 850ms：前半段"嗖"起速，后半段减速落地
      duration: const Duration(milliseconds: 850),
    );

    // 位置：先快后慢（decelerate = 嗖的感觉）
    _positionAnim = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.targetPosition,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );

    // 缩放：发射时略放大（兴奋感），落地时弹跳收缩
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    // 透明度：飞行中可见，最后 20% 淡出消失
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
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
      builder: (context, _) {
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
