# Hi Kiki服务器 - 2026 最新 Clean Architecture 架构说明

> **更新时间**: 2026-01-18
> **版本说明**: 基于简化版 Clean Architecture 重构，移除 Controller 冗余层，使用强类型 DTOs
> **重构内容**: 从 5 层简化为 4 层，保留核心 Use Case 层，提升简洁性和类型安全

---

## 1. 架构概览

### 1.1 目录结构与依赖方向

```
src/
├── core/                      # 核心层（业务逻辑）
│   ├── entities/             # 领域实体（User, etc.）
│   ├── use_cases/            # 用例（业务流程编排）✅ 保留
│   ├── ports/                # 接口定义（Repository trait）✅ 保留
│   ├── errors.rs             # 领域错误（DomainError）
│   └── value_objects.rs      # 值对象（UserId）
│
├── adapters/                  # 适配器层（技术实现）
│   ├── http/                 # HTTP 适配器
│   │   └── auth/
│   │       ├── handlers.rs   # ✅ 新增：HTTP 处理器（直接调用 Use Case）
│   │       ├── dtos.rs       # ✅ 新增：强类型 DTOs
│   │       └── mod.rs
│   ├── persistence/          # 持久化适配器
│   │   └── postgres/
│   │       └── user_repository.rs  # Repository 实现
│   └── mod.rs
│
├── framework/                 # 框架层（启动、配置）
│   ├── bootstrap/
│   │   ├── container.rs      # ✅ 简化：直接注入 Use Case
│   │   ├── routes/           # 路由汇总
│   │   └── mod.rs
│   ├── logging.rs            # 日志配置
│   └── mod.rs
│
├── shared/                    # 共享模块
│   └── api_response.rs       # 统一 API 响应格式
│
├── utils/                     # 工具模块
│   ├── jwt.rs                # JWT 工具
│   ├── http.rs               # HTTP 工具
│   ├── errors.rs             # 错误类型别名
│   └── mod.rs
│
├── config/                    # 配置模块
│   ├── database.rs
│   └── mod.rs
│
├── main.rs                    # 应用入口
└── lib.rs                     # 库入口
```

**依赖方向**（外层依赖内层）:

```
framework → adapters → core
         ↘ utils / shared (只提供通用能力)
```

- ✅ `core` 不依赖任何外层模块，只使用标准库
- ✅ `adapters` 实现 `core::ports` 定义的接口
- ✅ `framework` 负责组合和启动
- ✅ `config`、`shared`、`utils` 为配套模块

### 1.2 模块职责速览

| 模块 | 关键职责 | 代表文件 |
|------|---------|----------|
| `core` | 业务模型与用例编排 | `use_cases/auth/login_user.rs`、`ports/mod.rs` |
| `adapters/http` | HTTP 处理（强类型） | `http/auth/handlers.rs`、`http/auth/dtos.rs` |
| `adapters/persistence` | 数据库访问 | `postgres/user_repository.rs` |
| `framework` | 启动、依赖注入、日志 | `bootstrap/container.rs`、`logging.rs` |
| `config` | 环境配置加载 | `config/mod.rs`、`config/development.toml` |
| `shared` | API 响应协议 | `shared/api_response.rs` |
| `utils` | JWT/HTTP/错误工具 | `utils/jwt.rs`、`utils/errors.rs` |

---

## 2. 登录功能调用链（重构后）

### 2.1 HTTP 请求流程

```
POST /api/v1/auth/login
     ↓
┌──────────────────────────────────────────────┐
│ Middleware Stack (adapters/http/middleware)  │
│ 1. request_response_data_log_middleware      │
│ 2. error_handling_middleware                │
│ 3. jwt_auth_middleware（白名单跳过认证）      │
│ 4. CORS Layer                                │
└──────────────────────────────────────────────┘
     ↓
✅ login_handler (adapters/http/auth/handlers.rs)
  - 接收强类型 LoginRequest
  - 构造 LoginUserCommand
     ↓
✅ LoginUserUseCase::execute (core/use_cases/auth/login_user.rs)
  - 验证输入
  - 调用 Repository
  - 生成 JWT Token
     ↓
UserRepository trait (core/ports)
     ↓
PostgresUserRepository (adapters/persistence/postgres)
  - SQL 参数绑定查询
     ↓
JwtUtils::generate_token (utils/jwt.rs)
     ↓
✅ ApiResponse (shared/api_response.rs)
  - 成功: ApiResponse::success(LoginResponse)
  - 失败: ApiResponse::from_domain_error(DomainError)
```

### 2.2 重构前 vs 重构后对比

| 调用链 | 重构前（5 层） | 重构后（4 层）✅ |
|--------|---------------|----------------|
| HTTP → | routes.rs | handlers.rs |
| → | **controller.rs** ❌ | **（已移除）** |
| → | use_case.rs | use_case.rs |
| → | port.rs | port.rs |
| → | repository.rs | repository.rs |
| **类型安全** | `serde_json::Value` | `LoginRequest` (强类型) ✅ |
| **复杂度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

