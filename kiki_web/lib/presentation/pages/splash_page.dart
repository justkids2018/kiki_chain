import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';

/// 启动页面
///
/// 检查用户登录状态并导航到相应页面
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Duration _minimumSplashDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();

    // 保证欢迎页至少展示一段时间，同时等待认证状态初始化完成。
    await Future.wait([
      Future.delayed(_minimumSplashDuration),
      _waitAuthInitialization(authController),
    ]);

    // 根据登录状态导航
    if (authController.isLoggedIn || authController.isGuestMode) {
      Get.offAllNamed(AppConstants.routeHome);
    } else {
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
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C37D)),
        ),
      ),
    );
  }
}
