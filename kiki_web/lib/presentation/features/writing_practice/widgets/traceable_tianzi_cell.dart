import 'package:flutter/material.dart';

class TraceableTianziCell extends StatelessWidget {
  const TraceableTianziCell({
    super.key,
    required this.character,
    required this.size,
    this.pinyin,
    this.ghost = false,
    this.blank = false,
    this.showPinyinHeader = false,
  });

  final String character;
  final double size;
  final String? pinyin;
  final bool ghost;
  final bool blank;
  final bool showPinyinHeader;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: showPinyinHeader ? size * 1.34 : size,
      child: CustomPaint(
        painter: _TianziCellPainter(
          character: character,
          pinyin: pinyin,
          ghost: ghost,
          blank: blank,
          showPinyinHeader: showPinyinHeader,
        ),
      ),
    );
  }
}

class _TianziCellPainter extends CustomPainter {
  _TianziCellPainter({
    required this.character,
    required this.pinyin,
    required this.ghost,
    required this.blank,
    required this.showPinyinHeader,
  });

  final String character;
  final String? pinyin;
  final bool ghost;
  final bool blank;
  final bool showPinyinHeader;

  static const Color _lineColor = Color(0xFF7F7F7F);
  static const Color _guideColor = Color(0xFFB9C0C8);
  static const Color _traceColor = Color(0xFFD32F2F);

  @override
  void paint(Canvas canvas, Size size) {
    final headerHeight = showPinyinHeader ? size.width * 0.34 : 0.0;
    final cellRect = Rect.fromLTWH(
      0,
      headerHeight,
      size.width,
      size.height - headerHeight,
    );

    final border = Paint()
      ..color = _lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRect(Offset.zero & size, border);
    if (showPinyinHeader) {
      canvas.drawLine(
        Offset(0, headerHeight),
        Offset(size.width, headerHeight),
        border,
      );
      final pinyinPainter = TextPainter(
        text: TextSpan(
          text: pinyin ?? '',
          style: TextStyle(
            color: const Color(0xFF50565F),
            fontSize: size.width * 0.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      pinyinPainter.paint(
        canvas,
        Offset(
          (size.width - pinyinPainter.width) / 2,
          (headerHeight - pinyinPainter.height) / 2,
        ),
      );
    }

    final guide = Paint()
      ..color = _guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    _drawDashed(canvas, Offset(cellRect.center.dx, cellRect.top),
        Offset(cellRect.center.dx, cellRect.bottom), guide);
    _drawDashed(canvas, Offset(cellRect.left, cellRect.center.dy),
        Offset(cellRect.right, cellRect.center.dy), guide);

    if (!blank) {
      final painter = TextPainter(
        text: TextSpan(
          text: character,
          style: TextStyle(
            color: ghost ? _traceColor.withOpacity(0.36) : Colors.black87,
            fontSize: cellRect.width * 0.66,
            fontWeight: FontWeight.w500,
            fontFamily: 'ARPLKaitiMGB',
            fontFamilyFallback: const [
              'KaiTi',
              'Kaiti SC',
              'STKaiti',
              'Songti SC',
              'serif',
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      painter.paint(
        canvas,
        Offset(
          cellRect.left + (cellRect.width - painter.width) / 2,
          cellRect.top +
              (cellRect.height - painter.height) / 2 +
              cellRect.height * 0.04,
        ),
      );
    }
  }

  void _drawDashed(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final vector = end - start;
    final distance = vector.distance;
    if (distance == 0) return;
    final direction = vector / distance;
    var progress = 0.0;
    while (progress < distance) {
      final from = start + direction * progress;
      final to = start + direction * (progress + dash).clamp(0, distance);
      canvas.drawLine(from, to, paint);
      progress += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TianziCellPainter oldDelegate) {
    return oldDelegate.character != character ||
        oldDelegate.pinyin != pinyin ||
        oldDelegate.ghost != ghost ||
        oldDelegate.blank != blank ||
        oldDelegate.showPinyinHeader != showPinyinHeader;
  }
}
