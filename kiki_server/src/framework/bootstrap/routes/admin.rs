// 管理端路由模块
// 提供管理端专用的API端点
// 仅需Admin角色认证
// 创建时间: 2026-01-29

use axum::{middleware, routing::get, Router};
use tracing::info;

use crate::adapters::http::middleware::admin_auth_middleware;
use crate::framework::bootstrap::api_paths::ApiPaths;

/// 创建管理端路由
///
/// 所有路由都需要通过admin_auth_middleware认证
/// 仅允许Admin(role_type=2)角色访问
pub fn create_admin_routes() -> Router {
    info!("🔧 [管理端模块] 初始化管理端路由");
    info!("  ├── 用户列表路由: GET {}", ApiPaths::ADMIN_USERS);
    info!("  └── 用户详情路由: GET {}", ApiPaths::ADMIN_USER_DETAIL);

    Router::new()
        .route(ApiPaths::ADMIN_USERS, get(get_users))
        .route(ApiPaths::ADMIN_USER_DETAIL, get(get_user_detail))
        .layer(middleware::from_fn(admin_auth_middleware))
}

/// 获取用户列表
async fn get_users() -> axum::response::Json<serde_json::Value> {
    use serde_json::json;

    info!("🔧 [管理端] 获取用户列表");

    axum::response::Json(json!({
        "success": true,
        "message": "管理端用户列表",
        "data": {
            "endpoint": "admin/users",
            "description": "此端点仅限Admin角色访问"
        }
    }))
}

/// 获取用户详情
async fn get_user_detail() -> axum::response::Json<serde_json::Value> {
    use serde_json::json;

    info!("🔧 [管理端] 获取用户详情");

    axum::response::Json(json!({
        "success": true,
        "message": "管理端用户详情",
        "data": {
            "endpoint": "admin/users/:id",
            "description": "此端点仅限Admin角色访问"
        }
    }))
}
