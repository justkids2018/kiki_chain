import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../../../design_ui/kiki_ui_kit.dart';
import '../../../widgets/app_gradient_button.dart';
import '../controllers/register_page_controller.dart';

class RegisterForm extends StatelessWidget {
  final RegisterPageController controller;

  const RegisterForm({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            controller: controller.phoneController,
            hintText: localizations.pleaseEnterPhone,
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: controller.validatePhone,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildTextField(
                    controller: controller.passwordController,
                    hintText: localizations.password,
                    prefixIcon: Icons.lock_outline,
                    obscureText: !controller.passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: KikiUiColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    validator: controller.validatePassword,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(
                  () => _buildTextField(
                    controller: controller.confirmPasswordController,
                    hintText: localizations.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: !controller.confirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.confirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: KikiUiColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    validator: controller.validateConfirmPassword,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.agreeToTerms,
                  onChanged: (value) =>
                      controller.setAgreeToTerms(value ?? false),
                  activeColor: KikiUiColors.brandGreen,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Expanded(
                child: Text(
                  localizations.termsAgreementText,
                  style: TextStyle(
                    fontSize: 12,
                    color: KikiUiColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppGradientButton(
            text: localizations.register,
            onPressed: controller.register,
            height: 52,
            borderRadius: KikiUiRadii.button,
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
}
