import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import 'api_config.dart';
import 'http_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/network_status_interceptor.dart';

/// 简洁的网络客户端
/// 
/// 直接封装 Dio，提供基础网络方法
/// 采用单例模式，全局唯一实例
/// 支持流式请求、文件上传下载、认证管理
class NetworkClient {
  static NetworkClient? _instance;
  late final Dio _dio;
  late final HttpClient _httpClient;
  
  /// 私有构造函数
  NetworkClient._() {
    _initDio();
    _httpClient = HttpClient(_dio);
  }
  
  /// 获取单例实例
  static NetworkClient get instance {
    _instance ??= NetworkClient._();
    return _instance!;
  }
  
  /// 获取HTTP客户端
  HttpClient get httpClient => _httpClient;
  
  /// 初始化 Dio
  void _initDio() {
    final config = ApiConfig.instance;
    
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: Duration(milliseconds: config.connectTimeout),
      receiveTimeout: Duration(milliseconds: config.receiveTimeout),
      headers: Map<String, dynamic>.from(config.headers),
    ));
    
    // 添加拦截器
    _setupInterceptors();
  }
  
  /// 配置拦截器
  void _setupInterceptors() {
    final config = ApiConfig.instance;
    
    // 清空现有拦截器
    _dio.interceptors.clear();
    
    // 1. 网络状态检查拦截器（最先执行）
    if (config.enableNetworkStatusCheck) {
      _dio.interceptors.add(NetworkStatusInterceptor());
    }
    
    // 2. 认证拦截器
    if (config.enableAuth) {
      _dio.interceptors.add(AuthInterceptor());
    }
    // 
   // 3. 缓存拦截器
    if (config.enableCache) {
      _dio.interceptors.add(CacheInterceptor());
    }
    
    // 4. 重试拦截器 - 传入当前的 Dio 实例
    if (config.enableRetry) {
      _dio.interceptors.add(RetryInterceptor(_dio));
    }
    
    // 5. 日志拦截器（最后执行，记录所有信息）
    if (config.enableLogging) {
      _dio.interceptors.add(LoggingInterceptor(showRequestData: true, showResponseData: true));
    }
  }
  
  // ==================== 拦截器管理 ====================
  
  /// 获取指定类型的拦截器
  T? getInterceptor<T extends Interceptor>() {
    for (final interceptor in _dio.interceptors) {
      if (interceptor is T) {
        return interceptor;
      }
    }
    return null;
  }
  
  /// 添加拦截器
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
  
  /// 移除指定类型的拦截器
  void removeInterceptor<T extends Interceptor>() {
    _dio.interceptors.removeWhere((interceptor) => interceptor is T);
  }
  
  // ==================== 特殊功能 ====================
  
  /// 流式请求（用于 AI 聊天等场景）
  Stream<String> postStream(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async* {
    try {
      final options = Options(
        headers: headers,
        responseType: ResponseType.stream,
      );
      
      // 如果指定了不同的 baseUrl，临时修改
      final originalBaseUrl = _dio.options.baseUrl;
      if (baseUrl != null) {
        _dio.options.baseUrl = baseUrl;
      }
      
      final response = await _dio.post<ResponseBody>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // 记录收到 response 的时机和 headers
      AppLogger.info('[postStream] 收到 response, status: '
          '${response.statusCode}, headers: ${response.headers.map}');
      AppLogger.info('[postStream] response.data is null? ${response.data == null}');
      
      // 恢复原始 baseUrl
      if (baseUrl != null) {
        _dio.options.baseUrl = originalBaseUrl;
      }
      
      if (response.data != null) {
        await for (final chunk in response.data!.stream.transform(
          StreamTransformer<Uint8List, String>.fromHandlers(
            handleData: (Uint8List data, EventSink<String> sink) {
              final chunkStr = utf8.decode(data);
              sink.add(chunkStr);
            },
          ),
        )) {
          yield chunk;
        }
      }
    } catch (e) {
      throw Exception('流式请求失败: $e');
    }
  }
  
  /// 文件下载
  Future<Response> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.download(
      urlPath,
      savePath,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
  
  /// 文件上传
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) {
    return _dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }
  
  // ==================== 认证管理 ====================
  
  /// 设置认证 Token
  void setAuthToken(String token) {
    final authInterceptor = getInterceptor<AuthInterceptor>();
    if (authInterceptor != null) {
      authInterceptor.setToken(token);
    } else {
      // 如果没有认证拦截器，直接设置到默认请求头
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
  
  /// 清除认证 Token
  void clearAuthToken() {
    final authInterceptor = getInterceptor<AuthInterceptor>();
    if (authInterceptor != null) {
      authInterceptor.clearToken();
    } else {
      // 如果没有认证拦截器，直接从默认请求头移除
      _dio.options.headers.remove('Authorization');
    }
  }
  
  // ==================== 配置管理 ====================
  
  /// 更新 Base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
  
  /// 更新请求头
  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }
  
  /// 获取原始 Dio 实例（用于高级用法）
  Dio get dio => _dio;
}
