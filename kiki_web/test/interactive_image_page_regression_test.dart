import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kikichain/config/app_routes.dart';
import 'package:kikichain/core/constants/app_constants.dart';
import 'package:kikichain/generated/app_localizations.dart';
import 'package:kikichain/core/network/api_config.dart';
import 'package:kikichain/presentation/controllers/auth_controller.dart';
import 'package:kikichain/presentation/pages/interactive_image/interactive_image_controller.dart';
import 'package:kikichain/presentation/pages/interactive_image/interactive_image_view.dart';

void main() {
  setUpAll(() {
    ApiConfig.initTest();
    SharedPreferences.setMockInitialValues({});
    Get.put(AuthController());
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.reset();
  });

  testWidgets('scene navigation renders the learning card image',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(GetMaterialApp(
      getPages: AppRoutes.routes,
      initialRoute: '/',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SizedBox()),
    ));

    Get.toNamed(AppConstants.routeInteractiveImage, arguments: {
      'jsonFile': null,
      'imageItem': null,
      'images': <dynamic>[],
      'scene': {
        'id': 'scene_test',
        'name': '测试场景',
        'interactiveImage': 'assets/images/kiki_zhiwuyuan.jpg',
        'coverImage': 'assets/images/kiki_zhiwuyuan.jpg',
        'image_width': 1024,
        'image_height': 1024,
        'items_data': [
          {
            'type': 'chinese',
            'id': 'chinese_01',
            'index': 1,
            'text': '苹果',
            'text_pinyin': 'píng guǒ',
            'text_english': 'Apple',
            'text_phonetic': '/ˈæpl/',
            'regions': [
              {
                'region_type': 'card',
                'coordinate': [
                  {'x': 10, 'y': 10},
                  {'x': 100, 'y': 10},
                  {'x': 10, 'y': 100},
                  {'x': 100, 'y': 100},
                ],
              },
            ],
          },
        ],
      },
    });

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    final controller = Get.find<InteractiveImageController>();
    expect(controller.isLoaded.value, isTrue);
    expect(controller.regions, hasLength(1));
    expect(find.byType(InteractiveImageView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scene navigation falls back to cover image', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(GetMaterialApp(
      getPages: AppRoutes.routes,
      initialRoute: '/',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SizedBox()),
    ));

    Get.toNamed(AppConstants.routeInteractiveImage, arguments: {
      'jsonFile': null,
      'imageItem': null,
      'images': <dynamic>[],
      'scene': {
        'id': 'scene_cover_only',
        'name': '封面图场景',
        'coverImage': 'assets/images/kiki_zhiwuyuan.jpg',
        'image_width': 1024,
        'image_height': 1024,
        'items_data': [
          {
            'type': 'chinese',
            'id': 'chinese_01',
            'index': 1,
            'text': '苹果',
            'text_pinyin': 'píng guǒ',
            'text_english': 'Apple',
            'text_phonetic': '/ˈæpl/',
            'regions': [
              {
                'region_type': 'card',
                'coordinate': [
                  {'x': 10, 'y': 10},
                  {'x': 100, 'y': 10},
                  {'x': 10, 'y': 100},
                  {'x': 100, 'y': 100},
                ],
              },
            ],
          },
        ],
      },
    });

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    final controller = Get.find<InteractiveImageController>();
    expect(controller.isLoaded.value, isTrue);
    expect(controller.imagePath, 'assets/images/kiki_zhiwuyuan.jpg');
    expect(controller.regions, hasLength(1));
    expect(find.byType(InteractiveImageView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
