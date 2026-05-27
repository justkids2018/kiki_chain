import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../design_ui/kiki_ui_kit.dart';
import '../widgets/app_gradient_button.dart';
import '../controllers/auth_controller.dart';

/// 登录/注册页面 - Hi Kiki 风格
/// 横屏设计，带有 Tab 切换
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  static const bool _showForgotPasswordEntry = false;
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
      body: Container(
        decoration: KikiUiDecor.pageBackgroundDecor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const panelMinHeight = 500.0;
            final hasRoomForStaticLayout =
                constraints.maxHeight >= panelMinHeight + 32;

            final panel = Align(
              alignment: Alignment.center,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                margin:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 24),
                decoration: KikiUiDecor.panelDecor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    const Text(
                      '欢迎来到 Hi Kiki',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: KikiUiColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tab 切换
                    _buildTabBar(),

                    const SizedBox(height: 14),

                    // Tab 内容
                    SizedBox(
                      height: 360,
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
            );

            if (hasRoomForStaticLayout) {
              return panel;
            }

            // 小屏设备兜底：允许滚动，避免内容被遮挡
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: panel,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: KikiUiColors.line,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: KikiUiColors.brandGreen,
        unselectedLabelColor: KikiUiColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: KikiUiColors.brandGreen,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: '登录'),
          Tab(text: '注册'),
        ],
      ),
    );
  }

  Widget _buildLoginForm(
      AuthController controller, AppLocalizations localizations) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                  color: KikiUiColors.textSecondary,
                  size: 20,
                ),
                onPressed: controller.toggleLoginPasswordVisibility,
              ),
              validator: controller.validatePassword,
            ),
          ),

          if (_showForgotPasswordEntry) ...[
            const SizedBox(height: 12),
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
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 20),
          ],

          // 登录按钮
          _buildPrimaryButton(
            text: '登录',
            onPressed: controller.login,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(
      AuthController controller, AppLocalizations localizations) {
    return Form(
      key: controller.registerFormKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                          color: KikiUiColors.textSecondary,
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
                          color: KikiUiColors.textSecondary,
                          size: 20,
                        ),
                        onPressed:
                            controller.toggleRegisterConfirmPasswordVisibility,
                      ),
                      validator: controller.validateConfirmPassword,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 用户协议
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: controller.agreeToTerms,
                          onChanged: (value) =>
                              controller.setAgreeToTerms(value ?? false),
                          activeColor: KikiUiColors.brandGreen,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          children: [
                            Text(
                              '我已阅读并同意',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: KikiUiColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: 显示用户协议
                              },
                              child: Text(
                                '《用户协议》',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KikiUiColors.brandGreen,
                                ),
                              ),
                            ),
                            Text(
                              '和',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: KikiUiColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: 显示隐私政策
                              },
                              child: Text(
                                '《隐私政策》',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KikiUiColors.brandGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 注册按钮
                  _buildPrimaryButton(
                    text: '注册',
                    onPressed: controller.register,
                  ),
                ],
              ),
            ),
          );
        },
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
  }) {
    return AppGradientButton(
      text: text,
      onPressed: onPressed,
      height: 54,
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
