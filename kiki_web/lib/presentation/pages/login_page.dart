import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC), // Light Base 浅色模式背景，纯色不使用毛玻璃
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SizedBox(height: 60),
                
                // 头部
                _buildHeader(localizations),
                
                SizedBox(height: 50),
                
                // 登录卡片
                _buildLoginCard(authController, localizations),
                
                SizedBox(height: 30),
                
                // 注册提示
                _buildRegisterPrompt(),
                
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
  Widget _buildHeader(AppLocalizations localizations) {
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
                color: Colors.black.withValues(alpha: 0.04),
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
        
        SizedBox(height: 32),
        
        // 标题 - SF Pro字体规范
        Text(
          localizations.welcomeBack,
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
          localizations.pleaseLoginToAccount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400, // Regular
            color: Color(0xFF6B7280), // 次要文字色
            height: 1.4, // HIG规范行高
          ),
        ),
      ],
    );
  }

  /// 构建登录卡片 - 简洁纯色设计
  Widget _buildLoginCard(AuthController controller, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: controller.loginFormKey,
        child: Column(
          children: [
            // 用户名输入框
            _buildGlassTextField(
              controller: controller.loginIdentifierController,
              labelText: localizations.phoneNumber,
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: controller.validateLoginIdentifier,
            ),
            
            SizedBox(height: 16),
            
            // 密码输入框
            Obx(() => _buildGlassTextField(
              controller: controller.loginPasswordController,
              labelText: localizations.password,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !controller.loginPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.loginPasswordVisible 
                      ? Icons.visibility_off_rounded 
                      : Icons.visibility_rounded,
                  color: Color(0xFF27273F).withValues(alpha: 0.6),
                  size: 22,
                ),
                onPressed: controller.toggleLoginPasswordVisibility,
              ),
              textInputAction: TextInputAction.done,
              validator: controller.validatePassword,
              onFieldSubmitted: (_) => controller.login(),
            )),
            
            SizedBox(height: 24),
            
            // 登录按钮
            _buildGlassButton(
              text: localizations.login,
              onPressed: controller.login,
            ),
          ],
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
        color: Colors.white, // 白色背景
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFE2E8F0), // 标准边框色
          width: 1,
        ),
        boxShadow: [
          // 极轻阴影
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
          color: Color(0xFF27273F), // 主文字色
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Color(0xFF6B7280), // 次要文字色
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Color(0xFF00C37D), // Liquid Green主色调
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          // 聚焦态：边框高亮，轻微外阴影
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
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
          backgroundColor: Color(0xFF00C37D), // 主按钮：实心Liquid Green
          foregroundColor: Colors.white,
          elevation: 0, // 无阴影，符合简洁设计
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600, // Semibold
            letterSpacing: -0.01, // 字间距收紧
          ),
        ),
      ),
    );
  }

  /// 构建注册提示 - 简洁设计
  Widget _buildRegisterPrompt() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.noAccountYet,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280), // 次要文字色
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              SizedBox(width: 8),
              
              GestureDetector(
                onTap: () => Get.toNamed('/register'),
                child: Text(
                  localizations.register,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF00C37D), // Liquid Green主色调
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
