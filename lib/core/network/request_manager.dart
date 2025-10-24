import 'package:dio/dio.dart';
import 'network_client.dart';
import 'http_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/cache_interceptor.dart';

/// 请求管理器 - 业务层统一入口
/// 
/// 提供简化的业务方法，直接返回数据或抛出异常
/// 统一的错误处理，转换为用户友好的错误消息
/// 支持所有常用 HTTP 方法和特殊功能
class RequestManager {
  static RequestManager? _instance;
  late final HttpClient _httpClient;
  
  /// 私有构造函数
  RequestManager._() {
    _httpClient = NetworkClient.instance.httpClient;
  }
  
  /// 获取单例实例
  static RequestManager get instance {
    _instance ??= RequestManager._();
    return _instance!;
  }
  
  /// 重置实例（主要用于测试）
  static void reset() {
    _instance = null;
  }
  
  // ==================== 基础HTTP方法 ====================
  
  /// GET 请求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _httpClient.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
  
  /// POST 请求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _httpClient.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
  
  /// PUT 请求
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _httpClient.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
  
  /// DELETE 请求
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _httpClient.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  /// PATCH 请求
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _httpClient.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
  
  // ==================== 文件操作 ====================
  
  /// 上传文件
  Future<T> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    return await _httpClient.upload<T>(
      path,
      formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }
  
  /// 下载文件
  Future<void> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _httpClient.download(
      urlPath,
      savePath,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
  
  // ==================== 认证管理 ====================
  
  /// 设置认证Token
  void setAuthToken(String token) {
    NetworkClient.instance.setAuthToken(token);
  }
  
  /// 清除认证Token
  void clearAuthToken() {
    final authInterceptor = NetworkClient.instance.getInterceptor<AuthInterceptor>();
    authInterceptor?.clearToken();
  }
  
  /// 清除所有缓存
  void clearCache() {
    final cacheInterceptor = NetworkClient.instance.getInterceptor<CacheInterceptor>();
    cacheInterceptor?.clearAllCache();
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic>? getCacheStats() {
    final cacheInterceptor = NetworkClient.instance.getInterceptor<CacheInterceptor>();
    return cacheInterceptor?.getCacheStats();
  }
  
  /// 创建取消令牌
  CancelToken createCancelToken() {
    return CancelToken();
  }
  
  /// 创建表单数据
  FormData createFormData(Map<String, dynamic> fields) {
    return FormData.fromMap(fields);
  }

   /// 流式 POST 请求（如 AI 聊天场景）
 Stream<String> postStream(
   String path, {
   dynamic data,
   Map<String, dynamic>? queryParameters,
   String? baseUrl,
   Map<String, String>? headers,
   CancelToken? cancelToken,
 }) {
   return NetworkClient.instance.postStream(
     path,
     data: data,
     queryParameters: queryParameters,
     baseUrl: baseUrl,
     headers: headers,
     cancelToken: cancelToken,
   );
 }
}
