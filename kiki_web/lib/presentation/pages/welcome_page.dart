import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_gradient_button.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.1),

                  // Logo 和标语
                  _buildBranding(),

                  SizedBox(height: screenHeight * 0.18),

                  // 手机号登录按钮
                  _buildPhoneLoginButton(localizations),

                  const SizedBox(height: 16),

                  // 注册提示
                  _buildRegisterPrompt(localizations),

                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        // Hi Kiki Logo with animation-ready structure
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.eco,
            color: AppColors.primaryGreen,
            size: 64,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Hi Kiki',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: AppColors.textDarkBrown,
            height: 1.0,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 12),

        // 标语
        Text(
          '快乐学习 · 每天进步',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textGray,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLoginButton(AppLocalizations localizations) {
    return AppGradientButton(
      text: '立即登录',
      onPressed: () => Get.toNamed('/login'),
      height: 56,
      borderRadius: 28,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildRegisterPrompt(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '还没有账号？',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.toNamed('/register'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    '立即注册',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
