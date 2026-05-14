import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../controllers/auth_controller.dart';

/// 登录页面 - Liquid Glass Edition (Refined)
///
/// 遵循Refined设计原则：普通页面稳重简洁，优先可读性
/// 使用Light Base纯色背景，突出Liquid Green主色调
///
/// 创建时间: 2025年8月9日
/// 最后修改: 2025年9月15日
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 600; // phone vs iPad

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              child: _buildGlowBlob(
                size: 280,
                color: const Color(0xFF9EDBFF),
              ),
            ),
            Positioned(
              bottom: -140,
              right: -100,
              child: _buildGlowBlob(
                size: 320,
                color: const Color(0xFFB8F0D4),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isCompact ? 24 : 40),
                      _buildHeader(localizations, isCompact),
                      SizedBox(height: isCompact ? 18 : 24),
                      _buildLoginCard(authController, localizations, isCompact),
                      SizedBox(height: isCompact ? 18 : 24),
                      _buildRegisterPrompt(),
                      SizedBox(height: isCompact ? 12 : 16),
                      _buildGuestModeButton(),
                      SizedBox(height: isCompact ? 20 : 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowBlob({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.35),
              color.withValues(alpha: 0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations, bool isCompact) {
    final logoSize = isCompact ? 56.0 : 72.0;
    final iconSize = isCompact ? 28.0 : 36.0;
    final titleSize = isCompact ? 24.0 : 28.0;
    final subtitleSize = isCompact ? 14.0 : 16.0;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C37D), Color(0xFF3FD280)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.school_rounded,
            size: iconSize,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isCompact ? 20 : 32),
        Text(
          localizations.welcomeBack,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: Color(0xFF27273F),
            letterSpacing: -0.01,
            height: 1.2,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        Text(
          localizations.pleaseLoginToAccount,
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(AuthController controller,
      AppLocalizations localizations, bool isCompact) {
    final edgePadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
        : const EdgeInsets.all(28);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: edgePadding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              children: [
                _buildGlassTextField(
                  controller: controller.loginIdentifierController,
                  labelText: localizations.phoneNumber,
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: controller.validateLoginIdentifier,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => _buildGlassTextField(
                    controller: controller.loginPasswordController,
                    labelText: localizations.password,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !controller.loginPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.loginPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: const Color(0xFF27273F).withValues(alpha: 0.6),
                        size: 22,
                      ),
                      onPressed: controller.toggleLoginPasswordVisibility,
                    ),
                    textInputAction: TextInputAction.done,
                    validator: controller.validatePassword,
                    onFieldSubmitted: (_) => controller.login(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildGlassButton(
                  text: localizations.login,
                  onPressed: controller.login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建简洁输入框 - 符合普通页面规范
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
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
          color: const Color(0xFF27273F),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF00C37D),
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF00C37D),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建主按钮 - 符合普通页面规范
  Widget _buildGlassButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50, // 标准按钮高度
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C37D),
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

  Widget _buildRegisterPrompt() {
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.noAccountYet,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 6),
            GestureDetector(
              onTap: () => Get.toNamed('/register'),
              child: Text(
                localizations.register,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00C37D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGuestModeButton() {
    final AuthController authController = Get.find<AuthController>();
    return Builder(
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return GestureDetector(
          onTap: authController.enterGuestMode,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline_rounded,
                  color: Color(0xFF9CA3AF), size: 16),
              SizedBox(width: 6),
              Text(
                localizations.continueAsGuest,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
