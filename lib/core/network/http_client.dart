import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import 'api_config.dart';
import '../exceptions/app_exceptions.dart';

/// HTTP 客户端
/// 
/// 封装 Dio 的底层操作，提供统一的HTTP请求接口
/// 负责网络请求的具体实现，与业务逻辑完全解耦
class HttpClient {
  final Dio _dio;
  
  /// 创建HTTP客户端
  HttpClient(this._dio);
  
  /// 执行GET请求
  /// 
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  /// [onReceiveProgress] 接收进度回调
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 执行POST请求
  /// 
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  /// [onSendProgress] 发送进度回调
  /// [onReceiveProgress] 接收进度回调
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 执行PUT请求
  /// 
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  /// [onSendProgress] 发送进度回调
  /// [onReceiveProgress] 接收进度回调
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 执行DELETE请求
  /// 
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 执行PATCH请求
  /// 
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  /// [onSendProgress] 发送进度回调
  /// [onReceiveProgress] 接收进度回调
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 上传文件
  /// 
  /// [path] 请求路径
  /// [formData] 表单数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  /// [onSendProgress] 发送进度回调
  Future<T> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 下载文件
  /// 
  /// [urlPath] 下载URL
  /// [savePath] 保存路径
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// [cancelToken] 取消令牌
  /// [onReceiveProgress] 接收进度回调
  Future<void> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      if (ApiConfig.instance.enableLogging) {
        AppLogger.info('📥 文件下载完成: $savePath');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 处理响应数据
  T _handleResponse<T>(Response<T> response) {
    if (response.data != null) {
      if (ApiConfig.instance.enableLogging) {
        AppLogger.debug('✅ 请求成功: ${response.requestOptions.uri}');
      }
      return response.data!;
    } else {
      throw ApiResponseException.serverError(
        message: '响应数据为空',
        statusCode: response.statusCode,
      );
    }
  }
  
  /// 处理请求错误
  ApiResponseException _handleError(DioException error) {
    if (ApiConfig.instance.enableLogging) {
      AppLogger.error('❌ 请求失败: ${error.requestOptions.uri} - ${error.message}');
    }
    
    // 如果错误已经被拦截器处理过，直接使用
    if (error.error is ApiResponseException) {
      return error.error as ApiResponseException;
    }
    
    // 根据错误类型创建相应的网络异常
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponseException.timeout(
          message: '请求超时，请检查网络连接',
        );
      
      case DioExceptionType.unknown:
        return ApiResponseException.networkError(
          message: '网络连接失败，请检查网络设置',
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          // 提取后端返回的错误详情
          Map<String, dynamic>? errorDetails;
          String? errorMessage;
          
          if (error.response?.data is Map<String, dynamic>) {
            errorDetails = error.response?.data as Map<String, dynamic>;
            
            // 优先使用后端返回的 message 字段
            if (errorDetails['message'] != null) {
              errorMessage = errorDetails['message'].toString();
            }
          }
          
          return ApiResponseException.fromStatusCode(
            statusCode,
            message: errorMessage ?? error.response?.statusMessage ?? '请求失败',
            responseData: errorDetails,
          );
        }
        return ApiResponseException.serverError(
          message: error.message ?? '服务器错误',
        );
      
      case DioExceptionType.cancel:
        return ApiResponseException.networkError(
          message: '请求已取消',
        );
      
      default:
        return ApiResponseException.serverError(
          message: error.message ?? '未知错误',
        );
    }
  }
  
  /// 获取原始Dio实例（谨慎使用）
  Dio get rawDio => _dio;
}
