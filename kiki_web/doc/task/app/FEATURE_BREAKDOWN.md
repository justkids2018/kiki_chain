# Interactive Page Feature Breakdown & Implementation Plan

## Overview
This document breaks down the interactive detail page optimization requirements into specific, actionable features with clear priorities and dependencies.

---

## Feature List

### 🎯 Priority 1 - Quick Wins (Immediate Impact)

#### F1.1 - Layout Ratio Adjustment
**Description:** Adjust tablet layout from 60:40 to 70:30 ratio

**Files to modify:**
- `lib/presentation/pages/interactive_image/interactive_image_page.dart`

**Changes:**
```dart
// Line 82-92
Expanded(
  flex: 7,  // Changed from 3
  child: _buildLargeImageContainer(...),
),
Expanded(
  flex: 3,  // Keep as 3
  child: _buildCompactCharacterPanel(...),
),
```

**Testing:**
- [ ] Layout looks balanced on iPad
- [ ] Right panel not too cramped
- [ ] Interactive image has more space

**Dependencies:** None

---

#### F1.2 - Audio Playback Speed Reduction
**Description:** Reduce default TTS speed for clearer pronunciation

**Files to modify:**
- `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`

**Changes:**
```dart
// Line 89 - Chinese settings
await _tts.setSpeechRate(0.6);  // Changed from 0.85

// Line 101 - English settings
await _tts.setSpeechRate(0.7);  // Changed from 1.0
```

**Testing:**
- [ ] Chinese pronunciation is clear and not too fast
- [ ] English pronunciation is clear and not too fast
- [ ] Pause between Chinese and English is appropriate

**Dependencies:** None

---

### 🎨 Priority 2 - Visual Enhancements

#### F2.1 - Child-Friendly 田字格 Design
**Description:** Improve 田字格 visual design with warmer colors and better sizing

