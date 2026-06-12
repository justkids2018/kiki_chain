import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';

/// 启动页面
///
/// 检查用户登录状态并导航到相应页面
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 300);
  static const Duration _authInitializationTimeout = Duration(seconds: 4);
  static const String _welcomeImagePath = 'assets/images/kiki_welcome.png';

  Color _imageToneColor = AppColors.backgroundCream;

  @override
  void initState() {
    super.initState();
    _deriveImageToneColor();
    _checkLoginStatus();
  }

  Future<void> _deriveImageToneColor() async {
    try {
      final data = await rootBundle.load(_welcomeImagePath);
      final bytes = data.buffer.asUint8List();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;

      final sampleHeight = math.max(1, decoded.height ~/ 3).toInt();
      final stepX = math.max(1, decoded.width ~/ 24).toInt();
      final stepY = math.max(1, sampleHeight ~/ 24).toInt();

      int sumR = 0;
      int sumG = 0;
      int sumB = 0;
      int count = 0;

      for (int y = 0; y < sampleHeight; y += stepY) {
        for (int x = 0; x < decoded.width; x += stepX) {
          final pixel = decoded.getPixel(x, y);
          sumR += pixel.r.toInt();
          sumG += pixel.g.toInt();
          sumB += pixel.b.toInt();
          count++;
        }
      }

      if (count == 0) return;

      final base = Color.fromARGB(
        255,
        (sumR / count).round(),
        (sumG / count).round(),
        (sumB / count).round(),
      );

      final tone =
          Color.lerp(base, Colors.white, 0.35) ?? AppColors.backgroundCream;
      if (!mounted) return;
      setState(() {
        _imageToneColor = tone;
      });
    } catch (_) {
      // Keep the default background color when image sampling fails.
    }
  }

  Future<void> _checkLoginStatus() async {
    final authController = Get.find<AuthController>();

    // 等待认证状态初始化完成，但不能无限停留在启动页。
    final authReady = await _waitAuthInitialization(authController);
    if (!mounted) return;

    // 已登录用户直接进入首页，未登录用户稍作延迟后进入欢迎页
    if (authReady && authController.isLoggedIn) {
      Get.offAllNamed(AppConstants.routeHome);
    } else {
      await Future.delayed(_minimumSplashDuration);
      if (!mounted) return;
      Get.offAllNamed(AppConstants.routeWelcome);
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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        color: _imageToneColor,
        child: Center(
          child: Image.asset(
            _welcomeImagePath,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
