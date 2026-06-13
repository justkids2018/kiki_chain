import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Toast 显示位置
enum ToastPosition {
  top,
  center,
  centerBottom, // 中底部
  bottom,
}

/// 通用 Toast 工具类
/// 黑色悬浮气泡，自适应文字大小
class AppToast {
  /// 显示 Toast
  ///
  /// [message] 提示文字
  /// [position] 显示位置，默认中底部
  /// [duration] 显示时长，默认2秒
  static void show(
    String message, {
    ToastPosition position = ToastPosition.centerBottom,
    Duration duration = const Duration(seconds: 2),
  }) {
    final context = Get.overlayContext;
    if (context == null) return;

    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        position: position,
      ),
    );

    overlayState.insert(overlayEntry);

    // 指定时长后移除
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  /// 顶部 Toast
  static void showTop(String message, {Duration? duration}) {
    show(message, position: ToastPosition.top, duration: duration ?? const Duration(seconds: 2));
  }

  /// 中间 Toast
  static void showCenter(String message, {Duration? duration}) {
    show(message, position: ToastPosition.center, duration: duration ?? const Duration(seconds: 2));
  }

  /// 中底部 Toast（默认）
  static void showCenterBottom(String message, {Duration? duration}) {
    show(message, position: ToastPosition.centerBottom, duration: duration ?? const Duration(seconds: 2));
  }

  /// 底部 Toast
  static void showBottom(String message, {Duration? duration}) {
    show(message, position: ToastPosition.bottom, duration: duration ?? const Duration(seconds: 2));
  }
}

/// Toast Widget
class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastPosition position;

  const _ToastWidget({
    required this.message,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 根据位置计算 top 值
    double top;
    switch (position) {
      case ToastPosition.top:
        top = screenHeight * 0.15; // 顶部 15%
        break;
      case ToastPosition.center:
        top = screenHeight * 0.5 - 30; // 正中间
        break;
      case ToastPosition.centerBottom:
        top = screenHeight * 0.7; // 中底部 70%
        break;
      case ToastPosition.bottom:
        top = screenHeight - 100; // 底部上方 100px
        break;
    }

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.8, // 最大宽度 80%
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
