# Clean Architecture 业务开发指南（示例：用户查询功能）

> 更新时间：2025-08-15  
> 适用范围：基于 `core / adapters / framework` 新架构开发任何业务功能（以“用户查询”/“登录”逻辑为范例）

---

## 1. 开发目标与原则

1. **依赖方向**：外层依赖内层，绝不反向引用  
   `framework → adapters → core`（`utils`、`shared` 为横向工具）
2. **分层职责**：
   - `core`：业务语义（实体、值对象、错误、端口、用例）
   - `adapters`：技术实现（HTTP、持久化、中间件等）
   - `framework`：启动、依赖注入、路由装配、日志
3. **统一风格**：沿用登录功能的组织方式，确保新旧代码可拼装、可复用。

---

## 2. 功能开发总览

| 步骤 | 层级 | 目标 | 登录功能参考 |
| --- | --- | --- | --- |
| 1 | 需求澄清 | 输入/输出 & 场景流程 | `core/use_cases/auth/login_user.rs` |
| 2 | 领域建模 | 实体/值对象/端口 | `core/entities/mod.rs`、`core/ports/mod.rs` |
| 3 | 用例实现 | 编排业务逻辑 | `LoginUserUseCase::execute` |
| 4 | 持久化适配 | 实现端口接口 | `PostgresUserRepository` |
| 5 | HTTP 控制器 | 请求校验 + 调用用例 + 响应包装 | `adapters/http/auth/controller.rs` |
| 6 | 路由/中间件 | 注册路由，复用通用中间件 | `framework/bootstrap/routes` |
| 7 | 依赖注入 | 将新功能接入容器 | `framework/bootstrap/container.rs` |
| 8 | 测试/文档 | 单元测试、开发指南更新 | 本文即示例 |

---

## 3. 领域建模（core）

### 3.1 实体 & 值对象

- 位置：`src/core/entities/`、`src/core/value_objects.rs`
- 动作：
  1. 确认是否需要新增实体属性或值对象
  2. 添加业务校验逻辑（若涉业务规则建议封装为值对象）
  3. 避免直接暴露技术字段（如密码 hash）

> 登录示例：`User` 实体 + `Email` 值对象（若有）

### 3.2 领域错误

- 位置：`src/core/errors.rs`
- 约定：新业务错误优先复用已有枚举；如需新增 enum variant，确保在转换为 `utils::errors::Error`时有合理映射。

### 3.3 端口接口

- 位置：`src/core/ports/mod.rs`
- 步骤：
  1. 定义领域侧需要的能力（trait + async fn）
  2. 返回类型统一使用 `core::errors::Result`
  3. 避免出现技术细节（如 SQL 语句）

```rust
#[async_trait]
pub trait UserQueryPort: Send + Sync {
    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>>;
    async fn list_by_role(&self, role_id: i32) -> Result<Vec<User>>;
}
```

### 3.4 用例实现

- 位置：`src/core/use_cases/<bounded_context>/`
- 模板结构（参考 `auth/login_user.rs`）：
  - `Command`：输入参数
  - `Response`：输出结构
  - `UseCase`：构造函数、`execute` 方法、必要的私有步骤
  - 日志/工具调用使用 `Logger` / `ToolUtils` / `JwtUtils` 等

```rust
pub struct QueryUserUseCase {
    user_port: Arc<dyn UserQueryPort>,
}

impl QueryUserUseCase {
    pub async fn execute(&self, cmd: QueryUserCommand) -> Result<QueryUserResponse> {
        // 1. 输入校验
        // 2. 调用端口（持久化/外部服务）
        // 3. 组合业务响应
    }
}
```

---

## 4. 技术适配（adapters）

### 4.1 持久化实现

- 位置：`src/adapters/persistence/postgres/`
- 命名建议：`<bounded_context>_repository.rs`
- 参考 `user_repository.rs`：
  - 构造函数 `new(pool: PgPool)`
  - 实现 `core::ports` trait
  - 处理 SQL、错误转换、日志

```rust
#[async_trait]
impl UserQueryPort for PostgresUserRepository {
    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>> {
        // sqlx::query_as::<_, UserRow>(...)
        // map to Domain model
    }
}
```

### 4.2 HTTP 控制器 & 请求处理

- 位置：`src/adapters/http/<bounded_context>/`
- 组织结构：
  - `controller.rs`：负责 JSON 校验、调用用例、统一封装 `ApiResponse`
  - `routes.rs`：定义 Axum handler（`State<AppState>` + `Json`）
  - `mod.rs`：导出 `pub use`

控制器模板：

