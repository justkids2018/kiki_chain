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
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 等待AuthController初始化完成
    final authController = Get.find<AuthController>();

    // 等待初始化完成
    while (!authController.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 根据登录状态导航
    if (authController.isLoggedIn || authController.isGuestMode) {
      // 已登录或游客模式，进入主页
      Get.offAllNamed(AppConstants.routeInteractiveImageHome);
    } else {
      // 未登录，显示欢迎页
      Get.offAllNamed(AppConstants.routeWelcome);
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
