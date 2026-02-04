import 'package:get/get.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_category.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';
import '../pages/scene_detail_page.dart';

/// 场景列表控制器
///
/// 管理场景列表页面的状态和业务逻辑
class SceneListController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
    loadScenes();
  }

  /// 加载场景列表
  Future<void> loadScenes() async {
    try {
      isLoadingScenes.value = true;
      errorMessage.value = '';

      AppLogger.info('📦 Loading scenes for category: ${category.id}');

      final result = await _sceneRepository.getScenesByCategory(category.id);

      scenes.value = result;

      AppLogger.info('✅ Loaded ${scenes.length} scenes');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to load scenes', e, stackTrace);
      errorMessage.value = e.toString();
    } finally {
      isLoadingScenes.value = false;
    }
  }

  /// 刷新场景列表
  Future<void> refreshScenes() async {
    await loadScenes();
  }

  /// 导航到场景详情页
  void navigateToSceneDetail(Scene scene) {
    AppLogger.info('🚀 Navigating to scene detail: ${scene.name}');
    Get.to(
      () => SceneDetailPage(scene: scene),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
