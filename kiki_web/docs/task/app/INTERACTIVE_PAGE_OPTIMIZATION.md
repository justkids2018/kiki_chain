# Interactive Detail Page Optimization Requirements

## Overview
This document analyzes the requirements for optimizing the interactive detail page based on user feedback. The goal is to improve the learning experience for children by adjusting layout proportions, audio playback speed, and educational display formats.

## Current Implementation Analysis

### 1. Layout Structure (Tablet Mode)

**Current Implementation:**
- File: `lib/presentation/pages/interactive_image/interactive_image_page.dart:82-92`
- Layout: Row with two Expanded widgets
  - Left panel (Interactive Image): `flex: 3` → 60% width
  - Right panel (Character Display): `flex: 2` → 40% width

**User Feedback:**
- Right panel feels too wide (40% is excessive)
- Should be reduced to give more prominence to the interactive image

**Proposed Solutions:**
1. **Option A - 70:30 Ratio**: `flex: 7` (left) vs `flex: 3` (right)
   - Gives more space to interactive image
   - Right panel still comfortable for character display

2. **Option B - 75:25 Ratio**: `flex: 3` (left) vs `flex: 1` (right)
   - Maximum space for interactive image
   - Right panel more compact, suitable for single character focus

3. **Option C - Dynamic Width**: Fixed width for right panel (e.g., 320-400px)
   - Consistent character display size across devices
   - Left panel takes remaining space

**Recommendation:** Option A (70:30) provides good balance between image interaction space and character learning display.

---

### 2. Audio Playback Speed

**Current Implementation:**
- File: `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`
- Chinese TTS: `setSpeechRate(0.85)` (line 89)
- English TTS: `setSpeechRate(1.0)` (line 101)
- No user control over playback speed

**User Feedback:**
- Both Chinese and English playback are too fast for children
- Need slower, clearer pronunciation for learning

**Proposed Solutions:**

1. **Immediate Fix - Reduce Default Speed:**
   - Chinese: `0.85` → `0.6` (slower, clearer)
   - English: `1.0` → `0.7` (slower for learning)

2. **Enhanced Solution - Speed Controls:**
   - Add speed control UI (slow/normal/fast buttons)
   - Speed presets:
     - Slow: Chinese 0.5, English 0.6
     - Normal: Chinese 0.7, English 0.8
     - Fast: Chinese 0.9, English 1.0
   - Save user preference in local storage

3. **Advanced Solution - Adaptive Speed:**
   - Slower for longer words/phrases
   - Faster for single characters
   - Pause between Chinese and English

**Recommendation:** Start with Immediate Fix (reduce default speed), then add Speed Controls in next iteration.

---

### 3. English Display Format - 5-Line-3-Grid (五线三格)

**Current Implementation:**
- File: `lib/presentation/pages/interactive_image/widgets/english_stroke_display.dart`
- Simple text display with blue background box
- Letter-by-letter reveal animation (800ms)
- No writing format guidance

**User Requirement:**
- Display English letters using 5-line-3-grid format (五线三格)
- Show proper letter positioning for writing instruction
- Help children understand letter height and baseline alignment

**5-Line-3-Grid Format Explanation:**
```
Top Line        ────────────────────  (顶线)
                     ╱╲
Upper Line      ────────────────────  (上线)
                    │  │
Middle Line     ════════════════════  (中线 - thicker)
                    │  │
Lower Line      ────────────────────  (下线)
                     ╲╱
Bottom Line     ────────────────────  (底线)
```

**Design Requirements:**
1. **Grid Structure:**
   - 5 horizontal lines with proper spacing
   - Middle line (baseline) should be thicker/darker
   - Lines should be light gray, non-distracting
   - Grid height: ~120-150px for good visibility

2. **Letter Positioning:**
   - Uppercase letters: touch top line, sit on middle line
   - Lowercase letters (b, d, f, h, k, l, t): touch top line
   - Lowercase letters (a, c, e, m, n, o, r, s, u, v, w, x, z): between middle and upper line
   - Descenders (g, j, p, q, y): extend below middle line to lower line

3. **Visual Design:**
   - Letter color: Dark blue or black for contrast
   - Font: Clear, educational font (e.g., "Comic Sans MS", "Print Clearly")
   - Letter size: Large enough to see stroke details
   - Background: Light, warm color (cream/light yellow)

