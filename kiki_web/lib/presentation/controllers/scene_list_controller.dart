import 'dart:async';
import 'package:get/get.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_category.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/app_services.dart';

/// 场景列表控制器
///
/// 管理场景列表页面的状态和业务逻辑
class SceneListController extends GetxController {
  static const int maxDailyNewScenes = 3;

  SceneListController({
    ISceneRepository? sceneRepository,
    required this.category,
  }) : _sceneRepository =
            sceneRepository ?? ServiceLocator.instance.sceneRepository;

  final SceneCategory category;
  final ISceneRepository _sceneRepository;

  // 场景列表
  final RxList<Scene> scenes = <Scene>[].obs;
  final RxBool isLoadingScenes = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt restoredSceneIndex = 0.obs;
  final RxInt dailyNewScenesCount = 0.obs;

  bool get hasReachedDailyLimit =>
      dailyNewScenesCount.value >= maxDailyNewScenes;

  @override
  void onInit() {
    super.onInit();
    loadScenes();
  }

  /// 加载场景列表
  Future<void> loadScenes() async {
    final showInitialLoading = scenes.isEmpty;
    try {
      if (showInitialLoading) isLoadingScenes.value = true;
      errorMessage.value = '';

      AppLogger.info('📦 Loading scenes for category: ${category.id}');

      final result = await _sceneRepository.getScenesByCategory(category.id);

      // 防御式过滤：即便后端异常返回了其他分类数据，也只显示当前分类。
      final visibleScenes =
          result.where((scene) => scene.categoryId == category.id).toList();
      scenes.value = visibleScenes;

      await _restoreProgressionState();
      await _restoreLastSelectedSceneIndex();

      AppLogger.info('✅ Loaded ${scenes.length} scenes');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to load scenes', e, stackTrace);
      errorMessage.value = e.toString();
      if (showInitialLoading) scenes.clear();
    } finally {
      if (showInitialLoading) isLoadingScenes.value = false;
    }
  }

  /// 刷新场景列表
  Future<void> refreshScenes() async {
    await loadScenes();
  }

