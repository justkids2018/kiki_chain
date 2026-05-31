import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context)!;

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
                          child: _buildLoginForm(authController, localizations),
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

  Widget _buildLoginForm(
      AuthController controller, AppLocalizations localizations) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.welcomeBack,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: KikiUiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.pleaseLoginToAccount,
            style: const TextStyle(
              fontSize: 13,
              color: KikiUiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),

          // 手机号输入框
          _buildTextField(
            controller: controller.loginIdentifierController,
            hintText: localizations.pleaseEnterPhone,
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: controller.validateLoginIdentifier,
          ),
          const SizedBox(height: 14),

          // 密码输入框
          Obx(
            () => _buildTextField(
              controller: controller.loginPasswordController,
              hintText: localizations.pleaseEnterPassword,
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
                child: Text(
                  localizations.forgotPassword,
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
            text: localizations.login,
            onPressed: controller.login,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.noAccountYet,
                style: TextStyle(
                  fontSize: 12,
                  color: KikiUiColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.offNamed('/register'),
                child: Text(
                  localizations.register,
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
    final localizations = AppLocalizations.of(context)!;
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.hint),
          content: Text(localizations.forgotPasswordNotAvailable),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.clearAndRetry),
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
