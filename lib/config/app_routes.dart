import 'package:get/get.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/welcome_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/register_page.dart';
import '../presentation/controllers/home_controller.dart';
import '../core/constants/app_constants.dart';

/// 应用路由配置
class AppRoutes {
  /// 路由列表
  static final routes = [
    // 欢迎页面
    GetPage(
      name: '/',
      // page: () => const FigmaPreviewPage(),
      page: () => const WelcomePage(),
    ),
    // 主页面
    GetPage(
      name: AppConstants.routeHome,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    // 登录页面
    GetPage(
      name: AppConstants.routeLogin,
      page: () => const LoginPage(),
    ),
    // 注册页面
    GetPage(
      name: AppConstants.routeRegister,
      page: () => const RegisterPage(),
    ),
  ];

  /// 获取初始路由
  static String getInitialRoute() {
    // 这里可以根据用户登录状态决定初始路由
    return '/';
  }
}
