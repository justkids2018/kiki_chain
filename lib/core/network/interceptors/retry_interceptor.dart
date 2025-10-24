import 'package:dio/dio.dart';
import '../../logging/app_logger.dart';
import '../api_config.dart';

/// 简化的重试拦截器
/// 
/// 网络错误时自动重试，最多3次
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Dio _dio;

  RetryInterceptor(this._dio, {this.maxRetries = 3});

  /// 创建保守重试拦截器
  factory RetryInterceptor.conservative(Dio dio) => RetryInterceptor(dio, maxRetries: 2);

  /// 创建激进重试拦截器
  factory RetryInterceptor.aggressive(Dio dio) => RetryInterceptor(dio, maxRetries: 5);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = _getRetryCount(err.requestOptions);
    
    // 检查是否应该重试
    if (_shouldRetry(err) && retryCount < maxRetries) {
      final nextRetryCount = retryCount + 1;
      err.requestOptions.extra['retry_count'] = nextRetryCount;
      
      if (ApiConfig.instance.enableLogging) {
        AppLogger.warning('🔄 重试请求 $nextRetryCount/$maxRetries: ${err.requestOptions.uri}');
      }
      
      // 根据重试次数递增等待时间
      final waitTime = Duration(seconds: nextRetryCount);
      await Future.delayed(waitTime);

      try {
        // 使用传入的 dio 实例进行重试，而不是创建新的实例
        final response = await _dio.fetch(err.requestOptions);
        if (ApiConfig.instance.enableLogging) {
          AppLogger.info('✅ 重试成功: ${err.requestOptions.uri}');
        }
        handler.resolve(response);
      } catch (e) {
        if (ApiConfig.instance.enableLogging) {
          AppLogger.error('❌ 重试失败: $e');
        }

        // 如果是最后一次重试失败，提供友好的错误信息
        if (nextRetryCount >= maxRetries) {
          _handleFinalError(err, handler);
        } else {
          handler.next(err);
        }
      }
    } else {
      _handleFinalError(err, handler);
    }
  }
  
  /// 判断是否应该重试
  bool _shouldRetry(DioException error) {
    // 只重试网络相关错误
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badResponse:
        // 服务器错误才重试
        return error.response?.statusCode != null && 
               error.response!.statusCode! >= 500;
      default:
        return false;
    }
  }
  
  /// 获取当前重试次数
  int _getRetryCount(RequestOptions options) {
    return options.extra['retry_count'] ?? 0;
  }

  /// 处理最终错误
  void _handleFinalError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.instance.enableLogging) {
      AppLogger.error('❌ 最终重试失败: ${err.requestOptions.uri}');
    }

    // 可以在这里添加友好的错误提示逻辑
    handler.next(err);
  }
}
