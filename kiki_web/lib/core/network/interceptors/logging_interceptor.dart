import 'package:dio/dio.dart';
import '../../logging/app_logger.dart';
import '../api_config.dart';

/// 简化的日志拦截器
///
/// 记录请求和响应的基本信息
class LoggingInterceptor extends Interceptor {
  final bool showRequestData;
  final bool showResponseData;

  LoggingInterceptor({
    this.showRequestData = true,
    this.showResponseData = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConfig.instance.enableLogging) {
      AppLogger.info('📤 ${options.method} ${options.uri}');
      AppLogger.debug('🌐 Host: ${options.uri.host}:${options.uri.port}');
      AppLogger.debug('📍 Path: ${options.uri.path}');

      //head bian 遍历 放到日志里
      var head="";
      options.headers.forEach((key, value) {
          head=head+('$key: $value\n');
      });
      AppLogger.debug('Request Header: $head');
      if (showRequestData && options.data != null) {
        AppLogger.debug('Request Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        AppLogger.debug('Query Params: ${options.queryParameters}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (ApiConfig.instance.enableLogging) {
      final statusCode = response.statusCode ?? 0;
      final uri = response.requestOptions.uri;

      if (statusCode >= 200 && statusCode < 300) {
        AppLogger.info('📥 $statusCode ${response.requestOptions.method} $uri');
      } else {
        AppLogger.warning(
            '📥 $statusCode ${response.requestOptions.method} $uri');
      }

      if (showResponseData && response.data != null) {
        AppLogger.info('Response Data: ${response.data.toString()}');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.instance.enableLogging) {
      final statusCode = err.response?.statusCode ?? 'Unknown';
      final uri = err.requestOptions.uri;

      AppLogger.error('❌ $statusCode ${err.requestOptions.method} $uri');
      AppLogger.error('🌐 Host: ${uri.host}:${uri.port}');
      AppLogger.error('📍 Path: ${uri.path}');
      AppLogger.error('🔴 Error Type: ${err.type}');
      AppLogger.error('🔴 Error Message: ${err.message}');

      if (err.response != null) {
        AppLogger.error('Response Status: ${err.response?.statusCode}');
        AppLogger.error('Response Data: ${err.response?.data}');
      }

      // 打印堆栈跟踪以便调试
      if (err.stackTrace != null) {
        AppLogger.error('Stack Trace: ${err.stackTrace}');
      }
    }

    handler.next(err);
  }
}
