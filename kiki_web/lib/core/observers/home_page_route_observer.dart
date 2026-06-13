import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/controllers/app_update_controller.dart';

/// 首页路由观察器
/// 监听路由完成后触发版本更新检查
class HomePageRouteObserver extends NavigatorObserver {
  bool _hasChecked = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    // 当路由到首页时
    if (route.settings.name == '/home' && !_hasChecked) {
      _hasChecked = true;

      // 使用 addPostFrameCallback 确保在构建周期之外执行
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 再延迟一帧，完全避开构建周期
        Future.delayed(const Duration(milliseconds: 100), () {
          // 再延迟确保路由动画完成
          Future.delayed(const Duration(seconds: 3), () {
            _checkUpdate();
          });
        });
      });
    }
  }

  void _checkUpdate() async {
    try {
      // 检查上下文是否有效
      if (Get.context == null || !Get.context!.mounted) {
        debugPrint('[HomePageRouteObserver] 上下文无效，跳过更新检查');
        return;
      }

      // 检查当前路由
      if (Get.currentRoute != '/home') {
        debugPrint('[HomePageRouteObserver] 已离开首页，跳过更新检查');
        return;
      }

      // 初始化控制器
      if (!Get.isRegistered<AppUpdateController>()) {
        Get.put(AppUpdateController());
      }

      final controller = Get.find<AppUpdateController>();

      // 🧪 测试模式
      await controller.checkUpdateOnStartup(forceCheck: true);
    } catch (e) {
      debugPrint('[HomePageRouteObserver] 更新检查失败: $e');
    }
  }
}
