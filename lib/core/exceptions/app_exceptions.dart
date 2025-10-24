/// API响应异常 - 统一的异常处理类
/// 
/// 用于处理所有类型的错误：
/// 1. 后端API返回的错误 {success: false, message: "错误信息"}
/// 2. 网络连接错误
/// 3. 认证错误
/// 4. 其他业务错误
class ApiResponseException implements Exception {
  /// 错误消息
  final String message;
  
  /// 是否为API响应（true=后端返回, false=前端产生）
  final bool isApiResponse;
  
  /// 错误代码
  final String? errorCode;
  
  /// HTTP状态码
  final int? statusCode;
  
  /// 响应数据
  final Map<String, dynamic>? responseData;
  
  /// 是否可重试
  final bool isRetryable;
  
  /// 是否需要重新认证
  final bool needsReauth;

  const ApiResponseException({
    required this.message,
    this.isApiResponse = false,
    this.errorCode,
    this.statusCode,
    this.responseData,
    this.isRetryable = false,
    this.needsReauth = false,
  });

  /// 从API响应创建异常
  factory ApiResponseException.fromResponse(Map<String, dynamic> response) {
    return ApiResponseException(
      message: response['message']?.toString() ?? '操作失败',
      isApiResponse: true,
      errorCode: response['errorcode']?.toString(),
      statusCode: response['errorcode'] is int ? response['errorcode'] : null,
      responseData: response,
      isRetryable: false,
      needsReauth: false,
    );
  }
  
  /// 创建网络连接异常
  factory ApiResponseException.networkError({
    String? message,
    bool isRetryable = true,
  }) {
    return ApiResponseException(
      message: message ?? '网络连接失败，请检查网络设置',
      isApiResponse: false,
      isRetryable: isRetryable,
      needsReauth: false,
    );
  }
  
  /// 创建超时异常
  factory ApiResponseException.timeout({
    String? message,
  }) {
    return ApiResponseException(
      message: message ?? '请求超时，请检查网络连接',
      isApiResponse: false,
      isRetryable: true,
      needsReauth: false,
    );
  }
  
  /// 创建认证异常
  factory ApiResponseException.unauthorized({
    String? message,
  }) {
    return ApiResponseException(
      message: message ?? '身份验证失败，请重新登录',
      isApiResponse: false,
      statusCode: 401,
      isRetryable: false,
      needsReauth: true,
    );
  }
  
  /// 创建服务器错误异常
  factory ApiResponseException.serverError({
    String? message,
    int? statusCode,
  }) {
    return ApiResponseException(
      message: message ?? '服务器暂时不可用，请稍后重试',
      isApiResponse: false,
      statusCode: statusCode ?? 500,
      isRetryable: true,
      needsReauth: false,
    );
  }
  
  /// 从HTTP状态码创建异常
  factory ApiResponseException.fromStatusCode(
    int statusCode, {
    String? message,
    Map<String, dynamic>? responseData,
  }) {
    String defaultMessage;
    bool isRetryable = false;
    bool needsReauth = false;
    
    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 400:
          defaultMessage = '请求参数错误';
          break;
        case 401:
          defaultMessage = '身份验证失败，请重新登录';
          needsReauth = true;
          break;
        case 403:
          defaultMessage = '没有权限访问此资源';
          break;
        case 404:
          defaultMessage = '请求的资源不存在';
          break;
        default:
          defaultMessage = '客户端请求错误';
      }
    } else if (statusCode >= 500) {
      defaultMessage = '服务器暂时不可用，请稍后重试';
      isRetryable = true;
    } else {
      defaultMessage = '请求失败 (状态码: $statusCode)';
    }
    
    return ApiResponseException(
      message: message ?? defaultMessage,
      isApiResponse: false,
      statusCode: statusCode,
      responseData: responseData,
      isRetryable: isRetryable,
      needsReauth: needsReauth,
    );
  }
  
  /// 从其他异常创建
  factory ApiResponseException.fromError(dynamic error) {
    if (error is ApiResponseException) {
      return error;
    }
    
    String message = error.toString();
    bool isRetryable = false;
    
    // 判断是否为网络错误
    if (message.contains('网络') || 
        message.contains('connection') || 
        message.contains('timeout') ||
        message.contains('SocketException')) {
      isRetryable = true;
      message = '网络连接失败，请检查网络设置';
    }
    
    return ApiResponseException(
      message: message,
      isApiResponse: false,
      isRetryable: isRetryable,
      needsReauth: false,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('ApiResponseException: $message');
    
    if (statusCode != null) {
      buffer.write(' (状态码: $statusCode)');
    }
    
    if (errorCode != null) {
      buffer.write(' (错误码: $errorCode)');
    }
    
    if (isApiResponse) {
      buffer.write(' [API响应]');
    }
    
    return buffer.toString();
  }
  
  /// 转换为Map格式
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isApiResponse': isApiResponse,
      'errorCode': errorCode,
      'statusCode': statusCode,
      'responseData': responseData,
      'isRetryable': isRetryable,
      'needsReauth': needsReauth,
    };
  }
}
