import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 统一返回按钮
///
/// 全 App 通用，暖棕圆形风格：
/// - 纯白底 + 暖米色描边
/// - arrow_back_ios_new_rounded 图标（暖棕色）
/// - 细腻投影
class GlassBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const GlassBackButton({
    Key? key,
    this.onTap,
    this.size = 40.0,
    this.iconSize = 18.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () => Get.back(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFDDD0BC),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF7A4A22),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
