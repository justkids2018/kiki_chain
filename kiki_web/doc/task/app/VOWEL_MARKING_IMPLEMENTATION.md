# English Vowel Marking - Implementation Guide

## Overview
This document provides the implementation details for marking vowels in English words with red color to help children learn phonics patterns.

## Algorithm Implementation

### 1. Data Structures

```dart
class VowelMarker {
  // Priority order: Match longest patterns first to avoid partial matches

  // 4-letter complex patterns (highest priority)
  static const complexPatterns = [
    'aigh', 'eigh', 'ough', 'augh', 'eau',
  ];

  // 3-letter controlled vowels
  static const threeLetterPatterns = [
    'ear', 'air', 'ure', 'ier', 'are', 'ore', 'ere', 'ire',
    'ell', 'igh',
  ];

  // 2-letter vowel combinations
  static const twoLetterPatterns = [
    // R-controlled
    'ar', 'er', 'ir', 'or', 'ur',
    // L-controlled
    'al', 'el', 'il', 'ol',
    // Common digraphs
    'ea', 'ee', 'ie', 'oe', 'ue',
    'ai', 'oi', 'ui', 'ou', 'au',
    'oo', 'ow', 'ew', 'aw', 'oa',
    'ei', 'ey', 'oy', 'ay',
  ];

  // Single vowels (lowest priority)
  static const singleVowels = ['a', 'e', 'i', 'o', 'u'];

  // Split vowel pattern regex: vowel + consonant + e
  // Examples: make, time, home, cute
  static final splitVowelRegex = RegExp(
    r'([aeiou])([bcdfghjklmnpqrstvwxyz])e\b',
    caseSensitive: false,
  );
}
```

### 2. Core Marking Algorithm

