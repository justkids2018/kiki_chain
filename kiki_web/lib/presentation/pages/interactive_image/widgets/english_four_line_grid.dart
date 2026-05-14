import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'four_line_grid_painter.dart';
import '../utils/letter_position.dart';
import '../utils/vowel_marker.dart';

/// Widget that displays English text on a four-line-three-grid (四线三格) system,
/// positioning text according to proper writing guidelines.
/// Optionally marks vowels in red color.
class EnglishFourLineGrid extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fontColor;
  final double height;
  final bool markVowels;

  const EnglishFourLineGrid({
    Key? key,
    required this.text,
    this.fontSize = 24,
    this.fontColor = Colors.black,
    this.height = 150,
    this.markVowels = false,
  }) : super(key: key);

  double _calculateGridWidth(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.quicksand(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.0,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: textScale,
    )..layout();

    // Follow word length and keep extra horizontal breathing room.
    return (painter.width + 30).clamp(100.0, 420.0);
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = _calculateGridWidth(context);

    return SizedBox(
      width: gridWidth,
      height: height,
      child: CustomPaint(
        painter: FourLineGridPainter(
          lineColor: const Color(0xFFDDDDDD),
          baselineColor: const Color(0xFFBBBBBB),
          lineWidth: 1.0,
          baselineWidth: 1.5,
          useDashedLines: true,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: _buildText(constraints.maxHeight),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildText(double gridHeight) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (markVowels) {
      return _buildWithVowelMarking(gridHeight);
    } else {
      return _buildSimple(gridHeight);
    }
  }

  /// Build text with vowel marking.
  Widget _buildWithVowelMarking(double gridHeight) {
    final result = VowelMarker.markVowels(text);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: result.segments.expand((segment) {
        if (segment.text == ' ') {
          return [SizedBox(width: fontSize * 0.35)];
        }

        return segment.text
            .split('')
            .map((letter) => _buildLetter(letter, segment.isVowel, gridHeight));
      }).toList(),
    );
  }

  /// Build text without vowel marking.
  Widget _buildSimple(double gridHeight) {
    final letters = text.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: letters.map((letter) {
        if (letter == ' ') {
          return SizedBox(width: fontSize * 0.35);
        }
        return _buildLetter(letter, false, gridHeight);
      }).toList(),
    );
  }

  Widget _buildLetter(String letter, bool isVowel, double gridHeight) {
    final baselineY = gridHeight * (2.0 / 3.0);
    final letterHeightRatio = LetterPosition.getLetterHeight(letter);
    final isDescender = LetterPosition.hasDescender(letter);
    final isTall = LetterPosition.isTall(letter);
    final isUppercase = letter.isNotEmpty &&
        letter[0] == letter[0].toUpperCase() &&
        letter[0] != letter[0].toLowerCase();

    // 基于四线三格规则：
    // - 高字母/大写：line1~line3
    // - 常规字母：line2~line3
    // - 下行字母：line2~line4
    final effectiveFontSize = letterHeightRatio >= (2.0 / 3.0)
        ? (isUppercase
            ? gridHeight * 0.58
            : (isTall ? gridHeight * 0.60 : gridHeight * 0.56))
        : (isDescender ? gridHeight * 0.58 : gridHeight * 0.52);

    return SizedBox(
      height: gridHeight,
      child: Baseline(
        baseline: baselineY,
        baselineType: TextBaseline.alphabetic,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.5),
          child: Text(
            letter,
            style: GoogleFonts.quicksand(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w600,
              color: isVowel ? const Color(0xFFFF5252) : fontColor,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
