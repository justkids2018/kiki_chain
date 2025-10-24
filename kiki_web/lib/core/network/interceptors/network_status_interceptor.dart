import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../logging/app_logger.dart';
import '../network_exceptions.dart';

/// 简化的网络状态拦截器
/// 
/// 在发送请求前检查网络连接状态
class NetworkStatusInterceptor extends Interceptor {
  final Connectivity _connectivity = Connectivity();
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final isConnected = _isConnected(connectivityResults);
      
      if (!isConnected) {
        AppLogger.warning('📶 无网络连接');
        
        final networkError = NetworkException(
          message: '网络连接不可用，请检查网络设置',
          type: NetworkExceptionType.connectivity,
          statusCode: -1,
        );
        
        handler.reject(
          DioException(
            requestOptions: options,
            error: networkError,
            type: DioExceptionType.unknown,
          ),
        );
        return;
      }
    } catch (e) {
      AppLogger.error('📶 网络状态检查失败: $e');
    }
    
    handler.next(options);
  }
  
  /// 判断连接结果是否表示已连接
  bool _isConnected(List<ConnectivityResult> results) {
    // 如果列表中有任何一个连接类型表示已连接，就返回 true
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          return true;
        case ConnectivityResult.none:
        default:
          continue;
      }
    }
    return false;
  }
  
  /// 检查当前是否有网络连接
  Future<bool> isCurrentlyConnected() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }
}
