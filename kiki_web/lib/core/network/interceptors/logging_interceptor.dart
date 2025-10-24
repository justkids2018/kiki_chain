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
      //head bian 遍历 放到日志里
      var head="";
      options.headers.forEach((key, value) {
          head=head+('$key: $value\n');
      });
      AppLogger.debug('Request Header: $head');
      if (showRequestData && options.data != null) {
        AppLogger.debug('Request : ${options.data}');
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
      AppLogger.error(
          '❌ $statusCode ${err.requestOptions.method} ${err.requestOptions.uri}');
      AppLogger.error('Error: ${err.message}');
    }

    handler.next(err);
  }
}
