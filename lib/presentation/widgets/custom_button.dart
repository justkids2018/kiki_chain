import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_loading_indicator.dart';

/// 自定义按钮组件
/// 
/// 提供统一的按钮样式，支持多种类型和状态
/// 包含加载状态、禁用状态、不同样式等
/// 
/// 创建时间: 2025年8月9日
/// 最后修改: 2025年8月9日
class CustomButton extends StatelessWidget {
  /// 按钮文字
  final String text;
  
  /// 点击回调
  final VoidCallback? onPressed;
  
  /// 异步点击回调
  final Future<void> Function()? onPressedAsync;
  
  /// 按钮高度
  final double? height;
  
  /// 按钮宽度
  final double? width;
  
  /// 圆角半径
  final double? borderRadius;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 文字颜色
  final Color? textColor;
  
  /// 文字大小
  final double? fontSize;
  
  /// 字体粗细
  final FontWeight? fontWeight;
  
  /// 是否加载中
  final bool isLoading;
  
  /// 是否启用
  final bool enabled;
  
  /// 按钮类型
  final CustomButtonType type;
  
  /// 图标
  final IconData? icon;
  
  /// 边框颜色
  final Color? borderColor;
  
  /// 边框宽度
  final double? borderWidth;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.onPressedAsync,
    this.height,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.isLoading = false,
    this.enabled = true,
    this.type = CustomButtonType.filled,
    this.icon,
    this.borderColor,
    this.borderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || isLoading;
    final double buttonHeight = height ?? 48.0;
    final double buttonBorderRadius = borderRadius ?? 24.0;
    final double buttonWidth = width ?? double.infinity;
    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isDisabled ? null : _handlePress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: buttonHeight,
          width: buttonWidth,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : (backgroundColor != null
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF0071e3), Color(0xFF4FC3F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
            color: backgroundColor ?? (isDisabled ? Colors.grey[300] : null),
            borderRadius: BorderRadius.circular(buttonBorderRadius),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: (backgroundColor ?? const Color(0xFF0071e3)).withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
            border: borderColor != null
                ? Border.all(color: borderColor!, width: borderWidth ?? 2)
                : null,
          ),
          child: Center(
            child: _buildButtonContentWeb(isDisabled),
          ),
        ),
      ),
    );
  }
  
  Widget _buildButton(
    BuildContext context,
    bool isDisabled,
    double buttonHeight,
    double buttonBorderRadius,
  ) {
    switch (type) {
      case CustomButtonType.filled:
        return _buildFilledButton(isDisabled, buttonBorderRadius);
      case CustomButtonType.outlined:
        return _buildOutlinedButton(isDisabled, buttonBorderRadius);
      case CustomButtonType.text:
        return _buildTextButton(isDisabled);
    }
  }
  
  Widget _buildFilledButton(bool isDisabled, double buttonBorderRadius) {
    return ElevatedButton(
      onPressed: isDisabled ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled 
            ? Colors.grey[300] 
            : backgroundColor ?? const Color(0xFF4CAF50),
        foregroundColor: isDisabled 
            ? Colors.grey[600] 
            : textColor ?? Colors.white,
        elevation: isDisabled ? 0 : 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
      ),
      child: _buildButtonContentWeb(isDisabled),
    );
  }
  
  Widget _buildOutlinedButton(bool isDisabled, double buttonBorderRadius) {
    return OutlinedButton(
      onPressed: isDisabled ? null : _handlePress,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDisabled 
            ? Colors.grey[600] 
            : textColor ?? const Color(0xFF4CAF50),
        side: BorderSide(
          color: isDisabled 
              ? Colors.grey[300]! 
              : borderColor ?? const Color(0xFF4CAF50),
          width: borderWidth ?? 1.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
      ),
      child: _buildButtonContentWeb(isDisabled),
    );
  }
  
  Widget _buildTextButton(bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : _handlePress,
      style: TextButton.styleFrom(
        foregroundColor: isDisabled 
            ? Colors.grey[600] 
            : textColor ?? const Color(0xFF4CAF50),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
      ),
      child: _buildButtonContentWeb(isDisabled),
    );
  }
  
  Widget _buildButtonContentWeb(bool isDisabled) {
    final Color effectiveTextColor = textColor ?? (backgroundColor != null
        ? (backgroundColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white)
        : Colors.white);
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoadingIndicator(
            size: 18,
            strokeWidth: 2.2,
            color: effectiveTextColor,
          ),
          const SizedBox(width: 10),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: fontSize ?? 18,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: effectiveTextColor,
            ),
          ),
        ],
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: effectiveTextColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 18,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: effectiveTextColor,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 18,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: effectiveTextColor,
        letterSpacing: 0.2,
      ),
    );
  }
  
  void _handlePress() {
    if (onPressedAsync != null) {
      onPressedAsync!();
    } else if (onPressed != null) {
      onPressed!();
    }
  }
}

/// 按钮类型枚举
enum CustomButtonType {
  /// 填充按钮
  filled,
  /// 边框按钮
  outlined,
  /// 文本按钮
  text,
}
