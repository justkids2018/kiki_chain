# 奇奇满有服务器 - 2025 最新 Clean Architecture 说明

> 更新时间：2025-08-15  
> 版本说明：基于 Stage5 清理后的真实代码结构整理，兼容层（application / infrastructure / presentation）已移除，仅保留核心三层与支撑模块。

---

## 1. 体系概览

### 1.1 目录结构与依赖方向

```
src/
├── core/            # 业务内核：实体、值对象、领域错误、端口、用例
├── adapters/        # 适配层：HTTP 控制器/路由/中间件，Postgres 仓储实现
├── framework/       # 框架层：启动流程、依赖注入、路由装配、日志模块
├── config/          # 配置加载与校验
├── shared/          # 跨层共享（API 响应包装等）
├── utils/           # 通用工具（JWT、HTTP header、错误类型别名等）
├── main.rs          # 应用入口，仅负责组合框架层接口
└── lib.rs           # 对外导出模块及常用类型
```

依赖方向保持**外层依赖内层**：

```
framework → adapters → core
         ↘ utils / shared (只提供通用能力)
```

- `core` 不依赖任何外层模块，只使用标准库与无副作用第三方库。
- `adapters` 实现 `core::ports` 定义的接口，负责技术细节。
- `framework` 负责组合，集中处理日志、配置、依赖注入和路由注册。
- `config`、`shared`、`utils` 为配套模块，可被外层复用但不直接反向依赖 `core`。

### 1.2 模块职责速览

| 模块 | 关键职责 | 代表文件 |
| --- | --- | --- |
| `core` | 业务模型与用例编排 | `core/use_cases/auth/login_user.rs`、`core/ports/mod.rs` |
| `adapters` | 技术实现（HTTP + DB） | `adapters/http/auth/controller.rs`、`adapters/persistence/postgres/user_repository.rs` |
| `framework` | 启动、依赖注入、日志 | `framework/bootstrap/container.rs`、`framework/logging.rs` |
| `config` | 环境配置加载与校验 | `config/mod.rs`、`config/development.toml` |
| `shared` | API 响应协议 | `shared/api_response.rs` |
| `utils` | JWT/HTTP/错误工具 | `utils/jwt.rs`、`utils/errors.rs` |

---

## 2. 登录功能调用链

### 2.1 HTTP 请求流程

```
POST /api/auth/login
     ↓
┌──────────────────────────────────────────────┐
│ Middleware Stack (adapters/http/middleware.rs)│
│ 1. request_response_data_log_middleware        │
│ 2. error_handling_middleware                  │
│ 3. jwt_auth_middleware（白名单跳过认证）         │
│ 4. CORS Layer                                  │
└──────────────────────────────────────────────┘
     ↓
AuthController::login (adapters/http/auth/controller.rs)
     ↓
LoginUserUseCase::execute (core/use_cases/auth/login_user.rs)
     ↓
UserRepository (core/ports) ←→ PostgresUserRepository (adapters/persistence)
     ↓
ToolUtils / JwtUtils (utils)
     ↓
ApiResponse::success / ApiResponse::from_domain_error (shared/api_response.rs)
```

### 2.2 时序图（概要）

```sequence
Client->Middleware: POST /api/auth/login
Middleware->AuthController: login(Json<Value>)
AuthController->LoginUserUseCase: execute(LoginUserCommand)
LoginUserUseCase->UserRepository: find_by_phone(identifier)
UserRepository->PostgresUserRepository: SQL 查询
PostgresUserRepository->UserRepository: Option<User>
LoginUserUseCase->ToolUtils: verify_password(password, hash)
LoginUserUseCase->JwtUtils: generate_token(user)
LoginUserUseCase->AuthController: LoginUserResponse
AuthController->Client: JSON ApiResponse
```

---

## 3. 核心组件关系

### 3.1 依赖注入容器

```
// src/framework/bootstrap/container.rs
PostgresUserRepository (adapters/persistence)
    ↓ implements
UserRepository trait (core/ports)
    ↓ injected into
LoginUserUseCase / RegisterUserUseCase (core/use_cases)
    ↓ wrapped by
AuthController (adapters/http/auth/controller.rs)
    ↓ exposed via
AppState (framework/bootstrap/container.rs)
```

`main.rs` 流程：

1. `init_logging()` → 初始化日志（framework/logging.rs）
2. `AppConfig::load()` → 读取环境配置
3. `init_database()` → 建立 `PgPool`
4. `DependencyContainer::new(pool)` → 构建 `AppState`
5. `create_routes(app_state)` → 组合 Axum Router
6. `axum::serve(listener, app)` → 开始监听

### 3.2 关键模块引用

```
core/
├── entities/mod.rs          # User 实体
├── errors.rs                # DomainError / Result
├── ports/mod.rs             # UserRepository trait
└── use_cases/auth/          # login_user.rs / register_user.rs

adapters/
├── http/
│   ├── auth/controller.rs   # AuthController
│   ├── auth/routes.rs       # Axum handler
│   └── middleware.rs        # 日志、错误、JWT 中间件
└── persistence/postgres/
    └── user_repository.rs   # PostgresUserRepository 实现

framework/
├── bootstrap/
│   ├── container.rs         # DependencyContainer + AppState
│   ├── routes/app.rs        # create_routes
│   ├── routes/auth.rs       # 认证路由注册
│   └── api_paths.rs         # 路由常量
└── logging.rs               # 日志配置与便捷宏
```

