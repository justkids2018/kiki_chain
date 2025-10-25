# AuthRepository 架构优化方案

**日期**: 2025-10-25
**目录**: doc/framework/auth_repository_架构优化_20251025.md

---

## 🎯 优化目标
- 保持现有单例依赖结构（如`RequestManager.instance`、`AppServices.instance.localStorage`），不做构造参数注入
- 只做接口分离、命名规范和依赖倒置，不引入多余复杂度
- 兼容现有业务逻辑，平滑迁移

---

## 🏗️ 分步实现方案

### 步骤1：定义接口（Domain层）
- 路径：`lib/domain/repositories/i_auth_repository.dart`
- 只定义接口，方法与现有实现一一对应
- 示例：
```dart
abstract class IAuthRepository {
  Future<User?> login(String identifier, String password);
  Future<User?> register(String username, int roleId, String password, String phone);
  Future<bool> logout();
  Future<bool> checkServerHealth();
  Future<User?> getCurrentUser();
  Future<User?> updateUserInfo(Map<String, dynamic> userData);
  Future<bool> isLoggedIn();
  Future<String?> refreshAccessToken(String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearAuthData();
}
```

### 步骤2：实现接口（Data层）
- 路径：`lib/data/repositories/auth_repository_impl.dart`
- `AuthRepositoryImpl implements IAuthRepository`
- 内部依赖依然用`.instance`单例，不做构造注入
- 逻辑与现有`AuthRepository`完全一致，只是implements接口、命名规范
- 示例：
```dart
class AuthRepositoryImpl implements IAuthRepository {
  final RequestManager _requestManager = RequestManager.instance;
  get _localStorage => AppServices.instance.localStorage;
  // ...existing code...
}
```

### 步骤3：依赖管理（Core层）
- 路径：`lib/core/di/service_locator.dart`
- 提供`IAuthRepository`的单例获取方法（直接`new AuthRepositoryImpl()`，无参数）
- 支持`setAuthRepository(Mock)`替换，便于测试
- 示例：
```dart
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._();
  ServiceLocator._();
  IAuthRepository? _authRepository;
  IAuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl();
    return _authRepository!;
  }
  void setAuthRepository(IAuthRepository repo) => _authRepository = repo;
  void reset() => _authRepository = null;
}
```

### 步骤4：Controller依赖接口
- 路径：`lib/presentation/controllers/auth_controller.dart`
- 依赖`IAuthRepository`，默认用ServiceLocator提供的单例
- 支持构造注入（可选，便于测试）
- 示例：
```dart
class AuthController extends GetxController {
  final IAuthRepository _authRepository;
  AuthController({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? ServiceLocator.instance.authRepository;
  // ...existing code...
}
```

### 步骤5：测试与兼容
- 保证所有调用点平滑迁移，功能不变
- 可选：为接口和实现加简单单元测试模板

---

## 📋 关键原则
- 依赖倒置：Controller/业务层只依赖接口，不依赖具体实现
- 单例依赖：所有依赖均通过`.instance`获取，保持全局唯一
- 代码简洁：不引入多余参数和复杂注入逻辑
- 可测试性：ServiceLocator支持Mock替换，便于单元测试
- 渐进式迁移：每步可独立完成，兼容老代码

---

## 🚦 适用场景
- 适用于需要Clean Architecture分层、但又追求极简依赖管理的Flutter项目
- 适合团队协作、AI自动化开发、后续平滑扩展

---

## 📝 示例代码片段

### 1. 接口定义
```dart
abstract class IAuthRepository {
  Future<User?> login(String identifier, String password);
  // ...existing code...
}
```

### 2. 实现类
```dart
class AuthRepositoryImpl implements IAuthRepository {
  final RequestManager _requestManager = RequestManager.instance;
  get _localStorage => AppServices.instance.localStorage;
  // ...existing code...
}
```

### 3. ServiceLocator
```dart
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._();
  ServiceLocator._();
  IAuthRepository? _authRepository;
  IAuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl();
    return _authRepository!;
  }
  void setAuthRepository(IAuthRepository repo) => _authRepository = repo;
  void reset() => _authRepository = null;
}
```

### 4. Controller依赖
```dart
class AuthController extends GetxController {
  final IAuthRepository _authRepository;
  AuthController({IAuthRepository? authRepository})
    : _authRepository = authRepository ?? ServiceLocator.instance.authRepository;
  // ...existing code...
}
```

---

## 更新记录
- 2025-10-25：首次创建，输出Auth模块架构优化分步方案与示例代码
