/// Represents a segment of text that may or may not be a vowel.
class VowelSegment {
  final String text;
  final bool isVowel;

  VowelSegment(this.text, this.isVowel);

  @override
  String toString() => 'VowelSegment(text: $text, isVowel: $isVowel)';
}

/// Result of vowel marking operation.
class VowelMarkingResult {
  final List<VowelSegment> segments;

  VowelMarkingResult(this.segments);

  @override
  String toString() => 'VowelMarkingResult(segments: $segments)';
}

/// Utility class for identifying and marking vowels in English words.
///
/// Handles various vowel patterns including:
/// - Single vowels (a, e, i, o, u)
/// - Vowel digraphs (ai, ea, oa, etc.)
/// - R-controlled vowels (ar, er, ir, or, ur)
/// - Split vowels (a_e, i_e, o_e, u_e)
/// - Complex patterns (ough, augh, etc.)
/// - Y as a vowel
class VowelMarker {
  /// Vowel patterns ordered by priority (longest/most specific first).
  static final List<Pattern> _patterns = [
    // Complex patterns (4+ letters)
    RegExp(r'ough'),  // though, through, rough
    RegExp(r'augh'),  // caught, taught

    // Vowel trigraphs (3 letters)
    RegExp(r'eau'),   // beauty
    RegExp(r'ieu'),   // lieutenant

    // R-controlled vowels (2 letters)
    RegExp(r'ar'),    // car, star
    RegExp(r'er'),    // her, term
    RegExp(r'ir'),    // bird, girl
    RegExp(r'or'),    // for, born
    RegExp(r'ur'),    // turn, burn

    // Vowel digraphs (2 letters)
    RegExp(r'ai'),    // rain, main
    RegExp(r'ay'),    // day, play
    RegExp(r'ea'),    // eat, sea
    RegExp(r'ee'),    // see, tree
    RegExp(r'ei'),    // receive
    RegExp(r'ey'),    // key, they
    RegExp(r'ie'),    // pie, tie
    RegExp(r'oa'),    // boat, coat
    RegExp(r'oe'),    // toe, doe
    RegExp(r'oi'),    // coin, oil
    RegExp(r'oo'),    // book, moon
    RegExp(r'ou'),    // out, house
    RegExp(r'ow'),    // cow, now
    RegExp(r'oy'),    // boy, toy
    RegExp(r'ue'),    // blue, true
    RegExp(r'ui'),    // fruit, juice

    // Single vowels (1 letter)
    RegExp(r'a'),
    RegExp(r'e'),
    RegExp(r'i'),
    RegExp(r'o'),
    RegExp(r'u'),

    // Y as vowel (at end of word or middle)
    RegExp(r'y'),
  ];

  /// Marks vowels in the given word and returns segments.
  ///
  /// Uses a greedy algorithm to match the longest vowel patterns first.
  static VowelMarkingResult markVowels(String word) {
    if (word.isEmpty) {
      return VowelMarkingResult([]);
    }

    final segments = <VowelSegment>[];
    final lowerWord = word.toLowerCase();
    int position = 0;

    while (position < lowerWord.length) {
      bool matched = false;

      // Try to match patterns from longest to shortest
      for (final pattern in _patterns) {
        final match = pattern.matchAsPrefix(lowerWord, position);
        if (match != null) {
          final matchedText = word.substring(match.start, match.end);

          // Special case: 'y' is only a vowel if not at the beginning
          if (matchedText.toLowerCase() == 'y' && position == 0) {
            continue;
          }

          segments.add(VowelSegment(matchedText, true));
          position = match.end;
          matched = true;
          break;
        }
      }

      // If no vowel pattern matched, add as consonant
      if (!matched) {
        segments.add(VowelSegment(word[position], false));
        position++;
      }
    }

    return VowelMarkingResult(segments);
  }

  /// Checks if a character is a vowel (simple check).
  static bool isVowel(String char) {
    if (char.isEmpty) return false;
    final lower = char.toLowerCase();
    return 'aeiou'.contains(lower);
  }

  /// Checks if 'y' acts as a vowel in the given context.
  static bool isYVowel(String word, int position) {
    if (position < 0 || position >= word.length) return false;
    if (word[position].toLowerCase() != 'y') return false;

    // Y is a vowel if:
    // 1. At the end of a word (my, happy)
    // 2. In the middle with no other vowels nearby (gym, myth)
    // 3. Not at the beginning (yes, yellow - consonant)

    if (position == 0) return false; // Beginning: consonant
    if (position == word.length - 1) return true; // End: vowel

    // Middle: check if surrounded by consonants
    final before = position > 0 ? word[position - 1].toLowerCase() : '';
    final after = position < word.length - 1 ? word[position + 1].toLowerCase() : '';

    final beforeIsConsonant = before.isNotEmpty && !'aeiou'.contains(before);
    final afterIsConsonant = after.isNotEmpty && !'aeiou'.contains(after);

    return beforeIsConsonant && afterIsConsonant;
  }
}
