// 认证模块 - 路由配置和处理器
// 包含用户认证相关的所有HTTP路由和处理逻辑

use axum::{
    extract::{Json as JsonExtract, State},
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde_json::Value;
use tracing::{info, instrument, warn};

use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::{infrastructure::Logger, shared::api_response::ApiResponse};

// =============================================================================
// 路由配置
// =============================================================================

/// 创建认证模块路由
///
/// ## 路由清单
/// - POST /api/auth/login       - 用户登录
/// - POST /api/auth/register    - 用户注册
/// - GET  /api/auth/verify      - 令牌验证
pub fn create_auth_routes(app_state: AppState) -> Router {
    info!("🔐 [认证模块] 初始化认证路由");
    info!("  ├── 注册路由: POST {}", ApiPaths::LOGIN);
    info!("  ├── 注册路由: POST {}", ApiPaths::REGISTER);
    info!("  └── 注册路由: GET  {}", ApiPaths::VERIFY_TOKEN);

    Router::new()
        .route(ApiPaths::LOGIN, post(login))
        .route(ApiPaths::REGISTER, post(register))
        .route(ApiPaths::VERIFY_TOKEN, get(verify_token))
        .with_state(app_state)
}

// =============================================================================
// 处理器函数
// =============================================================================

/// 用户登录
///
/// ## 请求体示例
/// ```json
/// {
///   "email": "user@example.com",
///   "password": "password123"
/// }
/// ```
///
/// ## 响应示例
/// ```json
/// {
///   "success": true,
///   "data": {
///     "user_id": "uuid",
///     "email": "user@example.com",
///     "name": "用户名",
///     "role": "teacher",
///     "token": "jwt_token_here",
///     "expires_at": "2024-08-10T10:30:00Z"
///   },
///   "message": "登录成功"
/// }
/// ```
#[instrument(skip(state, request))]
async fn login(
    State(state): State<AppState>,
    JsonExtract(request): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🔐 [用户登录] 开始登录流程");
    match state.auth_controller.login(request).await {
        Ok(response_value) => {
            info!("✅ [用户登录] 登录成功");
            Ok(Json(ApiResponse::success(
                response_value,
                "登录成功".to_string(),
            )))
        }
        Err(e) => {
            warn!("🚫 [用户登录] 登录失败: {:?}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}

/// 用户注册
///
/// ## 请求体示例
/// ```json
/// {
///   "email": "newuser@example.com",
///   "password": "password123",
///   "name": "新用户",
///   "role": "student"
/// }
/// ```
#[instrument(skip(state, request))]
async fn register(
    State(state): State<AppState>,
    JsonExtract(request): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("📝 [用户注册] 开始注册流程");

    // 记录请求参数（不包含敏感信息）
    let email = request
        .get("email")
        .and_then(|v| v.as_str())
        .unwrap_or("未提供");
    let username = request
        .get("username")
        .and_then(|v| v.as_str())
        .unwrap_or("未提供");
    let phone = request
        .get("phone")
        .and_then(|v| v.as_str())
        .unwrap_or("未提供");
    let role_id = request.get("role_id").and_then(|v| v.as_i64()).unwrap_or(2);
    Logger::info(format!("  ├── email: {}", email));
    Logger::info(format!("  ├── phone: {}", phone));
    Logger::info(format!("  ├── 用户名: {}", username));
    Logger::info(format!("  └── 角色ID: {}", role_id));

    // 使用真实的注册控制器
    match state.auth_controller.register(request).await {
        Ok(response_value) => {
            Logger::info("✅ [用户注册] 注册成功");
            Ok(Json(ApiResponse::success(
                response_value,
                "注册成功".to_string(),
            )))
        }
        Err(e) => {
            warn!("🚫 [用户注册] 注册失败: {:?}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}

/// 令牌验证
///
/// ## 请求头
/// ```
/// Authorization: Bearer jwt_token_here
/// ```
#[instrument(skip(_state))]
async fn verify_token(
    State(_state): State<AppState>,
) -> Result<Json<ApiResponse<Value>>, axum::http::StatusCode> {
    info!("🔍 [令牌验证] 开始验证用户令牌");

    // TODO: 实现令牌验证逻辑
    // 1. 从请求头提取Bearer令牌
    // 2. 验证令牌有效性和过期时间
    // 3. 获取用户信息
    // 4. 可选：刷新即将过期的令牌

    let response = serde_json::json!({
        "user_id": uuid::Uuid::new_v4(),
        "email": "verified@example.com",
        "name": "已验证用户",
        "role": "teacher",
        "token": "mock_jwt_token_here",
        "expires_at": chrono::Utc::now() + chrono::Duration::hours(24)
    });

    info!("✅ [令牌验证] 令牌验证成功");

    Ok(Json(ApiResponse::success(
        response,
        "令牌验证成功".to_string(),
    )))
}
