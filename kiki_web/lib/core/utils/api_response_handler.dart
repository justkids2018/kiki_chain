import '../exceptions/app_exceptions.dart';

/// API响应处理器
/// 
/// 用于处理后端统一的响应格式：
/// ```json
/// {
///   "success": true/false,
///   "data": { ... },
///   "message": "操作结果消息",
///   "errorcode": 200 (可选)
/// }
/// ```
class ApiResponseHandler {
  /// 处理API响应，成功时返回数据，失败时抛出异常
  /// 
  /// 参数:
  /// - [response] API响应数据
  /// 
  /// 返回:
  /// - [T] 成功时返回data字段的数据
  /// 
  /// 异常:
  /// - [ApiResponseException] 当success为false时抛出
  static T handle<T>(Map<String, dynamic> response) {
    final success = response['success'] ?? false;
    
    if (success) {
      // 成功情况：返回data字段
      final data = response['data'];
      if (data is T) {
        return data;
      }
      // 如果T是动态类型或data匹配T类型，直接返回
      if (T == dynamic || data is T) {
        return data as T;
      }
      // 如果data为null但T是可空类型，返回null
      if (data == null) {
        return null as T;
      }
      
      throw ApiResponseException(
        message: '响应数据格式错误，期望类型: $T，实际类型: ${data.runtimeType}',
        isApiResponse: true,
        responseData: response,
      );
    } else {
      // 失败情况：抛出异常
      throw ApiResponseException.fromResponse(response);
    }
  }
  
  /// 处理API响应，返回结果对象而不是抛出异常
  static ApiResult<T> handleSafe<T>(Map<String, dynamic> response) {
    try {
      final data = handle<T>(response);
      return ApiResult.success(data, getMessage(response));
    } on ApiResponseException catch (e) {
      return ApiResult.failure(e.message, e.errorCode, e.responseData);
    } catch (e) {
      return ApiResult.failure(e.toString(), null, null);
    }
  }
  
  /// 检查响应是否成功
  static bool isSuccess(Map<String, dynamic> response) {
    return response['success'] ?? false;
  }
  
  /// 获取响应消息
  static String getMessage(Map<String, dynamic> response) {
    return response['message']?.toString() ?? (isSuccess(response) ? '操作成功' : '操作失败');
  }
  
  /// 获取响应数据
  static T? getData<T>(Map<String, dynamic> response) {
    if (!isSuccess(response)) {
      return null;
    }
    final data = response['data'];
    return data is T ? data : null;
  }
  
  /// 获取错误码
  static String? getErrorCode(Map<String, dynamic> response) {
    return response['errorcode']?.toString();
  }
  
  /// 从任何异常创建统一的ApiResponseException
  static ApiResponseException createException(dynamic error) {
    return ApiResponseException.fromError(error);
  }
}

/// API响应结果包装类
class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? details;
  
  const ApiResult._({
    required this.isSuccess,
    this.data,
    required this.message,
    this.errorCode,
    this.details,
  });
  
  /// 创建成功结果
  factory ApiResult.success(T data, [String? message]) {
    return ApiResult._(
      isSuccess: true,
      data: data,
      message: message ?? '操作成功',
    );
  }
  
  /// 创建失败结果
  factory ApiResult.failure(String message, [String? errorCode, Map<String, dynamic>? details]) {
    return ApiResult._(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
      details: details,
    );
  }
  
  /// 是否为失败结果
  bool get isFailure => !isSuccess;
  
  /// 获取数据，如果失败则抛出异常
  T get dataOrThrow {
    if (isSuccess) {
      return data as T;
    }
    throw ApiResponseException(
      message: message,
      isApiResponse: false,
      errorCode: errorCode,
      responseData: details,
    );
  }
  
  /// 安全获取数据，如果失败则返回null
  T? get dataOrNull => isSuccess ? data : null;
}