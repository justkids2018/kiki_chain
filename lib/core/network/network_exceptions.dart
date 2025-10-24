/// 网络异常类型枚举
enum NetworkExceptionType {
  /// 连接超时
  timeout,
  /// 网络连接问题
  connectivity,
  /// 服务器错误
  serverError,
  /// 客户端错误
  clientError,
  /// 认证错误
  unauthorized,
  /// 禁止访问
  forbidden,
  /// 资源未找到
  notFound,
  /// 请求格式错误
  badRequest,
  /// 未知错误
  unknown,
}

/// 网络异常类
/// 
/// 统一的网络请求异常处理
class NetworkException implements Exception {
  /// 错误消息
  final String message;
  
  /// 异常类型
  final NetworkExceptionType type;
  
  /// HTTP状态码
  final int? statusCode;
  
  /// 原始错误对象
  final dynamic originalError;
  
  /// 错误详情
  final Map<String, dynamic>? details;
  
  /// 创建网络异常
  const NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
    this.details,
  });
  
  /// 从HTTP状态码创建异常
  factory NetworkException.fromStatusCode(
    int statusCode, {
    String? message,
    dynamic originalError,
    Map<String, dynamic>? details,
  }) {
    final type = _getTypeFromStatusCode(statusCode);
    final defaultMessage = _getDefaultMessage(type, statusCode);
    
    return NetworkException(
      message: message ?? defaultMessage,
      type: type,
      statusCode: statusCode,
      originalError: originalError,
      details: details,
    );
  }
  
  /// 创建连接超时异常
  factory NetworkException.timeout({
    String? message,
    dynamic originalError,
  }) {
    return NetworkException(
      message: message ?? '请求超时，请检查网络连接',
      type: NetworkExceptionType.timeout,
      originalError: originalError,
    );
  }
  
  /// 创建网络连接异常
  factory NetworkException.connectivity({
    String? message,
    dynamic originalError,
  }) {
    return NetworkException(
      message: message ?? '网络连接失败，请检查网络设置',
      type: NetworkExceptionType.connectivity,
      originalError: originalError,
    );
  }
  
  /// 创建服务器错误异常
  factory NetworkException.serverError({
    String? message,
    int? statusCode,
    dynamic originalError,
    Map<String, dynamic>? details,
  }) {
    return NetworkException(
      message: message ?? '服务器暂时不可用，请稍后重试',
      type: NetworkExceptionType.serverError,
      statusCode: statusCode,
      originalError: originalError,
      details: details,
    );
  }
  
  /// 创建未授权异常
  factory NetworkException.unauthorized({
    String? message,
    dynamic originalError,
  }) {
    return NetworkException(
      message: message ?? '身份验证失败，请重新登录',
      type: NetworkExceptionType.unauthorized,
      statusCode: 401,
      originalError: originalError,
    );
  }
  
  /// 创建禁止访问异常
  factory NetworkException.forbidden({
    String? message,
    dynamic originalError,
  }) {
    return NetworkException(
      message: message ?? '没有权限访问此资源',
      type: NetworkExceptionType.forbidden,
      statusCode: 403,
      originalError: originalError,
    );
  }
  
  /// 创建资源未找到异常
  factory NetworkException.notFound({
    String? message,
    dynamic originalError,
  }) {
    return NetworkException(
      message: message ?? '请求的资源不存在',
      type: NetworkExceptionType.notFound,
      statusCode: 404,
      originalError: originalError,
    );
  }
  
  /// 创建未知异常
  factory NetworkException.unknown({
    String? message,
    dynamic originalError,
    Map<String, dynamic>? details,
  }) {
    return NetworkException(
      message: message ?? '网络请求失败，请重试',
      type: NetworkExceptionType.unknown,
      originalError: originalError,
      details: details,
    );
  }
  
  /// 根据状态码获取异常类型
  static NetworkExceptionType _getTypeFromStatusCode(int statusCode) {
    if (statusCode >= 400 && statusCode < 500) {
      switch (statusCode) {
        case 400:
          return NetworkExceptionType.badRequest;
        case 401:
          return NetworkExceptionType.unauthorized;
        case 403:
          return NetworkExceptionType.forbidden;
        case 404:
          return NetworkExceptionType.notFound;
        default:
          return NetworkExceptionType.clientError;
      }
    } else if (statusCode >= 500) {
      return NetworkExceptionType.serverError;
    } else {
      return NetworkExceptionType.unknown;
    }
  }
  
  /// 获取默认错误消息
  static String _getDefaultMessage(NetworkExceptionType type, int? statusCode) {
    switch (type) {
      case NetworkExceptionType.timeout:
        return '请求超时，请检查网络连接';
      case NetworkExceptionType.connectivity:
        return '网络连接失败，请检查网络设置';
      case NetworkExceptionType.serverError:
        return '服务器暂时不可用，请稍后重试';
      case NetworkExceptionType.unauthorized:
        return '身份验证失败，请重新登录';
      case NetworkExceptionType.forbidden:
        return '没有权限访问此资源';
      case NetworkExceptionType.notFound:
        return '请求的资源不存在';
      case NetworkExceptionType.badRequest:
        return '请求参数错误';
      case NetworkExceptionType.clientError:
        return '客户端请求错误';
      case NetworkExceptionType.unknown:
        return statusCode != null ? '请求失败 (状态码: $statusCode)' : '网络请求失败，请重试';
    }
  }
  
  /// 是否为可重试的错误
  bool get isRetryable {
    switch (type) {
      case NetworkExceptionType.timeout:
      case NetworkExceptionType.connectivity:
      case NetworkExceptionType.serverError:
        return true;
      case NetworkExceptionType.unauthorized:
      case NetworkExceptionType.forbidden:
      case NetworkExceptionType.notFound:
      case NetworkExceptionType.badRequest:
      case NetworkExceptionType.clientError:
        return false;
      case NetworkExceptionType.unknown:
        // 对于未知错误，如果有状态码且为5xx，则可重试
        return statusCode != null && statusCode! >= 500;
    }
  }
  
  /// 是否需要重新认证
  bool get needsReauth {
    return type == NetworkExceptionType.unauthorized;
  }
  
  @override
  String toString() {
    final buffer = StringBuffer('NetworkException: $message');
    
    if (statusCode != null) {
      buffer.write(' (状态码: $statusCode)');
    }
    
    buffer.write(' [类型: ${type.name}]');
    
    if (details != null && details!.isNotEmpty) {
      buffer.write(' 详情: $details');
    }
    
    return buffer.toString();
  }
  
  /// 转换为Map格式
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type.name,
      'statusCode': statusCode,
      'details': details,
      'isRetryable': isRetryable,
      'needsReauth': needsReauth,
    };
  }
}
