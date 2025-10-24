import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// 注册页面 - Liquid Glass Edition (Refined)
/// 
/// 遵循Refined设计原则：普通页面稳重简洁，优先可读性
/// 使用Light Base纯色背景，突出Liquid Green主色调
/// 
/// 创建时间: 2025年8月9日
/// 最后修改: 2025年9月15日
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
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                
                // 头部
                _buildHeader(),
                
                SizedBox(height: 15),
                
                // 注册卡片
                _buildRegisterCard(authController),
                
                SizedBox(height: 10),
                
                // 登录提示
                _buildLoginLink(),
                
                SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建页面头部 - Refined设计
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo - 简洁设计，突出Liquid Green主色调
        Container(
          width: 1,
          height: 1,
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
        
        SizedBox(height: 1),
        
        // 标题文字 - SF Pro Display
        Text(
          '创建账户',
          style: TextStyle(
            fontSize: 28, // 标题 Semibold
            fontWeight: FontWeight.w600,
            color: Color(0xFF27273F), // 主文字色
            letterSpacing: -0.01, // 字间距收紧，专业排版
            height: 1.2,
          ),
        ),
             SizedBox(height: 10),
        // 副标题 - SF Pro Text
        Text(
          '填写信息完成注册',
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

  /// 构建注册卡片 - 简洁纯色设计
  Widget _buildRegisterCard(AuthController controller) {
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
              labelText: '手机号',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: controller.validatePhone,
            ),
            
            SizedBox(height: 16),
            
            // 用户名输入框
            _buildGlassTextField(
              controller: controller.registerUsernameController,
              labelText: '用户名',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: controller.validateUsername,
            ),
            
            SizedBox(height: 16),
            
            // 身份选择
            _buildRoleSelection(controller),
            
            SizedBox(height: 16),
            
            // 密码输入框
            Obx(() => _buildGlassTextField(
              controller: controller.registerPasswordController,
              labelText: '密码',
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
              validator: controller.validatePassword,
            )),
            
            SizedBox(height: 16),
            
            // 确认密码输入框
            Obx(() => _buildGlassTextField(
              controller: controller.registerConfirmPasswordController,
              labelText: '确认密码',
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
              textInputAction: TextInputAction.next,
              validator: controller.validateConfirmPassword,
            )),
            
            SizedBox(height: 16),
            
            // 邀请码输入框
            _buildGlassTextField(
              controller: controller.registerInviteCodeController,
              labelText: '邀请码',
              prefixIcon: Icons.card_giftcard_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入邀请码';
                }
                if (value.trim().length != 4) {
                  return '邀请码必须为4位数字';
                }
                if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
                  return '邀请码只能包含数字';
                }
                if (!controller.validateInviteCode(value.trim())) {
                  return '邀请码格式不正确';
                }
                return null;
              },
              onFieldSubmitted: (_) => controller.register(),
            ),
            
            SizedBox(height: 24),
            
            // 注册按钮
            _buildGlassButton(
              text: '注册',
              onPressed: controller.register,
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE2E8F0), // 标准边框色
          width: 1,
        ),
        boxShadow: [
          // 轻量级阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
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
          letterSpacing: -0.1,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Color(0xFF27273F).withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.1,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Color(0xFF00C37D),
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
      height: 58,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF00C37D), // Liquid Green 主色
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // 轻量级阴影，避免过度设计
            BoxShadow(
              color: Color(0xFF00C37D).withOpacity(0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部登录链接
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账户？',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF27273F).withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
        
        TextButton(
          onPressed: () => Get.offNamed('/login'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '立即登录',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00C37D),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建角色选择组件 - 简洁版设计
  Widget _buildRoleSelection(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '选择身份 *',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              letterSpacing: -0.2,
              color: Color(0xFF27273F),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white, // 简洁纯色背景
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFFE2E8F0), // 标准边框色
              width: 1,
            ),
            boxShadow: [
              // 轻量级阴影
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => _buildLiquidRoleButton(
                  controller: controller,
                  roleId: 2,
                  label: '学生',
                  icon: Icons.school_rounded,
                  isSelected: controller.selectedRoleId == 2,
                )),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildLiquidRoleButton(
                  controller: controller,
                  roleId: 3,
                  label: '老师',
                  icon: Icons.person_rounded,
                  isSelected: controller.selectedRoleId == 3,
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 构建简洁风格的角色按钮
  Widget _buildLiquidRoleButton({
    required AuthController controller,
    required int roleId,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.setSelectedRole(roleId),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFF00C37D).withOpacity(0.08) // 选中状态轻微背景色
                : Color(0xFFF8FAFC), // Light Base背景
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(
                    color: Color(0xFF00C37D), // Liquid Green边框
                    width: 1.5,
                  )
                : Border.all(
                    color: Color(0xFFE2E8F0), // 标准边框色
                    width: 1,
                  ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Color(0xFF00C37D).withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 图标容器
              AnimatedContainer(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFF00C37D) // 选中时Liquid Green背景
                      : Color(0xFFE2E8F0), // 未选中时标准灰色
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : Color(0xFF6B7280),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Label with SF Pro styling
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 16,
                  letterSpacing: -0.2,
                  color: isSelected ? Color(0xFF00C37D) : Color(0xFF6E6E73),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
