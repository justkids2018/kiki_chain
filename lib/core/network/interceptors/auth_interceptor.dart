import 'package:dio/dio.dart';
import '../../logging/app_logger.dart';
import '../api_config.dart';

/// 简化的认证拦截器
/// 
/// 自动添加Bearer Token到请求头
class AuthInterceptor extends Interceptor {
  String? _token;
  
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
    final skipAuth =options.headers.containsKey('Authorization');
    if (!skipAuth && hasToken) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // 处理401未授权错误
    if (err.response?.statusCode == 401) {
      if (ApiConfig.instance.enableLogging) {
        AppLogger.warning('🔑 认证失败，Token可能已过期');
      }
      clearToken();
    }
    
    handler.next(err);
  }
}
