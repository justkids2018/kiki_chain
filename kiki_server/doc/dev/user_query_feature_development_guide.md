# 用户信息查询功能开发指南

## 概述

本文档详细记录了用户信息查询功能的完整开发过程，基于项目的DDD架构，提供从设计到实现的每一步操作指导。此功能支持通过uid或role_id查询用户信息。

## 功能需求

- **按uid查询**: 根据用户唯一标识获取单个用户信息
- **按role_id查询**: 根据角色ID获取用户列表
- **统一响应格式**: 使用项目标准的ApiResponse结构
- **错误处理**: 完善的错误处理和日志记录

## 开发架构

基于DDD (Domain-Driven Design) 分层架构：

```
Domain Layer (领域层)      ← 核心业务逻辑，不依赖外部
Application Layer (应用层)  ← 用例编排，协调领域对象
Infrastructure Layer (基础设施层) ← 数据库、外部服务
Presentation Layer (表现层) ← HTTP接口、请求响应处理
Routes Layer (路由层)      ← HTTP路由配置
```

## 实现步骤

### 第一步：领域层确认 (Domain Layer)

#### 1.1 用户实体定义
**文件**: `src/domain/entities.rs`

确认User实体包含所需字段：
```rust
#[derive(Debug, Clone, Serialize)]
pub struct User {
    pub id: Uuid,
    pub uid: String,
    pub name: String,
    pub email: String,
    #[serde(skip_serializing)]
    pub pwd: String,
    pub phone: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub role_id: i32,   // 支持按角色查询
}
```

#### 1.2 仓储接口定义
**文件**: `src/domain/repositories.rs`

确认UserRepository接口包含查询方法：
```rust
#[async_trait]
pub trait UserRepository: Send + Sync {
    /// 根据uid查找用户
    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>>;
    
    /// 根据角色查找用户
    async fn find_users_by_role(&self, role_id: i32) -> Result<Vec<User>>;
    
    // ... 其他方法
}
```

### 第二步：基础设施层实现 (Infrastructure Layer)

#### 2.1 数据库查询实现
**文件**: `src/infrastructure/persistence/postgres_user_repository.rs`

实现具体的数据库查询逻辑：
```rust
#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>> {
        let row = sqlx::query("SELECT * FROM \"users\" WHERE \"uid\" = $1")
            .bind(uid)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::DatabaseError(e.to_string()))?;
            
        match row {
            Some(row) => Ok(Some(User::from_row(&row)?)),
            None => Ok(None),
        }
    }

    async fn find_users_by_role(&self, role_id: i32) -> Result<Vec<User>> {
        let rows = sqlx::query("SELECT * FROM \"users\" WHERE \"role_id\" = $1")
            .bind(role_id)
            .fetch_all(&self.pool)
            .await
            .map_err(|e| DomainError::DatabaseError(e.to_string()))?;
            
        let users = rows.into_iter()
            .map(|row| User::from_row(&row))
            .collect::<Result<Vec<_>>>()?;
            
        Ok(users)
    }
}
```

### 第三步：应用层开发 (Application Layer)

#### 3.1 创建用例目录
```bash
mkdir -p src/application/use_cases/user
```

#### 3.2 获取用户用例实现
**文件**: `src/application/use_cases/user/get_user.rs`

```rust
use std::sync::Arc;
use crate::domain::entities::User;
use crate::domain::repositories::UserRepository;
use crate::domain::errors::Result;
use serde::{Deserialize, Serialize};

/// 获取用户命令 - 封装查询参数
#[derive(Deserialize)]
pub struct GetUserCommand {
    pub uid: Option<String>,
    pub role_id: Option<i32>,
}

/// 获取用户响应 - 封装返回结果
#[derive(Serialize)]
pub enum GetUserResponse {
    User(Option<User>),      // 单个用户查询结果
    Users(Vec<User>),        // 多个用户查询结果
}

/// 获取用户用例 - 核心业务逻辑
pub struct GetUserUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl GetUserUseCase {
    pub fn new(user_repository: Arc<dyn UserRepository>) -> Self {
        Self { user_repository }
    }

    /// 执行获取用户操作
    pub async fn execute(&self, command: GetUserCommand) -> Result<GetUserResponse> {
        // 优先处理uid查询（精确查询）
        if let Some(uid) = command.uid {
            let user = self.user_repository.find_by_uid(&uid).await?;
            return Ok(GetUserResponse::User(user));
        }

        // 处理role_id查询（批量查询）
        if let Some(role_id) = command.role_id {
            let users = self.user_repository.find_users_by_role(role_id).await?;
            return Ok(GetUserResponse::Users(users));
        }

        // 无查询条件时返回空结果
        Ok(GetUserResponse::Users(vec![]))
    }
}
```

