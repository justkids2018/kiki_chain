# Hi Kiki 项目代码实现规范 (Rust + Axum)

> **适用范围**: Hi Kiki 后端服务（Rust + Axum + SQLx + PostgreSQL）
> **架构**: Clean Architecture (4 Layers)
> **版本**: v2.0
> **最后更新**: 2026-01-19

---

## 📚 概述

本文档定义了 **Hi Kiki 项目专属** 的 Rust 代码实现规范。

**通用规范**: 请先阅读 [`COMMON.md`](./COMMON.md)

---

## 🏗️ 项目架构

### 目录结构（2026 重构后）

```
src/
├── core/                      # 核心层（业务逻辑）
│   ├── entities/             # 领域实体（User, etc.）
│   ├── use_cases/            # 用例（业务流程编排）✅ 保留
│   │   └── auth/
│   │       ├── login_user.rs
│   │       └── register_user.rs
│   ├── ports/                # 接口定义（Repository trait）✅ 保留
│   ├── errors.rs             # 领域错误（DomainError）
│   └── value_objects.rs      # 值对象（UserId）
│
├── adapters/                  # 适配器层（技术实现）
│   ├── http/                 # HTTP 适配器
│   │   └── auth/
│   │       ├── handlers.rs   # ✅ HTTP 处理器（直接调用 Use Case）
│   │       ├── dtos.rs       # ✅ 强类型 DTOs
│   │       └── mod.rs
│   └── persistence/          # 持久化适配器
│       └── postgres/
│           └── user_repository.rs  # Repository 实现
│
├── framework/                 # 框架层（启动、配置）
│   ├── bootstrap/
│   │   ├── container.rs      # ✅ 依赖注入（Use Case）
│   │   ├── routes/           # 路由汇总
│   │   └── mod.rs
│   └── logging.rs            # 日志配置
│
├── shared/                    # 共享模块
│   └── api_response.rs       # 统一 API 响应格式
│
├── utils/                     # 工具模块
│   ├── jwt.rs                # JWT 工具
│   └── http.rs               # HTTP 工具
│
├── config/                    # 配置模块
│   └── database.rs
│
├── lib.rs                     # 库入口
└── main.rs                    # 程序入口
```

**依赖方向**: `framework → adapters → core`

---

## 🔤 Rust 命名规范

### 1. 模块和文件

```rust
// ✅ 模块名：snake_case
mod user_repository;
mod login_user;
mod api_response;

// ✅ 文件名：snake_case.rs
// user_repository.rs
// login_user.rs
// api_response.rs
```

---

### 2. 类型和 Trait

```rust
// ✅ Struct：PascalCase
pub struct LoginUserCommand {
    pub identifier: String,
    pub password: String,
}

pub struct LoginUserUseCase { /* ... */ }

// ✅ Trait：PascalCase
pub trait UserRepository {
    async fn find_by_id(&self, id: &UserId) -> Result<Option<User>>;
}

// ✅ Enum：PascalCase，变体也是 PascalCase
#[derive(Error, Debug)]
pub enum DomainError {
    Validation(String),
    Authentication(String),
    Infrastructure(String),
}
```

---

### 3. 函数和变量

```rust
// ✅ 函数：snake_case，动词开头
pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> { }
fn validate_command(&self, command: &LoginUserCommand) -> Result<()> { }
async fn find_user(&self, identifier: &str) -> Result<User> { }

// ✅ 变量：snake_case
let user_name = "Alice";
let is_valid = true;
let max_retry_count = 3;

// ✅ 常量：SCREAMING_SNAKE_CASE
const MAX_POOL_SIZE: u32 = 10;
const DEFAULT_TIMEOUT: Duration = Duration::from_secs(30);

// ✅ 静态变量：SCREAMING_SNAKE_CASE
static JWT_SECRET: Lazy<String> = Lazy::new(|| { /* ... */ });
```

---

## 🧱 Clean Architecture 实现

### 1. Entity（领域实体）

