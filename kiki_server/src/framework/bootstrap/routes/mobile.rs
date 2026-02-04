// 移动端路由模块
// 提供移动端专用的API端点
// 需要User或Admin角色认证
// 创建时间: 2026-01-29

use axum::{middleware, routing::get, Router};
use tracing::info;

use crate::adapters::http::middleware::mobile_auth_middleware;
use crate::framework::bootstrap::api_paths::ApiPaths;

/// 创建移动端路由
///
/// 所有路由都需要通过mobile_auth_middleware认证
/// 允许User(role_type=1)和Admin(role_type=2)角色访问
pub fn create_mobile_routes() -> Router {
    info!("📱 [移动端模块] 初始化移动端路由");
    info!("  ├── 用户信息路由: GET {}", ApiPaths::MOBILE_USER_INFO);
    info!("  └── 个人资料路由: GET {}", ApiPaths::MOBILE_PROFILE);

    Router::new()
        .route(ApiPaths::MOBILE_USER_INFO, get(get_user_info))
        .route(ApiPaths::MOBILE_PROFILE, get(get_profile))
        .layer(middleware::from_fn(mobile_auth_middleware))
}

/// 获取用户信息
async fn get_user_info() -> axum::response::Json<serde_json::Value> {
    use serde_json::json;

    info!("📱 [移动端] 获取用户信息");

    axum::response::Json(json!({
        "success": true,
        "message": "移动端用户信息",
        "data": {
            "endpoint": "mobile/user/info",
            "description": "此端点需要User或Admin角色"
        }
    }))
}

/// 获取个人资料
async fn get_profile() -> axum::response::Json<serde_json::Value> {
    use serde_json::json;

    info!("📱 [移动端] 获取个人资料");

    axum::response::Json(json!({
        "success": true,
        "message": "移动端个人资料",
        "data": {
            "endpoint": "mobile/profile",
            "description": "此端点需要User或Admin角色"
        }
    }))
}
