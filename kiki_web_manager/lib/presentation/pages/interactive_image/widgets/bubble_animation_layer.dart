import 'dart:math';
import 'package:flutter/material.dart';

/// 气泡粒子数据类
class _BubbleParticle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final Color color;
  final double baseSize;
  final double peakSize;
  final double delay;

  _BubbleParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
    required this.baseSize,
    required this.peakSize,
    required this.delay,
  });
}

/// 气泡动画绘制器
class _BubblePainter extends CustomPainter {
  final List<_BubbleParticle> bubbles;
  final double progress;

  _BubblePainter({
    required this.bubbles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bubbles.isEmpty) return;

    for (final bubble in bubbles) {
      // 考虑延迟时间，计算有效进度
      final adjustedProgress =
          ((progress - bubble.delay) / (1.0 - bubble.delay)).clamp(0.0, 1.0);

      if (adjustedProgress == 0.0) continue;

      // 计算当前位置
      final currentX =
          bubble.startX + (bubble.endX - bubble.startX) * adjustedProgress;
      final currentY =
          bubble.startY + (bubble.endY - bubble.startY) * adjustedProgress;

      // 弹性缩放效果
      final sizeProgress = adjustedProgress < 0.5
          ? 1.0 + (adjustedProgress * 2.0) * 0.3
          : 1.3 - ((adjustedProgress - 0.5) * 2.0) * 1.3;

      final currentSize = bubble.baseSize * sizeProgress;

      // 透明度淡出效果
      final opacity = 1.0 - adjustedProgress;

      // 绘制气泡
      final paint = Paint()
        ..color = bubble.color.withOpacity(opacity * 0.7)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(currentX, currentY),
        currentSize,
        paint,
      );

      // 添加外光晕
      final glowPaint = Paint()
        ..color = bubble.color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(
        Offset(currentX, currentY),
        currentSize + 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}

/// 气泡动画图层 Widget
class BubbleAnimationLayer extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;

  const BubbleAnimationLayer({
    Key? key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<BubbleAnimationLayer> createState() => _BubbleAnimationLayerState();
}

class _BubbleAnimationLayerState extends State<BubbleAnimationLayer>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  final List<_BubbleParticle> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  void _createBubbles(Offset position) {
    _bubbles.clear();

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];

    // 创建 12-16 个彩色气泡
    final bubbleCount = Random().nextInt(5) + 12;
    for (int i = 0; i < bubbleCount; i++) {
      final angle = (i / bubbleCount) * 2 * pi;

      // 随机距离
      final distance = 60.0 + Random().nextDouble() * 80;
      final endX = position.dx + cos(angle) * distance;
      final endY =
          position.dy + sin(angle) * distance - (80 + Random().nextDouble() * 60);

      // 随机大小
      final baseSize = 4.0 + Random().nextDouble() * 12;
      final peakSize = baseSize * (1.2 + Random().nextDouble() * 0.8);

      // 延迟时间（波浪效果）
      final delay = (i % 4) * 0.15;

      _bubbles.add(
        _BubbleParticle(
          startX: position.dx,
          startY: position.dy,
          endX: endX,
          endY: endY,
          color: colors[i % colors.length],
          baseSize: baseSize,
          peakSize: peakSize,
          delay: delay,
        ),
      );
    }

    _bubbleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onLongPressDown: (details) {
          // 长按时在按下位置创建气泡
          _createBubbles(details.localPosition);
        },
        child: Stack(
          children: [
            // 子 widget
            widget.child,

            // 气泡动画层
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _BubblePainter(
                        bubbles: _bubbles,
                        progress: _bubbleController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
