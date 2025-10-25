# 奇奇满有服务器 - 最新DDD架构设计文档

## 1. 系统架构概览

基于Domain-Driven Design（DDD）的Clean Architecture实现，采用Rust + Axum框架构建。

### 架构层次图

```
┌─────────────────────────────────────────────────────────────────┐
│                    🌐 Presentation Layer                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  HTTP Middleware │  │   Controllers   │  │     Routes      │ │
│  │  ├─ CORS         │  │  ├─ AuthCtrl    │  │  ├─ /auth/*     │ │
│  │  ├─ JWT Auth     │  │  ├─ AssignCtrl  │  │  ├─ /assignment│ │
│  │  ├─ Logging      │  │  └─ StudentCtrl │  │  └─ /student   │ │
│  │  └─ Error Handle │  └─────────────────┘  └─────────────────┘ │
│  └─────────────────┘                                            │
├─────────────────────────────────────────────────────────────────┤
│                    💼 Application Layer                         │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    Use Cases                                │ │
│  │  ┌─────────────────┐  ┌─────────────────┐                  │ │
│  │  │  Authentication │  │    Assignment   │                  │ │
│  │  │  ├─ LoginUser   │  │  ├─ CreateAssgn │                  │ │
│  │  │  └─ RegisterUser│  │  └─ ListAssgn   │                  │ │
│  │  └─────────────────┘  └─────────────────┘                  │ │
│  └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                      🏛️ Domain Layer                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │    Entities     │  │   Repositories  │  │  Value Objects  │ │
│  │  ├─ User        │  │  ├─ UserRepo    │  │  ├─ UserId      │ │
│  │  ├─ Assignment  │  │  ├─ AssignRepo  │  │  ├─ Email       │ │
│  │  └─ Student     │  │  └─ StudentRepo │  │  └─ Phone       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                   🔧 Infrastructure Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Persistence   │  │     Logging     │  │    External     │ │
│  │  ├─ PostgresRepo│  │  ├─ Logger      │  │  ├─ Config      │ │
│  │  ├─ Database    │  │  └─ Structured  │  │  └─ Env         │ │
│  │  └─ Migrations  │  │      JSON       │  └─────────────────┘ │
│  └─────────────────┘  └─────────────────┘                      │
├─────────────────────────────────────────────────────────────────┤
│                      🛠️ Utils Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐                      │
│  │   JWT Utils     │  │   Tool Utils    │                      │
│  │  ├─ Generate    │  │  ├─ HashPassword │                      │
│  │  ├─ Verify      │  │  └─ VerifyPwd   │                      │
│  │  └─ Extract     │  └─────────────────┘                      │
│  └─────────────────┘                                            │
└─────────────────────────────────────────────────────────────────┘
```

## 2. 登录功能完整调用链路图

### 2.1 HTTP请求流程

