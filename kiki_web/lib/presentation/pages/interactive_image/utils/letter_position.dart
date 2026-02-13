/// Utility class for determining the vertical position of English letters
/// in a four-line-three-grid (四线三格) system (used for teaching proper letter writing).
class LetterPosition {
  /// Returns the baseline offset ratio (0.0 to 1.0) for a given letter.
  ///
  /// Four-line-three-grid structure:
  /// - Line 1: Top line (0.0)
  /// - Line 2: Upper middle line (0.333)
  /// - Line 3: Lower middle line (0.667) - baseline for most letters
  /// - Line 4: Bottom line (1.0)
  ///
  /// Three spaces:
  /// - Upper space: 0.0 to 0.333
  /// - Middle space: 0.333 to 0.667 (where most lowercase letters sit)
  /// - Lower space: 0.667 to 1.0
  static double getBaselineOffset(String letter) {
    if (letter.isEmpty) return 2.0 / 3;

    final char = letter[0].toLowerCase();

    // Uppercase letters: sit on line 3 (baseline), extend to line 1
    if (letter[0] == letter[0].toUpperCase() && letter[0] != letter[0].toLowerCase()) {
      return 2.0 / 3;
    }

    // Tall lowercase letters (b, d, f, h, k, l, t): sit on line 3, extend to line 1
    if ('bdfhklt'.contains(char)) {
      return 2.0 / 3;
    }

    // Descender letters (g, j, p, q, y): sit on line 3, extend to line 4
    if ('gjpqy'.contains(char)) {
      return 2.0 / 3;
    }

    // Regular lowercase letters (a, c, e, m, n, o, r, s, u, v, w, x, z):
    // sit on line 3 (baseline)
    return 2.0 / 3;
  }

  /// Returns the height ratio for a given letter (relative to grid height).
  static double getLetterHeight(String letter) {
    if (letter.isEmpty) return 1.0 / 3;

    final char = letter[0].toLowerCase();

    // Uppercase letters: from line 1 to line 3 (2/3 of grid height)
    if (letter[0] == letter[0].toUpperCase() && letter[0] != letter[0].toLowerCase()) {
      return 2.0 / 3;
    }

    // Tall lowercase letters: from line 1 to line 3 (2/3 of grid height)
    if ('bdfhklt'.contains(char)) {
      return 2.0 / 3;
    }

    // Descender letters: from line 2 to line 4 (2/3 of grid height)
    if ('gjpqy'.contains(char)) {
      return 2.0 / 3;
    }

    // Regular lowercase letters: from line 2 to line 3 (1/3 of grid height)
    return 1.0 / 3;
  }

  /// Checks if a letter has a descender (extends below baseline).
  static bool hasDescender(String letter) {
    if (letter.isEmpty) return false;
    final char = letter[0].toLowerCase();
    return 'gjpqy'.contains(char);
  }

  /// Checks if a letter is tall (extends to top line).
  static bool isTall(String letter) {
    if (letter.isEmpty) return false;
    final char = letter[0].toLowerCase();
    return 'bdfhklt'.contains(char);
  }
}