```rust
// core/entities/user.rs
use chrono::{DateTime, Utc};
use crate::core::value_objects::UserId;
use crate::core::errors::Result;

#[derive(Debug, Clone)]
pub struct User {
    id: i32,
    uid: String,
    name: String,
    email: String,
    pwd: String,
    phone: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
    role_id: i32,
}

impl User {
    // ✅ 构造函数（新建实体）
    pub fn new(
        uid: String,
        name: String,
        email: String,
        pwd: String,
        phone: String,
        role_id: i32,
    ) -> Result<Self> {
        // 验证逻辑
        if name.trim().is_empty() {
            return Err(DomainError::Validation("姓名不能为空".to_string()));
        }

        Ok(Self {
            id: 0,
            uid,
            name,
            email,
            pwd,
            phone,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            role_id,
        })
    }

    // ✅ 重构函数（从数据库恢复）
    pub fn reconstruct(
        id: i32,
        uid: String,
        name: String,
        email: String,
        pwd: String,
        phone: String,
        created_at: DateTime<Utc>,
        updated_at: DateTime<Utc>,
        role_id: i32,
    ) -> Result<Self> {
        Ok(Self {
            id, uid, name, email, pwd, phone,
            created_at, updated_at, role_id,
        })
    }

    // ✅ Getter 方法
    pub fn uid(&self) -> &str { &self.uid }
    pub fn name(&self) -> &str { &self.name }
    pub fn email(&self) -> &str { &self.email }
    pub fn pwd(&self) -> &str { &self.pwd }
    pub fn phone(&self) -> &str { &self.phone }
    pub fn role_id(&self) -> i32 { self.role_id }

    // ✅ 业务方法
    pub fn update_timestamp(&mut self) {
        self.updated_at = Utc::now();
    }
}
```

---

### 2. Use Case（用例）

```rust
// core/use_cases/auth/login_user.rs
use std::sync::Arc;
use serde::{Deserialize, Serialize};
use tracing::{info, warn};

use crate::core::entities::User;
use crate::core::errors::{DomainError, Result};
use crate::core::ports::UserRepository;
use crate::utils::JwtUtils;

/// 登录命令
#[derive(Debug, Deserialize)]
pub struct LoginUserCommand {
    pub identifier: String,  // 手机号或邮箱
    pub password: String,
}

/// 登录响应
#[derive(Debug, Serialize)]
pub struct LoginUserResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub token: String,
    pub message: String,
    pub phone: String,
    pub role_id: i32,
}

/// 用户登录用例
pub struct LoginUserUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl LoginUserUseCase {
    pub fn new(user_repository: Arc<dyn UserRepository>) -> Self {
        Self { user_repository }
    }

    /// 执行登录流程
    pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> {
        info!("开始用户登录流程: identifier={}", command.identifier);

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

        info!("用户登录成功: uid={}", updated_user.uid());

        Ok(LoginUserResponse {
            uid: updated_user.uid().to_string(),
            name: updated_user.name().to_string(),
            email: updated_user.email().to_string(),
            token,
            message: "登录成功".to_string(),
            phone: updated_user.phone().to_string(),
            role_id: updated_user.role_id(),
        })
    }

    fn validate_command(&self, command: &LoginUserCommand) -> Result<()> {
        if command.identifier.trim().is_empty() {
            return Err(DomainError::Validation("手机号或邮箱不能为空".to_string()));
        }
        if command.password.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }
        Ok(())
    }

    async fn find_user(&self, identifier: &str) -> Result<User> {
        self.user_repository
            .find_by_phone(identifier)
            .await?
            .ok_or_else(|| DomainError::Authentication("用户不存在或密码错误".to_string()))
    }

    fn verify_password(&self, user: &User, password: &str) -> Result<()> {
        if user.pwd() != password {
            warn!("密码验证失败: uid={}", user.uid());
            return Err(DomainError::Authentication("用户不存在或密码错误".to_string()));
        }
        Ok(())
    }
}
```

---

### 3. Port（接口定义）

```rust
// core/ports/mod.rs
use async_trait::async_trait;
use crate::core::entities::User;
use crate::core::value_objects::UserId;
use crate::core::errors::Result;

#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn save(&self, user: &User) -> Result<()>;
    async fn find_by_id(&self, id: &UserId) -> Result<Option<User>>;
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>>;
    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>>;
}
```

---

### 4. Adapter - Repository 实现

