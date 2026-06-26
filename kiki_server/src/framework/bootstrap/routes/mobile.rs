// 移动端路由模块
// 所有路由需要 User 或 Admin 角色认证

use axum::{
    middleware,
    routing::{get, post},
    Router,
};
use tracing::info;

use crate::adapters::http::feedback::submit_feedback_handler;
use crate::adapters::http::learning::{
    get_progress_handler, get_user_progress_list_handler, get_user_summary_handler,
    submit_progress_handler,
};
use crate::adapters::http::middleware::mobile_auth_middleware;
use crate::adapters::http::scene::{
    get_categories_handler, get_recommendations_handler, get_scene_detail_handler,
    get_scenes_by_category_handler, search_scenes_handler,
};
use crate::adapters::http::subscription::{
    confirm_order_handler, create_order_handler, get_entitlement_handler, list_products_handler,
    resolve_channel_handler,
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
            get(get_recommendations_handler).with_state(app_state.get_recommendations_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SCENE_DETAIL,
            get(get_scene_detail_handler).with_state(app_state.get_scene_detail_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SUBSCRIPTION_CHANNEL_RESOLVE,
            post(resolve_channel_handler).with_state(app_state.subscription_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SUBSCRIPTION_PRODUCTS,
            get(list_products_handler).with_state(app_state.subscription_uc.clone()),
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
        .route(
            ApiPaths::MOBILE_SUBSCRIPTION_ENTITLEMENT,
            get(get_entitlement_handler).with_state(app_state.subscription_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SUBSCRIPTION_ORDERS,
            post(create_order_handler).with_state(app_state.subscription_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_SUBSCRIPTION_ORDER_CONFIRM,
            post(confirm_order_handler).with_state(app_state.subscription_uc.clone()),
        )
        // 学习进度路由
        .route(
            ApiPaths::MOBILE_LEARNING_PROGRESS,
            get(get_progress_handler).with_state(app_state.get_progress_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_LEARNING_SUBMIT,
            axum::routing::post(submit_progress_handler)
                .with_state(app_state.submit_progress_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_LEARNING_SUMMARY,
            get(get_user_summary_handler).with_state(app_state.get_user_summary_uc.clone()),
        )
        .route(
            ApiPaths::MOBILE_LEARNING_PROGRESS_LIST,
            get(get_user_progress_list_handler)
                .with_state(app_state.get_user_progress_list_uc.clone()),
        )
        .layer(middleware::from_fn(mobile_auth_middleware));

    public_routes.merge(protected_routes)
}
