# Clean Architecture 优化架构图

**创建时间**: 2025年10月25日  
**版本**: v2.0 (优化版)

---

## 🏗️ 整体分层架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                         │
│                         (表现层)                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │    Pages     │  │ Controllers  │  │   Widgets    │          │
│  │   (UI组件)    │  │  (GetX状态)   │  │  (可复用组件) │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│         ↓                 ↓                  ↓                  │
│         └─────────────────┴──────────────────┘                  │
│                           ↓                                     │
└───────────────────────────┼─────────────────────────────────────┘
                            ↓ (依赖接口)
┌───────────────────────────┼─────────────────────────────────────┐
│                      Domain Layer                               │
│                        (领域层)                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Repository Interfaces (接口)                 │  │
│  │  ┌─────────────────┐  ┌─────────────────┐                │  │
│  │  │IAuthRepository  │  │IUserRepository  │  ...           │  │
│  │  └─────────────────┘  └─────────────────┘                │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Use Cases (业务用例)                    │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐  │  │
│  │  │LoginUseCase │  │RegisterUseCase│  │LogoutUseCase  │  │  │
│  │  └─────────────┘  └──────────────┘  └────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Entities (业务实体)                      │  │
│  │  ┌──────┐  ┌────────────┐  ┌──────────┐                 │  │
│  │  │ User │  │ Vocabulary │  │ Student  │  ...            │  │
│  │  └──────┘  └────────────┘  └──────────┘                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────────┬─────────────────────────────────┘
                                ↑ (实现接口)
┌───────────────────────────────┼─────────────────────────────────┐
│                       Data Layer                                │
│                        (数据层)                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          Repository Implementations (仓库实现)            │  │
│  │  ┌──────────────────────┐  ┌──────────────────────┐      │  │
│  │  │AuthRepositoryImpl    │  │UserRepositoryImpl    │ ...  │  │
│  │  │implements            │  │implements            │      │  │
│  │  │IAuthRepository       │  │IUserRepository       │      │  │
│  │  └──────────────────────┘  └──────────────────────┘      │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                 Data Services (数据服务)                  │  │
│  │  ┌─────────────────────┐  ┌─────────────────────┐        │  │
│  │  │LocalStorageService  │  │  UserService        │  ...   │  │
│  │  └─────────────────────┘  └─────────────────────┘        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              ↓                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               ↓
┌──────────────────────────────┼──────────────────────────────────┐
│                       Core Layer                                │
│                        (核心层)                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          Dependency Injection (依赖注入)                  │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │            ServiceLocator (服务定位器)              │  │  │
│  │  │  - 管理所有接口与实现的映射                         │  │  │
│  │  │  - 懒加载创建单例                                   │  │  │
│  │  │  - 支持测试Mock替换                                 │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Network (网络层)                             │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │NetworkClient │→ │RequestManager│→ │ Interceptors │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            Infrastructure (基础设施)                      │  │
│  │  ┌──────────┐ ┌─────────┐ ┌──────────┐ ┌──────────┐    │  │
│  │  │ApiConfig │ │AppLogger│ │Exceptions│ │Constants │    │  │
│  │  └──────────┘ └─────────┘ └──────────┘ └──────────┘    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 优化后的目录结构