```rust
// adapters/persistence/postgres/user_repository.rs
use async_trait::async_trait;
use sqlx::{PgPool, Row};
use chrono::{DateTime, Utc};

use crate::core::entities::User;
use crate::core::errors::{DomainError, Result};
use crate::core::ports::UserRepository;
use crate::core::value_objects::UserId;

#[derive(Clone)]
pub struct PostgresUserRepository {
    pool: PgPool,
}

impl PostgresUserRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn save(&self, user: &User) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO users (id, uid, name, email, pwd, phone, created_at, updated_at, role_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                email = EXCLUDED.email,
                pwd = EXCLUDED.pwd,
                phone = EXCLUDED.phone,
                updated_at = EXCLUDED.updated_at,
                role_id = EXCLUDED.role_id
            "#,
        )
        .bind(user.id())
        .bind(user.uid())
        .bind(user.name())
        .bind(user.email())
        .bind(user.pwd())
        .bind(user.phone())
        .bind(user.created_at())
        .bind(user.updated_at())
        .bind(user.role_id())
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("保存用户失败: {}", e)))?;

        Ok(())
    }

    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>> {
        // ✅ 使用参数绑定防止 SQL 注入
        let row = sqlx::query("SELECT * FROM users WHERE phone = $1")
            .bind(phone)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("查询用户失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = User::reconstruct(
                    row.get("id"),
                    row.get("uid"),
                    row.get("name"),
                    row.get("email"),
                    row.get("pwd"),
                    row.get("phone"),
                    row.get::<DateTime<Utc>, _>("created_at"),
                    row.get::<DateTime<Utc>, _>("updated_at"),
                    row.get("role_id"),
                )?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }
}
```

---

### 5. Adapter - HTTP Handler（2026 重构后）

```rust
// adapters/http/auth/handlers.rs

use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use std::sync::Arc;

use crate::core::use_cases::auth::{LoginUserCommand, LoginUserUseCase};
use crate::shared::api_response::ApiResponse;
use super::dtos::{LoginRequest, LoginResponse};

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

---

### 6. Adapter - HTTP DTOs

```rust
// adapters/http/auth/dtos.rs

