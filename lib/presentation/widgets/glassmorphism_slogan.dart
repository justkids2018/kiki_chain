import 'package:flutter/material.dart';
import '../../config/app_color.dart';

/// 玻璃拟态 Slogan 独立组件
class GlassmorphismSlogan extends StatelessWidget {
  final String slogan;
  final TextStyle? style;
  const GlassmorphismSlogan({
    Key? key,
    required this.slogan,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColorBg.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Text(
        slogan,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