```rust
pub struct UserQueryController {
    query_use_case: Arc<QueryUserUseCase>,
}

impl UserQueryController {
    pub async fn query(&self, request: Value) -> Result<Value> {
        let command = QueryUserCommand::from_json(request)?;
        let response = self.query_use_case.execute(command).await?;
        Ok(response.into_json())
    }
}
```

路由模板（参考 `adapters/http/auth/routes.rs`）：

```rust
pub async fn query_user<S>(
    State(state): State<S>,
    JsonExtract(request): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)>
where
    S: UserQueryControllerProvider,
{
    let controller = state.user_query_controller();
    match controller.query(request).await {
        Ok(value) => Ok(Json(ApiResponse::success(value, "查询成功"))),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}
```

### 4.3 中间件复用

- 无需重复造轮子：`request_response_data_log_middleware`、`error_handling_middleware`、`jwt_auth_middleware` 已在启动层统一装配。
- 若新业务需要白名单，可扩展已有 `whitelist_paths`。

---

## 5. 框架组合（framework）

### 5.1 依赖注入

- 修改 `src/framework/bootstrap/container.rs`
  1. 创建必要的仓储实例
  2.创建对应用例
  3.构造控制器
  4. 添加到 `AppState`

```rust
pub struct AppState {
    pub auth_controller: Arc<AuthController>,
    pub user_query_controller: Arc<UserQueryController>, // 新增
}

impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        // ...
        let user_query_use_case = Arc::new(QueryUserUseCase::new(user_repository.clone()));
        let user_query_controller = Arc::new(UserQueryController::new(user_query_use_case));

        let app_state = AppState {
            auth_controller,
            user_query_controller,
        };
        Self { app_state }
    }
}
```

> 若控制器需要通过 trait 暴露，仿照 `AuthControllerProvider` 新增 provider trait。

### 5.2 路由注册

- 文件：`src/framework/bootstrap/routes/auth.rs` 等
- 步骤：
  1. 新建 `<feature>.rs`（如 `user.rs`）注册 Axum 路由
  2. 在 `routes/mod.rs` 下 `pub mod user;` 并在 `create_routes` 时 `merge`
  3. 路径常量写入 `api_paths.rs`

```rust
pub fn create_user_routes<S>(state: S) -> Router
where
    S: Clone + Send + Sync + UserQueryControllerProvider + 'static,
{
    Router::new().route(ApiPaths::USER_QUERY, post(query_user)).with_state(state)
}
```

---

## 6. 文档与测试

### 6.1 必备检查清单

- [ ] `core` 层新增实体/端口/用例并通过 `cargo check`
- [ ] `adapters` 层实现 trait，SQL 语句有单元测试或经过验证
- [ ] `framework` 容器/路由已注册，`main.rs` 无需改动
- [ ] 新增 API 文档或更新 OpenAPI（若存在）
- [ ] 运行 `cargo fmt` / `cargo clippy`（处理关键警告）/ `cargo test`
- [ ] 更新相关开发文档、README 小节

### 6.2 建议的测试策略

1. **用例单测**：针对 `QueryUserUseCase` 使用内存仓储或 Mock（借助 trait object）
2. **适配层集成测试**：可结合 `sqlx::test` 或准备测试数据库
3. **路由端到端测试**：使用 `axum::Router::oneshot` + `httpc-test`

---

## 7. 常见问题与解法

| 问题 | 原因 | 处理方式 |
| --- | --- | --- |
| `could not find module` | 忘记在 `mod.rs` 中声明 | 检查 `core/use_cases/mod.rs`、`adapters/http/mod.rs` 等 |
| `trait object has no method` | 未在 AppState 使用 `Arc<dyn Trait>` | 确保用例结构体持有 trait object |
| `JWT 校验失败` | 未在框架层初始化 `JwtUtils` | 启动时调用 `JwtUtils::quick_init()` |
| 响应格式不一致 | 未使用 `ApiResponse` | 控制器统一返回 `ApiResponse::success/::from_domain_error` |
| 多层日志重复 | 手动 `println!` | 统一使用 `Logger` 或中间件日志 |

---

## 8. 扩展建议

1. **命令/响应复用**：若多个接口共用输入输出，可放入 `core/use_cases/<feature>/dto.rs`
2. **领域服务**：跨聚合逻辑可在 `core` 新增 `services` 目录
3. **共享工具**：共用中间件、响应包装可沉淀到 `utils` / `shared`
4. **文档模板**：复制本文档更新具体功能步骤，保证团队统一执行

---

借鉴登录功能的实现范式，按照以上步骤即可在新架构下快速、安全地拓展业务功能。若遇特殊需求（如调用外部服务、引入缓存），优先在 `core` 定义抽象，再在 `adapters` 提供对应实现，以保持架构稳定性。***