  /// 导航到场景详情页（直接进入互动学习）
  Future<void> navigateToSceneDetail(Scene scene,
      {required int selectedIndex}) async {
    AppLogger.info('🚀 Navigating to interactive scene: ${scene.name}');

    // 检查场景是否有互动数据（新的数据结构使用 itemCount）
    if (scene.itemCount <= 0) {
      AppLogger.warning('⚠️ Scene ${scene.name} has no interactive items');
      Get.snackbar(
        '提示',
        '该场景暂未开放互动学习功能',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    await _saveLastSelectedScene(selectedIndex, scene.id);

    // 直接导航到互动学习页面
    // 注意：新的数据结构中，数据已经内嵌在 scene 对象中（通过 API 的 items_data 字段）
    // 需要传递原始的 JSON 数据（包含 items_data），而不是转换后的 Scene 对象
    final result = await Get.toNamed<dynamic>(
      AppConstants.routeInteractiveImage,
      arguments: {
        'jsonFile': scene.dataFile, // 保留兼容性，但可能为 null
        'imageItem': null,
        'images': <dynamic>[], // 使用空的 dynamic 列表而不是 ImageItem 列表
        'scene': scene.toJson(), // 传递 JSON Map，保留所有字段
        'sceneObject': scene, // 同时传递 Scene 对象用于类型安全的属性访问
      },
    );

    final completed = result is Map && result['sceneCompleted'] == true;
    if (completed) {
      await markSceneCompleted(selectedIndex);
    }
  }

  /// 完成当前场景后，解锁并自动选中下一个场景。
  Future<void> markSceneCompleted(int completedIndex) async {
    if (completedIndex < 0 || completedIndex >= scenes.length) return;

    var completedThrough = completedIndex;
    final completedToday = <String>{scenes[completedIndex].id};

    try {
      final storage = AppServices.instance.localStorage;
      completedThrough = (storage.getInt(_completedThroughStorageKey) ?? -1)
          .clamp(-1, scenes.length - 1);
      if (completedIndex <= completedThrough) return;

      completedToday
        ..clear()
        ..addAll(storage.getStringList(_dailyCompletedStorageKey) ?? const []);
      if (!completedToday.add(scenes[completedIndex].id)) return;

      completedThrough = completedIndex;
      await storage.setInt(_completedThroughStorageKey, completedThrough);
      await storage.setStringList(
        _dailyCompletedStorageKey,
        completedToday.toList(),
      );
    } catch (e) {
      AppLogger.warning(
        '⚠️ Failed to save scene progression for category ${category.id}',
        e,
      );
    }

    dailyNewScenesCount.value = completedToday.length;
    final nextIndex = completedIndex + 1;
    if (!hasReachedDailyLimit && nextIndex < scenes.length) {
      scenes[nextIndex] = scenes[nextIndex].copyWith(isLocked: false);
      restoredSceneIndex.value = nextIndex;
      await _saveLastSelectedScene(nextIndex, scenes[nextIndex].id);
    } else {
      restoredSceneIndex.value = completedIndex;
      await _saveLastSelectedScene(
        completedIndex,
        scenes[completedIndex].id,
      );
    }
  }

  void persistSelectedSceneIndex(int selectedIndex) {
    if (scenes.isEmpty) {
      return;
    }

    final safeIndex = selectedIndex.clamp(0, scenes.length - 1);
    if (safeIndex == restoredSceneIndex.value) {
      return;
    }

    restoredSceneIndex.value = safeIndex;
    unawaited(_saveLastSelectedScene(safeIndex, scenes[safeIndex].id));
  }

  Future<void> _restoreLastSelectedSceneIndex() async {
    if (scenes.isEmpty) {
      restoredSceneIndex.value = 0;
      return;
    }

    final highestUnlockedIndex =
        scenes.lastIndexWhere((scene) => !scene.isLocked);
    restoredSceneIndex.value =
        highestUnlockedIndex < 0 ? 0 : highestUnlockedIndex;
    AppLogger.info(
      '🎯 Selected current available scene index: ${restoredSceneIndex.value} '
      '(category: ${category.id})',
    );
  }

  Future<void> _restoreProgressionState() async {
    if (scenes.isEmpty) return;
    try {
      final storage = AppServices.instance.localStorage;
      final completedThrough =
          (storage.getInt(_completedThroughStorageKey) ?? -1)
              .clamp(-1, scenes.length - 1);
      final completedToday =
          storage.getStringList(_dailyCompletedStorageKey) ?? const [];
      dailyNewScenesCount.value = completedToday.toSet().length;

      final availableThrough =
          (completedThrough + (hasReachedDailyLimit ? 0 : 1))
              .clamp(0, scenes.length - 1);
      for (var index = 0; index < scenes.length; index++) {
        scenes[index] = scenes[index].copyWith(
          isLocked: index > availableThrough,
        );
      }
    } catch (e) {
      AppLogger.warning(
        '⚠️ Failed to restore scene progression for category ${category.id}',
        e,
      );
      for (var index = 0; index < scenes.length; index++) {
        scenes[index] = scenes[index].copyWith(isLocked: index > 0);
      }
    }
  }

  Future<void> _saveLastSelectedScene(int selectedIndex, String sceneId) async {
    try {
      final storage = AppServices.instance.localStorage;
      await storage.setInt(_sceneIndexStorageKey, selectedIndex);
      await storage.setString(_sceneIdStorageKey, sceneId);
      AppLogger.debug(
        '💾 Saved last selected scene index: $selectedIndex, sceneId: $sceneId (category: ${category.id})',
      );
    } catch (e) {
      AppLogger.warning(
        '⚠️ Failed to save last selected scene index for category ${category.id}',
        e,
      );
    }
  }

  String get _sceneIndexStorageKey => 'scene_list_last_index_${category.id}';

  String get _sceneIdStorageKey => 'scene_list_last_scene_id_${category.id}';

  String get _completedThroughStorageKey =>
      'scene_list_completed_through_${category.id}';

  String get _dailyCompletedStorageKey {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return 'scene_list_daily_completed_$date';
  }
}
