import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/scene_category.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/logging/app_logger.dart';
import '../../data/services/learning/reward_service.dart';
import '../../core/network/network_client.dart';
import '../../core/constants/app_constants.dart';
import 'app_update_controller.dart';
import 'auth_controller.dart';
import '../../domain/entities/subscription.dart';

/// 简化的首页控制器
class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
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
  bool _hasCheckedAppUpdate = false;

  @override
  void onInit() {
    super.onInit();

    // 初始化TabController
    tabController = TabController(length: 2, vsync: this);

    // 监听tab变化
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentIndex.value = tabController.index;
        if (tabController.index == 1) {
          _refreshCurrentUserFromServer();
        }
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
      _checkAppUpdateAfterHomeDataLoaded();
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

  /// 首页主题层 VIP 策略：第一个主题免费，其余主题需要 VIP。
  bool categoryRequiresVip(int index) => index > 0;

  bool categoryIsLocked(int index) =>
      categoryRequiresVip(index) && !isVipActive;

  bool get isVipActive {
    if (currentUser.value?.isVipActive == true) {
      return true;
    }

    try {
      return Get.find<AuthController>().isVipActive;
    } catch (_) {
      return false;
    }
  }

  Future<void> openCategory(SceneCategory category, int index) async {
    if (categoryIsLocked(index)) {
      await _openSubscription();
      return;
    }

    Get.toNamed(
      AppConstants.routeSceneList,
      arguments: category,
    );
  }

  Future<void> _openSubscription() async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn) {
        Get.snackbar(
          '请先登录',
          '登录后即可开通 VIP 解锁主题',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        Get.toNamed(AppConstants.routeLogin);
        return;
      }
    } catch (_) {
      Get.toNamed(AppConstants.routeLogin);
      return;
    }

    final result = await Get.toNamed(AppConstants.routeSubscription);
    if (result is VipEntitlement && result.isVip) {
      await refreshAfterSubscription(result);
    }
  }

  Future<void> refreshAfterSubscription(VipEntitlement entitlement) async {
    if (!entitlement.isVip) return;

    try {
      final authController = Get.find<AuthController>();
      authController.applyVipEntitlement(
        isVip: entitlement.isVip,
        vipExpireAt: entitlement.vipExpireAt,
      );
      currentUser.value = authController.currentUser;
      currentUser.refresh();
      update();
      await _refreshCurrentUserFromServer();
      if (currentUser.value?.isVipActive != true) {
        authController.applyVipEntitlement(
          isVip: entitlement.isVip,
          vipExpireAt: entitlement.vipExpireAt,
        );
        currentUser.value = authController.currentUser;
        currentUser.refresh();
        update();
      }
    } catch (e, stackTrace) {
      AppLogger.warning(
        'HomeController: 刷新订阅权益后首页状态失败',
        e,
        stackTrace,
      );
    }
  }

  void _checkAppUpdateAfterHomeDataLoaded() {
    if (_hasCheckedAppUpdate || categories.isEmpty || !_isOnHomeRoute) {
      return;
    }

    _hasCheckedAppUpdate = true;
    if (!Get.isRegistered<AppUpdateController>()) {
      Get.put(AppUpdateController());
    }

    Get.find<AppUpdateController>().checkUpdateAfterHomeLoaded(
      canShowDialog: () => !isClosed && _isOnHomeRoute,
    );
  }

  bool get _isOnHomeRoute => Get.currentRoute == AppConstants.routeHome;

  /// 加载用户信息并同步服务器星星数据
  void _loadUserInfo() async {
    try {
      final user = await _refreshCurrentUserFromServer();

      // 如果用户已登录，从服务器拉取最新的总星星数进行同步
      if (user != null) {
        final authController = Get.find<AuthController>();
        final rewardService =
            RewardService(httpClient: NetworkClient.instance.httpClient);
        final serverStars = await rewardService.fetchUserTotalStars(user.id);
        if (serverStars != null) {
          await authController.updateUserStars(serverStars);
          // 刷新本地的 currentUser
          currentUser.value = authController.currentUser;
        }
      }
    } catch (e) {
      AppLogger.warning('HomeController: 加载/同步用户信息失败', e);
    }
  }

  Future<User?> _refreshCurrentUserFromServer() async {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.isLoggedIn
          ? await authController.refreshCurrentUser()
          : await _authRepository.getCurrentUser();
      currentUser.value = user;
      return user;
    } catch (e) {
      AppLogger.warning('HomeController: 刷新用户信息失败', e);
      return currentUser.value;
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
    if (index == 1) {
      _refreshCurrentUserFromServer();
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