```
kiki_web/                              # 项目根目录
├── lib/                               # 源代码目录
│   ├── core/                          # 核心基础设施层
│   │   ├── di/                        # 🆕 依赖注入
│   │   │   └── service_locator.dart   # ServiceLocator (替代AppServices)
│   │   ├── network/                   # 网络层
│   │   │   ├── network_client.dart
│   │   │   ├── request_manager.dart
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart
│   │   │       ├── retry_interceptor.dart
│   │   │       └── logging_interceptor.dart
│   │   ├── config/                    # API配置
│   │   │   └── api_config.dart
│   │   ├── constants/                 # 常量定义
│   │   │   ├── api_endpoints.dart
│   │   │   ├── app_constants.dart
│   │   │   └── app_colors.dart
│   │   ├── exceptions/                # 异常体系
│   │   │   ├── app_exceptions.dart
│   │   │   └── network_exceptions.dart
│   │   ├── logging/                   # 日志系统
│   │   │   └── app_logger.dart
│   │   └── utils/                     # 工具类
│   │       ├── validators.dart
│   │       └── formatters.dart
│   │
│   ├── domain/                        # 🔥 领域层 (核心业务)
│   │   ├── entities/                  # 业务实体
│   │   │   ├── user.dart
│   │   │   ├── vocabulary.dart
│   │   │   └── student.dart
│   │   ├── repositories/              # 🆕 Repository接口定义
│   │   │   ├── i_auth_repository.dart
│   │   │   ├── i_user_repository.dart
│   │   │   ├── i_vocabulary_repository.dart
│   │   │   └── i_storage_repository.dart
│   │   └── usecases/                  # 🆕 业务用例
│   │       ├── auth/
│   │       │   ├── login_usecase.dart
│   │       │   ├── register_usecase.dart
│   │       │   └── logout_usecase.dart
│   │       ├── user/
│   │       │   ├── get_user_profile_usecase.dart
│   │       │   └── update_user_profile_usecase.dart
│   │       └── vocabulary/
│   │           ├── get_vocabulary_list_usecase.dart
│   │           └── create_vocabulary_usecase.dart
│   │
│   ├── data/                          # 数据层
│   │   ├── repositories/              # Repository接口实现
│   │   │   ├── auth_repository_impl.dart          # 实现IAuthRepository
│   │   │   ├── user_repository_impl.dart          # 实现IUserRepository
│   │   │   ├── vocabulary_repository_impl.dart    # 实现IVocabularyRepository
│   │   │   └── storage_repository_impl.dart       # 实现IStorageRepository
│   │   └── services/                  # 数据服务
│   │       ├── local_storage_service.dart
│   │       └── user_service.dart
│   │
│   ├── presentation/                  # 表现层
│   │   ├── controllers/               # GetX状态管理
│   │   │   ├── auth_controller.dart
│   │   │   ├── user_controller.dart
│   │   │   └── vocabulary_controller.dart
│   │   ├── pages/                     # 页面
│   │   │   ├── auth/
│   │   │   │   ├── login_page.dart
│   │   │   │   └── register_page.dart
│   │   │   ├── home/
│   │   │   └── vocabulary/
│   │   └── widgets/                   # 可复用组件
│   │       ├── common/
│   │       │   ├── custom_button.dart
│   │       │   └── loading_indicator.dart
│   │       └── dialogs/
│   │
│   ├── l10n/                          # 国际化
│   │   ├── app_en.arb
│   │   ├── app_zh.arb
│   │   └── app_zh_TW.arb
│   │
│   ├── generated/                     # 自动生成
│   │   └── app_localizations.dart
│   │
│   └── main.dart                      # 应用入口
│
├── config/                            # 环境配置 (与lib同级)
│   ├── dev.env                        # 开发环境配置
│   ├── test.env                       # 测试环境配置
│   └── prod.env                       # 生产环境配置
│
├── doc/                               # 项目文档
│   ├── framework/                     # 架构文档
│   ├── api/                           # API文档
│   └── task/                          # 任务文档
│
├── assets/                            # 资源文件
│   └── images/
│
├── test/                              # 测试文件
│   └── ...
│
├── pubspec.yaml                       # 依赖配置
└── README.md                          # 项目说明
```

---

## 🔄 依赖关系详细图

### 1. 登录功能的完整依赖链

```
┌─────────────────────────────────────────────────────────────────┐
│                    Presentation Layer                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │       LoginPage (UI)                    │
        │  - 表单输入                              │
        │  - 显示loading/错误                      │
        └──────────────┬──────────────────────────┘
                       ↓ (用户交互)
        ┌──────────────────────────────────────────────┐
        │       AuthController (状态管理)              │
        │  - 管理表单状态                              │
        │  - 处理UI loading                           │
        │  - 调用UseCase                              │
        └──────────────┬───────────────────────────────┘
                       ↓ (依赖接口)
┌─────────────────────────────────────────────────────────────────┐
│                      Domain Layer                               │
└─────────────────────────────────────────────────────────────────┘
                       ↓
        ┌──────────────────────────────────────────────┐
        │       LoginUseCase (业务用例)                │
        │  业务逻辑:                                    │
        │  1. 参数验证(identifier/password)           │
        │  2. 调用IAuthRepository.login()            │
        │  3. 保存token到IStorageRepository          │
        │  4. 返回User实体                            │
        └──────────────┬───────────────────────────────┘
                       ↓ (依赖接口)
        ┌──────────────────────────────────────────────┐
        │   IAuthRepository (接口定义)                 │
        │   + login(identifier, password): User       │
        │   + register(...): User                     │
        │   + logout(): void                          │
        └──────────────┬───────────────────────────────┘
                       ↑ (实现接口)
┌─────────────────────────────────────────────────────────────────┐
│                       Data Layer                                │
└─────────────────────────────────────────────────────────────────┘
                       ↓
        ┌──────────────────────────────────────────────┐
        │  AuthRepositoryImpl (接口实现)               │
        │  实现逻辑:                                    │
        │  1. 调用RequestManager.post()              │
        │  2. 处理响应 (ApiResponseHandler)          │
        │  3. 转换为User实体                          │
        │  4. 统一异常处理                            │
        └──────────────┬───────────────────────────────┘
                       ↓ (使用)
┌─────────────────────────────────────────────────────────────────┐
│                       Core Layer                                │
└─────────────────────────────────────────────────────────────────┘
                       ↓
        ┌──────────────────────────────────────────────┐
        │       RequestManager (网络请求)              │
        │  - 发送HTTP请求                              │
        │  - 自动添加token                             │
        │  - 错误重试                                  │
        └──────────────┬───────────────────────────────┘
                       ↓
        ┌──────────────────────────────────────────────┐
        │       NetworkClient (HTTP客户端)             │
        │  - Dio配置                                   │
        │  - 拦截器管理                                │
        └──────────────────────────────────────────────┘
```

