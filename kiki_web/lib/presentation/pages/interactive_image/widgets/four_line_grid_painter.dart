import 'package:flutter/material.dart';

/// Custom painter for drawing a four-line-three-grid (四线三格) used in English letter writing.
///
/// The four lines create three spaces:
/// 1. Top line (0%)
/// 2. Upper middle line (33.3%)
/// 3. Lower middle line (66.7%) - main baseline
/// 4. Bottom line (100%)
///
/// The three spaces are:
/// - Upper space: for tall letters like b, d, f, h, k, l, t
/// - Middle space: for regular lowercase letters like a, c, e, m, n, o, r, s, u, v, w, x, z
/// - Lower space: for descenders like g, j, p, q, y
class FourLineGridPainter extends CustomPainter {
  final Color lineColor;
  final Color baselineColor;
  final double lineWidth;
  final double baselineWidth;
  final bool useDashedLines;

  FourLineGridPainter({
    this.lineColor = const Color(0xFFCCCCCC),
    this.baselineColor = const Color(0xFF999999),
    this.lineWidth = 1.0,
    this.baselineWidth = 1.5,
    this.useDashedLines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Regular line paint
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Draw 4 horizontal lines creating 3 spaces
    final lines = [
      0.0,      // Line 1: Top line
      1.0 / 3,  // Line 2: Upper middle line (33.3%)
      2.0 / 3,  // Line 3: Lower middle line (66.7%) - baseline
      1.0,      // Line 4: Bottom line
    ];

    for (int i = 0; i < lines.length; i++) {
      final y = height * lines[i];
      // Use same paint for all lines to keep colors consistent
      final paint = linePaint;

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
  bool shouldRepaint(covariant FourLineGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.baselineColor != baselineColor ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.baselineWidth != baselineWidth ||
        oldDelegate.useDashedLines != useDashedLines;
  }
}