#### 3.3 更新模块声明
**文件**: `src/application/use_cases/user/mod.rs`
```rust
pub mod get_user;
pub use get_user::*;
```

**文件**: `src/application/use_cases/mod.rs`
```rust
pub mod auth;
pub mod assignment;
pub mod student;
pub mod user;  // 新增

pub use auth::*;
pub use assignment::*;
pub use student::*;
pub use user::*;  // 新增
```

### 第四步：表现层开发 (Presentation Layer)

#### 4.1 创建控制器目录
```bash
mkdir -p src/presentation/http/user
```

#### 4.2 用户控制器实现
**文件**: `src/presentation/http/user/user_controller.rs`

```rust
use std::sync::Arc;
use axum::extract::Query;
use serde_json::{json, Value};
use crate::{
    application::use_cases::user::get_user::{GetUserUseCase, GetUserCommand, GetUserResponse},
    domain::errors::Result,
    shared::api_response::{ApiResponse, ErrorCode},
};

/// 用户控制器 - 处理HTTP请求响应
pub struct UserController {
    get_user_use_case: Arc<GetUserUseCase>,
}

impl UserController {
    pub fn new(get_user_use_case: Arc<GetUserUseCase>) -> Self {
        Self { get_user_use_case }
    }

    /// 获取用户信息接口
    /// 支持通过uid或role_id查询用户信息
    /// 返回统一的ApiResponse格式
    pub async fn get_user(&self, Query(command): Query<GetUserCommand>) -> Result<ApiResponse<Value>> {
        // 验证查询参数
        if command.uid.is_none() && command.role_id.is_none() {
            let error_response: ApiResponse<Value> = ApiResponse::error(
                ErrorCode::MISSING_PARAMETER,
                "缺少查询参数：需要提供uid或role_id"
            );
            return Ok(error_response);
        }

        // 执行业务逻辑
        let response = self.get_user_use_case.execute(command).await?;
        
        // 格式化响应数据
        let (json_response, message) = match response {
            GetUserResponse::User(Some(user)) => {
                (json!({ "user": user }), "获取用户信息成功".to_string())
            },
            GetUserResponse::User(None) => {
                let error_response: ApiResponse<Value> = ApiResponse::error(
                    ErrorCode::USER_NOT_FOUND,
                    "未找到指定的用户"
                );
                return Ok(error_response);
            },
            GetUserResponse::Users(users) => {
                if users.is_empty() {
                    (json!({ "users": [] }), "没有找到符合条件的用户".to_string())
                } else {
                    (json!({ "users": users }), format!("获取用户列表成功，共{}个用户", users.len()))
                }
            },
        };
        
        Ok(ApiResponse::success(json_response, message))
    }
}
```

#### 4.3 更新模块声明
**文件**: `src/presentation/http/user/mod.rs`
```rust
pub mod user_controller;
pub use user_controller::*;
```

**文件**: `src/presentation/http/mod.rs`
```rust
pub mod auth_controller;
pub mod assignment_controller;
pub mod student_controller;
pub mod user;  // 新增
pub mod middleware;

pub use auth_controller::AuthController;
pub use assignment_controller::AssignmentController;
pub use student_controller::StudentController;
pub use user::user_controller::UserController;  // 新增
```

### 第五步：路由层配置 (Routes Layer)

#### 5.1 用户路由配置
**文件**: `src/app/routes/user.rs`

```rust
use axum::{routing::get, Router, extract::{Query, State}, response::Json, http::StatusCode};
use serde_json::Value;
use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::{
    application::use_cases::user::get_user::GetUserCommand,
    shared::api_response::ApiResponse,
};

/// 创建用户相关路由
pub fn create_user_routes(app_state: AppState) -> Router {
    Router::new()
        .route(ApiPaths::USER_INFO, get(get_user_handler))
        .with_state(app_state)
}

/// 获取用户信息处理器
/// 使用标准的ApiResponse格式进行错误处理
pub async fn get_user_handler(
    State(state): State<AppState>,
    query: Query<GetUserCommand>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state.user_controller.get_user(query).await {
        Ok(response) => {
            tracing::info!("✅ [获取用户信息] 成功");
            Ok(Json(response))
        },
        Err(e) => {
            tracing::warn!("🚫 [获取用户信息] 失败: {:?}", e);
            let error_response = ApiResponse::from_domain_error(&e);
            let status_code = error_response.http_status();
            Err((status_code, Json(error_response)))
        }
    }
}
```

