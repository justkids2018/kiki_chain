import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 自定义文本输入框组件
/// 
/// 提供统一的输入框样式，支持各种配置选项
/// 包含验证、图标、密码可见性等功能
/// 
/// 创建时间: 2025年8月9日
/// 最后修改: 2025年8月9日
class CustomTextField extends StatelessWidget {
  /// 文本控制器
  final TextEditingController controller;
  
  /// 标签文字
  final String labelText;
  
  /// 提示文字
  final String hintText;
  
  /// 前置图标
  final IconData? prefixIcon;
  
  /// 后置组件
  final Widget? suffixIcon;
  
  /// 是否隐藏文本（密码输入）
  final bool obscureText;
  
  /// 键盘类型
  final TextInputType keyboardType;
  
  /// 文本输入动作
  final TextInputAction textInputAction;
  
  /// 验证器
  final String? Function(String?)? validator;
  
  /// 提交时的回调
  final void Function(String)? onFieldSubmitted;
  
  /// 是否启用
  final bool enabled;
  
  /// 最大行数
  final int maxLines;
  
  /// 最小行数
  final int? minLines;
  
  /// 最大长度
  final int? maxLength;
  
  /// 焦点节点
  final FocusNode? focusNode;
  
  /// 文本变化回调
  final void Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        if (labelText.isNotEmpty) ...[
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        
        // 输入框
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          focusNode: focusNode,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: Colors.grey[600],
                    size: 20.sp,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFF4CAF50),
                width: 2.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 2.w,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.grey[200]!,
                width: 1.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
