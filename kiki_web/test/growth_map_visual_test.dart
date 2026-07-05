import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kikichain/domain/entities/scene.dart';
import 'package:kikichain/domain/entities/scene_category.dart';
import 'package:kikichain/domain/repositories/i_scene_repository.dart';
import 'package:kikichain/generated/app_localizations.dart';
import 'package:kikichain/presentation/controllers/scene_list_controller.dart';
import 'package:kikichain/presentation/features/growth_map/pages/growth_map_page.dart';
import 'package:kikichain/presentation/features/growth_map/widgets/growth_tree_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('all scenes stay open and completion selects the next scene', () async {
    final category = SceneCategory(
      id: 'progression',
      name: '成长测试',
      icon: '',
      coverImage: '',
      description: '',
      sceneCount: 2,
      totalItemCount: 16,
      order: 1,
      isNew: false,
      createdAt: DateTime(2026, 1, 1),
    );
    final scenes = List.generate(
      2,
      (index) => Scene(
        id: 'progress_$index',
        name: '场景 $index',
        nameEn: 'Scene $index',
        categoryId: category.id,
        coverImage: '',
        interactiveImage: '',
        description: '',
        context: '',
        itemCount: 8,
        order: index,
        isNew: false,
        isLocked: index == 1,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    final controller = SceneListController(
      category: category,
      sceneRepository: _PreviewSceneRepository(scenes),
    );

    await controller.loadScenes();
    expect(controller.scenes.every((scene) => !scene.isLocked), isTrue);

    await controller.markSceneCompleted(0);

    expect(controller.isSceneLearned('progress_0'), isTrue);
    expect(controller.starsForScene('progress_0'), 3);
    expect(controller.restoredSceneIndex.value, 1);
  });

  testWidgets('growth map landscape selects a node and previews one card',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final category = SceneCategory(
      id: 'daily_life',
      name: '日常生活',
      icon: '',
      coverImage: '',
      description: '',
      sceneCount: 6,
      totalItemCount: 48,
      order: 1,
      isNew: false,
      createdAt: DateTime(2026, 1, 1),
    );
    final controller = _PreviewSceneListController(
      category: category,
      sceneRepository: _PreviewSceneRepository(
        ['早餐时间', '准备上学', '和妈妈做饭', '洗澡时间', '睡前故事', '周末野餐']
            .asMap()
            .entries
            .map(
              (entry) => Scene(
                id: 'scene_${entry.key}',
                name: entry.value,
                nameEn: const [
                  'Breakfast',
                  'Ready for school',
                  'Cooking',
                  'Bath time',
                  'Bedtime',
                  'Picnic',
                ][entry.key],
                categoryId: category.id,
                coverImage: '',
                interactiveImage: '',
                description: '',
                context: '',
                itemCount: 8,
                order: entry.key,
                isNew: entry.key == 5,
                createdAt: DateTime(2026, 1, 1),
              ),
            )
            .toList(),
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: GrowthMapPage(category: category, controller: controller),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(GrowthMapPage), findsOneWidget);
    expect(find.byKey(const ValueKey('selected-scene-title')), findsNothing);
    final firstNode = find.byWidgetPredicate(
      (widget) => widget is GrowthTreeNode && widget.scene.id == 'scene_0',
    );
    expect(tester.getCenter(firstNode).dy, closeTo(274, 2));
    expect(
        find.byKey(const ValueKey('unexplored-node-scene_0')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('selected-scene-preview')), findsOneWidget);
    expect(find.text('选择一个场景开始学习'), findsNothing);
    expect(
        find.byKey(const ValueKey('growth-map-bottom-refresh')), findsNothing);

    await controller.markSceneCompleted(0);
    await tester.pump();
    final secondNode = find.byWidgetPredicate(
      (widget) => widget is GrowthTreeNode && widget.scene.id == 'scene_1',
    );
    // Controller update and reactive map rebuild happen in separate frames.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const ValueKey('selected-scene-title')), findsNothing);
    expect(tester.getCenter(secondNode).dy, closeTo(274, 2));
    expect(find.byKey(const ValueKey('learned-badge-scene_0')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('unexplored-node-scene_1')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('selected-scene-preview')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: secondNode,
        matching: find.byType(GestureDetector),
      ),
    );
    await tester.pump();

    expect(controller.openedSceneId, 'scene_1');
    expect(tester.takeException(), isNull);
  });
}

class _PreviewSceneListController extends SceneListController {
  _PreviewSceneListController({
    required super.category,
    required ISceneRepository sceneRepository,
  }) : super(sceneRepository: sceneRepository);

  String? openedSceneId;

  @override
  Future<void> navigateToSceneDetail(
    Scene scene, {
    required int selectedIndex,
  }) async {
    openedSceneId = scene.id;
  }
}

class _PreviewSceneRepository implements ISceneRepository {
  const _PreviewSceneRepository(this.scenes);

  final List<Scene> scenes;

  @override
  Future<List<SceneCategory>> getCategories() async => const [];

  @override
  Future<Map<String, dynamic>> getSceneDetail(String sceneId) async => {};

  @override
  Future<List<Scene>> getScenesByCategory(String categoryId) async => scenes;

  @override
  Future<List<Scene>> searchScenes({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async =>
      const [];
}
