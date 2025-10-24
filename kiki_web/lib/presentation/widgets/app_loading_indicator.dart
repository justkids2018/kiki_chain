import 'package:flutter/material.dart';

/// 全局统一的加载指示器，遵循 UI 设计系统配色与尺寸规范。
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
    this.color = const Color(0xFF00C37D),
    this.backgroundColor = Colors.transparent,
  });

  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
