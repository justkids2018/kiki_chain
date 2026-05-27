import 'package:flutter/services.dart';

/// 环境配置管理类
/// 支持多环境配置文件加载（dev.env, test.env, prod.env）
class EnvConfig {
  static final Map<String, String> _config = {};
  static bool _initialized = false;

  /// 当前环境类型 - 支持dart-define参数
  static const String _defaultEnv = 'dev';

  /// 获取当前环境类型
  /// 优先使用 dart-define 的 APP_ENV 参数，其次使用默认值
  static String get currentEnv {
    const envFromDefine = String.fromEnvironment('APP_ENV');
    if (envFromDefine.isNotEmpty) {
      // 映射 production -> prod, development -> dev
      switch (envFromDefine.toLowerCase()) {
        case 'production':
          return 'prod';
        case 'development':
          return 'dev';
        case 'testing':
          return 'test';
        default:
          return envFromDefine;
      }
    }
    return _defaultEnv;
  }

  /// 异步加载环境配置
  /// [env] 环境类型，如果不指定则使用 dart-define 的 APP_ENV 或默认值
  static Future<void> load([String? env]) async {
    if (_initialized) return;

    final environment = env ?? currentEnv;

    try {
      // 从 assets 加载环境配置文件
      final configContent =
          await rootBundle.loadString('config/$environment.env');
      _parseConfig(configContent);
    } catch (e) {
      // 如果指定环境文件不存在，尝试加载默认环境
      if (environment != _defaultEnv) {
        try {
          final defaultContent =
              await rootBundle.loadString('config/$_defaultEnv.env');
          _parseConfig(defaultContent);
        } catch (defaultError) {
          _setDefaultConfig();
        }
      } else {
        _setDefaultConfig();
      }
    }

    _initialized = true;
  }

  /// 解析配置文件内容
  static void _parseConfig(String content) {
    final lines = content.split('\n');

    for (String line in lines) {
      line = line.trim();

      // 跳过注释和空行
      if (line.isEmpty || line.startsWith('#')) continue;

      // 解析键值对
      final separatorIndex = line.indexOf('=');
      if (separatorIndex != -1) {
        final key = line.substring(0, separatorIndex).trim();
        final value = line.substring(separatorIndex + 1).trim();
        _config[key] = value;
      }
    }
  }

  /// 设置默认配置（当配置文件加载失败时使用）
  static void _setDefaultConfig() {
    _config.addAll({
      'ENV_TYPE': 'dev',
      'DEBUG': 'true',
      'ENABLE_LOGGING': 'true',
      'CONNECT_TIMEOUT': '30000',
      'RECEIVE_TIMEOUT': '30000',
      'SEND_TIMEOUT': '30000',
      'ENABLE_CACHE': 'true',
      'CACHE_EXPIRE_MINUTES': '5',
      'MAX_RETRY_COUNT': '3',
      'APP_NAME': '扎根理论',
      'DEFAULT_PAGE_SIZE': '20',
    });
    print('🔧 使用默认配置');
  }

  /// 获取字符串类型配置
  static String getString(String key, [String defaultValue = '']) {
    return _config[key] ?? defaultValue;
  }

  /// 获取整数类型配置
  static int getInt(String key, [int defaultValue = 0]) {
    final value = _config[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// 获取布尔类型配置
  static bool getBool(String key, [bool defaultValue = false]) {
    final value = _config[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// 获取双精度类型配置
  static double getDouble(String key, [double defaultValue = 0.0]) {
    final value = _config[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  // === 业务配置访问器 ===

  /// API基础URL
  static String get apiBaseUrl => getString('API_BASE_URL');

  /// 环境类型
  static String get envType => getString('ENV_TYPE', 'prod');

  /// 是否为调试模式
  static bool get isDebug => getBool('DEBUG', true);

  /// 是否开启日志
  static bool get enableLogging => getBool('ENABLE_LOGGING', true);

  /// 连接超时时间（毫秒）
  static int get connectTimeout => getInt('CONNECT_TIMEOUT', 30000);

  /// 接收超时时间（毫秒）
  static int get receiveTimeout => getInt('RECEIVE_TIMEOUT', 30000);

  /// 发送超时时间（毫秒）
  static int get sendTimeout => getInt('SEND_TIMEOUT', 30000);

  /// 是否开启缓存
  static bool get enableCache => getBool('ENABLE_CACHE', true);

  /// 缓存过期时间（分钟）
  static int get cacheExpireMinutes => getInt('CACHE_EXPIRE_MINUTES', 5);

  /// 最大重试次数
  static int get maxRetryCount => getInt('MAX_RETRY_COUNT', 3);

  /// 应用名称
  static String get appName => getString('APP_NAME', '奇奇漫游记');

  /// 默认分页大小
  static int get defaultPageSize => getInt('DEFAULT_PAGE_SIZE', 20);

  // === 环境判断 ===

  /// 是否为开发环境
  static bool get isDev => envType == 'dev';

  /// 是否为测试环境
  static bool get isTest => envType == 'test';

  /// 是否为生产环境
  static bool get isProd => envType == 'prod';

  // === 工具方法 ===

  /// 获取所有配置信息（调试用）
  static Map<String, String> getAllConfig() => Map.from(_config);

  /// 检查配置是否已初始化
  static bool get isInitialized => _initialized;

  /// 重新加载配置
  static Future<void> reload([String? env]) async {
    _initialized = false;
    _config.clear();
    await load(env);
  }
}
