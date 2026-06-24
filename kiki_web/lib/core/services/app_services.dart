import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../network/api_config.dart';
import '../network/network_client.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/user_service.dart';
import '../../data/services/api/scene_api_service.dart';
import '../../data/services/api/subscription_api_service.dart';
import '../di/service_locator.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import 'package:get/get.dart';

/// 应用服务 - 统一管理所有业务服务
///
/// 使用简单的单例模式，避免复杂的依赖注入
/// 所有服务在这里初始化和访问
class AppServices {
  AppServices._internal();
  static final AppServices _instance = AppServices._internal();
  static AppServices get instance => _instance;

  // 服务实例
  LocalStorageService? _localStorage;
  UserService? _userService;
  IAuthRepository? _authRepository;
  ISceneRepository? _sceneRepository;
  ISubscriptionRepository? _subscriptionRepository;

  bool _initialized = false;

  /// 初始化所有服务
  Future<void> initialize() async {
    if (_initialized) {
      print('🔄 应用服务已初始化，跳过重复初始化');
      return;
    }

    print('🚀 开始初始化应用服务...');

    try {
      // 1. 初始化环境配置（release 模式自动使用生产环境）
      print('📝 开始加载环境配置...');
      await EnvConfig.load(kReleaseMode ? 'prod' : null);
      if (EnvConfig.apiBaseUrl.isEmpty) {
        throw StateError(
            'API_BASE_URL 未配置，请检查 config/${EnvConfig.currentEnv}.env');
      }
      print('✅ 环境配置初始化完成: ${EnvConfig.apiBaseUrl}');

      // 2. 初始化网络层（使用 env 配置）
      print('🌐 开始初始化网络层...');
      ApiConfig.init(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        enableLogging: EnvConfig.enableLogging,
        enableAuth: true,
        enableRetry: true,
        enableCache: EnvConfig.enableCache,
        enableNetworkStatusCheck: true,
      );
      print('✅ 网络层初始化完成 (baseUrl: ${EnvConfig.apiBaseUrl})');

      // 3. 初始化本地存储服务
      print('💾 开始初始化本地存储...');
      _localStorage = LocalStorageService();
      await _localStorage!.onInit();
      print('✅ 本地存储服务初始化完成');

      // 4. 注册API服务到GetX
      print('🔌 开始注册API服务...');
      Get.put(SceneApiService(httpClient: NetworkClient.instance.httpClient));
      Get.put(SubscriptionApiService(
          httpClient: NetworkClient.instance.httpClient));
      print('✅ API服务注册完成');

      // 5. 初始化业务服务（懒加载，使用时再创建）
      print('✅ 业务服务准备完成（懒加载）');

      _initialized = true;
      print('🎉 应用服务初始化完成');
    } catch (e, stackTrace) {
      print('❌ 应用服务初始化失败: $e');
      print('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  // ==================== 服务访问器 ====================

  /// 本地存储服务
  LocalStorageService get localStorage {
    if (_localStorage == null) {
      throw Exception(
          'LocalStorageService not initialized. Call AppServices.instance.initialize() first.');
    }
    return _localStorage!;
  }

  /// 用户服务
  UserService get userService {
    _userService ??= UserService();
    return _userService!;
  }

  /// 认证仓库
  IAuthRepository get authRepository {
    _authRepository ??= ServiceLocator.instance.authRepository;
    return _authRepository!;
  }

  /// 场景仓库
  ISceneRepository get sceneRepository {
    _sceneRepository ??= ServiceLocator.instance.sceneRepository;
    return _sceneRepository!;
  }

  /// 订阅仓库
  ISubscriptionRepository get subscriptionRepository {
    _subscriptionRepository ??= ServiceLocator.instance.subscriptionRepository;
    return _subscriptionRepository!;
  }

  /// 允许覆盖认证仓库实例（例如测试场景）
  void setAuthRepository(IAuthRepository repository) {
    _authRepository = repository;
    ServiceLocator.instance.setAuthRepository(repository);
  }

  /// 允许覆盖场景仓库实例（例如测试场景）
  void setSceneRepository(ISceneRepository repository) {
    _sceneRepository = repository;
    ServiceLocator.instance.setSceneRepository(repository);
  }

  /// 允许覆盖订阅仓库实例（例如测试场景）
  void setSubscriptionRepository(ISubscriptionRepository repository) {
    _subscriptionRepository = repository;
    ServiceLocator.instance.setSubscriptionRepository(repository);
  }

  void resetAuthRepository() {
    _authRepository = null;
    ServiceLocator.instance.resetAuthRepository();
  }

  void resetSceneRepository() {
    _sceneRepository = null;
    ServiceLocator.instance.resetSceneRepository();
  }

  void resetSubscriptionRepository() {
    _subscriptionRepository = null;
    ServiceLocator.instance.resetSubscriptionRepository();
  }

  /// 检查初始化状态
  bool get isInitialized => _initialized;

  /// 重置所有服务（主要用于测试）
  void reset() {
    _localStorage = null;
    _userService = null;
    _authRepository = null;
    _sceneRepository = null;
    _subscriptionRepository = null;
    ServiceLocator.instance.resetAuthRepository();
    ServiceLocator.instance.resetSceneRepository();
    ServiceLocator.instance.resetSubscriptionRepository();
    _initialized = false;
  }
}
