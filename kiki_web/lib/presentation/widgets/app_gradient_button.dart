import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color textColor;
  final IconData? trailingIcon;

  const AppGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 52,
    this.borderRadius = 28,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w700,
    this.padding,
    this.gradient,
    this.textColor = Colors.white,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: isDisabled
              ? const LinearGradient(
                  colors: [Color(0xFFCAD5B4), Color(0xFFB9C8A2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : (gradient ?? AppColors.primaryGradient),
          boxShadow: isDisabled
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.darkGreen.withOpacity(0.24),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: textColor,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: fontSize + 2, color: textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
