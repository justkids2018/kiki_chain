import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qiqimanyou/core/constants/app_constants.dart';
import 'config/app_routes.dart';
import 'core/app_initializer.dart';
import 'presentation/controllers/auth_controller.dart';

void main() async {
  // 初始化应用程序
  await AppInitializer.initialize();
  // 全局注册 AuthController
  Get.put(AuthController());
  // 运行应用
  runApp(
     const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
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
          initialRoute: '/welcome',
          getPages: AppRoutes.routes,
          // EasyLoading配置
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
