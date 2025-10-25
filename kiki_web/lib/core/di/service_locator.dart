import '../../domain/repositories/i_auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// 简易服务定位器，提供领域接口单例访问能力
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  IAuthRepository? _authRepository;

  IAuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl();
    return _authRepository!;
  }

  void setAuthRepository(IAuthRepository repository) {
    _authRepository = repository;
  }

  void resetAuthRepository() {
    _authRepository = null;
  }
}
