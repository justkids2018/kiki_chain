import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../controllers/auth_controller.dart';

/// 注册页面 - Liquid Glass Edition (Refined)
///
/// 遵循Refined设计原则：普通页面稳重简洁，优先可读性
/// 使用Light Base纯色背景，突出Liquid Green主色调
///
/// 创建时间: 2025年8月9日
/// 最后修改: 2026年1月20日
class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC), // Light Base 浅色模式背景，纯色不使用毛玻璃
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),

                SizedBox(height: 30),

                // 注册卡片
                _buildRegisterCard(authController),

                SizedBox(height: 20),

                // 登录提示
                _buildLoginLink(),

                SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建页面头部 - Refined设计
  // ignore: unused_element
  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return Column(
          children: [
            // Logo - 简洁设计，突出Liquid Green主色调
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C37D), Color(0xFF3FD280)], // 核心色到强调色
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  // 极轻阴影：遵循普通页面规范
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.school_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 24),

            // 标题文字 - SF Pro Display
            Text(
              localizations.createAccount,
              style: TextStyle(
                fontSize: 28, // 标题 Semibold
                fontWeight: FontWeight.w600,
                color: Color(0xFF27273F), // 主文字色
                letterSpacing: -0.01, // 字间距收紧，专业排版
                height: 1.2,
              ),
            ),
                 SizedBox(height: 12),
            // 副标题 - SF Pro Text
            Text(
              localizations.fillInfoToRegister,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400, // Regular
                color: Color(0xFF6B7280), // 次要文字色
                height: 1.4, // HIG规范行高
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建注册卡片 - 简洁纯色设计
  Widget _buildRegisterCard(AuthController controller) {
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white, // 纯色背景，符合普通页面规范
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFFE2E8F0), // 标准边框色
              width: 1,
            ),
            boxShadow: [
              // 极轻阴影：遵循普通页面规范
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              children: [
                // 手机号输入框
                _buildGlassTextField(
                  controller: controller.registerPhoneController,
                  labelText: localizations.phoneNumber,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: controller.validatePhone,
                ),

                SizedBox(height: 12),

                // 昵称输入框（可选）
                _buildGlassTextField(
                  controller: controller.registerNicknameController,
                  labelText: localizations.nicknameOptional,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: controller.validateNickname,
                ),



                SizedBox(height: 12),

                // 密码输入框
                Obx(() => _buildGlassTextField(
                  controller: controller.registerPasswordController,
                  labelText: localizations.passwordRequirement,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !controller.registerPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.registerPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Color(0xFF27273F).withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: controller.toggleRegisterPasswordVisibility,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: controller.validateRegisterPassword,
                )),

                SizedBox(height: 12),

                // 确认密码输入框
                Obx(() => _buildGlassTextField(
                  controller: controller.registerConfirmPasswordController,
                  labelText: localizations.confirmPassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !controller.registerConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.registerConfirmPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Color(0xFF27273F).withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: controller.toggleRegisterConfirmPasswordVisibility,
                  ),
                  textInputAction: TextInputAction.done,
                  validator: controller.validateConfirmPassword,
                  onFieldSubmitted: (_) => controller.register(),
                )),

                SizedBox(height: 18),

                // 注册按钮
                _buildGlassButton(
                  text: localizations.register,
                  onPressed: controller.register,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建简洁输入框 - 遵循Refined设计
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    Function(String)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // 纯色背景
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFE2E8F0), // 标准边框色
          width: 1,
        ),
        boxShadow: [
          // 轻量级阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        style: TextStyle(
          color: Color(0xFF27273F),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Color(0xFF00C37D),
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  /// 构建简洁主要按钮 - 遵循Refined设计
  Widget _buildGlassButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00C37D), // Liquid Green 主色
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
        ),
      ),
    );
  }

  /// 构建底部登录链接
  Widget _buildLoginLink() {
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white, // 纯色背景
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFFE2E8F0), // 标准边框色
              width: 1,
            ),
            boxShadow: [
              // 极轻阴影
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.alreadyHaveAccount,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(width: 8),

              GestureDetector(
                onTap: () => Get.offNamed('/login'),
                child: Text(
                  localizations.loginNow,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF00C37D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
