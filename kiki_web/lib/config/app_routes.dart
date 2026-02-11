import 'package:get/get.dart';
import 'package:kikichain/presentation/pages/interactive_image_home/interactive_image_home_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/register_page.dart';
import '../presentation/pages/welcome_page.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/interactive_image/interactive_image_page.dart';
import '../presentation/pages/scene_list_page.dart';
import '../presentation/controllers/home_controller.dart';
import '../core/constants/app_constants.dart';

/// 应用路由配置
class AppRoutes {
  /// 路由列表
  static final routes = [
    // 欢迎页面（应用入口，自动检查登录状态）
    GetPage(
      name: '/',
      page: () => const WelcomePage(),
    ),
    // 启动页面（已废弃，保留用于兼容）
    GetPage(
      name: '/splash',
      page: () => const SplashPage(),
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
    // 互动图片页面
    GetPage(
      name: AppConstants.routeInteractiveImage,
      page: () => InteractiveImagePage(),
    ),
    // 互动图片首页
    GetPage(
      name: AppConstants.routeInteractiveImageHome,
      page: () => const InteractiveImageHomePage(),
    ),
    // 场景列表页面
    GetPage(
      name: AppConstants.routeSceneList,
      page: () {
        final category = Get.arguments;
        return SceneListPage(category: category);
      },
    ),
  ];

  /// 获取初始路由
  static String getInitialRoute() {
    // 这里可以根据用户登录状态决定初始路由
    return '/';
  }
}
