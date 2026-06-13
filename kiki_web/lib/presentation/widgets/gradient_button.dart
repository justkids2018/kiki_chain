import 'package:flutter/material.dart';

/// 统一的渐变按钮组件
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isDisabled;

  const GradientButton({
    Key? key,
    required this.text,
    this.onTap,
    this.isPrimary = true,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : (isPrimary
                  ? const LinearGradient(
                      colors: [Color(0xFF8BC34A), Color(0xFF7CB342)],
                    )
                  : null),
          color: isDisabled
              ? Colors.grey.shade300
              : (isPrimary ? null : Colors.white.withOpacity(0.9)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDisabled || !isPrimary
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF8BC34A).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPrimary
                  ? Colors.white
                  : (isDisabled ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }
}
