import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../controllers/auth_controller.dart';

/// 注册页面 - Hi Kiki 风格
/// 注：登录页面已包含注册功能，此页面作为独立入口
class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: Stack(
        children: [
          // 底部装饰
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomDecoration(),
          ),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 顶部返回按钮
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: AppColors.textDarkBrown),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                // 注册表单区域
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.cardCream,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: authController.registerFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 标题
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '注册新账号',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDarkBrown,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.eco, color: AppColors.primaryGreen, size: 24),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // 副标题
                              Text(
                                '填写信息，开始学习之旅',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGray,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // 手机号输入框
                              _buildTextField(
                                controller: authController.registerPhoneController,
                                hintText: '请输入手机号',
                                prefixIcon: Icons.phone_android,
                                keyboardType: TextInputType.phone,
                                validator: authController.validatePhone,
                              ),

                              const SizedBox(height: 16),

                              // 昵称输入框
                              _buildTextField(
                                controller: authController.registerNicknameController,
                                hintText: '请输入昵称（可选）',
                                prefixIcon: Icons.person_outline,
                                validator: authController.validateNickname,
                              ),

                              const SizedBox(height: 16),

                              // 密码输入框
                              Obx(
                                () => _buildTextField(
                                  controller: authController.registerPasswordController,
                                  hintText: '请输入密码（6位以上）',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !authController.registerPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController.registerPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textGray,
                                      size: 20,
                                    ),
                                    onPressed: authController.toggleRegisterPasswordVisibility,
                                  ),
                                  validator: authController.validatePassword,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 确认密码输入框
                              Obx(
                                () => _buildTextField(
                                  controller: authController.registerConfirmPasswordController,
                                  hintText: '请再次输入密码',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !authController.registerConfirmPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController.registerConfirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textGray,
                                      size: 20,
                                    ),
                                    onPressed: authController.toggleRegisterConfirmPasswordVisibility,
                                  ),
                                  validator: (value) => authController.validateConfirmPassword(value),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // 用户协议
                              Row(
                                children: [
                                  Obx(
                                    () => Checkbox(
                                      value: authController.agreeToTerms,
                                      onChanged: (value) => authController.setAgreeToTerms(value ?? false),
                                      activeColor: AppColors.primaryGreen,
                                    ),
                                  ),
                                  Expanded(
                                    child: Wrap(
                                      children: [
                                        Text(
                                          '我已阅读并同意',
                                          style: TextStyle(fontSize: 12, color: AppColors.textGray),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: 显示用户协议
                                          },
                                          child: Text(
                                            '《用户协议》',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '和',
                                          style: TextStyle(fontSize: 12, color: AppColors.textGray),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: 显示隐私政策
                                          },
                                          child: Text(
                                            '《隐私政策》',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // 注册按钮
                              _buildPrimaryButton(
                                text: '注册',
                                onPressed: authController.register,
                              ),

                              const SizedBox(height: 24),

                              // 登录提示
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '已有账号？',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => Get.offNamed('/login'),
                                    child: Text(
                                      '立即登录',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textBrown,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textLightGray,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.textGray,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomDecoration() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryGreen.withOpacity(0.0),
            AppColors.primaryGreen.withOpacity(0.15),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 60,
            bottom: 0,
            child: Icon(
              Icons.grass,
              size: 50,
              color: AppColors.darkGreen.withOpacity(0.5),
            ),
          ),
          Positioned(
            right: 60,
            bottom: 0,
            child: Icon(
              Icons.local_florist,
              size: 40,
              color: AppColors.primaryGreen.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
