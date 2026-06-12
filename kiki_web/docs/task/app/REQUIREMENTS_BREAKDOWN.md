# Interactive Page Requirements Breakdown

## Overview
This document breaks down each feature into specific, actionable requirements and tasks that can be tracked and implemented independently.

---

## Phase 1: Quick Wins

### F1.1 - Layout Ratio Adjustment

#### Requirements

**REQ-F1.1-01: Adjust Left Panel Flex Ratio**
- **Description:** Change left panel (interactive image) flex value from 3 to 7
- **File:** `lib/presentation/pages/interactive_image/interactive_image_page.dart`
- **Line:** 82
- **Acceptance Criteria:**
  - [ ] Left panel flex value is 7
  - [ ] Layout compiles without errors
  - [ ] Interactive image takes ~70% of screen width on iPad

**REQ-F1.1-02: Verify Right Panel Ratio**
- **Description:** Ensure right panel (character display) maintains flex value of 3
- **File:** `lib/presentation/pages/interactive_image/interactive_image_page.dart`
- **Line:** 90
- **Acceptance Criteria:**
  - [ ] Right panel flex value remains 3
  - [ ] Character display is not cramped
  - [ ] All UI elements in right panel are visible

**REQ-F1.1-03: Test Layout on iPad**
- **Description:** Verify layout looks balanced on iPad Pro 13-inch
- **Acceptance Criteria:**
  - [ ] Layout is visually balanced
  - [ ] Interactive image has sufficient space for interaction
  - [ ] Character panel is readable and functional
  - [ ] No UI overflow or clipping

---

### F1.2 - Audio Playback Speed Reduction

#### Requirements

**REQ-F1.2-01: Reduce Chinese TTS Speed**
- **Description:** Change Chinese speech rate from 0.85 to 0.6
- **File:** `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`
- **Line:** 89
- **Acceptance Criteria:**
  - [ ] Chinese speech rate is set to 0.6
  - [ ] Chinese pronunciation is clear and understandable
  - [ ] Speed is appropriate for children learning

**REQ-F1.2-02: Reduce English TTS Speed**
- **Description:** Change English speech rate from 1.0 to 0.7
- **File:** `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`
- **Line:** 101
- **Acceptance Criteria:**
  - [ ] English speech rate is set to 0.7
  - [ ] English pronunciation is clear and understandable
  - [ ] Speed is appropriate for children learning

**REQ-F1.2-03: Test Audio Playback**
- **Description:** Verify audio playback quality and speed
- **Acceptance Criteria:**
  - [ ] Chinese audio is not too slow or too fast
  - [ ] English audio is not too slow or too fast
  - [ ] Pause between Chinese and English is appropriate
  - [ ] Audio quality is maintained

---

## Phase 2: Visual Enhancements

### F2.1 - Child-Friendly 田字格 Design

#### Requirements

**REQ-F2.1-01: Update Container Size**
- **Description:** Increase 田字格 cell size from 100px to 120px
- **File:** `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- **Line:** 163-164
- **Acceptance Criteria:**
  - [ ] Container width is 120
  - [ ] Container height is 120
  - [ ] Character is properly centered

**REQ-F2.1-02: Update Background Color**
- **Description:** Change background color to lighter cream (#FFFEF7)
- **File:** `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- **Line:** 166
- **Acceptance Criteria:**
  - [ ] Background color is Color(0xFFFFFEF7)
  - [ ] Color is visually lighter and warmer
  - [ ] Contrast with character is sufficient

**REQ-F2.1-03: Update Border Color and Style**
- **Description:** Change border to coral pink with rounded corners
- **File:** `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- **Line:** 167-169
- **Acceptance Criteria:**
  - [ ] Border color is Color(0xFFFF9B9B) (coral pink)
  - [ ] Border width is 3
  - [ ] Border radius is 8
  - [ ] Rounded corners are smooth

**REQ-F2.1-04: Add Shadow Effect**
- **Description:** Add subtle shadow for depth
- **File:** `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- **Line:** 170-176
- **Acceptance Criteria:**
  - [ ] Shadow color is black with 0.05 opacity
  - [ ] Blur radius is 8
  - [ ] Offset is (0, 2)
  - [ ] Shadow is subtle and not distracting

