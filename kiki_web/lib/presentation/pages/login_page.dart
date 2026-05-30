import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../design_ui/kiki_ui_kit.dart';
import '../widgets/app_gradient_button.dart';
import '../controllers/auth_controller.dart';

/// 纯登录页面（注册拆分到独立页面）
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const bool _showForgotPasswordEntry = false;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: KikiUiDecor.pageBackgroundDecor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobileWidth = constraints.maxWidth < 700;
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              final keyboardVisible = bottomInset > 0;

              return AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: bottomInset),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          keyboardVisible ? 0 : constraints.maxHeight - 48,
                    ),
                    child: Align(
                      alignment: keyboardVisible
                          ? Alignment.topCenter
                          : Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobileWidth ? 20 : 28,
                          ),
                          child: _buildLoginForm(authController),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthController controller) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            '欢迎登录',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: KikiUiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '登录后继续你的学习旅程',
            style: const TextStyle(
              fontSize: 13,
              color: KikiUiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),

          // 手机号输入框
          _buildTextField(
            controller: controller.loginIdentifierController,
            hintText: '请输入手机号',
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: controller.validateLoginIdentifier,
          ),
          const SizedBox(height: 14),

          // 密码输入框
          Obx(
            () => _buildTextField(
              controller: controller.loginPasswordController,
              hintText: '请输入密码',
              prefixIcon: Icons.lock_outline,
              obscureText: !controller.loginPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.loginPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: KikiUiColors.textSecondary,
                  size: 20,
                ),
                onPressed: controller.toggleLoginPasswordVisibility,
              ),
              validator: controller.validatePassword,
            ),
          ),

          if (_showForgotPasswordEntry) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(controller),
                child: const Text(
                  '忘记密码？',
                  style: TextStyle(
                    fontSize: 14,
                    color: KikiUiColors.brandGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ] else ...[
            const SizedBox(height: 18),
          ],

          _buildPrimaryButton(
            text: '登录',
            onPressed: controller.login,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '还没有账号？',
                style: TextStyle(
                  fontSize: 12,
                  color: KikiUiColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.offNamed('/register'),
                child: const Text(
                  '立即注册',
                  style: TextStyle(
                    fontSize: 13,
                    color: KikiUiColors.brandGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      strutStyle: const StrutStyle(height: 1.25, forceStrutHeight: true),
      style: const TextStyle(
        fontSize: 16,
        height: 1.25,
        color: KikiUiColors.textPrimary,
      ),
      decoration: KikiUiDecor.inputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    double height = 54,
  }) {
    return AppGradientButton(
      text: text,
      onPressed: onPressed,
      height: height,
      borderRadius: KikiUiRadii.button,
    );
  }

  Future<void> _showForgotPasswordDialog(AuthController controller) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('暂未开放找回密码，请清空后重新输入账号和密码。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('清空重填'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      controller.loginIdentifierController.clear();
      controller.loginPasswordController.clear();
    }
  }
}
