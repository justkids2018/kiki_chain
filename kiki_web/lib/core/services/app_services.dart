import '../logging/app_logger.dart';
import '../config/env_config.dart';
import '../network/api_config.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/user_service.dart';
import '../../data/repositories/auth_repository.dart';

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
  AuthRepository? _authRepository;
  
  bool _initialized = false;
  
  /// 初始化所有服务
  Future<void> initialize() async {
    if (_initialized) {
      AppLogger.info('🔄 应用服务已初始化，跳过重复初始化');
      return;
    }
    
    AppLogger.info('🚀 开始初始化应用服务...');
    
    try {
      // 1. 初始化环境配置
      await EnvConfig.load();
      AppLogger.info('✅ 环境配置初始化完成');
      
      // 2. 初始化网络层（使用 env 配置）
      ApiConfig.init(
        baseUrl: EnvConfig.apiBaseUrl, // 例如 http://127.0.0.1:8080
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
      AppLogger.info('✅ 网络层初始化完成 (baseUrl: ${EnvConfig.apiBaseUrl})');
      
      // 3. 初始化本地存储服务
      _localStorage = LocalStorageService();
      await _localStorage!.onInit();
      AppLogger.info('✅ 本地存储服务初始化完成');
      
      // 4. 初始化业务服务（懒加载，使用时再创建）
      AppLogger.info('✅ 业务服务准备完成（懒加载）');
      
      _initialized = true;
      AppLogger.info('🎉 应用服务初始化完成');
      
    } catch (e, stackTrace) {
      AppLogger.error('❌ 应用服务初始化失败: $e');
      AppLogger.error('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
  
  // ==================== 服务访问器 ====================
  
  /// 本地存储服务
  LocalStorageService get localStorage {
    if (_localStorage == null) {
      throw Exception('LocalStorageService not initialized. Call AppServices.instance.initialize() first.');
    }
    return _localStorage!;
  }
  
  /// 用户服务
  UserService get userService {
    _userService ??= UserService();
    return _userService!;
  }
  
  /// 认证仓库
  AuthRepository get authRepository {
    _authRepository ??= AuthRepository();
    return _authRepository!;
  }
  /// 检查初始化状态
  bool get isInitialized => _initialized;
  
  /// 重置所有服务（主要用于测试）
  void reset() {
    _localStorage = null;
    _userService = null;
    _authRepository = null;
    _initialized = false;
  }
}