**REQ-F2.1-05: Update Grid Line Color**
- **Description:** Change grid line color to lighter shade
- **File:** `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- **Line:** 203-206
- **Acceptance Criteria:**
  - [ ] Grid line color is Color(0xFFFFE4C4) with 0.6 opacity
  - [ ] Lines are visible but not intrusive
  - [ ] Stroke width is 1.5

**REQ-F2.1-06: Update Cell Spacing**
- **Description:** Increase spacing between cells from 12px to 16px
- **File:** `lib/presentation/pages/interactive_image/widgets/character_stroke_grid.dart`
- **Line:** 31-32
- **Acceptance Criteria:**
  - [ ] Spacing is 16
  - [ ] RunSpacing is 16
  - [ ] Cells have clear visual separation

**REQ-F2.1-07: Update Cell Size Parameter**
- **Description:** Update cellSize parameter in CharacterStrokeGrid usage
- **File:** `lib/presentation/pages/interactive_image/interactive_image_page.dart`
- **Line:** 490
- **Acceptance Criteria:**
  - [ ] cellSize parameter is 120
  - [ ] All characters display at correct size
  - [ ] Layout adjusts properly

**REQ-F2.1-08: Visual Testing**
- **Description:** Verify overall visual appeal
- **Acceptance Criteria:**
  - [ ] Colors are child-friendly
  - [ ] Design is appealing to children
  - [ ] Characters are clearly visible
  - [ ] Grid is educational and not distracting

---

## Phase 3: English Features

### F3.1 - Five-Line-Three-Grid Widget

#### Requirements

**REQ-F3.1-01: Create FiveLineGridPainter**
- **Description:** Create CustomPainter for drawing 5 horizontal lines
- **File:** `lib/presentation/pages/interactive_image/widgets/five_line_grid_painter.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Draws 5 horizontal lines (top, upper, middle, lower, bottom)
  - [ ] Middle line is thicker (baseline)
  - [ ] Lines are evenly spaced (25% intervals)
  - [ ] Line color is light gray (#E0E0E0)
  - [ ] Middle line color is darker (#9E9E9E)

**REQ-F3.1-02: Create Letter Position Calculator**
- **Description:** Create utility to calculate letter vertical position
- **File:** `lib/presentation/pages/interactive_image/utils/letter_position_calculator.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Handles uppercase letters (sit on middle line, touch top line)
  - [ ] Handles tall lowercase (b,d,f,h,k,l,t - touch top line)
  - [ ] Handles normal lowercase (a,c,e,m,n,o,r,s,u,v,w,x,z - between middle and upper)
  - [ ] Handles descenders (g,j,p,q,y - extend to lower line)
  - [ ] Returns correct baseline offset for each letter type

**REQ-F3.1-03: Create EnglishFiveLineGrid Widget**
- **Description:** Create main widget for displaying English text on 5-line grid
- **File:** `lib/presentation/pages/interactive_image/widgets/english_five_line_grid.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Accepts text, fontSize, fontColor parameters
  - [ ] Uses FiveLineGridPainter for background
  - [ ] Positions each letter correctly using LetterPositionCalculator
  - [ ] Supports letter-by-letter animation
  - [ ] Grid height is 120-150px

**REQ-F3.1-04: Replace EnglishStrokeDisplay**
- **Description:** Replace old widget with new EnglishFiveLineGrid
- **File:** `lib/presentation/pages/interactive_image/interactive_image_page.dart`
- **Line:** 221-226
- **Acceptance Criteria:**
  - [ ] EnglishStrokeDisplay import removed
  - [ ] EnglishFiveLineGrid imported
  - [ ] Widget replaced in _buildCompactCharacterPanel
  - [ ] Widget replaced in _buildFloatingCharacterPanel
  - [ ] Parameters passed correctly

**REQ-F3.1-05: Test Letter Positioning**
- **Description:** Verify all letter types position correctly
- **Acceptance Criteria:**
  - [ ] Uppercase letters (A-Z) position correctly
  - [ ] Tall lowercase letters position correctly
  - [ ] Normal lowercase letters position correctly
  - [ ] Descender letters position correctly
  - [ ] Mixed case words display correctly
  - [ ] Grid lines are visible and helpful

**REQ-F3.1-06: Test with Sample Words**
- **Description:** Test with various English words
- **Test Cases:**
  - [ ] "Ball" - uppercase + lowercase
  - [ ] "happy" - descender
  - [ ] "Dog" - uppercase + descender
  - [ ] "Toy" - uppercase + descender
  - [ ] "Duck" - uppercase + tall lowercase

---

### F3.2 - Vowel Marking Implementation

#### Requirements

**REQ-F3.2-01: Create VowelMarker Utility Class**
- **Description:** Create utility class for vowel pattern matching
- **File:** `lib/presentation/pages/interactive_image/utils/vowel_marker.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Defines all vowel patterns (complex, controlled, digraphs, single)
  - [ ] Implements markVowels() method
  - [ ] Returns VowelMarkingResult with segments
  - [ ] Matches longest patterns first (greedy matching)
  - [ ] Handles overlapping patterns correctly

**REQ-F3.2-02: Implement Pattern Matching - Complex Patterns**
- **Description:** Match 4-letter complex vowel patterns
- **File:** `lib/presentation/pages/interactive_image/utils/vowel_marker.dart`
- **Patterns:** aigh, eigh, ough, augh, eau
- **Acceptance Criteria:**
  - [ ] "night" → n[igh]t
  - [ ] "though" → th[ough]
  - [ ] "caught" → c[augh]t
  - [ ] "beautiful" → b[eau]tiful

**REQ-F3.2-03: Implement Pattern Matching - Controlled Vowels**
- **Description:** Match r-controlled and l-controlled vowels
- **File:** `lib/presentation/pages/interactive_image/utils/vowel_marker.dart`
- **Patterns:** ar, er, ir, or, ur, ear, air, ure, etc.
- **Acceptance Criteria:**
  - [ ] "car" → c[ar]
  - [ ] "bird" → b[ir]d
  - [ ] "bear" → b[ear]
  - [ ] "care" → c[are]

**REQ-F3.2-04: Implement Pattern Matching - Digraphs**
- **Description:** Match 2-letter vowel combinations
- **File:** `lib/presentation/pages/interactive_image/utils/vowel_marker.dart`
- **Patterns:** ea, ee, ai, oi, ou, oo, ow, oa, etc.
- **Acceptance Criteria:**
  - [ ] "boat" → b[oa]t
  - [ ] "rain" → r[ai]n
  - [ ] "feet" → f[ee]t

**REQ-F3.2-05: Implement Pattern Matching - Split Vowels**
- **Description:** Match vowel-consonant-e patterns
- **File:** `lib/presentation/pages/interactive_image/utils/vowel_marker.dart`
- **Patterns:** a-e, i-e, o-e, u-e, e-e
- **Acceptance Criteria:**
  - [ ] "make" → m[a]k[e]
  - [ ] "time" → t[i]m[e]
  - [ ] "home" → h[o]m[e]

**REQ-F3.2-06: Implement Pattern Matching - Y as Vowel**
- **Description:** Detect when 'y' acts as vowel
- **File:** `lib/presentation/pages/interactive_image/utils/vowel_marker.dart`
- **Acceptance Criteria:**
  - [ ] "my" → m[y]
  - [ ] "fly" → fl[y]
  - [ ] "happy" → happ[y]
  - [ ] "gym" → g[y]m
  - [ ] "yes" → yes (y not marked - consonant)

**REQ-F3.2-07: Create VowelMarkedText Widget**
- **Description:** Create widget to display text with marked vowels
- **File:** `lib/presentation/pages/interactive_image/widgets/vowel_marked_text.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Uses RichText with TextSpan
  - [ ] Vowels displayed in red
  - [ ] Consonants displayed in black
  - [ ] Vowels are slightly bolder (FontWeight.w600)

**REQ-F3.2-08: Integrate with EnglishFiveLineGrid**
- **Description:** Add vowel marking option to EnglishFiveLineGrid
- **File:** `lib/presentation/pages/interactive_image/widgets/english_five_line_grid.dart`
- **Acceptance Criteria:**
  - [ ] Add markVowels parameter (default: true)
  - [ ] Use VowelMarker when markVowels is true
  - [ ] Apply red color to vowel segments
  - [ ] Maintain correct letter positioning

**REQ-F3.2-09: Create Unit Tests**
- **Description:** Create comprehensive unit tests for VowelMarker
- **File:** `test/utils/vowel_marker_test.dart` (new)
- **Acceptance Criteria:**
  - [ ] Test single vowels (cat, dog, pen)
  - [ ] Test digraphs (boat, rain, feet)
  - [ ] Test r-controlled (car, bird, turn)
  - [ ] Test split vowels (make, time, home)
  - [ ] Test complex patterns (night, though, caught)
  - [ ] Test y as vowel (my, happy, gym)
  - [ ] Test overlapping patterns (bear, care)
  - [ ] All tests pass

**REQ-F3.2-10: Visual Testing**
- **Description:** Verify vowel marking is clear and educational
- **Acceptance Criteria:**
  - [ ] Red color is visible but not overwhelming
  - [ ] Vowel patterns are correctly identified
  - [ ] No incorrect markings
  - [ ] Helpful for learning vowel recognition

---

## Phase 4: Advanced Features

### F4.1 - Global Playback Speed Settings

#### Requirements

**REQ-F4.1-01: Create AppSettingsService**
- **Description:** Create global settings service with GetX
- **File:** `lib/core/settings/app_settings_service.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Extends GetxService
  - [ ] Defines PlaybackSpeed enum (slow, normal, fast)
  - [ ] Has observable playbackSpeed property
  - [ ] Implements setPlaybackSpeed() method
  - [ ] Implements getSpeedRates() method
  - [ ] Uses GetStorage for persistence

**REQ-F4.1-02: Implement Settings Persistence**
- **Description:** Save and load speed settings from storage
- **File:** `lib/core/settings/app_settings_service.dart`
- **Acceptance Criteria:**
  - [ ] Settings saved to GetStorage on change
  - [ ] Settings loaded on app start (onInit)
  - [ ] Default to 'normal' if no saved setting
  - [ ] Settings persist across app restarts

**REQ-F4.1-03: Define Speed Rate Mappings**
- **Description:** Define TTS speed rates for each speed level
- **File:** `lib/core/settings/app_settings_service.dart`
- **Acceptance Criteria:**
  - [ ] Slow: Chinese 0.5, English 0.6
  - [ ] Normal: Chinese 0.7, English 0.8
  - [ ] Fast: Chinese 0.9, English 1.0
  - [ ] Rates are easily adjustable

**REQ-F4.1-04: Initialize Settings Service**
- **Description:** Initialize AppSettingsService in main.dart
- **File:** `lib/main.dart`
- **Acceptance Criteria:**
  - [ ] GetStorage.init() called before runApp
  - [ ] AppSettingsService registered with Get.put()
  - [ ] Service is available globally
  - [ ] No initialization errors

**REQ-F4.1-05: Update TTS Service**
- **Description:** Modify TTS service to use global settings
- **File:** `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`
- **Acceptance Criteria:**
  - [ ] Inject AppSettingsService
  - [ ] Read speed rates from settings
  - [ ] Apply rates before speaking
  - [ ] Remove hardcoded speed values

**REQ-F4.1-06: Create SettingsDialog Widget**
- **Description:** Create dialog for settings UI
- **File:** `lib/presentation/widgets/settings_dialog.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Uses Dialog widget
  - [ ] Shows title "设置"
  - [ ] Has playback speed section
  - [ ] Uses SegmentedButton for speed selection
  - [ ] Has close button
  - [ ] Responsive to speed changes

**REQ-F4.1-07: Implement Speed Selection UI**
- **Description:** Create speed selection buttons
- **File:** `lib/presentation/widgets/settings_dialog.dart`
- **Acceptance Criteria:**
  - [ ] Three buttons: 慢速, 正常, 快速
  - [ ] Active button is highlighted
  - [ ] Tapping button changes speed immediately
  - [ ] Visual feedback on selection
  - [ ] Child-friendly design

**REQ-F4.1-08: Add Settings Button to Home Page**
- **Description:** Add settings button to main app bar
- **File:** `lib/presentation/pages/home/home_page.dart` (or equivalent)
- **Acceptance Criteria:**
  - [ ] Settings icon button in AppBar actions
  - [ ] Opens SettingsDialog on tap
  - [ ] Icon is clearly visible
  - [ ] Accessible from home page

**REQ-F4.1-09: Add Settings Button to Interactive Page**
- **Description:** Add settings button to interactive page top bar
- **File:** `lib/presentation/pages/interactive_image/interactive_image_page.dart`
- **Acceptance Criteria:**
  - [ ] Settings button added to _buildTopBar
  - [ ] Positioned before hint button
  - [ ] Opens SettingsDialog on tap
  - [ ] Consistent styling with other buttons

**REQ-F4.1-10: Test Settings Persistence**
- **Description:** Verify settings persist correctly
- **Acceptance Criteria:**
  - [ ] Change speed to 'slow', restart app → speed is 'slow'
  - [ ] Change speed to 'fast', restart app → speed is 'fast'
  - [ ] Default speed is 'normal' on first launch
  - [ ] Settings survive app updates

**REQ-F4.1-11: Test Speed Application**
- **Description:** Verify speed changes apply to audio
- **Acceptance Criteria:**
  - [ ] Set to 'slow' → audio plays slowly
  - [ ] Set to 'normal' → audio plays at normal speed
  - [ ] Set to 'fast' → audio plays quickly
  - [ ] Speed change applies immediately to next playback
  - [ ] Both Chinese and English respect speed setting

---

### F4.2 - Animation Enhancements

#### Requirements

**REQ-F4.2-01: Slow Down Stroke Animation**
- **Description:** Reduce stroke animation speed from 2.0 to 1.5
- **File:** `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- **Line:** 95
- **Acceptance Criteria:**
  - [ ] strokeAnimationSpeed is 1.5
  - [ ] Animation is slower and more educational
  - [ ] Stroke order is clearly visible
  - [ ] Not too slow to be boring

**REQ-F4.2-02: Create CharacterCelebration Widget**
- **Description:** Create celebration animation for character completion
- **File:** `lib/presentation/pages/interactive_image/widgets/character_celebration.dart` (new)
- **Acceptance Criteria:**
  - [ ] File created
  - [ ] Shows sparkle/star effect
  - [ ] Has bounce animation
  - [ ] Duration is 1-2 seconds
  - [ ] Child-friendly and encouraging
  - [ ] Not too distracting

**REQ-F4.2-03: Integrate Celebration Animation**
- **Description:** Show celebration when character animation completes
- **File:** `lib/presentation/pages/interactive_image/widgets/tian_zi_ge_char.dart`
- **Acceptance Criteria:**
  - [ ] Celebration triggers on _notifyCompletion
  - [ ] Overlays on top of character
  - [ ] Fades out after duration
  - [ ] Doesn't block user interaction
  - [ ] Works for all characters

**REQ-F4.2-04: Test Animation Smoothness**
- **Description:** Verify animations are smooth and educational
- **Acceptance Criteria:**
  - [ ] No frame drops or stuttering
  - [ ] Stroke animation is fluid
  - [ ] Celebration animation is smooth
  - [ ] Animations enhance learning experience
  - [ ] Performance is acceptable on iPad

---

## Summary

### Total Requirements: 58

**Phase 1:** 6 requirements
**Phase 2:** 8 requirements
**Phase 3:** 26 requirements
**Phase 4:** 18 requirements

### Files to Create: 10
1. `five_line_grid_painter.dart`
2. `letter_position_calculator.dart`
3. `english_five_line_grid.dart`
4. `vowel_marker.dart`
5. `vowel_marked_text.dart`
6. `vowel_marker_test.dart`
7. `app_settings_service.dart`
8. `settings_dialog.dart`
9. `character_celebration.dart`
10. Directory: `lib/core/settings/`

### Files to Modify: 6
1. `interactive_image_page.dart`
2. `text_to_speech_service.dart`
3. `tian_zi_ge_char.dart`
4. `character_stroke_grid.dart`
5. `main.dart`
6. `home_page.dart` (or equivalent)

---

*Document created: 2026-02-12*
*Status: Requirements Breakdown - Ready for Task Creation*
