import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_update_controller.dart';

/// 版本更新检查 Widget
/// 独立触发，避免与页面生命周期冲突
class AppUpdateChecker extends StatefulWidget {
  final Widget child;

  const AppUpdateChecker({Key? key, required this.child}) : super(key: key);

  @override
  State<AppUpdateChecker> createState() => _AppUpdateCheckerState();
}

class _AppUpdateCheckerState extends State<AppUpdateChecker> {
  Timer? _checkTimer;
  Animation<double>? _routeAnimation;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_canCheckUpdate()) {
        return;
      }

      final route = ModalRoute.of(context);
      final animation = route?.animation;
      if (animation == null || animation.status == AnimationStatus.completed) {
        _startCheckTimer();
        return;
      }

      _routeAnimation = animation;
      animation.addStatusListener(_handleRouteAnimationStatus);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _checkTimer?.cancel();
    _routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    super.dispose();
  }

  bool _canCheckUpdate() {
    return !_disposed && mounted && Get.currentRoute == '/home';
  }

  void _handleRouteAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    _routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    _routeAnimation = null;

    if (_canCheckUpdate()) {
      _startCheckTimer();
    }
  }

  void _startCheckTimer() {
    _checkTimer?.cancel();
    // 延迟5秒后检查更新；页面销毁时会取消，避免 Overlay 动画回调打到已销毁页面。
    _checkTimer = Timer(const Duration(seconds: 5), () {
      if (_canCheckUpdate()) {
        _checkUpdate();
      }
    });
  }

  Future<void> _checkUpdate() async {
    try {
      if (!_canCheckUpdate()) {
        return;
      }

      // 初始化控制器
      if (!Get.isRegistered<AppUpdateController>()) {
        Get.put(AppUpdateController());
      }

      final controller = Get.find<AppUpdateController>();

      // ✅ 正常模式：遵循7天检查间隔 + updateStatus 规则
      await controller.checkUpdateOnStartup(
        forceCheck: false,
        canShowDialog: _canCheckUpdate,
      );

      // 🧪 测试模式：忽略7天限制和 updateStatus，总是弹窗
      // await controller.checkUpdateOnStartup(forceCheck: true);
    } catch (e) {
      debugPrint('[AppUpdateChecker] 更新检查失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
