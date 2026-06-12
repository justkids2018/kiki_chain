import 'package:flutter/material.dart';

/// Displays English text with elegant animation and letter-by-letter reveal effect
class EnglishStrokeDisplay extends StatefulWidget {
  const EnglishStrokeDisplay({
    super.key,
    required this.text,
    this.fontSize = 32,
    this.fontColor = Colors.black,
    this.animationSpeed = 1.0,
    this.onAnimationComplete,
  });

  /// The English text to display
  final String text;

  /// Font size of the text
  final double fontSize;

  /// Color of the text
  final Color fontColor;

  /// Speed multiplier of the animation (default is 1.0)
  final double animationSpeed;

  /// Callback invoked once the animation completes
  final VoidCallback? onAnimationComplete;

  @override
  State<EnglishStrokeDisplay> createState() => _EnglishStrokeDisplayState();
}

class _EnglishStrokeDisplayState extends State<EnglishStrokeDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasNotifiedCompletion = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _hasNotifiedCompletion = false;

    _controller = AnimationController(
      duration: Duration(
        milliseconds: (800 * (1.0 / widget.animationSpeed)).toInt(),
      ),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {});
      if (_controller.isCompleted && !_hasNotifiedCompletion) {
        _hasNotifiedCompletion = true;
        widget.onAnimationComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(EnglishStrokeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      _controller.dispose();
      _initializeAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final displayLength = (text.length * _animation.value).toStringAsFixed(0);
    final visibleText = text.substring(0, int.parse(displayLength));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue[200] ?? Colors.blue,
          width: 1.5,
        ),
      ),
      child: Text(
        visibleText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w600,
          color: widget.fontColor,
          letterSpacing: 2,
          fontFamily: 'Nunito', // Using Nunito for rounded friendly look
          height: 1.6,
        ),
      ),
    );
  }
}
