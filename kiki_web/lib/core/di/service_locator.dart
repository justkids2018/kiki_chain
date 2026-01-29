import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_scene_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/scene_repository_impl.dart';
import '../../data/services/api/scene_api_service.dart';
import 'package:get/get.dart';

/// 简易服务定位器，提供领域接口单例访问能力
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  IAuthRepository? _authRepository;
  ISceneRepository? _sceneRepository;

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

  void setAuthRepository(IAuthRepository repository) {
    _authRepository = repository;
  }

  void setSceneRepository(ISceneRepository repository) {
    _sceneRepository = repository;
  }

  void resetAuthRepository() {
    _authRepository = null;
  }

  void resetSceneRepository() {
    _sceneRepository = null;
  }
}
