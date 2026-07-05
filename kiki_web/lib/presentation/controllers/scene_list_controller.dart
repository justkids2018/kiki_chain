import 'dart:async';
import 'package:get/get.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_category.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/network_client.dart';
import '../../core/services/app_services.dart';
import '../../data/services/learning/reward_service.dart';
import 'auth_controller.dart';

/// 场景列表控制器
///
/// 管理场景列表页面的状态和业务逻辑
class SceneListController extends GetxController {
  SceneListController({
    ISceneRepository? sceneRepository,
    RewardService? rewardService,
    required this.category,
  })  : _sceneRepository =
            sceneRepository ?? ServiceLocator.instance.sceneRepository,
        _rewardService = rewardService ?? _createRewardService();

  static RewardService _createRewardService() {
    try {
      return RewardService(httpClient: NetworkClient.instance.httpClient);
    } catch (_) {
      return RewardService();
    }
  }

  final SceneCategory category;
  final ISceneRepository _sceneRepository;
  final RewardService _rewardService;

  // 场景列表
  final RxList<Scene> scenes = <Scene>[].obs;
  final RxBool isLoadingScenes = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt restoredSceneIndex = 0.obs;
  final RxMap<String, int> sceneStars = <String, int>{}.obs;
  final RxSet<String> learnedSceneIds = <String>{}.obs;

  bool isSceneLearned(String sceneId) => learnedSceneIds.contains(sceneId);

  int starsForScene(String sceneId) => sceneStars[sceneId] ?? 0;

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

      _unlockAllScenes();
      await _restoreLearningState();
      _selectFirstUnlearnedScene();

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

    await _restoreLearningState();
    final completed = result is Map && result['sceneCompleted'] == true;
    if (completed) {
      await markSceneCompleted(selectedIndex);
    }
  }

  /// 完成场景后更新内存摘要，不限制任何其他节点。
  Future<void> markSceneCompleted(int completedIndex) async {
    if (completedIndex < 0 || completedIndex >= scenes.length) return;
    final sceneId = scenes[completedIndex].id;
    learnedSceneIds.add(sceneId);
    sceneStars[sceneId] = RewardService.maxStars;
    final nextIndex = completedIndex + 1;
    if (nextIndex < scenes.length) {
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

  void _selectFirstUnlearnedScene() {
    if (scenes.isEmpty) return;
    final firstUnlearned =
        scenes.indexWhere((scene) => !learnedSceneIds.contains(scene.id));
    restoredSceneIndex.value =
        firstUnlearned < 0 ? scenes.length - 1 : firstUnlearned;
    AppLogger.info(
      '🎯 Selected first unexplored scene index: ${restoredSceneIndex.value} '
      '(category: ${category.id})',
    );
  }

  void _unlockAllScenes() {
    for (var index = 0; index < scenes.length; index++) {
      if (scenes[index].isLocked) {
        scenes[index] = scenes[index].copyWith(isLocked: false);
      }
    }
  }

  Future<void> _restoreLearningState() async {
    if (scenes.isEmpty) return;
    final userId = _currentUserId;
    final sceneIds = scenes.map((scene) => scene.id).toList(growable: false);
    final sceneIdSet = sceneIds.toSet();
    final localCounts =
        await _rewardService.loadLearnedRegionCounts(userId, sceneIds);
    final mergedStars = <String, int>{};
    final learnedIds = <String>{};

    for (final scene in scenes) {
      final learnedCount = localCounts[scene.id] ?? 0;
      if (learnedCount > 0) learnedIds.add(scene.id);
      mergedStars[scene.id] =
          _rewardService.calculateStars(learnedCount, scene.itemCount);
    }

    if (userId.isNotEmpty) {
      final serverProgress = await _rewardService.loadProgressSnapshot(userId);
      for (final progress in serverProgress) {
        if (!sceneIdSet.contains(progress.sceneId)) continue;
        if (progress.learnedCount > 0 || progress.starsEarned > 0) {
          learnedIds.add(progress.sceneId);
        }
        final localStars = mergedStars[progress.sceneId] ?? 0;
        if (progress.starsEarned > localStars) {
          mergedStars[progress.sceneId] = progress.starsEarned;
        }
      }
    }

    sceneStars.assignAll(mergedStars);
    learnedSceneIds.assignAll(learnedIds);
  }

  String get _currentUserId {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn) {
        return authController.currentUser?.id ?? '';
      }
    } catch (_) {}
    return '';
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
}
