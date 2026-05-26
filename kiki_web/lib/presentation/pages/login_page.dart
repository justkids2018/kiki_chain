import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../controllers/auth_controller.dart';

/// 登录/注册页面 - Hi Kiki 风格
/// 横屏设计，带有 Tab 切换
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
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

                // 登录表单区域
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 标题
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '登录 / 注册',
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
                              '欢迎来到 Hi Kiki',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGray,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Tab 切换
                            _buildTabBar(),

                            const SizedBox(height: 24),

                            // Tab 内容
                            SizedBox(
                              height: 280,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLoginForm(authController, localizations),
                                  _buildRegisterForm(authController, localizations),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: AppColors.textGray,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: AppColors.primaryGreen,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: '登录'),
          Tab(text: '注册'),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthController controller, AppLocalizations localizations) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          // 手机号输入框
          _buildTextField(
            controller: controller.loginIdentifierController,
            hintText: '请输入手机号',
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: controller.validateLoginIdentifier,
          ),

          const SizedBox(height: 16),

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
                  color: AppColors.textGray,
                  size: 20,
                ),
                onPressed: controller.toggleLoginPasswordVisibility,
              ),
              validator: controller.validatePassword,
            ),
          ),

          const SizedBox(height: 12),

          // 忘记密码
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: 实现忘记密码功能
                Get.snackbar('提示', '忘记密码功能开发中');
              },
              child: Text(
                '忘记密码？',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 登录按钮
          _buildPrimaryButton(
            text: '登录',
            onPressed: controller.login,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthController controller, AppLocalizations localizations) {
    return SingleChildScrollView(
      child: Form(
        key: controller.registerFormKey,
        child: Column(
          children: [
            // 手机号输入框
            _buildTextField(
              controller: controller.registerPhoneController,
              hintText: '请输入手机号',
              prefixIcon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              validator: controller.validatePhone,
            ),

            const SizedBox(height: 16),

            // 密码输入框
            Obx(
              () => _buildTextField(
                controller: controller.registerPasswordController,
                hintText: '请输入密码',
                prefixIcon: Icons.lock_outline,
                obscureText: !controller.registerPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.registerPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textGray,
                    size: 20,
                  ),
                  onPressed: controller.toggleRegisterPasswordVisibility,
                ),
                validator: controller.validatePassword,
              ),
            ),

            const SizedBox(height: 16),

            // 确认密码输入框
            Obx(
              () => _buildTextField(
                controller: controller.registerConfirmPasswordController,
                hintText: '请再次输入密码',
                prefixIcon: Icons.lock_outline,
                obscureText: !controller.registerConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.registerConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textGray,
                    size: 20,
                  ),
                  onPressed: controller.toggleRegisterConfirmPasswordVisibility,
                ),
                validator: controller.validateConfirmPassword,
              ),
            ),

            const SizedBox(height: 24),

            // 用户协议
            Row(
              children: [
                Obx(
                  () => Checkbox(
                    value: controller.agreeToTerms,
                    onChanged: (value) => controller.setAgreeToTerms(value ?? false),
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

            const SizedBox(height: 16),

            // 注册按钮
            _buildPrimaryButton(
              text: '注册',
              onPressed: controller.register,
            ),
          ],
        ),
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
}
