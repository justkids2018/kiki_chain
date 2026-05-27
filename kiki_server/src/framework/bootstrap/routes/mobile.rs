// 移动端路由模块
// 所有路由需要 User 或 Admin 角色认证

use axum::{middleware, routing::get, Router};
use tracing::info;

use crate::adapters::http::feedback::submit_feedback_handler;
use crate::adapters::http::middleware::mobile_auth_middleware;
use crate::adapters::http::scene::{
    get_categories_handler, get_recommendations_handler, get_scene_detail_handler,
    get_scenes_by_category_handler, search_scenes_handler,
};
use crate::adapters::http::user::{get_profile_handler, update_profile_handler};
use crate::framework::bootstrap::{api_paths::ApiPaths, AppState};

/// 创建移动端路由
pub fn create_mobile_routes(app_state: AppState) -> Router {
    info!("📱 [移动端模块] 初始化移动端路由");

    // 公开路由（无需认证）
    let public_routes = Router::new()
        .route(
            ApiPaths::MOBILE_SCENE_CATEGORIES,
            get(get_categories_handler).with_state(app_state.get_categories_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SCENE_BY_CATEGORY,
            get(get_scenes_by_category_handler)
                .with_state(app_state.get_scenes_by_category_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SCENE_SEARCH,
            get(search_scenes_handler).with_state(app_state.search_scenes_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SCENE_RECOMMENDATIONS,
            get(get_recommendations_handler)
                .with_state(app_state.get_recommendations_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SCENE_DETAIL,
            get(get_scene_detail_handler).with_state(app_state.get_scene_detail_uc.clone()),
        );

    // 需要认证的路由
    let protected_routes = Router::new()
        .route(
            ApiPaths::MOBILE_USER_PROFILE,
            get(get_profile_handler)
                .put(update_profile_handler)
                .with_state(app_state.user_repository.clone()),
        )
        .route(
            ApiPaths::MOBILE_FEEDBACK,
            axum::routing::post(submit_feedback_handler).with_state(app_state.clone()),
        )
        .layer(middleware::from_fn(mobile_auth_middleware));

    public_routes.merge(protected_routes)
}