### 2.3 时序图（重构后）

```sequence
Client->Middleware: POST /api/v1/auth/login
Middleware->login_handler: Json<LoginRequest>
login_handler->LoginUserUseCase: execute(LoginUserCommand)
LoginUserUseCase->UserRepository: find_by_phone(identifier)
UserRepository->PostgresUserRepository: SQL query with params
PostgresUserRepository->UserRepository: Option<User>
LoginUserUseCase->LoginUserUseCase: verify_password(user, password)
LoginUserUseCase->JwtUtils: generate_token(user)
JwtUtils->LoginUserUseCase: JWT token
LoginUserUseCase->login_handler: LoginUserResponse
login_handler->login_handler: LoginResponse::from(response)
login_handler->Client: ApiResponse<LoginResponse>
```

---

## 3. 核心组件详解

### 3.1 依赖注入容器（简化版）

```rust
// src/framework/bootstrap/container.rs

#[derive(Clone)]
pub struct AppState {
    // ✅ 直接注入 Use Case（移除 Controller）
    pub login_use_case: Arc<LoginUserUseCase>,
    pub register_use_case: Arc<RegisterUserUseCase>,
}

impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        // 1. 初始化 Repository
        let user_repository: Arc<dyn UserRepository> =
            Arc::new(PostgresUserRepository::new(pool));

        // 2. 初始化 Use Cases（直接注入）
        let login_use_case = Arc::new(LoginUserUseCase::new(user_repository.clone()));
        let register_use_case = Arc::new(RegisterUserUseCase::new(user_repository));

        let app_state = AppState {
            login_use_case,
            register_use_case,
        };

        Self { app_state }
    }
}
```

### 3.2 HTTP Handler（新架构核心）

```rust
// src/adapters/http/auth/handlers.rs

/// 用户登录处理器（直接调用 Use Case）
pub async fn login_handler(
    State(login_use_case): State<Arc<LoginUserUseCase>>,
    Json(request): Json<LoginRequest>,  // ✅ 强类型
) -> Response {
    // 1. 构造 Use Case 命令
    let command = LoginUserCommand {
        identifier: request.identifier,
        password: request.password,
    };

    // 2. 执行 Use Case（直接调用）
    match login_use_case.execute(command).await {
        Ok(response) => {
            // 3. 转换为 DTO
            let dto: LoginResponse = response.into();
            let api_response = ApiResponse::success(dto, "登录成功");
            (StatusCode::OK, Json(api_response)).into_response()
        }
        Err(e) => {
            // 4. 统一错误处理
            let api_response = ApiResponse::from_domain_error(&e);
            let status = api_response.http_status();
            (status, Json(api_response)).into_response()
        }
    }
}
```

### 3.3 强类型 DTOs

```rust
// src/adapters/http/auth/dtos.rs

/// 登录请求（强类型）
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    #[serde(alias = "phone", alias = "email")]
    pub identifier: String,
    pub password: String,
}

/// 登录响应（强类型）
#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub token: String,
    pub role_id: i32,
    pub message: String,
}

/// 自动转换（Use Case Response → DTO）
impl From<crate::core::use_cases::LoginUserResponse> for LoginResponse {
    fn from(response: crate::core::use_cases::LoginUserResponse) -> Self {
        Self {
            uid: response.uid,
            name: response.name,
            email: response.email,
            phone: response.phone,
            token: response.token,
            role_id: response.role_id,
            message: response.message,
        }
    }
}
```

### 3.4 Use Case 层（保留）

```rust
// src/core/use_cases/auth/login_user.rs

pub struct LoginUserUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl LoginUserUseCase {
    pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> {
        // 1. 验证输入
        self.validate_command(&command)?;

        // 2. 查找用户
        let user = self.find_user(&command.identifier).await?;

        // 3. 验证密码
        self.verify_password(&user, &command.password)?;

        // 4. 更新时间戳
        let mut updated_user = user.clone();
        updated_user.update_timestamp();
        self.user_repository.save(&updated_user).await?;

        // 5. 生成 JWT Token
        let token = JwtUtils::generate_token(&updated_user)?;

        Ok(LoginUserResponse { token, ... })
    }
}
```

### 3.5 Repository 模式（保留）

```rust
// src/core/ports/mod.rs (接口定义)

#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn save(&self, user: &User) -> Result<()>;
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>>;
}

// src/adapters/persistence/postgres/user_repository.rs (实现)

#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>> {
        // ✅ 使用参数绑定防止 SQL 注入
        let row = sqlx::query("SELECT * FROM users WHERE phone = $1")
            .bind(phone)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("查询失败: {}", e)))?;

        // ... 转换为 User 实体
    }
}
```

---

## 4. 路由配置

### 4.1 路由注册