```
HTTP Request: POST /api/auth/login
     ↓
┌─────────────────────────────────────────────────────────────────┐
│                      🌐 Middleware Stack                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Request/Response│  │  Error Handling │  │   JWT Auth      │ │
│  │    Logging      │→ │   Middleware    │→ │  (Whitelist)    │ │
│  │                 │  │                 │  │  ✅ /auth/login │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
     ↓
┌─────────────────────────────────────────────────────────────────┐
│                    💼 AuthController                           │
│  pub async fn login(&self, Json(request): Json<Value>)         │
│      → LoginUserCommand::deserialize(request)                  │
│      → self.login_use_case.execute(command).await             │
└─────────────────────────────────────────────────────────────────┘
     ↓
┌─────────────────────────────────────────────────────────────────┐
│                   💼 LoginUserUseCase                          │
│  pub async fn execute(&self, command) → LoginUserResponse      │
│    1. validate_command(&command)                               │
│    2. find_user(&command.identifier)                          │
│    3. verify_password(&user, &command.password)               │
│    4. update_user_timestamp()                                 │
│    5. generate_jwt_token(&user)                               │
└─────────────────────────────────────────────────────────────────┘
     ↓
┌─────────────────────────────────────────────────────────────────┐
│                🏛️ Domain & Infrastructure                      │
│  UserRepository::find_by_phone(identifier)                     │
│      ↓                                                         │
│  PostgresUserRepository::find_by_phone()                       │
│      ↓                                                         │
│  SELECT * FROM users WHERE phone = $1                          │
└─────────────────────────────────────────────────────────────────┘
     ↓
┌─────────────────────────────────────────────────────────────────┐
│                     🛠️ Utils Layer                             │
│  ToolUtils::verify_password(password, hash)                    │
│      ↓                                                         │
│  bcrypt::verify(password, hash)                                │
│      ↓                                                         │
│  JwtUtils::generate_token(&user)                               │
│      ↓                                                         │
│  jsonwebtoken::encode(claims, key, algorithm)                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 关键方法调用序列

```sequence
Client->Middleware: POST /api/auth/login
Middleware->AuthController: login(Json<Value>)
AuthController->LoginUserUseCase: execute(LoginUserCommand)
LoginUserUseCase->LoginUserUseCase: validate_command()
LoginUserUseCase->UserRepository: find_by_phone(identifier)
UserRepository->PostgresUserRepo: find_by_phone()
PostgresUserRepo->Database: SELECT * FROM users
Database->PostgresUserRepo: User Record
PostgresUserRepo->UserRepository: Option<User>
UserRepository->LoginUserUseCase: User
LoginUserUseCase->ToolUtils: verify_password(password, hash)
ToolUtils->bcrypt: verify()
bcrypt->ToolUtils: bool
ToolUtils->LoginUserUseCase: Result<bool>
LoginUserUseCase->UserRepository: save(updated_user)
LoginUserUseCase->JwtUtils: generate_token(user)
JwtUtils->jsonwebtoken: encode()
jsonwebtoken->JwtUtils: String
JwtUtils->LoginUserUseCase: Result<String>
LoginUserUseCase->AuthController: LoginUserResponse
AuthController->Client: JSON Response
```

## 3. 核心组件引用关系

### 3.1 依赖注入容器

```rust
// src/app/dependency_container.rs
pub struct AppState {
    pub auth_controller: Arc<AuthController>,
    pub assignment_controller: Arc<AssignmentController>,
    pub student_controller: Arc<StudentController>,
}

// 依赖创建链路：
Repository → UseCase → Controller → AppState
```

### 3.2 关键文件引用关系

```
src/
├── presentation/http/
│   ├── auth_controller.rs          [控制器层]
│   │   ├─ LoginUserUseCase         → application/use_cases/auth/
│   │   └─ Logger                   → infrastructure/logging/
│   └── middleware.rs               [中间件层]
│       ├─ JWT白名单验证
│       ├─ CORS配置
│       └─ 请求响应日志
├── application/use_cases/auth/
│   ├── login_user.rs               [用例层]
│   │   ├─ UserRepository           → domain/repositories/
│   │   ├─ JwtUtils                 → utils/jwt/
│   │   ├─ ToolUtils                → utils/tool/
│   │   └─ Logger                   → infrastructure/logging/
│   └── register_user.rs
├── domain/
│   ├── entities.rs                 [实体层]
│   │   └─ User, Assignment, Student
│   ├── repositories.rs             [仓储接口]
│   │   └─ UserRepository trait
│   └── errors.rs                   [错误定义]
├── infrastructure/persistence/
│   └── postgres_user_repository.rs [仓储实现]
│       ├─ UserRepository trait     → domain/repositories/
│       └─ sqlx::PgPool
└── utils/
    ├── jwt.rs                      [JWT工具库]
    │   ├─ jsonwebtoken
    │   ├─ chrono
    │   └─ serde
    └── tool.rs                     [通用工具库]
        └─ bcrypt
```

## 4. 登录功能关键方法详解

### 4.1 控制器层方法

#### AuthController::login()
```rust
// 文件位置: src/presentation/http/auth_controller.rs
pub async fn login(&self, Json(request): Json<Value>) -> Result<Value> {
    // 1. 反序列化请求体
    // 2. 调用用例执行登录逻辑
    // 3. 包装返回结果
}
```

### 4.2 用例层方法

#### LoginUserUseCase::execute()
```rust
// 文件位置: src/application/use_cases/auth/login_user.rs
pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> {
    // 登录业务流程编排：
    // 1. validate_command() - 输入验证
    // 2. find_user() - 用户查找
    // 3. verify_password() - 密码验证
    // 4. update_timestamp() - 更新时间戳
    // 5. generate_token() - 生成JWT
}
```

#### 关键私有方法：

**validate_command()**
```rust
fn validate_command(&self, command: &LoginUserCommand) -> Result<()> {
    // 验证手机号/邮箱和密码不为空
}
```

**find_user()**
```rust
async fn find_user(&self, identifier: &str) -> Result<User> {
    // 调用仓储接口查找用户
    // 支持手机号查找
}
```

**verify_password()**
```rust
fn verify_password(&self, user: &User, password: &str) -> Result<()> {
    // 调用ToolUtils验证密码
    // 包含详细的日志记录
}
```

### 4.3 工具库方法

#### JwtUtils工具方法
```rust
// 文件位置: src/utils/jwt.rs

