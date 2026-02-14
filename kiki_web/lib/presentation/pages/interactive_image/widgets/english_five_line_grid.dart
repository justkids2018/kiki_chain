import 'package:flutter/material.dart';
import 'five_line_grid_painter.dart';
import '../utils/letter_position.dart';
import '../utils/vowel_marker.dart';

/// Widget that displays English text on a five-line grid system,
/// positioning each letter according to proper writing guidelines.
/// Optionally marks vowels in red color.
class EnglishFiveLineGrid extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fontColor;
  final double height;
  final bool markVowels;

  const EnglishFiveLineGrid({
    Key? key,
    required this.text,
    this.fontSize = 24,
    this.fontColor = Colors.black,
    this.height = 150,
    this.markVowels = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: FiveLineGridPainter(
          lineColor: const Color(0xFFDDDDDD),
          middleLineColor: const Color(0xFFBBBBBB),
          lineWidth: 1.0,
          middleLineWidth: 1.5,
          useDashedLines: true,
        ),
        child: Center(
          child: _buildPositionedLetters(),
        ),
      ),
    );
  }

  Widget _buildPositionedLetters() {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (markVowels) {
      return _buildWithVowelMarking();
    } else {
      return _buildSimple();
    }
  }

  /// Build letters with vowel marking.
  Widget _buildWithVowelMarking() {
    final result = VowelMarker.markVowels(text);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: result.segments.map((segment) {
        if (segment.text == ' ') {
          return SizedBox(width: fontSize * 0.4);
        }

        // For multi-character segments (like 'oa', 'ai'), display as a group
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: segment.text.split('').map((letter) {
            return _buildLetter(letter, segment.isVowel);
          }).toList(),
        );
      }).toList(),
    );
  }

  /// Build letters without vowel marking.
  Widget _buildSimple() {
    final letters = text.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: letters.map((letter) {
        if (letter == ' ') {
          return SizedBox(width: fontSize * 0.4);
        }
        return _buildLetter(letter, false);
      }).toList(),
    );
  }

  Widget _buildLetter(String letter, bool isVowel) {
    final baselineOffset = LetterPosition.getBaselineOffset(letter);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 1),
      alignment: Alignment(0, baselineOffset * 2 - 1), // Convert 0-1 to -1 to 1
      child: Text(
        letter,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: isVowel ? const Color(0xFFFF5252) : fontColor,
          height: 1.0,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