### 2. ServiceLocator 依赖注入流程

```
┌──────────────────────────────────────────────────────────────┐
│              ServiceLocator (服务定位器)                      │
│                                                              │
│  接口注册表:                                                  │
│  ┌────────────────────────────────────────────────────┐    │
│  │ IAuthRepository      → AuthRepositoryImpl          │    │
│  │ IUserRepository      → UserRepositoryImpl          │    │
│  │ IStorageRepository   → StorageRepositoryImpl       │    │
│  │ LoginUseCase         → LoginUseCase(repo, storage) │    │
│  │ AuthController       → AuthController(usecases)    │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  使用方式:                                                    │
│  ┌────────────────────────────────────────────────────┐    │
│  │ // 获取接口实例                                     │    │
│  │ final authRepo = services.authRepository;          │    │
│  │ // 返回: IAuthRepository (接口类型)                 │    │
│  │                                                     │    │
│  │ // 获取UseCase                                      │    │
│  │ final loginUseCase = services.loginUseCase;        │    │
│  │                                                     │    │
│  │ // 测试时替换                                       │    │
│  │ services.setAuthRepository(MockAuthRepository());  │    │
│  └────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

---

## 🎯 核心改进点对比

### 改进前 (当前架构)

```
Controller → AppServices → AuthRepository (具体类) → RequestManager
    ↓                            ↓
业务逻辑混在Controller      直接依赖实现,无法替换
```

**问题**:
- ❌ Controller臃肿,业务逻辑混杂
- ❌ 依赖具体实现,违反依赖倒置
- ❌ 难以测试,无法Mock
- ❌ 业务逻辑无法复用

### 改进后 (优化架构)

```
Controller → UseCase → IRepository (接口) ← RepositoryImpl → RequestManager
    ↓          ↓                               ↑
  UI状态    业务逻辑                    ServiceLocator注入
```

**优势**:
- ✅ Controller职责单一,只管UI状态
- ✅ UseCase封装业务逻辑,可复用
- ✅ 依赖接口,符合依赖倒置原则
- ✅ 易于测试,可Mock任何层
- ✅ 层级清晰,架构优雅

---

## 📊 层级职责说明

### Presentation Layer (表现层)
**职责**: 
- 处理用户交互
- 管理UI状态(loading/error/success)
- 调用UseCase执行业务
- 显示结果或错误

**不应该**:
- ❌ 包含业务逻辑
- ❌ 直接调用Repository
- ❌ 处理数据转换

---

### Domain Layer (领域层) 🔥 核心

**Entities (实体)**:
- 业务核心对象
- 包含业务规则
- 独立于框架

**Repository Interfaces (仓库接口)**:
- 定义数据访问抽象
- 不关心实现细节
- 被UseCase依赖

**Use Cases (用例)**:
- 封装单一业务场景
- 协调多个Repository
- 包含业务验证逻辑
- 返回Domain实体

**特点**:
- ✅ 不依赖任何外层
- ✅ 可独立测试
- ✅ 可独立于框架存在

---

### Data Layer (数据层)

**Repository Implementations (仓库实现)**:
- 实现Domain层定义的接口
- 调用网络/本地数据源
- 数据格式转换
- 统一异常处理

**Data Services**:
- 本地存储服务
- 缓存服务
- 其他数据服务

**职责**:
- ✅ 实现数据访问
- ✅ 处理响应解析
- ✅ 异常转换

---

### Core Layer (核心层)

**ServiceLocator (依赖注入)**:
- 管理所有服务实例
- 接口与实现映射
- 支持测试替换

**Network (网络层)**:
- HTTP客户端封装
- 请求/响应拦截
- 统一错误处理

**Infrastructure (基础设施)**:
- 配置管理
- 日志系统
- 工具类
- 常量定义

---

## 🚀 数据流向示例

### 用户登录流程

```
1. 用户输入账号密码,点击登录
   LoginPage → AuthController.login()