```rust
// src/framework/bootstrap/routes/auth.rs

pub fn create_auth_routes(app_state: AppState) -> Router {
    Router::new()
        .route(
            ApiPaths::LOGIN,
            post(login_handler).with_state(app_state.login_use_case.clone()),
        )
        .route(
            ApiPaths::REGISTER,
            post(register_handler).with_state(app_state.register_use_case.clone()),
        )
}
```

### 4.2 中间件配置

```rust
// src/framework/bootstrap/routes/app.rs

pub fn create_routes(app_state: AppState) -> Router {
    Router::new()
        .merge(create_auth_routes(app_state))
        .layer(middleware::from_fn(jwt_auth_middleware))        // JWT 认证
        .layer(middleware::from_fn(error_handling_middleware))  // 错误处理
        .layer(middleware::from_fn(request_response_data_log_middleware))  // 日志
        .layer(create_cors_layer(config.cors_origins()))        // CORS
}
```

---

## 5. 错误处理

### 5.1 领域错误定义

```rust
// src/core/errors.rs

#[derive(Error, Debug)]
pub enum DomainError {
    #[error("验证失败: {0}")]
    Validation(String),

    #[error("认证失败: {0}")]
    Authentication(String),

    #[error("资源已存在: {0}")]
    AlreadyExists(String),

    #[error("资源未找到: {0}")]
    NotFound(String),

    #[error("基础设施错误: {0}")]
    Infrastructure(String),
}
```

### 5.2 统一错误响应

```rust
// src/shared/api_response.rs

impl ApiResponse<Value> {
    pub fn from_domain_error(error: &DomainError) -> Self {
        match error {
            DomainError::Validation(msg) =>
                ApiResponse::error(ErrorCode::VALIDATION_FAILED, msg),
            DomainError::Authentication(msg) =>
                ApiResponse::error(ErrorCode::INVALID_CREDENTIALS, msg),
            DomainError::NotFound(msg) =>
                ApiResponse::error(ErrorCode::USER_NOT_FOUND, msg),
            // ...
        }
    }

    pub fn http_status(&self) -> StatusCode {
        match self.errorcode.unwrap_or(500) {
            100..=199 => StatusCode::BAD_REQUEST,
            200 => StatusCode::CONFLICT,      // USER_ALREADY_EXISTS
            201 => StatusCode::NOT_FOUND,     // USER_NOT_FOUND
            202 => StatusCode::UNAUTHORIZED,  // INVALID_CREDENTIALS
            // ...
        }
    }
}
```

---

## 6. 重构总结

### 6.1 架构优化

| 维度 | 重构前 | 重构后 | 改进 |
|------|--------|--------|------|
| **调用层数** | 5 层 | 4 层 | -20% 复杂度 |
| **Controller 层** | ✅ 存在 | ❌ 移除 | 减少冗余 |
| **类型安全** | `Value` | DTOs | ✅ 强类型 |
| **代码跳转** | 多 | 少 | ✅ 易维护 |
| **Use Case** | ✅ 保留 | ✅ 保留 | 核心价值 |
| **Repository** | ✅ 保留 | ✅ 保留 | 依赖倒置 |

### 6.2 保留的核心价值

✅ **Use Case 层**: 复杂业务逻辑编排（登录流程有多步骤）
✅ **Repository 模式**: 数据访问抽象，易于测试和替换
✅ **依赖倒置**: core 层不依赖外层，技术无关
✅ **Clean Architecture 理念**: 分层清晰，职责单一

### 6.3 移除的冗余

❌ **Controller 层**: 只是简单调用 Use Case，无额外价值
❌ **弱类型 Value**: 使用强类型 DTOs 替代
❌ **过度抽象**: 在保持架构优势的前提下简化

---

## 7. 最佳实践

### 7.1 命名规范

- **模块**: `snake_case`
- **结构体/Trait**: `PascalCase`
- **函数/变量**: `snake_case`
- **常量**: `SCREAMING_SNAKE_CASE`

### 7.2 错误处理

- ✅ 使用 `Result` 和 `?` 传播错误
- ✅ 避免 `unwrap()`，使用 `ok_or_else()`
- ✅ 为错误提供上下文信息

### 7.3 异步编程

- ✅ 使用 `async/await`
- ✅ 使用 `Arc` 共享所有权
- ✅ 避免在异步代码中阻塞

### 7.4 数据库安全

- ✅ 使用 SQLx 参数绑定（防止 SQL 注入）
- ✅ 使用连接池管理连接
- ✅ 正确处理 `Option` (`fetch_optional`)

---

## 8. 参考资料

- **架构分析**: `doc/architecture/ARCHITECTURE_ANALYSIS.md`
- **重构总结**: `doc/architecture/REFACTORING_SUMMARY.md`
- **Skills 指南**: `doc/guides/RUST_SKILLS_SETUP_GUIDE.md`
- **API 文档**: `doc/api/backend_api_documentation.md`

---

**文档版本**: v2.0 (Refactored)
**最后更新**: 2026-01-18
**架构**: Clean Architecture (Simplified - 4 Layers)
**技术栈**: Rust + Axum 0.8.4 + SQLx + PostgreSQL
