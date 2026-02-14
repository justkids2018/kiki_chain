import 'package:flutter/material.dart';

/// Custom painter for drawing a five-line grid used in English letter writing.
///
/// The five lines are:
/// 1. Top line (0%)
/// 2. Upper line (25%)
/// 3. Middle line (50%) - thicker, main baseline
/// 4. Lower line (75%)
/// 5. Bottom line (100%)
class FiveLineGridPainter extends CustomPainter {
  final Color lineColor;
  final Color middleLineColor;
  final double lineWidth;
  final double middleLineWidth;
  final bool useDashedLines;

  FiveLineGridPainter({
    this.lineColor = const Color(0xFFCCCCCC),
    this.middleLineColor = const Color(0xFF999999),
    this.lineWidth = 1.0,
    this.middleLineWidth = 1.5,
    this.useDashedLines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Regular line paint
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // Middle line paint (slightly thicker)
    final middleLinePaint = Paint()
      ..color = middleLineColor
      ..strokeWidth = middleLineWidth
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Draw 5 horizontal lines
    final lines = [
      0.0,    // Top line
      0.25,   // Upper line
      0.5,    // Middle line (baseline) - thicker
      0.75,   // Lower line
      1.0,    // Bottom line
    ];

    for (int i = 0; i < lines.length; i++) {
      final y = height * lines[i];
      final paint = (i == 2) ? middleLinePaint : linePaint;

      if (useDashedLines) {
        _drawDashedLine(canvas, Offset(0, y), Offset(width, y), paint);
      } else {
        canvas.drawLine(Offset(0, y), Offset(width, y), paint);
      }
    }
  }

  /// Draw a dashed line
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double distance = (end - start).distance;
    double progress = 0.0;

    final delta = (end - start) / distance;
    while (progress < distance) {
      final currentStart = start + delta * progress;
      final currentEnd = start + delta * (progress + dashWidth).clamp(0, distance);
      canvas.drawLine(currentStart, currentEnd, paint);
      progress += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant FiveLineGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.middleLineColor != middleLineColor ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.middleLineWidth != middleLineWidth ||
        oldDelegate.useDashedLines != useDashedLines;
  }
}
