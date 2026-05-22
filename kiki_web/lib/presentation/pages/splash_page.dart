import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// 启动页面
///
/// 检查用户登录状态并导航到相应页面
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();

    // 等待认证状态初始化完成
    await _waitAuthInitialization(authController);

    // 已登录用户直接进入首页，未登录用户稍作延迟后进入欢迎页
    if (authController.isLoggedIn || authController.isGuestMode) {
      Get.offAllNamed(AppConstants.routeHome);
    } else {
      await Future.delayed(_minimumSplashDuration);
      Get.offAllNamed(AppConstants.routeWelcome);
    }
  }

  Future<void> _waitAuthInitialization(AuthController authController) async {
    while (!authController.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Center(
        child: Image.asset(
          'assets/images/kiki_welcom.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
