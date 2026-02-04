import 'package:flutter/material.dart';

import '../models/character_cell.dart';
import 'tian_zi_ge_char.dart';

/// Displays Chinese characters inside Tian Zi Ge grids and plays strokes sequentially.
class CharacterStrokeGrid extends StatelessWidget {
  const CharacterStrokeGrid({
    super.key,
    required this.cells,
    this.cellSize = 100,
    this.strokeColor = Colors.black,
    this.animationSpeed = 2.0,
    this.onCharacterComplete,
  });

  final List<CharacterCell> cells;
  final double cellSize;
  final Color strokeColor;
  final double animationSpeed;
  final ValueChanged<int>? onCharacterComplete;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = cells.length;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List<Widget>.generate(total, (index) {
        final cell = cells[index];
        if (!cell.isVisible) {
          return _PendingCharacterCell(
            key: ValueKey('pending-${cell.character}-$index'),
            size: cellSize,
          );
        }

        return TianZiGeChar(
          key: ValueKey('char-${cell.character}-$index'),
          character: cell.character,
          size: cellSize,
          animate: cell.shouldAnimate,
          strokeColor: strokeColor,
          animationSpeed: animationSpeed,
          onAnimationComplete: cell.shouldAnimate
              ? () => onCharacterComplete?.call(index)
              : null,
        );
      }),
    );
  }
}

class _PendingCharacterCell extends StatelessWidget {
  const _PendingCharacterCell({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        border: Border.all(color: const Color(0xFFE0C0A0), width: 2),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _TianZiGeGridPainter(),
      ),
    );
  }
}

class _TianZiGeGridPainter extends CustomPainter {
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
