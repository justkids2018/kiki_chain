// 认证模块 - 路由配置和处理器
// 包含用户认证相关的所有HTTP路由和处理逻辑

use axum::{
    extract::{Json as JsonExtract, State},
    http::StatusCode,
    response::Json,
    routing::post,
    Router,
};
use serde_json::Value;
use tracing::{info, instrument, warn};

use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::shared::api_response::ApiResponse;

// =============================================================================
// 路由配置
// =============================================================================

/// 创建认证模块路由
///
/// ## 路由清单
/// - POST /api/auth/login       - 用户登录
pub fn create_auth_routes(app_state: AppState) -> Router {
    info!("🔐 [认证模块] 初始化认证路由");
    info!("  └── 登录路由: POST {}", ApiPaths::LOGIN);

    Router::new()
        .route(ApiPaths::LOGIN, post(login))
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
