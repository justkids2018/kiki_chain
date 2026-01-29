use axum::{routing::post, Router};
use tracing::info;

use crate::adapters::http::auth::{login_handler, register_handler};
use crate::framework::bootstrap::{api_paths::ApiPaths, AppState};

/// 创建认证模块路由
pub fn create_auth_routes(app_state: AppState) -> Router {
    info!("🔐 [认证模块] 初始化认证路由");
    info!("  ├── 登录路由: POST {}", ApiPaths::LOGIN);
    info!("  └── 注册路由: POST {}", ApiPaths::REGISTER);

    Router::new()
        .route(
            ApiPaths::LOGIN,
            post(login_handler).with_state(app_state.login_use_case.clone()),
        )
        .route(
            ApiPaths::REGISTER,
            post(register_handler).with_state(app_state.register_use_case.clone()),
        )
}