```dart
class VowelMarkingResult {
  final String originalWord;
  final List<VowelSegment> segments;

  VowelMarkingResult(this.originalWord, this.segments);
}

class VowelSegment {
  final String text;
  final bool isVowel;
  final String? patternType;  // 'single', 'digraph', 'r-controlled', etc.
  final int startIndex;
  final int endIndex;

  VowelSegment({
    required this.text,
    required this.isVowel,
    this.patternType,
    required this.startIndex,
    required this.endIndex,
  });
}

class VowelMarker {
  /// Main method to mark vowels in a word
  static VowelMarkingResult markVowels(String word) {
    if (word.isEmpty) {
      return VowelMarkingResult(word, []);
    }

    final lowerWord = word.toLowerCase();
    final markedIndices = <int>{};  // Track marked positions
    final segments = <VowelSegment>[];

    // Step 1: Find all vowel patterns (longest first)
    final patterns = <_PatternMatch>[];

    // Match 4-letter patterns
    for (var pattern in complexPatterns) {
      _findPatternMatches(lowerWord, pattern, patterns, 'complex');
    }

    // Match 3-letter patterns
    for (var pattern in threeLetterPatterns) {
      _findPatternMatches(lowerWord, pattern, patterns, 'controlled');
    }

    // Match 2-letter patterns
    for (var pattern in twoLetterPatterns) {
      String type = 'digraph';
      if (pattern.endsWith('r')) type = 'r-controlled';
      if (pattern.endsWith('l')) type = 'l-controlled';
      _findPatternMatches(lowerWord, pattern, patterns, type);
    }

    // Match split vowel patterns (a-e, i-e, etc.)
    _findSplitVowelPatterns(lowerWord, patterns);

    // Match single vowels
    for (var i = 0; i < lowerWord.length; i++) {
      if (singleVowels.contains(lowerWord[i])) {
        patterns.add(_PatternMatch(
          pattern: lowerWord[i],
          startIndex: i,
          endIndex: i + 1,
          type: 'single',
        ));
      }
    }

    // Match 'y' as vowel (conditional)
    _findYAsVowel(lowerWord, patterns);

    // Step 2: Sort patterns by start index and length (prefer longer)
    patterns.sort((a, b) {
      if (a.startIndex != b.startIndex) {
        return a.startIndex.compareTo(b.startIndex);
      }
      // If same start, prefer longer pattern
      return b.length.compareTo(a.length);
    });

    // Step 3: Build segments, avoiding overlaps
    int currentIndex = 0;

    for (var pattern in patterns) {
      // Skip if this pattern overlaps with already marked indices
      bool hasOverlap = false;
      for (var i = pattern.startIndex; i < pattern.endIndex; i++) {
        if (markedIndices.contains(i)) {
          hasOverlap = true;
          break;
        }
      }

      if (hasOverlap) continue;

      // Add consonant segment before this vowel (if any)
      if (currentIndex < pattern.startIndex) {
        segments.add(VowelSegment(
          text: word.substring(currentIndex, pattern.startIndex),
          isVowel: false,
          startIndex: currentIndex,
          endIndex: pattern.startIndex,
        ));
      }

      // Add vowel segment
      segments.add(VowelSegment(
        text: word.substring(pattern.startIndex, pattern.endIndex),
        isVowel: true,
        patternType: pattern.type,
        startIndex: pattern.startIndex,
        endIndex: pattern.endIndex,
      ));

      // Mark these indices as used
      for (var i = pattern.startIndex; i < pattern.endIndex; i++) {
        markedIndices.add(i);
      }

      currentIndex = pattern.endIndex;
    }

    // Add remaining consonants
    if (currentIndex < word.length) {
      segments.add(VowelSegment(
        text: word.substring(currentIndex),
        isVowel: false,
        startIndex: currentIndex,
        endIndex: word.length,
      ));
    }

    return VowelMarkingResult(word, segments);
  }

  /// Helper: Find all matches of a pattern in the word
  static void _findPatternMatches(
    String word,
    String pattern,
    List<_PatternMatch> matches,
    String type,
  ) {
    int index = 0;
    while (index < word.length) {
      final pos = word.indexOf(pattern, index);
      if (pos == -1) break;

      matches.add(_PatternMatch(
        pattern: pattern,
        startIndex: pos,
        endIndex: pos + pattern.length,
        type: type,
      ));

      index = pos + 1;  // Continue searching
    }
  }

  /// Helper: Find split vowel patterns (a-e, i-e, o-e, u-e)
  static void _findSplitVowelPatterns(
    String word,
    List<_PatternMatch> matches,
  ) {
    final regex = RegExp(r'([aeiou])([bcdfghjklmnpqrstvwxyz])e\b');
    final allMatches = regex.allMatches(word);

    for (var match in allMatches) {
      // Mark the first vowel
      matches.add(_PatternMatch(
        pattern: match.group(1)!,
        startIndex: match.start,
        endIndex: match.start + 1,
        type: 'split-vowel',
      ));

      // Mark the final 'e'
      matches.add(_PatternMatch(
        pattern: 'e',
        startIndex: match.end - 1,
        endIndex: match.end,
        type: 'silent-e',
      ));
    }
  }

  /// Helper: Find 'y' acting as vowel
  static void _findYAsVowel(String word, List<_PatternMatch> matches) {
    for (var i = 0; i < word.length; i++) {
      if (word[i] != 'y') continue;

      bool isVowel = false;

      // Rule 1: 'y' at end of word (my, fly, happy)
      if (i == word.length - 1) {
        isVowel = true;
      }
      // Rule 2: 'y' in middle with no other vowel nearby (gym, myth)
      else if (i > 0 && i < word.length - 1) {
        final before = word[i - 1];
        final after = word[i + 1];
        // If surrounded by consonants, likely a vowel
        if (!singleVowels.contains(before) &&
            !singleVowels.contains(after)) {
          isVowel = true;
        }
      }

      if (isVowel) {
        matches.add(_PatternMatch(
          pattern: 'y',
          startIndex: i,
          endIndex: i + 1,
          type: 'y-vowel',
        ));
      }
    }
  }
}

/// Internal class to track pattern matches
class _PatternMatch {
  final String pattern;
  final int startIndex;
  final int endIndex;
  final String type;

  int get length => endIndex - startIndex;

  _PatternMatch({
    required this.pattern,
    required this.startIndex,
    required this.endIndex,
    required this.type,
  });
}
```

### 3. Flutter Widget Implementation

```dart
class VowelMarkedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool showPatternInfo;  // Show pattern type on long press

  const VowelMarkedText({
    Key? key,
    required this.text,
    this.fontSize = 24,
    this.showPatternInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final result = VowelMarker.markVowels(text);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Comic Sans MS',
          height: 1.5,
        ),
        children: result.segments.map((segment) {
          return TextSpan(
            text: segment.text,
            style: TextStyle(
              color: segment.isVowel ? Colors.red : Colors.black,
              fontWeight: segment.isVowel ? FontWeight.w600 : FontWeight.w400,
            ),
            // Optional: Add gesture recognizer for pattern info
            recognizer: showPatternInfo && segment.isVowel
                ? (TapGestureRecognizer()
                  ..onTap = () => _showPatternInfo(context, segment))
                : null,
          );
        }).toList(),
      ),
    );
  }

  void _showPatternInfo(BuildContext context, VowelSegment segment) {
    final patternNames = {
      'single': '单元音',
      'digraph': '元音组合',
      'r-controlled': 'R控制元音',
      'l-controlled': 'L控制元音',
      'complex': '复杂元音组合',
      'split-vowel': '分离元音',
      'silent-e': '不发音的e',
      'y-vowel': 'Y作为元音',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${segment.text}" - ${patternNames[segment.patternType] ?? '元音'}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

### 4. Integration with 5-Line-3-Grid

```dart
class EnglishFiveLineGridWithVowels extends StatelessWidget {
  final String text;