4. **Animation:**
   - Letter appears stroke-by-stroke or character-by-character
   - Show proper writing direction
   - Maintain current 800ms animation duration

**Implementation Approach:**
- Create new widget: `EnglishFiveLineGrid`
- Use CustomPainter for grid lines
- Position letters using Stack and Positioned widgets
- Calculate letter positioning based on character type (uppercase/lowercase/descender)

---

### 4. Chinese 田字格 (Tian Zi Ge) - Child-Friendly Design

**Current Implementation:**
- File: `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- Background: `#FFF9F0` (cream/beige)
- Border: `#E0C0A0` (light brown), 2px solid
- Grid lines: Dashed, semi-transparent
- Size: 100px
- Uses stroke order animation

**User Requirement:**
- Make 田字格 more child-friendly
- Improve visual appeal and learning effectiveness

**Proposed Improvements:**

1. **Color Scheme:**
   - **Current:** Cream background (#FFF9F0), brown border (#E0C0A0)
   - **Proposed:**
     - Background: Lighter, warmer cream (#FFFEF7 or #FFF8E7)
     - Border: Softer, friendlier color (coral #FF9B9B or sky blue #87CEEB)
     - Grid lines: Lighter, less intrusive (#FFE4C4 or #E8D5C4)

2. **Size and Spacing:**
   - **Current:** 100px cells with 12px spacing
   - **Proposed:**
     - Increase cell size to 120px for better visibility
     - Increase spacing to 16px for clearer separation
     - Consider responsive sizing based on screen size

3. **Grid Line Style:**
   - **Current:** Dashed lines, semi-transparent
   - **Proposed Options:**
     - Option A: Solid but very light lines (more traditional)
     - Option B: Dotted lines (softer, more playful)
     - Option C: Keep dashed but with rounded caps (friendlier)

4. **Visual Enhancements:**
   - Add subtle shadow or glow effect to make characters "pop"
   - Rounded corners on the border (current: sharp corners)
   - Add small decorative elements (stars, dots) for completed characters
   - Consider adding a subtle texture or pattern to background

5. **Animation Improvements:**
   - Current stroke animation speed: 2.0
   - Consider slower speed (1.5) for better learning
   - Add celebratory effect when character completes (sparkle, bounce)
   - Show stroke order numbers more prominently

**Recommended Changes:**
```dart
// Proposed new values
Container(
  width: 120,  // Increased from 100
  height: 120,
  decoration: BoxDecoration(
    color: Color(0xFFFFFEF7),  // Lighter cream
    border: Border.all(
      color: Color(0xFFFF9B9B),  // Coral pink
      width: 3,  // Slightly thicker
    ),
    borderRadius: BorderRadius.circular(8),  // Rounded corners
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

---

## Implementation Priority

### Phase 1 - Quick Wins (Immediate)
1. **Adjust layout ratio** from 60:40 to 70:30
   - File: `interactive_image_page.dart`
   - Change: `flex: 3` → `flex: 7` (left), `flex: 2` → `flex: 3` (right)
   - Effort: 5 minutes

2. **Reduce audio playback speed**
   - File: `text_to_speech_service.dart`
   - Chinese: `0.85` → `0.6`
   - English: `1.0` → `0.7`
   - Effort: 5 minutes

### Phase 2 - Enhanced Features (Short-term)
3. **Improve 田字格 visual design**
   - Update colors, size, spacing
   - Add rounded corners and subtle shadows
   - Effort: 1-2 hours

4. **Implement 5-line-3-grid for English**
   - Create new `EnglishFiveLineGrid` widget
   - Implement grid drawing with CustomPainter
   - Add letter positioning logic
   - Effort: 3-4 hours

### Phase 3 - Advanced Features (Future)
5. **Add playback speed controls**
   - UI for speed selection (slow/normal/fast)
   - Save user preferences
   - Effort: 2-3 hours

6. **Enhanced animations and celebrations**
   - Character completion effects
   - Stroke order improvements
   - Effort: 2-3 hours

---

## Testing Checklist

After implementation, verify:
- [ ] Layout looks balanced on iPad (70:30 ratio)
- [ ] Right panel is not too cramped for character display
- [ ] Audio playback is clear and not too fast for children
- [ ] Chinese and English can be distinguished clearly
- [ ] 5-line-3-grid displays correctly for all English letters
- [ ] Uppercase, lowercase, and descender letters position correctly
- [ ] 田字格 colors are child-friendly and appealing
- [ ] Character animations are smooth and educational
- [ ] Overall page feels more suitable for children's learning

---

## User Confirmation Required

Before implementation, please confirm:
1. **Layout ratio preference:** 70:30, 75:25, or fixed width?
2. **Audio speed:** Start with slower defaults, or add speed controls immediately?
3. **田字格 color scheme:** Coral pink border, sky blue border, or keep brown?
4. **5-line-3-grid priority:** Implement in Phase 2 or defer to Phase 3?

---

---

## 5. English Vowel Marking Feature (元音标记功能)

### Feature Overview
Mark vowels in English words with red color to help children identify and learn vowel patterns. This is an important phonics learning tool.

### User-Provided Rules Analysis

**Current Rules:**
```
基础元音：a、e、i、o、u
基础辅音：b、c、d、f、g、h、j、k、l、m、n、p、r、s、t、v、w、x、y、z

元音组合：
1. ea、ee、ie、oe、ue、ai、oi、ou、au、oo、ow、ei、ey、oy、ay
2. a-e、i-e、o-e、u-e、e-e（分离元音组合，如 make, time, home）
3. aigh、eigh、ough、augh、eau
4. ar、er、ir、or、ur、ear、air、ure、ier、are、ore、ere、ire
5. al、el、il、ol、ell
```

### Rule Analysis and Issues

**✅ Correct Rules:**
- Basic vowels (a, e, i, o, u) are correct
- Most vowel digraphs are correct (ea, ee, ai, oi, etc.)
- R-controlled vowels are well covered (ar, er, ir, or, ur)
- Split vowel patterns (a-e, i-e, o-e, u-e) are important

**⚠️ Issues to Consider:**

1. **Letter "y" as a vowel:**
   - "y" is listed as consonant, but it acts as vowel in many cases:
     - At end of words: "my", "fly", "happy", "baby"
     - In middle of words: "gym", "myth", "symbol"
   - **Recommendation:** Add "y" as conditional vowel

2. **Letter "w" in vowel combinations:**
   - "w" can be part of vowel sounds: "ow" (cow), "ew" (new), "aw" (saw)
   - Already have "ow" in list, but missing "ew", "aw"
   - **Recommendation:** Add "ew", "aw"

3. **Pattern Overlap Issues:**
   - "ear" matches both "ea" and "ear" - which to mark?
   - "ough" contains "ou" - need to match longest first
   - "are" contains "ar" - need to match longest first
   - **Recommendation:** Match longest patterns first (greedy matching)

4. **Missing Common Patterns:**
   - "oa" (boat, coat) - very common
   - "ui" (fruit, suit)
   - "ew" (new, few)
   - "aw" (saw, law)
   - "igh" (high, night) - you have "aigh", "eigh" but not plain "igh"
   - **Recommendation:** Add these patterns

5. **Silent "e" in Split Patterns:**
   - In "make" (a-e pattern), should we mark both "a" and "e"?
   - Or just the "a" since "e" is silent?
   - **Educational decision needed:** Mark both or just the sounding vowel?

### Revised Rule Set

**Recommended Complete Rules:**

```dart
// Priority order: Match longest patterns first!

// 1. Complex vowel combinations (3-4 letters) - MATCH FIRST
final complexPatterns = [
  'aigh', 'eigh', 'ough', 'augh', 'eau',  // 4-letter patterns
];

// 2. R-controlled and L-controlled vowels (2-3 letters)
final controlledVowels = [
  'ear', 'air', 'ure', 'ier', 'are', 'ore', 'ere', 'ire',  // 3-letter
  'ar', 'er', 'ir', 'or', 'ur',  // 2-letter r-controlled
  'ell', 'al', 'el', 'il', 'ol',  // 2-letter l-controlled
];

// 3. Common vowel digraphs (2 letters)
final vowelDigraphs = [
  'ea', 'ee', 'ie', 'oe', 'ue',  // e-combinations
  'ai', 'oi', 'ui',  // i-combinations
  'ou', 'au', 'oo',  // o/u combinations
  'ow', 'ew', 'aw',  // w-combinations
  'ei', 'ey', 'oy', 'ay',  // y-combinations
  'oa', 'igh',  // other common patterns
];

// 4. Split vowel patterns (vowel-consonant-e)
// Special handling: need to find pattern like "a...e" with one consonant between
final splitVowelPatterns = [
  'a_e', 'i_e', 'o_e', 'u_e', 'e_e',  // _ represents any single consonant
];

// 5. Single vowels (match last)
final singleVowels = ['a', 'e', 'i', 'o', 'u'];

// 6. Conditional vowels
// "y" is vowel when:
// - At end of word (my, fly, happy)
// - In middle with no other vowel in syllable (gym, myth)
// - After a consonant at end (baby, candy)
```

### Implementation Algorithm

```dart
String markVowels(String word) {
  String result = word;
  List<int> markedIndices = [];  // Track which letters are already marked

  // Step 1: Match complex patterns (longest first)
  for (var pattern in complexPatterns) {
    // Find and mark all occurrences
  }

  // Step 2: Match controlled vowels
  for (var pattern in controlledVowels) {
    // Find and mark if not already marked
  }

  // Step 3: Match vowel digraphs
  for (var pattern in vowelDigraphs) {
    // Find and mark if not already marked
  }

  // Step 4: Match split vowel patterns (special logic)
  // Look for pattern: vowel + single consonant + 'e'
  // Example: "make" -> mark 'a' and 'e'

  // Step 5: Match single vowels
  for (var vowel in singleVowels) {
    // Mark if not already marked
  }

  // Step 6: Handle 'y' as vowel (conditional)
  // Check position and context

  return result;
}
```

### Educational Considerations

**Questions to Decide:**

1. **Silent letters:**
   - In "make" (a-e), mark both 'a' and 'e', or just 'a'?
   - **Recommendation:** Mark both to show the pattern, but maybe use different shade for silent 'e'

2. **Vowel sounds vs vowel letters:**
   - Should we mark letters or sounds?
   - Example: "ough" in "though" sounds like "o", but all 4 letters are part of the pattern
   - **Recommendation:** Mark the entire pattern to teach pattern recognition

3. **Multiple interpretations:**
   - Some words can be read different ways
   - Example: "read" (present) vs "read" (past)
   - **Recommendation:** Use most common pronunciation

4. **Color coding:**
   - All vowels in same red color?
   - Or different colors for different types (basic vowels, digraphs, r-controlled)?
   - **Recommendation:** Start with single red color, can enhance later

### Implementation Approach

**Option A - Simple Highlighting:**
```dart
// Use RichText with TextSpan
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: 'B', style: blackStyle),
      TextSpan(text: 'a', style: redStyle),  // Vowel
      TextSpan(text: 'll', style: blackStyle),
    ],
  ),
)
```

**Option B - Advanced with Pattern Info:**
```dart
// Show pattern type on tap
GestureDetector(
  onTap: () => showPatternInfo('ea', 'vowel digraph'),
  child: Text('ea', style: redStyle),
)
```

### Testing Examples

Test the algorithm with these words:

```
Simple vowels:
- "cat" -> c[a]t
- "dog" -> d[o]g

