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
  static const Duration _authInitializationTimeout = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();
    final deadline = DateTime.now().add(_authInitializationTimeout);
    while (!authController.isInitialized && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted || !authController.isInitialized) return;
    if (authController.isLoggedIn) {
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
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.18),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/icon/app_icon.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPhoneLoginButton(AppLocalizations localizations) {
    return AppGradientButton(
      text: localizations.loginNow,
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
            localizations.noAccountYet,
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
                    localizations.register,
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
