import 'package:logger/logger.dart';
import '../config/env_config.dart';

/// 应用程序日志管理器
/// 支持环境感知：生产环境下自动禁用日志输出
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// 检查是否应该输出日志
  /// 生产环境下禁用日志，开发和测试环境启用
  static bool get _shouldLog {
    // 如果环境配置未初始化，默认允许日志输出（开发阶段）
    if (!EnvConfig.isInitialized) return true;
    
    // 生产环境禁用日志，开发和测试环境启用
    return !EnvConfig.isProd && EnvConfig.enableLogging;
  }

  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog) return;
    _logger.v(message, error, stackTrace);
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog) return;
    _logger.d(message, error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog) return;
    _logger.i(message, error, stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog) return;
    _logger.w(message, error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog) return;
    _logger.e(message, error, stackTrace);
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog) return;
    _logger.wtf(message, error, stackTrace);
  }

  // === 工具方法 ===

  /// 获取当前日志状态
  static bool get isEnabled => _shouldLog;

  /// 获取当前环境信息
  static String get environmentInfo {
    if (!EnvConfig.isInitialized) return 'Environment not initialized';
    return 'Environment: ${EnvConfig.envType}, Logging: ${EnvConfig.enableLogging ? 'enabled' : 'disabled'}';
  }

  /// 强制输出一条日志（忽略环境设置，用于重要信息）
  static void forceLog(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('[FORCE LOG] $message', error, stackTrace);
  }
}


