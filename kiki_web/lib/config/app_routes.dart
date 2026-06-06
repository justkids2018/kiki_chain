import 'package:get/get.dart';
import 'package:kikichain/presentation/pages/interactive_image_home/interactive_image_home_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/login_selector_page.dart';
import '../presentation/pages/register/controllers/register_page_controller.dart';
import '../presentation/pages/register/pages/register_page.dart';
import '../presentation/pages/welcome_page.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/interactive_image/interactive_image_page.dart';
import '../presentation/pages/interactive_image/interactive_image_controller.dart';
import '../presentation/pages/scene_list_page.dart';
import '../presentation/controllers/home_controller.dart';
import '../core/constants/app_constants.dart';

/// 应用路由配置
class AppRoutes {
  /// 路由列表
  static final routes = [
    // 启动欢迎页（应用入口，展示后自动检查登录状态）
    GetPage(
      name: '/',
      page: () => const SplashPage(),
    ),
    // 欢迎页面（纯展示页）
    GetPage(
      name: AppConstants.routeWelcome,
      page: () => const WelcomePage(),
    ),
    // 登录选择页面（独立页）
    GetPage(
      name: AppConstants.routeLoginSelector,
      page: () => const LoginSelectorPage(),
    ),
    // 启动页兼容路由
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
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterPageController>(
          () => RegisterPageController(),
        );
      }),
    ),
    // 互动图片页面
    GetPage(
      name: AppConstants.routeInteractiveImage,
      page: () => const InteractiveImagePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<InteractiveImageController>(
          () => InteractiveImageController(),
        );
      }),
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
