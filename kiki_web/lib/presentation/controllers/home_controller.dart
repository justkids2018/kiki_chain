import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/scene_category.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';

/// 简化的首页控制器
class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  HomeController({
    IAuthRepository? authRepository,
    ISceneRepository? sceneRepository,
  })  : _authRepository =
            authRepository ?? ServiceLocator.instance.authRepository,
        _sceneRepository =
            sceneRepository ?? ServiceLocator.instance.sceneRepository;

  // 底部导航相关
  late TabController tabController;
  final RxInt currentIndex = 0.obs;

  // 用户信息
  final Rxn<User> currentUser = Rxn<User>();

  // 场景分类相关
  final RxList<SceneCategory> categories = <SceneCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxString errorMessage = ''.obs;

  // 服务访问
  final IAuthRepository _authRepository;
  final ISceneRepository _sceneRepository;
  
  @override
  void onInit() {
    super.onInit();

    // 初始化TabController
    tabController = TabController(length: 2, vsync: this);

    // 监听tab变化
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentIndex.value = tabController.index;
      }
    });

    // 加载用户信息
    _loadUserInfo();

    // 加载场景分类
    loadCategories();
  }

  /// 加载场景分类列表
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      errorMessage.value = '';

      AppLogger.info('🏠 Loading scene categories...');

      final result = await _sceneRepository.getCategories();

      categories.value = result;

      AppLogger.info('✅ Loaded ${result.length} categories');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to load categories', e, stackTrace);
      errorMessage.value = e.toString();
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// 刷新分类列表
  Future<void> refreshCategories() async {
    await loadCategories();
  }
  
  /// 加载用户信息
  void _loadUserInfo() async {
    try {
      // 从认证仓库获取当前用户信息
      final user = await _authRepository.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      // 如果获取失败，使用模拟数据
    }
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
  
  /// 切换tab
  void switchTab(int index) {
    if (index != currentIndex.value) {
      tabController.animateTo(index);
      currentIndex.value = index;
    }
  }
  
  /// 登出
  void logout() async {
    try {
      // 调用认证仓库的登出方法
      await _authRepository.logout();
      // 清除用户信息
      currentUser.value = null;
    } catch (e, stackTrace) {
      // 处理登出错误
      AppLogger.error('❌ Logout failed', e, stackTrace);
    }
  }
}
