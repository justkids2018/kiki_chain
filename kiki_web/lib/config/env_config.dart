/// 环境配置
///
/// 管理应用运行环境（开发/测试/生产）和 Mock 模式切换

enum AppEnvironment {
  /// 开发环境 (Mock 数据)
  development,

  /// 测试环境 (真实 API - 测试服务器)
  testing,

  /// 生产环境 (真实 API - 生产服务器)
  production,
}

class EnvConfig {
  static AppEnvironment _currentEnv = AppEnvironment.development;

  /// 是否使用 Mock 数据（开发阶段使用）
  static bool _useMock = false;

  /// 获取当前环境
  static AppEnvironment get currentEnv => _currentEnv;

  /// 是否使用 Mock 数据
  static bool get useMock => _useMock;

  /// 是否是开发环境
  static bool get isDevelopment => _currentEnv == AppEnvironment.development;

  /// 是否是测试环境
  static bool get isTesting => _currentEnv == AppEnvironment.testing;

  /// 是否是生产环境
  static bool get isProduction => _currentEnv == AppEnvironment.production;

  /// 设置环境
  static void setEnvironment(AppEnvironment env) {
    _currentEnv = env;
  }

  /// 切换 Mock 模式
  ///
  /// [enabled] true=使用Mock数据, false=使用真实API
  static void setMockMode(bool enabled) {
    _useMock = enabled;
  }

  /// 获取 API Base URL
  static String get apiBaseUrl {
    // 如果使用 Mock，返回空字符串（不需要真实 URL）
    if (_useMock) {
      return '';
    }

    // 根据环境返回对应的 API 地址
    switch (_currentEnv) {
      case AppEnvironment.development:
        return 'http://127.0.0.1:8080/api';
      case AppEnvironment.testing:
        return 'https://test-api.hikiki.com/api';
      case AppEnvironment.production:
        return 'https://api.hikiki.com/api';
    }
  }

  /// 环境配置说明
  static String get envDescription {
    final mockStatus = _useMock ? 'Mock模式' : '真实API';
    return '${_currentEnv.name} - $mockStatus';
  }

  /// 初始化为开发环境（Mock模式）
  static void initDevelopment() {
    _currentEnv = AppEnvironment.development;
    _useMock = true;
  }

  /// 初始化为测试环境（真实API）
  static void initTesting() {
    _currentEnv = AppEnvironment.testing;
    _useMock = false;
  }

  /// 初始化为生产环境（真实API）
  static void initProduction() {
    _currentEnv = AppEnvironment.production;
    _useMock = false;
  }
}