#### 5.2 路由模块更新
**文件**: `src/app/routes/mod.rs`
```rust
pub mod assignment;
pub mod student;
pub mod auth;
pub mod user;         // 新增
pub mod main_routes;

pub use main_routes::create_routes;
```

#### 5.3 主路由集成
**文件**: `src/app/routes/main_routes.rs`

在`create_routes`函数中添加：
```rust
pub fn create_routes(app_state: AppState) -> Router {
    // 健康检查路由
    let health_routes = Router::new()
        .route("/health", get(health_check));
    
    // 业务模块路由
    let auth_routes = auth::create_auth_routes(app_state.clone());
    let assignment_routes = assignment::create_assignment_routes(app_state.clone());
    let student_routes = student::create_student_routes(app_state.clone());
    let user_routes = user::create_user_routes(app_state.clone());  // 新增
    
    // 合并所有路由
    let app_router = Router::new()
        .merge(health_routes)
        .merge(auth_routes)
        .merge(assignment_routes)
        .merge(student_routes)
        .merge(user_routes)  // 新增
        .layer(
            ServiceBuilder::new()
                .layer(HandleErrorLayer::new(|error: BoxError| async move {
                    if error.is::<tower::timeout::error::Elapsed>() {
                        Ok(StatusCode::REQUEST_TIMEOUT)
                    } else {
                        Err((
                            StatusCode::INTERNAL_SERVER_ERROR,
                            format!("Unhandled internal error: {}", error),
                        ))
                    }
                }))
                .timeout(Duration::from_secs(10))
                .layer(TraceLayer::new_for_http()),
        );
    
    app_router
}
```

### 第六步：依赖注入配置

#### 6.1 应用状态更新
**文件**: `src/app/dependency_container.rs`

```rust
use crate::presentation::http::UserController;

#[derive(Clone)]
pub struct AppState {
    pub auth_controller: Arc<AuthController>,
    pub assignment_controller: Arc<qiqimanyou_server::presentation::http::AssignmentController>,
    pub student_controller: Arc<qiqimanyou_server::presentation::http::StudentController>,
    pub user_controller: Arc<UserController>,  // 新增
}
```

#### 6.2 依赖注入实现
```rust
impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        // 基础设施层 - 仓储
        let user_repository = Arc::new(PostgresUserRepository::new(pool.clone()));
        let assignment_repository = Arc::new(PostgresAssignmentRepository::new(pool.clone()));
        let student_repository = Arc::new(PostgresStudentRepository::new(pool.clone()));
        
        // 应用层 - 用例
        let login_use_case = Arc::new(LoginUseCase::new(user_repository.clone()));
        let get_user_use_case = Arc::new(GetUserUseCase::new(user_repository.clone()));  // 新增
        let create_assignment_use_case = Arc::new(CreateAssignmentUseCase::new(assignment_repository.clone()));
        let get_assignments_use_case = Arc::new(GetAssignmentsUseCase::new(assignment_repository.clone()));
        let get_students_use_case = Arc::new(GetStudentsUseCase::new(student_repository.clone()));
        
        // 表现层 - 控制器
        let auth_controller = Arc::new(AuthController::new(login_use_case));
        let user_controller = Arc::new(UserController::new(get_user_use_case));  // 新增
        let assignment_controller = Arc::new(qiqimanyou_server::presentation::http::AssignmentController::new(
            create_assignment_use_case,
            get_assignments_use_case,
        ));
        let student_controller = Arc::new(qiqimanyou_server::presentation::http::StudentController::new(
            get_students_use_case,
        ));
        
        let app_state = AppState {
            auth_controller,
            assignment_controller,
            student_controller,
            user_controller,  // 新增
        };
        
        Self { app_state }
    }
}
```

### 第七步：API路径配置

#### 7.1 API路径常量
**文件**: `src/app/api_paths.rs`

```rust
pub struct ApiPaths;

impl ApiPaths {
    // 认证相关
    pub const LOGIN: &'static str = "/api/auth/login";
    
    // 用户相关  
    pub const USER_INFO: &'static str = "/api/user";  // 新增
    
    // 作业相关
    pub const ASSIGNMENTS: &'static str = "/api/assignments";
    pub const ASSIGNMENT_CREATE: &'static str = "/api/assignment";
    
    // 学生相关
    pub const STUDENTS: &'static str = "/api/students";
}
```

