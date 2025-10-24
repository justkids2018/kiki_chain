/// 简洁的 API 配置类
/// 
/// 负责管理全局网络配置，支持环境切换
/// 采用单例模式，确保配置的一致性
class ApiConfig {
  static ApiConfig? _instance;
  
  final String baseUrl;
  final int connectTimeout;
  final int receiveTimeout;
  final Map<String, String> headers;
  final bool enableLogging;
  final bool enableAuth;
  final bool enableRetry;
  final bool enableCache;
  final bool enableNetworkStatusCheck;
  
  /// 私有构造函数
  ApiConfig._({
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.headers,
    required this.enableLogging,
    required this.enableAuth,
    required this.enableRetry,
    required this.enableCache,
    required this.enableNetworkStatusCheck,
  });
  
  /// 初始化配置
  /// 
  /// [baseUrl] API基础URL
  /// [connectTimeout] 连接超时时间(毫秒)
  /// [receiveTimeout] 接收超时时间(毫秒)
  /// [headers] 默认请求头
  /// [enableLogging] 是否启用日志
  /// [enableAuth] 是否启用认证
  /// [enableRetry] 是否启用重试
  /// [enableCache] 是否启用缓存
  /// [enableNetworkStatusCheck] 是否启用网络状态检查
  static void init({
    required String baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
    Map<String, String>? headers,
    bool enableLogging = true,
    bool enableAuth = true,
    bool enableRetry = true,
    bool enableCache = false,
    bool enableNetworkStatusCheck = true,
  }) {
    _instance = ApiConfig._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: headers ?? {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      enableLogging: enableLogging,
      enableAuth: enableAuth,
      enableRetry: enableRetry,
      enableCache: enableCache,
      enableNetworkStatusCheck: enableNetworkStatusCheck,
    );
  }
  
  /// 快速环境配置 - 开发环境
  static void initDev() => init(
    baseUrl: 'http://127.0.0.1:8080',
    enableLogging: true,
    enableCache: true, // 开发环境启用缓存用于测试
  );
  
  /// 快速环境配置 - 生产环境
  static void initProd() => init(
    baseUrl: 'https://api.example.com/v1',
    enableLogging: false,
    enableCache: true, // 生产环境启用缓存提升性能
  );
  
  /// 快速环境配置 - 测试环境
  static void initTest() => init(
    baseUrl: 'https://test-api.example.com/v1',
    enableLogging: true,
    enableCache: false, // 测试环境禁用缓存确保数据准确性
  );
  
  /// 获取实例
  static ApiConfig get instance {
    if (_instance == null) {
      throw StateError('ApiConfig 未初始化，请先调用 ApiConfig.init() 或快速配置方法');
    }
    return _instance!;
  }
  
  /// 检查是否已初始化
  static bool get isInitialized => _instance != null;
  
  /// 重置配置（主要用于测试）
  static void reset() {
    _instance = null;
  }
}
