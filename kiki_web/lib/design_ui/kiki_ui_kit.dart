import 'package:flutter/material.dart';

/// Hi Kiki UI 规范（基于当前设计稿提炼）
///
/// 目标：沉淀“可复用规范”，而不是页面级散乱样式。
class KikiUiColors {
  KikiUiColors._();

  // Canvas / surfaces
  static const Color pageBackground = Color(0xFFF7EEDB);
  static const Color panel = Color(0xFFFFF7E8);
  static const Color panelSoft = Color(0xFFFDF4E2);
  static const Color inputBackground = Color(0xFFFFFFFF);

  // Primary accents
  static const Color brandGreen = Color(0xFF79BF3F);
  static const Color brandGreenDark = Color(0xFF66A932);
  static const Color brandGreenLight = Color(0xFFA4D564);

  // Text
  static const Color textPrimary = Color(0xFF3F2718);
  static const Color textSecondary = Color(0xFF7A6A5B);
  static const Color textHint = Color(0xFFB7AB9D);

  // Utility
  static const Color line = Color(0xFFE7DCCB);
  static const Color danger = Color(0xFFEC5B57);
}

class KikiUiRadii {
  KikiUiRadii._();

  static const double card = 24;
  static const double input = 16;
  static const double button = 28;
  static const double chip = 999;
}

class KikiUiShadows {
  KikiUiShadows._();

  static List<BoxShadow> panel = const [
    BoxShadow(
      color: Color(0x1F5D4A2E),
      blurRadius: 26,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x14FFFFFF),
      blurRadius: 2,
      offset: Offset(0, -1),
    ),
  ];

  static List<BoxShadow> button = const [
    BoxShadow(
      color: Color(0x2A5A9B2B),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> floating = const [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

class KikiUiDecor {
  KikiUiDecor._();

  static BoxDecoration pageBackgroundDecor = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF8EFDC), Color(0xFFF5E7CF)],
    ),
  );

  static BoxDecoration panelDecor = BoxDecoration(
    color: KikiUiColors.panel,
    borderRadius: BorderRadius.circular(KikiUiRadii.card),
    border: Border.all(color: const Color(0xFFFFFBF2), width: 1.4),
    boxShadow: KikiUiShadows.panel,
  );

  static InputDecoration inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        height: 1.25,
        color: KikiUiColors.textHint,
      ),
      prefixIcon: Icon(prefixIcon, color: KikiUiColors.textHint, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: KikiUiColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KikiUiRadii.input),
        borderSide: const BorderSide(color: KikiUiColors.line, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KikiUiRadii.input),
        borderSide: const BorderSide(color: KikiUiColors.line, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KikiUiRadii.input),
        borderSide: const BorderSide(color: KikiUiColors.brandGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KikiUiRadii.input),
        borderSide: const BorderSide(color: KikiUiColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KikiUiRadii.input),
        borderSide: const BorderSide(color: KikiUiColors.danger, width: 2),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: KikiUiColors.brandGreen,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(KikiUiRadii.button),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14),
  ).copyWith(
    overlayColor: WidgetStatePropertyAll(
      KikiUiColors.brandGreenDark.withValues(alpha: 0.08),
    ),
  );

  static BoxDecoration primaryButtonDecor = BoxDecoration(
    borderRadius: BorderRadius.circular(KikiUiRadii.button),
    gradient: const LinearGradient(
      colors: [KikiUiColors.brandGreenLight, KikiUiColors.brandGreen],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    boxShadow: KikiUiShadows.button,
  );

  static BoxDecoration glassChipDecor = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.75),
    borderRadius: BorderRadius.circular(KikiUiRadii.chip),
    border: Border.all(color: Colors.white.withValues(alpha: 0.88), width: 1),
    boxShadow: KikiUiShadows.floating,
  );
}
