import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kikichain/core/constants/app_constants.dart';
import 'package:kikichain/generated/app_localizations.dart';
import 'config/app_routes.dart';
import 'core/app_initializer.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/language_controller.dart';

void main() async {
  // 初始化应用程序
  await AppInitializer.initialize();
  // 全局注册控制器
  Get.put(AuthController());
  Get.put(LanguageController());
  // 运行应用
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 应用恢复到前台时，如果在详情页，则返回首页
    if (state == AppLifecycleState.resumed) {
      if (Get.currentRoute == AppConstants.routeInteractiveImage) {
        Get.offNamed(AppConstants.routeInteractiveImageHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetBuilder<LanguageController>(
          builder: (languageController) {
            return GetMaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,

              // 国际化配置
              locale: languageController.currentLocale,
              supportedLocales: languageController.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              theme: ThemeData(
                primarySwatch: Colors.green,
                primaryColor: const Color(0xFF4CAF50),
                fontFamily: 'PingFang SC',
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // 设置路由
              initialRoute: AppConstants.routeInteractiveImageHome,
              getPages: AppRoutes.routes,
              // EasyLoading配置
              builder: EasyLoading.init(),
            );
          },
        );
      },
    );
  }
}
