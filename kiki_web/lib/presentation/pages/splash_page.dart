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
  static const Duration _authInitializationTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();

    // 等待认证状态初始化完成，但不能无限停留在启动页。
    final authReady = await _waitAuthInitialization(authController);
    if (!mounted) return;

    // 已登录用户直接进入首页，未登录用户稍作延迟后进入欢迎页
    if (authReady && authController.isLoggedIn) {
      Get.offAllNamed(AppConstants.routeHome);
    } else {
      await Future.delayed(_minimumSplashDuration);
      if (!mounted) return;
      Get.offAllNamed(AppConstants.routeWelcome);
    }
  }

  Future<bool> _waitAuthInitialization(AuthController authController) async {
    final deadline = DateTime.now().add(_authInitializationTimeout);
    while (!authController.isInitialized && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return authController.isInitialized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Center(
        child: Image.asset(
          'assets/images/kiki_welcome.png',
          fit: BoxFit.fitHeight,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
