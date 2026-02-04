# Picture Generation Configuration

Based on the `PageConfig` constants, the required image specifications are **A4 Portrait** at **300 DPI**.

## Technical Specifications
- **Physical Dimensions**: 210mm x 297mm
- **Pixel Dimensions**: 2481px x 3508px
- **Aspect Ratio**: 1:1.414 (Vertical)

## Image Generation Prompt Template

Copy and paste the following prompt structure. Replace `[Subject]` with your specific image description.

### For Midjourney / General AI
```text
[Subject], high quality, 8k resolution, A4 portrait size, highly detailed, 300 DPI, --ar 210:297
```

### For Stable Diffusion (Parameters)
- **Width**: 2481 (or scaled down to 512/1024 maintaining ratio)
- **Height**: 3508 (or scaled down to 728/1456 maintaining ratio)

## Code Reference
```dart
class PageConfig {
  static const double defaultPaperHeight = 297;
  static const double defaultPaperWidth = 210;
  static const double defaultPxPaperWidth = 2481; // 300 DPI
  static const double defaultPxPaperHeight = 3508; // 300 DPI
}
```
