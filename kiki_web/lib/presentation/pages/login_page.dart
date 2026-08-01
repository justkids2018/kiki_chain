import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kikichain/generated/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../design_ui/kiki_ui_kit.dart';
import '../widgets/app_gradient_button.dart';
import '../controllers/auth_controller.dart';

enum AuthPanelMode { login, register }

/// 横屏认证页
///
/// 登录与注册共用同一个横屏入口。视觉层负责承接 Kiki 学习氛围，
/// 表单层仍复用 AuthController，避免把登录和注册业务逻辑混在一起。
class LoginPage extends StatefulWidget {
  final AuthPanelMode initialMode;

  const LoginPage({
    Key? key,
    this.initialMode = AuthPanelMode.login,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const bool _showForgotPasswordEntry = false;

  late AuthPanelMode _mode;
  late final TapGestureRecognizer _userAgreementRecognizer;
  late final TapGestureRecognizer _privacyPolicyRecognizer;

  bool get _isRegisterMode => _mode == AuthPanelMode.register;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _userAgreementRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLocalAgreement(
            title: '用户协议',
            assetPath: 'assets/legal/user_agreement.html',
          );
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLocalAgreement(
            title: '隐私政策',
            assetPath: 'assets/legal/privacy_policy.html',
          );
  }

  @override
  void dispose() {
    _userAgreementRecognizer.dispose();
    _privacyPolicyRecognizer.dispose();
    super.dispose();
  }

  void _openLocalAgreement({
    required String title,
    required String assetPath,
  }) {
    Get.toNamed(
      AppConstants.routeWebView,
      arguments: {
        'title': title,
        'assetPath': assetPath,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: KikiUiDecor.pageBackgroundDecor,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactHeight = constraints.maxHeight < 430;
              final verticalPadding = compactHeight ? 12.0 : 24.0;
              final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

              return AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth < 860 ? 22 : 34,
                  ).copyWith(top: verticalPadding, bottom: 0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - verticalPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: _buildPlaygroundAuthLayout(
                          authController,
                          localizations,
                          compactHeight,
                          constraints.maxHeight - verticalPadding,
                          keyboardInset,
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

  Widget _buildPlaygroundAuthLayout(
    AuthController controller,
    AppLocalizations localizations,
    bool compactHeight,
    double availableHeight,
    double keyboardInset,
  ) {
    final cardLift = keyboardInset <= 0
        ? 0.0
        : (keyboardInset * 0.62)
            .clamp(compactHeight ? 76.0 : 112.0, compactHeight ? 132.0 : 190.0)
            .toDouble();

    return SizedBox(
      height: availableHeight
          .clamp(compactHeight ? 360.0 : 460.0, 620.0)
          .toDouble(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: CustomPaint(
                painter: const _PlaygroundBackgroundPainter(),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -24,
            child: Image.asset(
              'assets/images/growth_map/meadow_wide.png',
              height: compactHeight ? 112 : 150,
              fit: BoxFit.fill,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned(
            left: compactHeight ? 44 : 98,
            bottom: compactHeight ? -54 : -48,
            child: _CroppedAsset(
              assetPath: 'assets/images/growth_map/kiki_map.png',
              visibleHeight: compactHeight ? 128 : 170,
              originalHeight: 1536,
              transparentTop: 121,
              transparentBottom: 253,
            ),
          ),
          Positioned(
            right: compactHeight ? 22 : 78,
            bottom: compactHeight ? -52 : -46,
            child: _CroppedAsset(
              assetPath: 'assets/images/growth_map/yuki_map.png',
              visibleHeight: compactHeight ? 134 : 178,
              originalHeight: 1536,
              transparentTop: 137,
              transparentBottom: 243,
            ),
          ),
          Positioned(
            right: compactHeight ? 144 : 238,
            bottom: compactHeight ? -40 : -32,
            child: _CroppedAsset(
              assetPath: 'assets/images/growth_map/mimi_map.png',
              visibleHeight: compactHeight ? 62 : 82,
              originalHeight: 1312,
              transparentTop: 138,
              transparentBottom: 234,
            ),
          ),
          const Positioned(
            left: 86,
            top: 36,
            child: _SoftSun(),
          ),
          const Positioned(
            right: 142,
            top: 42,
            child: _FloatingStar(size: 28, rotation: 0.16),
          ),
          const Positioned(
            left: 250,
            top: 74,
            child: _FloatingStar(size: 15, rotation: -0.24),
          ),
          Align(
            alignment: Alignment.center,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: -cardLift),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, offsetY, child) {
                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: child,
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: _buildAuthCard(controller, localizations, compactHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard(
    AuthController controller,
    AppLocalizations localizations,
    bool compactHeight,
  ) {
    final cardHeight = compactHeight ? 376.0 : 430.0;
    final verticalPadding = compactHeight ? 14.0 : 20.0;

    return SizedBox(
      height: cardHeight,
      child: Container(
        decoration: KikiUiDecor.panelDecor.copyWith(
          color: const Color(0xFFFFF9EC),
          boxShadow: const [
            BoxShadow(
              color: Color(0x235D4A2E),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
            BoxShadow(
              color: Color(0x18FFFFFF),
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(22, verticalPadding, 22, verticalPadding),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: cardHeight - verticalPadding * 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeTabs(localizations),
                SizedBox(height: compactHeight ? 12 : 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _isRegisterMode
                        ? _buildRegisterForm(
                            controller,
                            localizations,
                            compactHeight,
                          )
                        : _buildLoginForm(
                            controller,
                            localizations,
                            compactHeight,
                          ),
                  ),
                ),
                SizedBox(height: compactHeight ? 8 : 10),
                _buildTermsRow(controller, localizations),
                SizedBox(height: compactHeight ? 8 : 10),
                _buildPrimaryButton(
                  text: _isRegisterMode
                      ? localizations.register
                      : localizations.login,
                  onPressed:
                      _isRegisterMode ? controller.register : controller.login,
                  height: compactHeight ? 46 : 48,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabs(AppLocalizations localizations) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF2E6D0),
        borderRadius: BorderRadius.circular(KikiUiRadii.chip),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildModeTab(
            text: localizations.login,
            selected: !_isRegisterMode,
            onTap: () => setState(() => _mode = AuthPanelMode.login),
          ),
          _buildModeTab(
            text: localizations.register,
            selected: _isRegisterMode,
            onTap: () => setState(() => _mode = AuthPanelMode.register),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(KikiUiRadii.chip),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x165D4A2E),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? KikiUiColors.textPrimary
                  : KikiUiColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(
    AuthController controller,
    AppLocalizations localizations,
    bool compactHeight,
  ) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        key: const ValueKey('login-form'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            controller: controller.loginIdentifierController,
            hintText: localizations.pleaseEnterPhone,
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: controller.validateLoginIdentifier,
          ),
          SizedBox(height: compactHeight ? 10 : 14),
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(controller),
                child: Text(
                  localizations.forgotPassword,
                  style: const TextStyle(
                    fontSize: 14,
                    color: KikiUiColors.brandGreen,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegisterForm(
    AuthController controller,
    AppLocalizations localizations,
    bool compactHeight,
  ) {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        key: const ValueKey('register-form'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            controller: controller.registerPhoneController,
            hintText: localizations.pleaseEnterPhone,
            prefixIcon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            validator: controller.validatePhone,
          ),
          SizedBox(height: compactHeight ? 10 : 12),
          Obx(
            () => _buildTextField(
              controller: controller.registerPasswordController,
              hintText: localizations.password,
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
          SizedBox(height: compactHeight ? 10 : 12),
          Obx(
            () => _buildTextField(
              controller: controller.registerConfirmPasswordController,
              hintText: localizations.confirmPassword,
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
                onPressed: controller.toggleRegisterConfirmPasswordVisibility,
              ),
              validator: controller.validateConfirmPassword,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsRow(
    AuthController controller,
    AppLocalizations localizations,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => Checkbox(
            value: controller.agreeToTerms,
            onChanged: (value) => controller.setAgreeToTerms(value ?? false),
            activeColor: KikiUiColors.brandGreen,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
                color: KikiUiColors.textSecondary,
              ),
              children: [
                const TextSpan(text: '我已阅读并同意'),
                TextSpan(
                  text: '《用户协议》',
                  style: const TextStyle(
                    color: KikiUiColors.brandGreen,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: _userAgreementRecognizer,
                ),
                const TextSpan(text: '和'),
                TextSpan(
                  text: '《隐私政策》',
                  style: const TextStyle(
                    color: KikiUiColors.brandGreen,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: _privacyPolicyRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
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
    double height = 48,
  }) {
    return AppGradientButton(
      text: text,
      onPressed: onPressed,
      height: height,
      fontSize: 16,
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

class _PlaygroundBackgroundPainter extends CustomPainter {
  const _PlaygroundBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Intentionally empty. The playground uses the original PNG assets only.
  }

  @override
  bool shouldRepaint(covariant _PlaygroundBackgroundPainter oldDelegate) =>
      false;
}

class _CroppedAsset extends StatelessWidget {
  final String assetPath;
  final double visibleHeight;
  final double originalHeight;
  final double transparentTop;
  final double transparentBottom;

  const _CroppedAsset({
    required this.assetPath,
    required this.visibleHeight,
    required this.originalHeight,
    required this.transparentTop,
    required this.transparentBottom,
  });

  @override
  Widget build(BuildContext context) {
    final visibleOriginalHeight =
        originalHeight - transparentTop - transparentBottom;
    final fullHeight = visibleHeight * originalHeight / visibleOriginalHeight;
    final topOffset = fullHeight * transparentTop / originalHeight;

    return SizedBox(
      height: visibleHeight,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(0, -topOffset),
          child: Image.asset(
            assetPath,
            height: fullHeight,
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class _SoftSun extends StatelessWidget {
  const _SoftSun();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFD678).withValues(alpha: 0.46),
      ),
    );
  }
}

class _FloatingStar extends StatelessWidget {
  final double size;
  final double rotation;

  const _FloatingStar({
    required this.size,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        Icons.star_rounded,
        size: size,
        color: const Color(0xFFFFC755),
        shadows: const [
          Shadow(
            color: Color(0x225D4A2E),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
