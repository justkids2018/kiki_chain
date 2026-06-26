import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/scene_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../data/services/api/scene_api_service.dart';
import '../../data/services/api/subscription_api_service.dart';
import 'package:get/get.dart';

/// 简易服务定位器，提供领域接口单例访问能力
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  IAuthRepository? _authRepository;
  ISceneRepository? _sceneRepository;
  ISubscriptionRepository? _subscriptionRepository;

  IAuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl();
    return _authRepository!;
  }

  ISceneRepository get sceneRepository {
    _sceneRepository ??= SceneRepositoryImpl(
      apiService: Get.find<SceneApiService>(),
    );
    return _sceneRepository!;
  }

  ISubscriptionRepository get subscriptionRepository {
    _subscriptionRepository ??= SubscriptionRepositoryImpl(
      apiService: Get.find<SubscriptionApiService>(),
    );
    return _subscriptionRepository!;
  }

  void setAuthRepository(IAuthRepository repository) {
    _authRepository = repository;
  }

  void setSceneRepository(ISceneRepository repository) {
    _sceneRepository = repository;
  }

  void setSubscriptionRepository(ISubscriptionRepository repository) {
    _subscriptionRepository = repository;
  }

  void resetAuthRepository() {
    _authRepository = null;
  }

  void resetSceneRepository() {
    _sceneRepository = null;
  }

  void resetSubscriptionRepository() {
    _subscriptionRepository = null;
  }
}
