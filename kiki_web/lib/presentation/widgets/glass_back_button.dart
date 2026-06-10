import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 毛玻璃效果的返回按钮组件
class GlassBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const GlassBackButton({
    Key? key,
    this.onTap,
    this.size = 44.0,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.back(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: const Color(0xFF5A6B7B),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
