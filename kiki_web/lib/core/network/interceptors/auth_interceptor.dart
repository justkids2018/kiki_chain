import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../logging/app_logger.dart';
import '../api_config.dart';
import '../../../presentation/controllers/auth_controller.dart';

/// 简化的认证拦截器
///
/// 自动添加Bearer Token到请求头
class AuthInterceptor extends Interceptor {
  String? _token;

  bool _isAuthEndpoint(String path) {
    final normalizedPath = path.toLowerCase();
    return normalizedPath.contains('/api/v1/auth/login') ||
        normalizedPath.contains('/api/v1/auth/register') ||
        normalizedPath.contains('/api/v1/auth/verify') ||
        normalizedPath.contains('/api/v1/auth/refresh-token') ||
        normalizedPath.contains('/api/v1/auth/logout');
  }

  /// 设置认证Token
  void setToken(String token) {
    _token = token;
    if (ApiConfig.instance.enableLogging) {
      AppLogger.info('🔑 设置认证Token');
    }
  }

  /// 清除认证Token
  void clearToken() {
    _token = null;
    if (ApiConfig.instance.enableLogging) {
      AppLogger.info('🔑 清除认证Token');
    }
  }

  /// 获取当前Token
  String? get currentToken => _token;

  /// 是否已设置Token
  bool get hasToken => _token != null && _token!.isNotEmpty;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skipAuth = options.headers.containsKey('Authorization') ||
        _isAuthEndpoint(options.path);
    if (!skipAuth && hasToken) {
      options.headers['Authorization'] = 'Bearer $_token';
    }

    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // 处理401未授权错误
    if (err.response?.statusCode == 401) {
      // 登录/注册等认证接口失败时，仅将错误交给上层展示 toast，不触发全局登出跳转。
      if (_isAuthEndpoint(err.requestOptions.path)) {
        handler.next(err);
        return;
      }

      if (ApiConfig.instance.enableLogging) {
        AppLogger.warning('🔑 认证失败，Token可能已过期');
      }
      clearToken();

      try {
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().logout();
        }
      } catch (e) {
        AppLogger.error('Failed to logout on 401', e);
      }
    }

    handler.next(err);
  }
}