---

## 4. 关键方法与工具

### 4.1 控制器层

```rust
// src/adapters/http/auth/controller.rs
pub async fn login(&self, request: Value) -> Result<Value> {
    let command = LoginUserCommand::from_json(request)?;
    let response = self.login_use_case.execute(command).await?;
    Ok(response.into_json())
}
```

### 4.2 用例层

```rust
// src/core/use_cases/auth/login_user.rs
pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> {
    self.validate_command(&command)?;
    let user = self.find_user(&command.identifier).await?;
    self.verify_password(&user, &command.password)?;
    let token = JwtUtils::generate_token(&user)?;
    Ok(LoginUserResponse::new(user, token))
}
```

### 4.3 仓储实现

```rust
// src/adapters/persistence/postgres/user_repository.rs
#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>> {
        let row = sqlx::query_as::<_, UserRow>(...)
            .bind(phone)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(e.to_string()))?;
        Ok(row.map(User::from))
    }
    // ...
}
```

### 4.4 工具模块

- `utils/jwt.rs`：封装 `jsonwebtoken`，提供 `generate_token`、`verify_token`、`quick_init` 等方法。
- `utils/tool.rs`：封装 `bcrypt`，提供 `hash_password` / `verify_password`。
- `shared/api_response.rs`：统一成功 / 失败响应结构，并提供 `from_domain_error` 转换。

---

## 5. 中间件体系

文件：`src/adapters/http/middleware.rs`

1. `request_response_data_log_middleware`  
   - 记录 request / response payload、耗时、request_id。
2. `error_handling_middleware`  
   - 捕获业务错误并转换为统一 `ApiResponse`。
3. `jwt_auth_middleware`  
   - 支持白名单路径（`/api/auth/login`、`/api/auth/register`、`/health`），其他路径强制校验 JWT。
4. `create_cors_layer`  
   - 读取配置允许跨域。

Router 装配顺序：`src/framework/bootstrap/routes/app.rs`

```rust
Router::new()
    .merge(health_routes)
    .merge(auth_routes)
    .layer(middleware::from_fn(jwt_auth_middleware))
    .layer(middleware::from_fn(error_handling_middleware))
    .layer(middleware::from_fn(request_response_data_log_middleware))
    .layer(cors_layer);
```

---

## 6. 错误处理链路

```
utils::errors::Error  ↔  shared::ApiResponse::error(...)
          ↑                     ↑
      core::errors::DomainError ──┘
```

- `core/errors.rs` 定义领域错误枚举，并提供 `impl From<DomainError> for utils::errors::Error` 以便适配层统一处理。
- 控制器 / 中间件捕获 `DomainError` 后，通过 `ApiResponse::from_domain_error` 生成对应 HTTP 状态码与错误码。

---

## 7. 配置与环境

目录：`config/`

| 文件 | 说明 |
| --- | --- |
| `development.toml` | 开发环境默认配置 |
| `pre-release.toml` | 预发布环境 |
| `production.toml` | 生产环境 |
| `app.toml` | 通用占位（当前主要使用分环境配置） |

加载流程（`config/mod.rs`）：

1. 读取 `.env` 与 `ENVIRONMENT` 环境变量。
2. 加载对应 `config/{environment}.toml`。
3. 环境变量覆盖配置文件。
4. 校验 `JWT_SECRET`、`DATABASE_URL` 等关键配置。
5. 对开发环境缺失密钥提供安全提示与默认值。

`framework/bootstrap/mod.rs` 根据环境自动选择日志级别并初始化 `Logger`。

---

## 8. 数据库集成

- 连接池：`sqlx::PgPool`（`framework/bootstrap/mod.rs::init_database`）。
- 表访问：`PostgresUserRepository` 通过 `sqlx::query` / `query_as` 执行 SQL。
- DTO → Entity 转换由 `User::from` 或相关构造函数负责，确保 `core` 中的实体保持业务语义。

---

## 9. 日志体系

文件：`src/framework/logging.rs`

- `LogConfig`：支持 development / production / from_env 三种初始化方式。
- `Logger`：封装 `tracing` 初始化与常用日志方法（info / warn / error / debug / json）。
- 宏 `log_info!`、`log_error!` 等已重定向到 `framework::logging`，供全局使用。
- 中间件会输出结构化 JSON 日志，包含 request_id、耗时等字段；数据库事件、启动事件也使用定制前缀 emoji 便于筛选。

---

## 10. 阶段总结与后续计划

当前阶段（Stage5）成果：
- ✅ 目录结构完全切换至 `core / adapters / framework` 主干。
- ✅ Logging 模块迁移至 `framework`，兼容层彻底移除。
- ✅ 文档、架构说明与实际代码保持一致。
- ✅ `cargo fmt`、`cargo check`、`cargo test` 均通过。

下一阶段（Stage6）重点：
1. 补充核心用例与适配层的单元 / 集成测试，确保行为稳定。
2. 对历史文档（`doc/dev/*`）标注“归档示例”或更新引用路径。
3. 视情况优化 Clippy 提示（实现 `Display`、改进中间件小细节等）。

该架构同时兼顾 Clean Architecture 的依赖方向与实际项目的落地成本，适合持续扩展更多业务上下文。
