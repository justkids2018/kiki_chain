import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

/// 欢迎页面 - Hi Kiki 风格
/// 横屏设计，带有可爱的插画和登录选项
class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();
    while (!authController.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (authController.isLoggedIn || authController.isGuestMode) {
      Get.offAllNamed(AppConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Stack(
        children: [
          // 底部装饰 - 绿色植物
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomDecoration(),
          ),

          // 主内容
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo 和标语
                    _buildBranding(),

                    const SizedBox(height: 40),

                    // 插画区域（占位）
                    _buildIllustration(),

                    const Spacer(),

                    // 微信登录按钮
                    _buildWechatLoginButton(localizations),

                    const SizedBox(height: 16),

                    // 手机号登录按钮
                    _buildPhoneLoginButton(localizations),

                    const SizedBox(height: 24),

                    // 注册提示
                    _buildRegisterPrompt(localizations),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        // Hi Kiki Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hi Kiki',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkBrown,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            // 绿叶装饰
            Icon(
              Icons.eco,
              color: AppColors.primaryGreen,
              size: 32,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 标语
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              '快乐学习 每天进步',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.auto_stories, color: AppColors.primaryGreen, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    // 插画占位区域
    // TODO: 添加实际的插画图片
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardCream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: AppColors.primaryGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '两个可爱的卡通角色在看书',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWechatLoginButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 实现微信登录
          Get.snackbar('提示', '微信登录功能开发中');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.wechatGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wechat, size: 24),
            const SizedBox(width: 12),
            Text(
              '微信登录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLoginButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => Get.toNamed('/login'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: BorderSide(color: AppColors.primaryGreen, width: 2),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 24),
            const SizedBox(width: 12),
            Text(
              '手机号登录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterPrompt(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '没有账号？',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Get.toNamed('/register'),
          child: Text(
            '立即注册',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward,
          size: 16,
          color: AppColors.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildBottomDecoration() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryGreen.withOpacity(0.0),
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.primaryGreen.withOpacity(0.2),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 左侧植物
          Positioned(
            left: 40,
            bottom: 0,
            child: Icon(
              Icons.grass,
              size: 60,
              color: AppColors.darkGreen.withOpacity(0.6),
            ),
          ),
          // 右侧植物
          Positioned(
            right: 40,
            bottom: 0,
            child: Icon(
              Icons.local_florist,
              size: 50,
              color: AppColors.primaryGreen.withOpacity(0.6),
            ),
          ),
          // 中间小花
          Positioned(
            left: 200,
            bottom: 20,
            child: Icon(
              Icons.filter_vintage,
              size: 30,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Positioned(
            right: 180,
            bottom: 15,
            child: Icon(
              Icons.filter_vintage,
              size: 25,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
