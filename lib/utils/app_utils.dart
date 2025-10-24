import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../presentation/widgets/app_loading_indicator.dart';

/// 应用程序工具类
class AppUtils {
  /// 显示成功消息
  static void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
  
  /// 显示错误消息
  static void showError(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
  
  /// 显示警告消息
  static void showWarning(String message) {
    Get.snackbar(
      '警告',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
  
  /// 显示信息消息
  static void showInfo(String message) {
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
  
  /// 显示确认对话框
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// 显示加载对话框
  static void showLoading([String? message]) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const AppLoadingIndicator(size: 28, strokeWidth: 3),
              const SizedBox(width: 20),
              Text(message ?? '加载中...'),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  /// 隐藏加载对话框
  static void hideLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
  
  /// 格式化日期
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// 获取相对时间
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// 验证手机号格式
  static bool isValidPhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }
  
  /// 获取随机颜色
  static Color getRandomColor() {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
      const Color(0xFFF44336),
      const Color(0xFF607D8B),
      const Color(0xFF795548),
      const Color(0xFF009688),
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
}
