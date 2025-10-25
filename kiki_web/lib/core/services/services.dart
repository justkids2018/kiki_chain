/// 服务访问的便捷导出
/// 
/// 提供简洁的全局访问方式
export 'app_services.dart';

// 便捷访问器
import 'app_services.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// 应用服务的便捷访问器
final appServices = AppServices.instance;

/// 快捷访问各个服务
final localStorage = AppServices.instance.localStorage;
final userService = AppServices.instance.userService;
final IAuthRepository authRepository = AppServices.instance.authRepository;
