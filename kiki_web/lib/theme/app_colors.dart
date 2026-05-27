import 'package:flutter/material.dart';

/// Hi Kiki 应用颜色体系
/// 基于 2025 年 UI 设计规范
class AppColors {
  AppColors._();

  // ==================== 主色调 ====================
  /// 主绿色 - 按钮、强调元素
  static const Color primaryGreen = Color(0xFF7CB342);

  /// 深绿色 - 按钮阴影、深色元素
  static const Color darkGreen = Color(0xFF689F38);

  /// 浅绿色 - hover 状态
  static const Color lightGreen = Color(0xFF9CCC65);

  // ==================== 背景色 ====================
  /// 米黄色 - 主背景
  static const Color backgroundCream = Color(0xFFF5E6D3);

  /// 浅灰色 - 护眼主背景
  static const Color backgroundSoftGray = Color(0xFFF3F4F6);

  /// 浅米色 - 卡片背景
  static const Color cardCream = Color(0xFFFFF8E7);

  /// 个人中心页背景（比主背景更浅，减少压迫感）
  static const Color profilePageBackground = Color(0xFFFFF8E7);

  /// 个人中心用户信息卡背景
  static const Color profileHeaderCardBackground = Color(0xFFF7F1E1);

  /// 个人中心卡片边框
  static const Color profileCardBorder = Color(0xFFE8E1D7);

  /// 白色 - 输入框背景
  static const Color white = Color(0xFFFFFFFF);

  // ==================== 辅助色 ====================
  /// 橙黄色 - 等级、徽章
  static const Color orange = Color(0xFFFFA726);

  /// 蓝色 - 通知图标
  static const Color blue = Color(0xFF42A5F5);

  /// 紫色 - 帮助图标
  static const Color purple = Color(0xFFAB47BC);

  /// 粉色 - 关于图标
  static const Color pink = Color(0xFFEC407A);

  /// 红色 - 退出按钮、错误提示
  static const Color red = Color(0xFFEF5350);

  // ==================== 文字色 ====================
  /// 深棕色 - 主标题
  static const Color textDarkBrown = Color(0xFF4E342E);

  /// 中棕色 - 正文
  static const Color textBrown = Color(0xFF6D4C41);

  /// 灰色 - 次要文字、占位符
  static const Color textGray = Color(0xFF9E9E9E);

  /// 浅灰色 - 禁用文字
  static const Color textLightGray = Color(0xFFBDBDBD);

  // ==================== 边框色 ====================
  /// 浅边框
  static const Color borderLight = Color(0xFFE0E0E0);

  /// 中等边框
  static const Color borderMedium = Color(0xFFBDBDBD);

  // ==================== 阴影色 ====================
  /// 卡片阴影
  static const Color shadowLight = Color(0x1A000000);

  /// 按钮阴影
  static const Color shadowMedium = Color(0x33000000);

  // ==================== 渐变色 ====================
  /// 主按钮渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, darkGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// 等级进度条渐变
  static const LinearGradient levelGradient = LinearGradient(
    colors: [orange, Color(0xFFFFB74D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
