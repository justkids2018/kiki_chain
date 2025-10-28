use axum::{middleware, routing::get, Router};
use tracing::info;

use super::auth;
use crate::adapters::http::middleware::{
    create_cors_layer, error_handling_middleware, jwt_auth_middleware,
    request_response_data_log_middleware,
};
use crate::config::get_config;
use crate::framework::bootstrap::{api_paths::ApiPaths, AppState};

pub fn create_routes(app_state: AppState) -> Router {
    info!("🚀 [主路由] 开始初始化应用路由");

    let config = get_config().expect("无法获取配置");

    let health_routes = Router::new().route(ApiPaths::HEALTH, get(health_check));

    info!("  ├── ✅ 健康检查路由已注册");

    let auth_routes = auth::create_auth_routes(app_state.clone());

    info!("  ├── 🔐 认证模块路由已注册");

    let cors_layer = create_cors_layer(config.cors_origins().to_vec());
    info!("  ├── 🌐 CORS 中间件已配置: {:?}", config.cors_origins());

    let app_router = Router::new()
        .merge(health_routes)
        .merge(auth_routes)
        .layer(middleware::from_fn(jwt_auth_middleware))
        .layer(middleware::from_fn(error_handling_middleware))
        .layer(middleware::from_fn(request_response_data_log_middleware))
        .layer(cors_layer);

    info!("  ├── 🔐 JWT认证中间件已配置");
    info!("  ├── ⚠️ 错误处理中间件已配置");
    info!("  └── 📝 请求响应日志中间件已配置");
    info!("🎯 [主路由] 应用路由初始化完成");

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
