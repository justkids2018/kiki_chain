import 'dart:math' as math;
import 'package:flutter/material.dart';

class _BubbleSeed {
  final double angle;
  final double distanceFactor;
  final double size;
  final double delay;
  final double swayAmplitude;
  final double swaySpeed;
  final double phase;
  final Color color;
  final double alpha;
  final double peakScale;

  _BubbleSeed({
    required this.angle,
    required this.distanceFactor,
    required this.size,
    required this.delay,
    required this.swayAmplitude,
    required this.swaySpeed,
    required this.phase,
    required this.color,
    required this.alpha,
    required this.peakScale,
  });
}

class _BubbleBurst {
  final Offset origin;
  final int startedAtMs;
  final List<_BubbleSeed> bubbles;

  _BubbleBurst({
    required this.origin,
    required this.startedAtMs,
    required this.bubbles,
  });
}

/// 页面级扩散动画触发器。
class ScreenDiffusionController extends ChangeNotifier {
  Offset? _origin;
  int _tick = 0;

  Offset? get origin => _origin;
  int get tick => _tick;

  void trigger(Offset localPosition) {
    _origin = localPosition;
    _tick += 1;
    notifyListeners();
  }
}

class _ScreenDiffusionPainter extends CustomPainter {
  final int nowMs;
  final int durationMs;
  final List<_BubbleBurst> bursts;

  _ScreenDiffusionPainter({
    required this.nowMs,
    required this.durationMs,
    required this.bursts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bursts.isEmpty) return;

    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height);
    final maxTravel = size.shortestSide * 0.32 + size.longestSide * 0.10;

    for (final burst in bursts) {
      final burstProgress =
          ((nowMs - burst.startedAtMs) / durationMs).clamp(0.0, 1.0);
      if (burstProgress <= 0 || burstProgress >= 1) continue;

      final center = burst.origin;

      final glowPulse = Curves.easeOut.transform(burstProgress);
      final glowRadius = 14 + (maxRadius * 0.06 * glowPulse);
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF9DFFEF).withValues(
              alpha: 0.14 * math.pow(1 - burstProgress, 1.4).toDouble(),
            ),
            const Color(0xFF00C37D).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
      canvas.drawCircle(center, glowRadius, glowPaint);

      for (final bubble in burst.bubbles) {
        final t = ((burstProgress - bubble.delay) / (1 - bubble.delay))
            .clamp(0.0, 1.0);
        if (t <= 0) continue;

        // 先慢后快：越往外扩散速度越快。
        final spread = Curves.easeInCubic.transform(t);
        final distance = maxTravel * bubble.distanceFactor * spread;

        final x = center.dx +
            math.cos(bubble.angle) * distance +
            math.sin(bubble.phase + t * bubble.swaySpeed) *
                bubble.swayAmplitude *
                (1 - 0.4 * t);

        final y = center.dy +
            math.sin(bubble.angle) * distance +
            math.cos(bubble.phase + t * bubble.swaySpeed * 0.8) *
                bubble.swayAmplitude *
                0.7 *
                (1 - 0.4 * t);

        final growThenShrink = t < 0.38
            ? (0.56 + (bubble.peakScale - 0.56) * (t / 0.38))
            : t < 0.66
                ? bubble.peakScale
                : (bubble.peakScale -
                    (bubble.peakScale - 0.42) * ((t - 0.66) / 0.34));

        // 点击后立马可见，慢慢消失。
        final fadeIn = (t / 0.06).clamp(0.0, 1.0);
        final fadeOut = math.pow(1 - t, 0.65).toDouble();
        final alpha = bubble.alpha * fadeIn * fadeOut;
        if (alpha <= 0.001) continue;

        final radius = bubble.size * growThenShrink;

        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = bubble.color.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), radius, fillPaint);

        final edgePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = Colors.white.withValues(alpha: alpha * 0.30);
        canvas.drawCircle(Offset(x, y), radius + 0.7, edgePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScreenDiffusionPainter oldDelegate) {
    return oldDelegate.nowMs != nowMs || oldDelegate.bursts != bursts;
  }
}

/// 全屏扩散动画层（不拦截点击事件）。
class ScreenDiffusionLayer extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final ScreenDiffusionController controller;

  const ScreenDiffusionLayer({
    Key? key,
    required this.child,
    required this.controller,
    this.animationDuration = const Duration(milliseconds: 900),
  }) : super(key: key);

  @override
  State<ScreenDiffusionLayer> createState() => _ScreenDiffusionLayerState();
}

class _ScreenDiffusionLayerState extends State<ScreenDiffusionLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tickerController;
  final List<_BubbleBurst> _bursts = [];

  @override
  void initState() {
    super.initState();
    _tickerController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..addListener(_onTick);
    widget.controller.addListener(_onTrigger);
  }

  @override
  void didUpdateWidget(covariant ScreenDiffusionLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTrigger);
      widget.controller.addListener(_onTrigger);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTrigger);
    _tickerController.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted || _bursts.isEmpty) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final durationMs = widget.animationDuration.inMilliseconds;

    _bursts.removeWhere((burst) => nowMs - burst.startedAtMs >= durationMs);

    if (_bursts.isEmpty) {
      _tickerController.stop();
    }
  }

  void _onTrigger() {
    if (!mounted || widget.controller.origin == null) return;

    final random = math.Random(widget.controller.tick * 7919);
    final palette = [
      const Color(0xFF6EE7FF),
      const Color(0xFF7FFFB8),
      const Color(0xFFFFE16A),
      const Color(0xFFFFB27D),
      const Color(0xFFFF8FCB),
      const Color(0xFFB59CFF),
    ];

    final bubbles = List.generate(14, (index) {
      final immediateDelay = random.nextDouble() * 0.03;
      return _BubbleSeed(
        angle: random.nextDouble() * math.pi * 2,
        distanceFactor: 0.50 + random.nextDouble() * 0.30,
        size: 5.0 + random.nextDouble() * 4.0,
        delay: immediateDelay,
        swayAmplitude: 1.5 + random.nextDouble() * 3.0,
        swaySpeed: 3.2 + random.nextDouble() * 2.8,
        phase: random.nextDouble() * math.pi * 2,
        color: palette[index % palette.length],
        alpha: 0.30 + random.nextDouble() * 0.18,
        peakScale: 1.00 + random.nextDouble() * 0.12,
      );
    });

    _bursts.add(
      _BubbleBurst(
        origin: widget.controller.origin!,
        startedAtMs: DateTime.now().millisecondsSinceEpoch,
        bubbles: bubbles,
      ),
    );

    // Keep only a small number of active bursts to avoid repaint overload.
    if (_bursts.length > 2) {
      _bursts.removeRange(0, _bursts.length - 2);
    }

    if (!_tickerController.isAnimating) {
      _tickerController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _tickerController,
              builder: (_, __) {
                return CustomPaint(
                  painter: _ScreenDiffusionPainter(
                    nowMs: DateTime.now().millisecondsSinceEpoch,
                    durationMs: widget.animationDuration.inMilliseconds,
                    bursts: _bursts,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