use serde::{Deserialize, Serialize};

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
impl From<crate::core::use_cases::auth::LoginUserResponse> for LoginResponse {
    fn from(response: crate::core::use_cases::auth::LoginUserResponse) -> Self {
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

---

### 7. Framework - 依赖注入

```rust
// framework/bootstrap/container.rs

use std::sync::Arc;
use sqlx::PgPool;

use crate::core::use_cases::auth::{LoginUserUseCase, RegisterUserUseCase};
use crate::core::ports::UserRepository;
use crate::adapters::persistence::postgres::user_repository::PostgresUserRepository;

#[derive(Clone)]
pub struct AppState {
    // ✅ 直接注入 Use Case（移除 Controller）
    pub login_use_case: Arc<LoginUserUseCase>,
    pub register_use_case: Arc<RegisterUserUseCase>,
}

pub struct DependencyContainer {
    pub app_state: AppState,
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

---

## ⚠️ Rust 错误处理

### 错误定义（使用 thiserror）

```rust
// core/errors.rs
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DomainError {
    #[error("验证失败: {0}")]
    Validation(String),

    #[error("认证失败: {0}")]
    Authentication(String),

    #[error("未找到资源: {0}")]
    NotFound(String),

    #[error("权限不足: {0}")]
    PermissionDenied(String),

    #[error("基础设施错误: {0}")]
    Infrastructure(String),

    #[error("资源已存在: {0}")]
    AlreadyExists(String),
}

pub type Result<T> = std::result::Result<T, DomainError>;
```

---

### 错误传播（使用 ?）

```rust
// ✅ 好的写法：使用 ? 传播错误
pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> {
    self.validate_command(&command)?;  // 自动传播错误
    let user = self.find_user(&command.identifier).await?;  // 自动传播错误
    self.verify_password(&user, &command.password)?;
    Ok(response)
}

// ❌ 不好的写法：使用 unwrap()
pub async fn execute(&self, command: LoginUserCommand) -> LoginUserResponse {
    let user = self.find_user(&command.identifier).await.unwrap();  // ❌ 可能 panic
    response
}
```

---

### Option 处理

```rust
// ✅ 好的写法：使用 ok_or_else 转换为 Result
async fn find_user(&self, identifier: &str) -> Result<User> {
    self.user_repository
        .find_by_phone(identifier)
        .await?
        .ok_or_else(|| DomainError::Authentication("用户不存在".to_string()))
}

// ❌ 不好的写法：使用 unwrap()
async fn find_user(&self, identifier: &str) -> User {
    self.user_repository
        .find_by_phone(identifier)
        .await
        .unwrap()          // ❌ 可能 panic
        .unwrap()          // ❌ 可能 panic
}
```

---

## 🔄 异步编程（Tokio）

### 基本使用

```rust
use tokio::time::{sleep, Duration};
use std::sync::Arc;

// ✅ async 函数
pub async fn fetch_data() -> Result<String> {
    // 模拟异步操作
    sleep(Duration::from_millis(100)).await;
    Ok("data".to_string())
}

// ✅ 使用 Arc 共享所有权
pub struct MyService {
    repository: Arc<dyn UserRepository>,
}

impl MyService {
    pub fn new(repository: Arc<dyn UserRepository>) -> Self {
        Self { repository }
    }
}
```

---

### 并发执行多个异步任务

```rust
use tokio::try_join;

pub async fn load_all_data() -> Result<(User, Vec<Post>)> {
    let user_future = fetch_user();
    let posts_future = fetch_posts();

    // 并发执行，任一失败则返回错误
    let (user, posts) = try_join!(user_future, posts_future)?;

    Ok((user, posts))
}
```

---

## 🛣️ Axum 路由和中间件

### 路由注册

```rust
// framework/bootstrap/routes/auth.rs

use axum::{Router, routing::post};
use crate::adapters::http::auth::handlers::{login_handler, register_handler};
use crate::framework::bootstrap::container::AppState;

pub fn create_auth_routes(app_state: AppState) -> Router {
    Router::new()
        .route(
            "/api/v1/auth/login",
            post(login_handler).with_state(app_state.login_use_case.clone()),
        )
        .route(
            "/api/v1/auth/register",
            post(register_handler).with_state(app_state.register_use_case.clone()),
        )
}
```

---

### 中间件配置

```rust
// framework/bootstrap/routes/app.rs

use axum::{Router, middleware};
use tower_http::cors::CorsLayer;

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

## 📝 日志记录（tracing）

```rust
use tracing::{info, warn, error, debug};

pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> {
    // ✅ 记录关键操作
    info!("开始用户登录: identifier={}", command.identifier);

    // 业务逻辑...

    match self.verify_password(&user, &command.password) {
        Ok(_) => {
            info!("用户登录成功: uid={}", user.uid());
        }
        Err(e) => {
            warn!("密码验证失败: uid={}, error={}", user.uid(), e);
            return Err(e);
        }
    }

    Ok(response)
}
```

---

## ⛔ Rust Anti-Patterns

### ❌ 1. 跨层依赖

```rust
// ❌ 错误：core 层依赖 adapters 层
// core/use_cases/login_user.rs
use crate::adapters::persistence::postgres::PostgresUserRepository;  // 违反依赖倒置

// ✅ 正确：core 层只依赖 port（接口）
use crate::core::ports::UserRepository;  // 依赖抽象
```

---

### ❌ 2. 不必要的 clone

```rust
// ❌ 错误：不必要的 clone
fn process_user(user: &User) -> String {
    let user_clone = user.clone();  // 不必要
    user_clone.name().to_string()
}

// ✅ 正确：直接使用引用
fn process_user(user: &User) -> String {
    user.name().to_string()
}
```

---

### ❌ 3. 滥用 unwrap

```rust
// ❌ 错误：可能 panic
let user = repository.find_by_id(&id).await.unwrap();

// ✅ 正确：使用 ? 传播错误
let user = repository.find_by_id(&id).await?
    .ok_or_else(|| DomainError::NotFound("用户不存在".to_string()))?;
```

---

### ❌ 4. SQL 注入风险

```rust
// ❌ 错误：字符串拼接 SQL
let sql = format!("SELECT * FROM users WHERE phone = '{}'", phone);
sqlx::query(&sql).fetch_one(&pool).await?;

// ✅ 正确：使用参数绑定
sqlx::query("SELECT * FROM users WHERE phone = $1")
    .bind(phone)
    .fetch_one(&pool)
    .await?;
```

---

## ✅ Best Practices 检查清单

### 代码实现前

- [ ] 架构清晰 - 遵循 Clean Architecture 分层
- [ ] 依赖倒置 - core 层不依赖外层
- [ ] 命名规范 - 遵循 Rust 命名规范

### 代码实现中

- [ ] 错误处理 - 使用 Result 和 ? 传播错误
- [ ] 异步处理 - 正确使用 async/await
- [ ] SQL 安全 - 使用参数绑定
- [ ] 日志记录 - 使用 tracing 记录关键操作
- [ ] 类型安全 - 避免 unwrap()，使用类型系统

### 代码实现后

- [ ] 测试覆盖 - 为核心逻辑编写测试
- [ ] 代码审查 - 自动触发 code-review skill

---

## 📚 相关文档

- [`COMMON.md`](./COMMON.md) - 通用代码实现规范
- [`doc/architecture/clean_architecture_2026.md`](../../../doc/architecture/clean_architecture_2026.md) - Hi Kiki 架构文档
- [`doc/dev/development_guide.md`](../../../doc/dev/development_guide.md) - 开发指南

---

**版本**: v2.0 (Refactored)
**最后更新**: 2026-01-19
**架构**: Clean Architecture (4 Layers)
**技术栈**: Rust + Axum 0.8.4 + SQLx + PostgreSQL