// JWT配置初始化
pub fn init(config: JwtConfig) -> Result<()>
pub fn quick_init() -> Result<()>  // 使用默认配置

// JWT令牌操作
pub fn generate_token(user: &User) -> Result<String>
pub fn verify_token(token: &str) -> Result<Claims>
pub fn extract_user_id(token: &str) -> Result<String>
```

#### ToolUtils工具方法
```rust
// 文件位置: src/utils/tool.rs

// 密码处理
pub fn hash_password(password: &str) -> Result<String>
pub fn verify_password(password: &str, hash: &str) -> Result<bool>
```

### 4.4 仓储层方法

#### UserRepository接口
```rust
// 文件位置: src/domain/repositories.rs
pub trait UserRepository: Send + Sync {
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>>;
    async fn save(&self, user: &User) -> Result<()>;
    // ... 其他方法
}
```

#### PostgresUserRepository实现
```rust
// 文件位置: src/infrastructure/persistence/postgres_user_repository.rs
impl UserRepository for PostgresUserRepository {
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>> {
        // SQL查询实现
        // 错误处理和日志记录
    }
}
```

## 5. 中间件系统

### 5.1 中间件调用顺序

```rust
// src/app/routes/main_routes.rs
Router::new()
    .merge(all_routes)
    .layer(middleware::from_fn(jwt_auth_middleware))           // 4. JWT认证
    .layer(middleware::from_fn(error_handling_middleware))     // 3. 错误处理
    .layer(middleware::from_fn(request_response_data_log_middleware)) // 2. 日志记录
    .layer(cors_layer);                                       // 1. CORS (最后执行)
```

### 5.2 JWT认证中间件

```rust
// 文件位置: src/presentation/http/middleware.rs
pub async fn jwt_auth_middleware(request: Request<Body>, next: Next) -> Result<Response> {
    // 白名单路径检查
    let whitelist_paths = vec![
        "/api/auth/login",
        "/api/auth/register", 
        "/health",
    ];
    
    // 如果在白名单中，跳过认证
    // 否则验证JWT令牌
}
```

## 6. 错误处理体系

### 6.1 错误类型定义

```rust
// 文件位置: src/domain/errors.rs
pub enum DomainError {
    Authentication(String),    // 认证错误
    Validation(String),        // 验证错误
    Infrastructure(String),    // 基础设施错误
    NotFound(String),          // 资源未找到
}
```

### 6.2 错误传播链路

```
Utils Error → Domain Error → Use Case Error → Controller Error → HTTP Response
```

## 7. 配置和环境

### 7.1 配置文件结构

```
config/
├── development.toml      // 开发环境配置
├── production.toml       // 生产环境配置
└── app.toml             // 默认配置
```

### 7.2 JWT配置

```rust
// JWT配置初始化
JwtUtils::quick_init()  // 使用默认配置
// 或
JwtUtils::init(JwtConfig {
    secret: "your-secret-key".to_string(),
    expiry_hours: 24,
})
```

## 8. 数据库集成

### 8.1 数据库连接

```rust
// 使用sqlx连接PostgreSQL
let pool = PgPool::connect(&database_url).await?;
```

### 8.2 实体映射

```rust
// User实体与数据库表映射
// 支持UUID主键
// 自动时间戳管理
```

## 9. 开发调试

### 9.1 日志系统

```rust
// 结构化JSON日志
Logger::info("消息");
Logger::warn("警告");
Logger::error("错误");
```

### 9.2 请求跟踪

每个HTTP请求都有唯一的request_id，便于追踪调试。

## 10. 总结

当前架构特点：
- ✅ 简化的DDD架构，移除了不必要的服务层
- ✅ 用例直接调用仓储，减少抽象层级
- ✅ JWT和通用工具独立为工具库
- ✅ 完善的中间件系统
- ✅ 结构化日志和错误处理
- ✅ 支持UUID主键和现代化数据库集成

这种架构在保持DDD核心理念的同时，避免了过度设计，更适合中小型项目的快速开发和维护。
