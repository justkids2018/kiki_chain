import 'package:flutter/material.dart';

import 'tian_zi_ge_char.dart';

/// Displays a wrap of [TianZiGeChar] widgets for a list of characters.
/// Optionally controls which character animates via [activeIndex] and reports
/// completion events with [onCharacterComplete].
class CharacterStrokeGrid extends StatelessWidget {
  const CharacterStrokeGrid({
    super.key,
    required this.characters,
    this.cellSize = 100,
    this.activeIndex,
    this.onCharacterComplete,
    this.strokeColor = Colors.black,
    this.animationSpeed = 2.0,
  });

  final List<String> characters;
  final double cellSize;
  final int? activeIndex;
  final ValueChanged<int>? onCharacterComplete;
  final Color strokeColor;
  final double animationSpeed;

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: characters.asMap().entries.map((entry) {
        final index = entry.key;
        final char = entry.value;
        final shouldAnimate = activeIndex == null || index == activeIndex;

        return TianZiGeChar(
          key: ValueKey('$char-$index'),
          character: char,
          size: cellSize,
          animate: shouldAnimate,
          strokeColor: strokeColor,
          animationSpeed: animationSpeed,
          onAnimationComplete: shouldAnimate
              ? () => onCharacterComplete?.call(index)
              : null,
        );
      }).toList(),
    );
  }
}