Vowel digraphs:
- "boat" -> b[oa]t
- "rain" -> r[ai]n

R-controlled:
- "car" -> c[ar]
- "bird" -> b[ir]d

Split vowels:
- "make" -> m[a]k[e]
- "time" -> t[i]m[e]

Complex:
- "night" -> n[igh]t
- "though" -> th[ough]

Y as vowel:
- "my" -> m[y]
- "happy" -> happ[y]
- "gym" -> g[y]m

Overlapping patterns:
- "bear" -> b[ear] (not b[ea]r)
- "care" -> c[are] (not c[ar]e)
```

### Integration with 5-Line-3-Grid

The vowel marking should work together with the 5-line-3-grid display:
- Vowels displayed in red color
- Consonants in black color
- All letters positioned correctly on the grid
- Pattern highlighting helps children see vowel combinations

### Implementation Priority

**Suggested Approach:**
1. **Phase 1:** Implement basic vowel marking (single vowels + common digraphs)
2. **Phase 2:** Add complex patterns and r-controlled vowels
3. **Phase 3:** Add split vowel pattern detection
4. **Phase 4:** Add conditional 'y' handling

---

*Document created: 2026-02-12*
*Last updated: 2026-02-12*
*Status: Requirements Analysis - Awaiting User Confirmation*