### 第八步：编译验证

#### 8.1 检查编译
```bash
cargo check
```

确保所有代码编译通过，没有错误和警告。

#### 8.2 运行项目
```bash
cargo run
```

## API使用指南

### 接口地址
- **GET** `/api/user?uid={uid}` - 根据uid获取用户
- **GET** `/api/user?role_id={role_id}` - 根据角色获取用户列表

### 请求示例

#### 按uid查询
```bash
curl "http://localhost:8080/api/user?uid=123456"
```

#### 按role_id查询
```bash
curl "http://localhost:8080/api/user?role_id=1"
```

### 响应格式

#### 成功响应 - 单个用户
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "uid": "123456",
      "name": "张三",
      "email": "zhangsan@example.com", 
      "phone": "13888888888",
      "created_at": "2025-01-15T10:30:00Z",
      "updated_at": "2025-01-15T10:30:00Z",
      "role_id": 1
    }
  },
  "message": "获取用户信息成功"
}
```

#### 成功响应 - 用户列表（详细信息）
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "uid": "123456",
        "name": "张三",
        "email": "zhangsan@example.com", 
        "phone": "13888888888",
        "created_at": "2025-01-15T10:30:00Z",
        "updated_at": "2025-01-15T10:30:00Z",
        "role_id": 1
      }
    ]
  },
  "message": "获取用户列表成功，共1个用户"
}
```

#### 成功响应 - 空结果
```json
{
  "success": true,
  "data": {
    "users": []
  },
  "message": "没有找到符合条件的用户"
}
```

#### 错误响应示例

##### 参数缺失错误
```json
{
  "success": false,
  "errorcode": 101,
  "message": "缺少查询参数：需要提供uid或role_id"
}
```

##### 用户不存在错误
```json
{
  "success": false,
  "errorcode": 201,
  "message": "未找到指定的用户"
}
```

##### 系统错误
```json
{
  "success": false,
  "errorcode": 501,
  "message": "数据库错误: 连接超时"
}
```

## 功能优化改进

### 优化概述
基于开发规范要求，对用户信息查询功能进行了以下关键优化：
- **统一错误处理**: 严格按照 `api_response.rs` 的 `success` 和 `error` 方式
- **参数验证**: 增加查询参数的前置验证
- **精确错误码**: 使用预定义的错误码进行精确错误分类
- **详细响应消息**: 提供更详细和用户友好的响应消息

### 1. 控制器层优化

#### 1.1 参数验证增强
```rust
// 验证查询参数
if command.uid.is_none() && command.role_id.is_none() {
    let error_response: ApiResponse<Value> = ApiResponse::error(
        ErrorCode::MISSING_PARAMETER,
        "缺少查询参数：需要提供uid或role_id"
    );
    return Ok(error_response);
}
```

#### 1.2 结果处理优化
```rust
// 格式化响应数据
let (json_response, message) = match response {
    GetUserResponse::User(Some(user)) => {
        (json!({ "user": user }), "获取用户信息成功".to_string())
    },
       GetUserResponse::User(None) => {
           return Ok(ApiResponse::error(
               ErrorCode::USER_NOT_FOUND,
               "未找到指定的用户"
           ));
       GetUserResponse::User(None) => {
           return Ok(ApiResponse::error(
               ErrorCode::USER_NOT_FOUND,
               "未找到指定的用户"
           ));
       GetUserResponse::User(None) => {
           return Ok(ApiResponse::error(
               ErrorCode::USER_NOT_FOUND,
               "未找到指定的用户"
           ));
       GetUserResponse::User(None) => {
           return Ok(ApiResponse::error(
               ErrorCode::USER_NOT_FOUND,
               "未找到指定的用户"
           ));
       GetUserResponse::User(None) => {
           return Ok(ApiResponse::error(
               ErrorCode::USER_NOT_FOUND,
               "未找到指定的用户"
           ));
       GetUserResponse::User(None) => {
           return Ok(ApiResponse::error(
               ErrorCode::USER_NOT_FOUND,
               "未找到指定的用户"
           ));
       GetUserResponse::User(None) => {
           return Ok(ApiResponse::error(
               ErrorCode::USER_NOT_FOUND,
               "未找到指定的用户"
           ));
    GetUserResponse::Users(users) => {
        if users.is_empty() {
            (json!({ "users": [] }), "没有找到符合条件的用户".to_string())
        } else {
            (json!({ "users": users }), format!("获取用户列表成功，共{}个用户", users.len()))
        }
    },
};
```

