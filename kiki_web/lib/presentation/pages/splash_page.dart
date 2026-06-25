import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';

/// 启动页面
///
/// 检查用户登录状态并导航到相应页面
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeInDuration = Duration(milliseconds: 600);
  static const Duration _stayDuration = Duration(milliseconds: 1000);
  static const Duration _authInitializationTimeout = Duration(seconds: 4);
  static const String _welcomeImagePath = 'assets/images/kiki_welcome.png';
  static const Color _splashBackgroundColor = Color(0xFFEBCDB2);
  static const double _logoShortSideFactor = 0.84;
  static const double _logoHorizontalPadding = 32.0;
  static const double _logoMaxWidth = 600.0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _fadeInDuration,
    );
    // 从0.3开始渐入到1.0，避免从完全透明开始的"闪"感
    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();

    // 等待认证状态初始化完成，但不能无限停留在启动页。
    final authReady = await _waitAuthInitialization(authController);
    if (!mounted) return;

    // 等待渐入动画完成 + 停留1秒
    await Future.wait([
      _animationController.forward(),
      Future.delayed(_fadeInDuration + _stayDuration),
    ]);
    if (!mounted) return;

    // 开始渐出动画
    await _animationController.reverse();
    if (!mounted) return;

    // 已登录用户直接进入首页，未登录用户直接进入登录页。
    if (authReady && authController.isLoggedIn) {
      Get.offAllNamed(AppConstants.routeHome);
    } else {
      Get.offAllNamed(AppConstants.routeLogin);
    }
  }

  Future<bool> _waitAuthInitialization(AuthController authController) async {
    final deadline = DateTime.now().add(_authInitializationTimeout);
    while (!authController.isInitialized && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return authController.isInitialized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: _splashBackgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortestSide = constraints.biggest.shortestSide;
            final availableWidth =
                (constraints.maxWidth - _logoHorizontalPadding)
                    .clamp(0.0, _logoMaxWidth);
            final logoWidth = (shortestSide * _logoShortSideFactor)
                .clamp(0.0, availableWidth)
                .toDouble();

            return Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: logoWidth,
                  child: Image.asset(
                    _welcomeImagePath,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
