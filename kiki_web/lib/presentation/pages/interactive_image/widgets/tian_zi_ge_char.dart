import 'package:flutter/material.dart';
import 'package:stroke_order_animator/stroke_order_animator.dart';

import '../services/stroke_order_service.dart';

/// Displays a single Chinese character inside a Tian Zi Ge grid with
/// animated stroke order. The animation can be toggled via [animate], and
/// [onAnimationComplete] notifies callers once all strokes finish drawing.
class TianZiGeChar extends StatefulWidget {
  const TianZiGeChar({
    super.key,
    required this.character,
    this.size = 80,
    this.animate = true,
    this.strokeColor = Colors.black,
    this.animationSpeed = 2.0,
    this.onAnimationComplete,
  });

  /// The Chinese character to display.
  final String character;

  /// Size of the square grid.
  final double size;

  /// Whether the stroke animation should play automatically.
  final bool animate;

  /// Color used for drawing the strokes.
  final Color strokeColor;

  /// Speed multiplier of the stroke animation (default is 1.0).
  final double animationSpeed;

  /// Callback invoked once the animation completes all strokes.
  final VoidCallback? onAnimationComplete;

  @override
  State<TianZiGeChar> createState() => _TianZiGeCharState();
}

class _TianZiGeCharState extends State<TianZiGeChar>
    with TickerProviderStateMixin {
  StrokeOrderAnimationController? _strokeController;
  bool _isDisposed = false;
  bool _hasNotifiedCompletion = false;

  @override
  void initState() {
    super.initState();
    _loadStrokeData();
  }

  @override
  void didUpdateWidget(TianZiGeChar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.character != widget.character) {
      _hasNotifiedCompletion = false;
      _loadStrokeData();
      return;
    }

    if (oldWidget.animate != widget.animate && widget.animate) {
      _startAnimation();
    } else if (oldWidget.animate && !widget.animate) {
      _strokeController?.showFullCharacter();
    }
  }

  Future<void> _loadStrokeData() async {
    if (_isDisposed) return;

    if (_strokeController != null) {
      _strokeController!
        ..removeListener(_handleAnimationState)
        ..dispose();
      _strokeController = null;
    }
    setState(() {});

    final json =
        await StrokeOrderService().getStrokeOrderData(widget.character);
    if (_isDisposed) return;

    if (json == null) {
      setState(() {});
      return;
    }

    try {
      final controller = StrokeOrderAnimationController(
        StrokeOrder(json),
        this,
        strokeAnimationSpeed: widget.animationSpeed,
        strokeColor: widget.strokeColor,
        onQuizCompleteCallback: (_) => _notifyCompletion(),
      )
        ..setShowOutline(false)
        ..setShowMedian(false);

      controller.addListener(_handleAnimationState);
      _strokeController = controller;

      if (!widget.animate) {
        controller.showFullCharacter();
      }
    } catch (error) {
      debugPrint(
          'Failed to create stroke controller for ${widget.character}: $error');
      _strokeController = null;
    }

    if (!_isDisposed) {
      setState(_startAnimation);
    }
  }

  void _startAnimation() {
    if (!widget.animate || _strokeController == null) {
      return;
    }

    _hasNotifiedCompletion = false;
    _strokeController!
      ..reset()
      ..startAnimation();
  }

  void _notifyCompletion() {
    if (_hasNotifiedCompletion) return;
    _hasNotifiedCompletion = true;
    widget.onAnimationComplete?.call();
  }

  void _handleAnimationState() {
    final controller = _strokeController;
    if (controller == null || _hasNotifiedCompletion) {
      return;
    }

    final bool finished = !controller.isAnimating &&
        controller.currentStroke >= controller.strokeOrder.nStrokes;
    if (finished) {
      _notifyCompletion();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_strokeController != null) {
      _strokeController!
        ..removeListener(_handleAnimationState)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        border: Border.all(color: const Color(0xFFE0C0A0), width: 2),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _TianZiGePainter(),
          ),
          Center(
            child: _strokeController != null
                ? SizedBox(
                    width: widget.size * 0.85,
                    height: widget.size * 0.85,
                    child: StrokeOrderAnimator(_strokeController!),
                  )
                : Text(
                    widget.character,
                    style: TextStyle(
                      fontSize: widget.size * 0.7,
                      fontFamily: 'KaiTi',
                      fontWeight: FontWeight.w500,
                      color: widget.strokeColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TianZiGePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0C0A0).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    void drawDashedLine(Offset start, Offset end) {
      const dashWidth = 4.0;
      const dashSpace = 4.0;
      double distance = (end - start).distance;
      double progress = 0.0;

      final delta = (end - start) / distance;
      while (progress < distance) {
        final currentStart = start + delta * progress;
        final currentEnd = start + delta * (progress + dashWidth);
        canvas.drawLine(currentStart, currentEnd, paint);
        progress += dashWidth + dashSpace;
      }
    }

    drawDashedLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2));
    drawDashedLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