### 2. 路由层优化

#### 2.1 标准错误处理
```rust
pub async fn get_user_handler(
    State(state): State<AppState>,
    query: Query<GetUserCommand>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state.user_controller.get_user(query).await {
        Ok(response) => {
            tracing::info!("✅ [获取用户信息] 成功");
            Ok(Json(response))
        },
        Err(e) => {
            tracing::warn!("🚫 [获取用户信息] 失败: {:?}", e);
            let error_response = ApiResponse::from_domain_error(&e);
            let status_code = error_response.http_status();
            Err((status_code, Json(error_response)))
        }
    }
}
```

### 3. 优化后的响应格式

#### 3.1 参数缺失错误
```json
{
  "success": false,
  "errorcode": 101,
  "message": "缺少查询参数：需要提供uid或role_id"
}
```

#### 3.2 用户不存在错误
```json
{
  "success": false,
  "errorcode": 201,
  "message": "未找到指定的用户"
}
```

#### 3.3 详细成功响应
```json
{
  "success": true,
  "data": {
    "users": [...]
  },
  "message": "获取用户列表成功，共3个用户"
}
```

### 4. 优化效果

#### 4.1 错误处理标准化
- **统一格式**: 所有错误都使用 `ApiResponse::error()` 方法
- **精确错误码**: 使用预定义的 `ErrorCode` 常量
- **HTTP状态码**: 自动映射到合适的HTTP状态码

#### 4.2 用户体验提升
- **参数验证**: 前置验证避免无效请求
- **详细消息**: 提供清晰的操作结果说明
- **空结果处理**: 优雅处理查询无结果的情况

#### 4.3 开发维护性
- **类型安全**: 明确的类型注释避免编译错误
- **错误追踪**: 完整的日志记录便于问题排查
- **代码复用**: 使用统一的错误处理机制

## 技术要点总结

### 1. DDD架构原则
- **依赖倒置**: 外层依赖内层，内层不依赖外层
- **关注点分离**: 每层职责单一明确
- **接口抽象**: 使用trait定义抽象接口

### 2. 代码组织
- **模块化**: 按功能和层次组织代码结构
- **命名规范**: 使用清晰的英文命名
- **文档注释**: 为公共接口提供文档

### 3. 错误处理
- **统一错误类型**: 使用领域层定义的Result类型
- **错误转换**: 在边界层进行错误类型转换
- **日志记录**: 记录关键操作和错误信息

### 4. 响应格式
- **统一结构**: 所有API使用相同的响应格式
- **成功失败标识**: 明确的success字段
- **错误码机制**: 使用errorcode标识具体错误类型

## 开发流程最佳实践

1. **自底向上**: 从领域层开始，逐层向上实现
2. **接口优先**: 先定义接口，再实现具体逻辑
3. **测试驱动**: 编写测试用例验证功能
4. **增量开发**: 小步快跑，频繁验证
5. **代码审查**: 确保代码质量和架构一致性
6. **标准化响应**: 严格按照 `api_response.rs` 规范处理所有响应
7. **参数验证**: 在控制器层进行前置参数验证
8. **错误分类**: 使用预定义错误码进行精确错误分类

## 开发检查清单

### ✅ 功能实现检查
- [ ] 领域实体定义完整
- [ ] 仓储接口和实现正确
- [ ] 用例业务逻辑准确
- [ ] 控制器参数验证完备
- [ ] 路由配置正确
- [ ] 依赖注入配置完整

### ✅ 代码质量检查
- [ ] 使用统一的 `ApiResponse::success()` 和 `ApiResponse::error()` 方法
- [ ] 错误处理使用预定义的 `ErrorCode` 常量
- [ ] HTTP状态码自动映射正确
- [ ] 日志记录完整
- [ ] 类型注释明确
- [ ] 代码编译通过

### ✅ 文档更新检查
- [ ] API文档更新
- [ ] 错误码文档更新
- [ ] 开发指南更新
- [ ] 测试用例文档

## 总结

此文档记录了用户信息查询功能的完整开发过程，包括：

1. **标准DDD架构实现** - 严格按照分层架构进行开发
2. **标准化错误处理** - 使用统一的响应格式和错误码
3. **功能优化改进** - 基于开发规范进行持续优化
4. **详细实现指导** - 提供每一步的具体操作和代码示例

可作为后续类似功能开发的标准参考模板，确保代码质量和架构一致性。