2. Controller显示loading,调用UseCase
   AuthController → LoginUseCase.execute(identifier, password)

3. UseCase执行业务逻辑
   LoginUseCase:
   - 验证参数格式
   - 调用 IAuthRepository.login(identifier, password)
   - 保存token到 IStorageRepository
   - 返回 User 实体

4. Repository调用网络请求
   AuthRepositoryImpl:
   - 调用 RequestManager.post(ApiEndpoints.login, data)
   - 使用 ApiResponseHandler 处理响应
   - 转换JSON → User实体
   - 统一异常处理

5. Network层发送请求
   RequestManager:
   - 添加通用请求头
   - 发送HTTP请求
   - 拦截器处理(认证/重试/日志)
   - 返回响应数据

6. 数据逐层返回
   User实体 → LoginUseCase → AuthController

7. Controller更新UI
   AuthController:
   - 隐藏loading
   - 更新用户状态
   - 导航到首页

异常处理:
   任何层抛出异常 → ApiResponseException
   → LoginUseCase捕获 → AuthController处理
   → 显示错误Toast
```

---

## 🧪 测试示例

### UseCase单元测试 (不依赖任何框架)

```dart
void main() {
  group('LoginUseCase Tests', () {
    late LoginUseCase loginUseCase;
    late MockAuthRepository mockAuthRepo;
    late MockStorageRepository mockStorage;
    
    setUp(() {
      mockAuthRepo = MockAuthRepository();
      mockStorage = MockStorageRepository();
      loginUseCase = LoginUseCase(
        repository: mockAuthRepo,
        storage: mockStorage,
      );
    });
    
    test('成功登录应保存token和用户信息', () async {
      // Arrange
      final user = User(id: '1', name: 'Test', token: 'abc123');
      when(mockAuthRepo.login(any, any)).thenAnswer((_) async => user);
      
      // Act
      final result = await loginUseCase.execute(
        identifier: '13800138000',
        password: '123456',
      );
      
      // Assert
      expect(result, equals(user));
      verify(mockStorage.saveAccessToken('abc123')).called(1);
      verify(mockStorage.saveUser(user)).called(1);
    });
    
    test('空账号应抛出验证异常', () async {
      // Act & Assert
      expect(
        () => loginUseCase.execute(identifier: '', password: '123456'),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

### Controller测试 (Mock UseCase)

```dart
void main() {
  group('AuthController Tests', () {
    late AuthController controller;
    late MockLoginUseCase mockLoginUseCase;
    
    setUp(() {
      mockLoginUseCase = MockLoginUseCase();
      controller = AuthController(loginUseCase: mockLoginUseCase);
    });
    
    test('登录成功应更新用户状态', () async {
      // Arrange
      final user = User(id: '1', name: 'Test');
      when(mockLoginUseCase.execute(any, any)).thenAnswer((_) async => user);
      
      // Act
      await controller.login();
      
      // Assert
      expect(controller.currentUser, equals(user));
      expect(controller.isLoggedIn, isTrue);
    });
  });
}
```

---

## ✅ 架构优势总结

### 1. **清晰的职责分离**
- Presentation: UI状态管理
- Domain: 业务逻辑
- Data: 数据访问
- Core: 基础设施

### 2. **依赖倒置原则**
- 高层模块(Controller/UseCase)依赖抽象(接口)
- 低层模块(Repository)实现抽象
- ServiceLocator管理依赖注入

### 3. **易于测试**
- UseCase可独立测试(Mock Repository)
- Controller可独立测试(Mock UseCase)
- Repository可独立测试(Mock RequestManager)

### 4. **易于维护**
- 业务逻辑集中在UseCase,修改不影响UI
- Repository实现可替换,不影响业务逻辑
- 接口定义稳定,实现可灵活变更

### 5. **可扩展性强**
- 新增功能只需添加UseCase
- 新增数据源只需添加Repository实现
- UI框架可替换(GetX → Riverpod)

---

**下一步**: 开始实施架构优化,从Auth模块开始重构! 🚀