  const EnglishFiveLineGridWithVowels({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final result = VowelMarker.markVowels(text);

    return CustomPaint(
      painter: FiveLineGridPainter(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: result.segments.map((segment) {
            return _buildLetterWithPosition(segment);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLetterWithPosition(VowelSegment segment) {
    // Position each letter correctly on the 5-line grid
    // Vowels in red, consonants in black
    // Handle uppercase, lowercase, descenders

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        segment.text,
        style: TextStyle(
          fontSize: 32,
          color: segment.isVowel ? Colors.red : Colors.black,
          fontWeight: segment.isVowel ? FontWeight.w600 : FontWeight.w400,
          fontFamily: 'Comic Sans MS',
        ),
      ),
    );
  }
}
```

## Testing Examples

```dart
void testVowelMarking() {
  final testCases = {
    'cat': 'c[a]t',
    'dog': 'd[o]g',
    'boat': 'b[oa]t',
    'rain': 'r[ai]n',
    'car': 'c[ar]',
    'bird': 'b[ir]d',
    'make': 'm[a]k[e]',
    'time': 't[i]m[e]',
    'night': 'n[igh]t',
    'though': 'th[ough]',
    'my': 'm[y]',
    'happy': 'happ[y]',
    'gym': 'g[y]m',
    'bear': 'b[ear]',
    'care': 'c[are]',
    'beautiful': 'b[eau]t[i]f[u]l',
    'through': 'thr[ough]',
  };

  for (var entry in testCases.entries) {
    final word = entry.key;
    final expected = entry.value;
    final result = VowelMarker.markVowels(word);

    // Build result string with brackets
    final resultStr = result.segments.map((s) {
      return s.isVowel ? '[${s.text}]' : s.text;
    }).join('');

    print('$word: $resultStr ${resultStr == expected ? "✓" : "✗ Expected: $expected"}');
  }
}
```

## Visual Examples

```
Simple words:
cat  → c[a]t
dog  → d[o]g
pen  → p[e]n

Vowel digraphs:
boat → b[oa]t
rain → r[ai]n
feet → f[ee]t

R-controlled:
car  → c[ar]
bird → b[ir]d
turn → t[ur]n

Split vowels:
make → m[a]k[e]
time → t[i]m[e]
home → h[o]m[e]

Complex:
night   → n[igh]t
though  → th[ough]
caught  → c[augh]t

Y as vowel:
my    → m[y]
fly   → fl[y]
happy → happ[y]
gym   → g[y]m
```

## Performance Considerations

1. **Caching:** Cache marked results for frequently used words
2. **Lazy evaluation:** Only mark vowels when text is visible
3. **Batch processing:** Process multiple words together if needed

```dart
class VowelMarkingCache {
  static final _cache = <String, VowelMarkingResult>{};
  static const maxCacheSize = 1000;

  static VowelMarkingResult getMarkedWord(String word) {
    if (_cache.containsKey(word)) {
      return _cache[word]!;
    }

    final result = VowelMarker.markVowels(word);

    if (_cache.length >= maxCacheSize) {
      _cache.clear();  // Simple cache eviction
    }

    _cache[word] = result;
    return result;
  }
}
```

## Future Enhancements

1. **Color coding by pattern type:**
   - Single vowels: Red
   - Digraphs: Orange
   - R-controlled: Purple
   - Silent letters: Light gray

2. **Interactive learning:**
   - Tap vowel to hear its sound
   - Show pattern explanation
   - Quiz mode: "Find all vowels"

3. **Syllable division:**
   - Show syllable breaks
   - Mark vowels within each syllable

4. **Phonetic transcription:**
   - Show IPA symbols
   - Link to pronunciation audio

---

*Document created: 2026-02-12*
*Status: Implementation Guide*
