use axum::{middleware, routing::get, Router};
use tracing::info;

use super::{admin, auth, mobile};
use crate::adapters::http::middleware::{
    create_cors_layer, error_handling_middleware, request_response_data_log_middleware,
};
use crate::config::get_config;
use crate::framework::bootstrap::{api_paths::ApiPaths, AppState};

pub fn create_routes(app_state: AppState) -> Router {
    info!("🚀 [主路由] 开始初始化应用路由");

    let config = get_config().expect("无法获取配置");

    // 健康检查路由（无需认证）
    let health_routes = Router::new().route(ApiPaths::HEALTH, get(health_check));
    info!("  ├── ✅ 健康检查路由已注册");

    // 认证路由（无需认证）
    let auth_routes = auth::create_auth_routes(app_state.clone());
    info!("  ├── 🔐 认证模块路由已注册");

    // 移动端路由（需要User或Admin角色）
    let mobile_routes = mobile::create_mobile_routes(app_state.clone());
    info!("  ├── 📱 移动端模块路由已注册");

    // 管理端路由（仅需Admin角色）
    let admin_routes = admin::create_admin_routes(app_state.clone());
    info!("  ├── 🔧 管理端模块路由已注册");

    // CORS配置
    let cors_layer = create_cors_layer(config.cors_origins().to_vec());
    info!("  ├── 🌐 CORS 中间件已配置");

    // 合并所有路由
    let app_router = Router::new()
        .merge(health_routes)
        .merge(auth_routes)
        .merge(mobile_routes)
        .merge(admin_routes)
        .layer(middleware::from_fn(error_handling_middleware))
        .layer(middleware::from_fn(request_response_data_log_middleware))
        .layer(cors_layer);

    info!("🎯 [主路由] 应用路由初始化完成");
    info!("📋 [路由架构]");
    info!("   ├── GET  /health");
    info!("   ├── POST /api/v1/auth/login");
    info!("   ├── POST /api/v1/auth/register");
    info!("   ├── GET  /api/v1/auth/verify");
    info!("   ├── POST /api/v1/auth/logout");
    info!("   ├── GET  /api/v1/mobile/user/profile");
    info!("   ├── PUT  /api/v1/mobile/user/profile");
    info!("   ├── POST /api/v1/mobile/feedback");
    info!("   ├── GET  /api/v1/mobile/scene/categories");
    info!("   ├── GET  /api/v1/mobile/scene/categories/:id/scenes");
    info!("   ├── GET  /api/v1/mobile/scene/:id");
    info!("   ├── GET  /api/v1/mobile/scene/search");
    info!("   ├── GET  /api/v1/mobile/scene/recommendations");
    info!("   ├── GET/POST   /api/v1/admin/scene/categories");
    info!("   ├── PUT/DELETE /api/v1/admin/scene/categories/:id");
    info!("   ├── GET/POST   /api/v1/admin/scene/scenes");
    info!("   ├── GET  /api/v1/admin/feedback");
    info!("   ├── PATCH /api/v1/admin/feedback/:id/status");
    info!("   └── GET/PUT/DELETE /api/v1/admin/scene/scenes/:id");

    app_router
}

async fn health_check() -> axum::response::Json<serde_json::Value> {
    use serde_json::json;

    info!("💓 [健康检查] 系统状态检查");

    axum::response::Json(json!({
        "status": "OK",
        "timestamp": chrono::Utc::now(),
        "version": env!("CARGO_PKG_VERSION"),
        "service": "qiqimanyou_server"
    }))
}
