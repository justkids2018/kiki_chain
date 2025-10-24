import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../config/app_color.dart';
import '../presentation/widgets/app_loading_indicator.dart';
import 'services/app_services.dart';

/// 应用程序初始化器
class AppInitializer {
  /// 初始化应用程序
  static Future<void> initialize() async {
    // 确保Flutter绑定已初始化
    WidgetsFlutterBinding.ensureInitialized();
    
    // 设置系统UI样式
    _setSystemUIOverlayStyle();
    
    // 初始化应用服务（包含网络层、本地存储、配置等）
    await AppServices.instance.initialize();
    
    // 初始化UI组件
    _initializeUI();
  }
  
  /// 设置系统UI样式
  static void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  /// 初始化UI组件
  static void _initializeUI() {
    // 配置EasyLoading
    _configureEasyLoading();
  }
  
  /// 配置EasyLoading
  static void _configureEasyLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 1600)
      ..indicatorWidget = const AppLoadingIndicator(size: 38, strokeWidth: 3.2)
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 42.0
      ..radius = 14.0
      ..progressColor = AppColors.buttonColorBg
      ..backgroundColor = Colors.white
      ..indicatorColor = AppColors.buttonColorBg
      ..textColor = const Color(0xFF1F2937)
      ..successWidget = _buildStatusIcon(
        icon: Icons.check_rounded,
        color: AppColors.buttonColorBg,
      )
      ..errorWidget = _buildStatusIcon(
        icon: Icons.error_outline,
        color: const Color(0xFFEF4444),
      )
      ..infoWidget = _buildStatusIcon(
        icon: Icons.info_outline,
        color: const Color(0xFF38BDF8),
      )
      ..maskColor = const Color(0xFF0F172A).withOpacity(0.35)
      ..userInteractions = false
      ..dismissOnTap = false
      ..animationStyle = EasyLoadingAnimationStyle.scale;
  }

  static Widget _buildStatusIcon({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 22),
    );
  }
}