**Files to modify:**
- `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- `lib/presentation/pages/interactive_image/widgets/character_stroke_grid.dart`

**Changes:**

**Step 1: Update colors and size**
```dart
// tian_zi_ge_char.dart - Line 162-168
Container(
  width: 120,  // Increased from 100
  height: 120,
  decoration: BoxDecoration(
    color: Color(0xFFFFFEF7),  // Lighter cream (was #FFF9F0)
    border: Border.all(
      color: Color(0xFFFF9B9B),  // Coral pink (was #E0C0A0)
      width: 3,  // Increased from 2
    ),
    borderRadius: BorderRadius.circular(8),  // Added rounded corners
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

**Step 2: Update grid painter colors**
```dart
// _TianZiGePainter - Line 203-206
final paint = Paint()
  ..color = Color(0xFFFFE4C4).withOpacity(0.6)  // Lighter grid lines
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.5;  // Slightly thicker
```

**Step 3: Update spacing**
```dart
// character_stroke_grid.dart - Line 31-32
Wrap(
  spacing: 16,  // Increased from 12
  runSpacing: 16,  // Increased from 12
  ...
)
```

**Step 4: Update cell size parameter**
```dart
// interactive_image_page.dart - Line 490
CharacterStrokeGrid(
  cells: cells,
  cellSize: 120,  // Increased from 100
  ...
)
```

**Testing:**
- [ ] Colors are child-friendly and appealing
- [ ] Size is appropriate for iPad display
- [ ] Spacing provides clear separation
- [ ] Rounded corners look smooth
- [ ] Shadow effect is subtle

**Dependencies:** None

---

### 📝 Priority 3 - English Display Features

#### F3.1 - Five-Line-Three-Grid Widget
**Description:** Create new widget to display English letters with proper writing format

**New files to create:**
- `lib/presentation/pages/interactive_image/widgets/english_five_line_grid.dart`
- `lib/presentation/pages/interactive_image/widgets/five_line_grid_painter.dart`

**Implementation steps:**

**Step 1: Create FiveLineGridPainter**
```dart
class FiveLineGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw 5 horizontal lines
    // Top line, Upper line, Middle line (thicker), Lower line, Bottom line
    // Spacing: 25% between each line
  }
}
```

**Step 2: Create letter positioning logic**
```dart
class LetterPosition {
  static double getBaselineOffset(String letter) {
    // Uppercase: sit on middle line
    // Lowercase (a,c,e,m,n,o,r,s,u,v,w,x,z): between middle and upper
    // Tall lowercase (b,d,f,h,k,l,t): touch top line
    // Descenders (g,j,p,q,y): extend to lower line
  }
}
```

**Step 3: Create EnglishFiveLineGrid widget**
```dart
class EnglishFiveLineGrid extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FiveLineGridPainter(),
      child: _buildPositionedLetters(),
    );
  }
}
```

**Step 4: Replace EnglishStrokeDisplay**
```dart
// interactive_image_page.dart - Line 221-226
// Replace EnglishStrokeDisplay with EnglishFiveLineGrid
EnglishFiveLineGrid(
  text: region.textEnglish,
  fontSize: 24,
  fontColor: Colors.black,
)
```

**Testing:**
- [ ] 5 lines display correctly with proper spacing
- [ ] Middle line is thicker/darker
- [ ] Uppercase letters position correctly
- [ ] Lowercase letters position correctly
- [ ] Descenders extend below baseline
- [ ] Grid height is appropriate (~120-150px)

**Dependencies:** None

---

#### F3.2 - Vowel Marking Implementation
**Description:** Mark vowels in English words with red color

**New files to create:**
- `lib/presentation/pages/interactive_image/utils/vowel_marker.dart`
- `lib/presentation/pages/interactive_image/widgets/vowel_marked_text.dart`

**Implementation steps:**

**Step 1: Create VowelMarker utility class**
```dart
// vowel_marker.dart
class VowelMarker {
  static VowelMarkingResult markVowels(String word) {
    // Implement pattern matching algorithm
    // Priority: complex patterns → controlled vowels → digraphs → single vowels
  }
}
```

**Step 2: Create VowelMarkedText widget**
```dart
// vowel_marked_text.dart
class VowelMarkedText extends StatelessWidget {
  final String text;

  @override
  Widget build(BuildContext context) {
    final result = VowelMarker.markVowels(text);
    return RichText(
      text: TextSpan(
        children: result.segments.map((s) => TextSpan(
          text: s.text,
          style: TextStyle(
            color: s.isVowel ? Colors.red : Colors.black,
          ),
        )).toList(),
      ),
    );
  }
}
```

**Step 3: Integrate with EnglishFiveLineGrid**
```dart
// Modify EnglishFiveLineGrid to support vowel marking
class EnglishFiveLineGrid extends StatelessWidget {
  final String text;
  final bool markVowels;  // New parameter

  Widget _buildPositionedLetters() {
    if (markVowels) {
      final result = VowelMarker.markVowels(text);
      // Build with colored segments
    }
  }
}
```

**Step 4: Add unit tests**
```dart
// test/vowel_marker_test.dart
void main() {
  test('marks single vowels', () {
    expect(VowelMarker.markVowels('cat'), ...);
  });

  test('marks vowel digraphs', () {
    expect(VowelMarker.markVowels('boat'), ...);
  });

  // Add more test cases
}
```

**Testing:**
- [ ] Single vowels marked correctly (cat, dog)
- [ ] Vowel digraphs marked correctly (boat, rain)
- [ ] R-controlled vowels marked correctly (car, bird)
- [ ] Split vowels marked correctly (make, time)
- [ ] Complex patterns marked correctly (night, though)
- [ ] Y as vowel marked correctly (my, happy, gym)
- [ ] No overlapping marks
- [ ] Longest patterns matched first

**Dependencies:** F3.1 (EnglishFiveLineGrid)

---

### 🎛️ Priority 4 - Advanced Controls

#### F4.1 - Global Playback Speed Settings
**Description:** Add global settings for audio playback speed with persistence

**Architecture:** Global app setting (not per-page control)

**Files to create:**
- `lib/core/settings/app_settings_service.dart` (if not exists)
- `lib/presentation/widgets/settings_dialog.dart`

**Files to modify:**
- `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`
- `lib/presentation/pages/home/home_page.dart` (or main app bar)
- `lib/core/constants/app_constants.dart`

**Implementation steps:**

**Step 1: Create global settings service**
```dart
// lib/core/settings/app_settings_service.dart
import 'package:get_storage/get_storage.dart';

enum PlaybackSpeed { slow, normal, fast }

class AppSettingsService extends GetxService {
  final _storage = GetStorage();
  static const _speedKey = 'playback_speed';

  // Observable speed setting
  final playbackSpeed = PlaybackSpeed.normal.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final savedSpeed = _storage.read(_speedKey);
    if (savedSpeed != null) {
      playbackSpeed.value = PlaybackSpeed.values.firstWhere(
        (e) => e.toString() == savedSpeed,
        orElse: () => PlaybackSpeed.normal,
      );
    }
  }

  Future<void> setPlaybackSpeed(PlaybackSpeed speed) async {
    playbackSpeed.value = speed;
    await _storage.write(_speedKey, speed.toString());
  }

  // Get speed rates for TTS
  ({double chinese, double english}) getSpeedRates() {
    return switch (playbackSpeed.value) {
      PlaybackSpeed.slow => (chinese: 0.5, english: 0.6),
      PlaybackSpeed.normal => (chinese: 0.7, english: 0.8),
      PlaybackSpeed.fast => (chinese: 0.9, english: 1.0),
    };
  }
}
```

**Step 2: Initialize settings service in main.dart**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize global settings
  Get.put(AppSettingsService());

  runApp(MyApp());
}
```

**Step 3: Update TTS service to use global settings**
```dart
// text_to_speech_service.dart
class TextToSpeechService {
  final _settings = Get.find<AppSettingsService>();

  Future<void> speakRegion(InteractiveRegion region) async {
    final rates = _settings.getSpeedRates();

    // Chinese
    await _tts.setSpeechRate(rates.chinese);
    await _tts.speak(region.text);

    // English
    await _tts.setSpeechRate(rates.english);
    await _tts.speak(region.textEnglish);
  }
}
```

**Step 4: Create settings dialog**
```dart
// lib/presentation/widgets/settings_dialog.dart
class SettingsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsService>();

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('设置', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),

            // Playback speed section
            Text('语音播放速度', style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),

            Obx(() => SegmentedButton<PlaybackSpeed>(
              segments: [
                ButtonSegment(
                  value: PlaybackSpeed.slow,
                  label: Text('慢速'),
                  icon: Icon(Icons.speed),
                ),
                ButtonSegment(
                  value: PlaybackSpeed.normal,
                  label: Text('正常'),
                  icon: Icon(Icons.speed),
                ),
                ButtonSegment(
                  value: PlaybackSpeed.fast,
                  label: Text('快速'),
                  icon: Icon(Icons.speed),
                ),
              ],
              selected: {settings.playbackSpeed.value},
              onSelectionChanged: (Set<PlaybackSpeed> selected) {
                settings.setPlaybackSpeed(selected.first);
              },
            )),

            SizedBox(height: 24),

            // Close button
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('完成'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Add settings button to app bar**
```dart
// home_page.dart or main app bar
AppBar(
  title: Text('奇奇漫游'),
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        Get.dialog(SettingsDialog());
      },
    ),
  ],
)
```

**Step 6: Add settings button to interactive page**
```dart
// interactive_image_page.dart - _buildTopBar
Widget _buildTopBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
      children: [
        // Back Button
        GestureDetector(...),

        const Spacer(),

        // Settings Button (NEW)
        GestureDetector(
          onTap: () => Get.dialog(SettingsDialog()),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
        ),

        const SizedBox(width: 12),

        // Hint Button
        Container(...),
      ],
    ),
  );
}
```

**Testing:**
- [ ] Settings dialog opens from app bar
- [ ] Settings dialog opens from interactive page
- [ ] Speed selection updates immediately
- [ ] Speed change applies to next audio playback
- [ ] Speed preference persists after app restart
- [ ] All three speeds work correctly (slow/normal/fast)
- [ ] Settings dialog UI is child-friendly
- [ ] Settings button is easily accessible

**Dependencies:** None

**Notes:**
- Uses GetStorage for persistence (lightweight, fast)
- Settings apply globally across all pages
- User only needs to set once
- Can add more settings in future (volume, language preference, etc.)

---

#### F4.2 - Animation Enhancements
**Description:** Add celebratory effects and improve stroke animations

**Files to modify:**
- `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- `lib/presentation/pages/interactive_image/widgets/character_stroke_grid.dart`

**Implementation steps:**

**Step 1: Slow down stroke animation**
```dart
// tian_zi_ge_char.dart - Line 95
StrokeOrderAnimationController(
  strokeAnimationSpeed: 1.5,  // Changed from 2.0
  ...
)
```

**Step 2: Add completion celebration**
```dart
// Create new widget: character_celebration.dart
class CharacterCelebration extends StatelessWidget {
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // Sparkle effect, bounce animation, etc.
    );
  }
}
```

**Step 3: Integrate celebration**
```dart
// tian_zi_ge_char.dart
void _notifyCompletion() {
  if (_hasNotifiedCompletion) return;
  _hasNotifiedCompletion = true;

  // Show celebration
  _showCelebration();

  widget.onAnimationComplete?.call();
}
```

**Testing:**
- [ ] Stroke animation is smooth and educational
- [ ] Celebration appears on completion
- [ ] Celebration is child-friendly and encouraging
- [ ] Animation doesn't interfere with learning

**Dependencies:** F2.1 (田字格 design)

---

## Implementation Sequence

### Phase 1: Foundation (Quick Wins)
1. F1.1 - Layout Ratio Adjustment
2. F1.2 - Audio Playback Speed Reduction

**Outcome:** Immediate improvement in user experience

---

### Phase 2: Visual Polish
3. F2.1 - Child-Friendly 田字格 Design

**Outcome:** More appealing Chinese character display

---

### Phase 3: English Features
4. F3.1 - Five-Line-Three-Grid Widget
5. F3.2 - Vowel Marking Implementation

**Outcome:** Complete English learning features

---

### Phase 4: Advanced Features
6. F4.1 - Global Playback Speed Settings (with persistence)
7. F4.2 - Animation Enhancements

**Outcome:** Enhanced interactivity and customization with global settings infrastructure

---

## Testing Strategy

### Unit Tests
- [ ] VowelMarker algorithm tests
- [ ] Letter positioning logic tests
- [ ] Speed calculation tests

### Widget Tests
- [ ] EnglishFiveLineGrid rendering
- [ ] VowelMarkedText rendering
- [ ] Speed control UI (SettingsDialog)
- [ ] Settings persistence

### Integration Tests
- [ ] Complete flow: tap region → display → audio playback
- [ ] Speed changes persist
- [ ] Layout adapts to different screen sizes

### Manual Testing
- [ ] Test on iPad Pro 13-inch
- [ ] Test with all 15 scenes
- [ ] Test with different English words
- [ ] Test audio quality
- [ ] Test visual appeal with children (if possible)

---

## Rollback Plan

Each feature should be implemented with feature flags:

```dart
class FeatureFlags {
  static const useNewLayout = true;  // F1.1
  static const useSlowerAudio = true;  // F1.2
  static const useNewTianZiGe = true;  // F2.1
  static const useFiveLineGrid = true;  // F3.1
  static const useVowelMarking = true;  // F3.2
  static const useSpeedControls = true;  // F4.1
  static const useAnimationEnhancements = true;  // F4.2
}
```

If any feature causes issues, set its flag to `false` to revert.

---

## Success Metrics

After implementation, measure:
- [ ] User engagement time on interactive pages
- [ ] Number of regions tapped per session
- [ ] Audio playback completion rate
- [ ] User feedback on visual appeal
- [ ] Learning effectiveness (if measurable)

---

*Document created: 2026-02-12*
*Status: Feature Breakdown - Ready for Implementation*
