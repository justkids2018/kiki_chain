use axum::{
    extract::Request,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use tracing::info;

use crate::adapters::http::auth::{login_handler, register_handler};
use crate::framework::bootstrap::{api_paths::ApiPaths, AppState};
use crate::shared::api_response::ApiResponse;
use crate::utils::jwt::JwtUtils;

/// 创建认证模块路由
pub fn create_auth_routes(app_state: AppState) -> Router {
    info!("🔐 [认证模块] 初始化认证路由");
    info!("  ├── 登录路由: POST {}", ApiPaths::LOGIN);
    info!("  ├── 注册路由: POST {}", ApiPaths::REGISTER);
    info!("  ├── 验证路由: GET {}", ApiPaths::AUTH_VERIFY);
    info!("  └── 登出路由: POST {}", ApiPaths::AUTH_LOGOUT);

    Router::new()
        .route(
            ApiPaths::LOGIN,
            post(login_handler).with_state(app_state.login_use_case.clone()),
        )
        .route(
            ApiPaths::REGISTER,
            post(register_handler).with_state(app_state.register_use_case.clone()),
        )
        .route(ApiPaths::AUTH_VERIFY, get(verify_token_handler))
        .route(ApiPaths::AUTH_LOGOUT, post(logout_handler))
}

/// GET /api/v1/auth/verify - 验证 Token 有效性
async fn verify_token_handler(request: Request) -> Response {
    use axum::http::header;

    let auth_header = request
        .headers()
        .get(header::AUTHORIZATION)
        .and_then(|h| h.to_str().ok());

    match auth_header {
        Some(h) if h.starts_with("Bearer ") => {
            let token = &h[7..];
            match JwtUtils::verify_token(token) {
                Ok(claims) => {
                    info!("✅ [Auth] Token 验证通过: uid={}", claims.sub);
                    let data = serde_json::json!({
                        "valid": true,
                        "uid": claims.sub,
                        "phone": claims.phone,
                        "role_type": claims.role_type,
                        "expires_at": claims.exp
                    });
                    (StatusCode::OK, Json(ApiResponse::success(data, "Token有效"))).into_response()
                }
                Err(_) => {
                    let r = ApiResponse::<serde_json::Value>::error(401, "Token无效或已过期");
                    (StatusCode::UNAUTHORIZED, Json(r)).into_response()
                }
            }
        }
        _ => {
            let r = ApiResponse::<serde_json::Value>::error(401, "缺少认证令牌");
            (StatusCode::UNAUTHORIZED, Json(r)).into_response()
        }
    }
}

/// POST /api/v1/auth/logout - 登出（服务端确认，客户端负责清除 Token）
async fn logout_handler() -> Response {
    info!("🔐 [Auth] 用户登出");
    (StatusCode::OK, Json(ApiResponse::success(
        serde_json::json!({}),
        "登出成功，请客户端清除本地 Token",
    ))).into_response()
}
