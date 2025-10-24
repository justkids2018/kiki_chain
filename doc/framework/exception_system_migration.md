# 统一异常体系迁移指南

## 🎯 统一后的异常体系

我们已经将所有异常统一到 `lib/core/exceptions/app_exceptions.dart` 中，包括：

### 1. **基础异常类**
```dart
AppException // 所有异常的基类
```

### 2. **API相关异常**
```dart
ApiResponseException // 处理后端API响应 {success: false, message: "错误信息"}
```

### 3. **网络相关异常**
```dart
NetworkException // 处理网络连接、超时、HTTP状态码等错误
```

### 4. **其他业务异常**
```dart
AuthException      // 认证相关
ValidationException // 验证相关  
ServerException    // 服务器相关
CacheException     // 缓存相关
```

## 🔧 核心工具类

### ApiResponseHandler
统一处理后端API响应格式：
```dart
// 成功时自动提取data，失败时抛出ApiResponseException
final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);

// 安全处理，返回结果对象而不抛出异常
final result = ApiResponseHandler.handleSafe<User>(response);
if (result.isSuccess) {
  final user = result.data;
} else {
  print('错误: ${result.message}');
}
```

## 📝 使用示例

### Repository层
```dart
Future<User> login(String identifier, String password) async {
  try {
    final response = await _requestManager.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: {'identifier': identifier, 'password': password},
    );
    
    // 使用ApiResponseHandler自动处理响应
    final data = ApiResponseHandler.handle<Map<String, dynamic>>(response);
    
    // 处理成功的业务逻辑
    return _createUserFromData(data);
    
  } on ApiResponseException {
    // API响应异常直接重新抛出（包含后端错误信息）
    rethrow;
  } catch (e) {
    // 其他异常转换为NetworkException
    throw ApiResponseHandler.createNetworkException(e);
  }
}
```

### Controller层
```dart
Future<bool> login() async {
  try {
    final user = await _authRepository.login(identifier, password);
    // 处理成功逻辑
    return true;
    
  } on ApiResponseException catch (e) {
    // 处理API响应异常（后端返回的错误信息）
    EasyLoading.showError(e.message); // 显示 "师生关系已存在" 等具体错误
    return false;
    
  } on NetworkException catch (e) {
    // 处理网络异常
    if (e.needsReauth) {
      // 需要重新认证
      _redirectToLogin();
    } else if (e.isRetryable) {
      // 可重试的错误
      EasyLoading.showError('${e.message}，请稍后重试');
    } else {
      EasyLoading.showError(e.message);
    }
    return false;
    
  } catch (e) {
    // 处理其他未知异常
    EasyLoading.showError('操作失败，请重试');
    return false;
  }
}
```

## 🚀 优势总结

### 1. **统一性**
- 所有异常都继承自 `AppException`
- 统一的错误处理机制
- 一致的API设计

### 2. **语义明确**
- `ApiResponseException`: 后端API返回的错误
- `NetworkException`: 网络层面的错误
- 每个异常都有明确的使用场景

### 3. **功能丰富**
- `NetworkException.isRetryable`: 判断是否可重试
- `NetworkException.needsReauth`: 判断是否需要重新认证
- `ApiResponseException.fromResponse()`: 从后端响应自动创建异常

### 4. **类型安全**
- 编译时类型检查
- 具体的异常类型便于处理
- 完整的错误信息传递

### 5. **易于调试**
- 完整的调用栈信息
- 结构化的错误详情
- 统一的toString()格式

## 📋 迁移检查清单

- ✅ 统一异常体系到 `app_exceptions.dart`
- ✅ 创建 `ApiResponseHandler` 工具类
- ✅ 更新 `AuthRepository` 使用新异常体系
- ✅ 更新 `AuthController` 使用新异常处理
- ✅ 移除旧的 `network_exceptions.dart` 依赖（如需要）

现在整个项目使用统一的异常体系，无论是登录、注册还是其他API调用，都能：
- 🎯 准确显示后端返回的错误信息（如"师生关系已存在"）
- 🔧 自动处理网络层错误
- 🚀 提供类型安全的错误处理机制