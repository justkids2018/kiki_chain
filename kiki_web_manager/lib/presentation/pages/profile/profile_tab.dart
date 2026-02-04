import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/guest_profile.dart';
import 'widgets/logged_in_profile.dart';

/// "我的"Tab页面
///
/// 根据登录状态显示不同内容：
/// - 未登录：显示GuestProfile
/// - 已登录：显示LoggedInProfile
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          if (authController.isLoggedIn && authController.currentUser != null) {
            return LoggedInProfile(user: authController.currentUser!);
          } else {
            return const GuestProfile();
          }
        }),
      ),
    );
  }
}
