import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'four_line_grid_painter.dart';
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
        painter: FourLineGridPainter(
          lineColor: const Color(0xFFDDDDDD),
          baselineColor: const Color(0xFFBBBBBB),
          lineWidth: 1.0,
          baselineWidth: 1.5,
          useDashedLines: true,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Position text so baseline aligns with line 3 (at 2/3 height)
            // Line 3 is at 66.7% from top, which is the baseline for English text
            final baselinePosition = constraints.maxHeight * (2.0 / 3.0);

            // Adjust positioning to place lowercase letters' main body in the second grid
            // Using 0.8 to move text higher, plus additional 4dp adjustment
            final textTop = baselinePosition - fontSize * 0.8 - 4;

            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: textTop,
                  child: _buildText(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (markVowels) {
      return _buildWithVowelMarking();
    } else {
      return _buildSimple();
    }
  }

  /// Build text with vowel marking.
  Widget _buildWithVowelMarking() {
    final result = VowelMarker.markVowels(text);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: result.segments.map((segment) {
          if (segment.text == ' ') {
            return SizedBox(width: fontSize * 0.4);
          }

          return Text(
            segment.text,
            style: GoogleFonts.quicksand(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: segment.isVowel ? const Color(0xFFFF5252) : fontColor,
              height: 1.0,
              letterSpacing: 0,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build text without vowel marking.
  Widget _buildSimple() {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.quicksand(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: fontColor,
          height: 1.0,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
