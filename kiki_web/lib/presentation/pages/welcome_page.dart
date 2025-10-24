import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_color.dart';
import '../widgets/custom_button.dart';
import '../widgets/glassmorphism_slogan.dart';

/// 欢迎页面
///
/// 应用启动页面，提供登录、注册入口
/// 如果用户已登录，自动跳转到首页
///
/// 创建时间: 2025年8月9日
/// 最后修改: 2025年8月9日
/// Apple 风格欢迎页
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sloganStyle = TextStyle(
      fontSize: 18,
      color: Colors.black.withOpacity(0.75),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 148, horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 148, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black12,
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO
                const SizedBox(height: 12),
                // 标题
                GlassmorphismSlogan(
                  slogan: 'Kiki World',
                  style: sloganStyle.copyWith(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 32),
                // 玻璃拟态 Slogan
                // GlassmorphismSlogan(
                  // slogan: 'More than just a machine.',
                  // style: sloganStyle.copyWith(
                      // fontSize: 20, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 40),
                // 按钮组
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: '注册',
                      height: 44,
                      width: 120,
                      borderRadius: 20,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      backgroundColor:  AppColors.buttonColorBg,
                      textColor: Colors.white,
                      onPressed: () => Get.toNamed('/register'),
                    ),
                    const SizedBox(width: 24),
                    CustomButton(
                      text: '登录',
                      height: 44,
                      width: 120,
                      borderRadius: 20,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      backgroundColor: Colors.white,
                      textColor: AppColors.buttonColorBg,
                      borderColor: AppColors.buttonColorBg,
                      borderWidth: 2,
                      onPressed: () => Get.toNamed('/login'),
// onPressed: () => Get.toNamed(AppConstants.routeChatDify),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
