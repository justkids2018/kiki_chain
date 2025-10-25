use crate::app::{api_paths::ApiPaths, AppState};
use axum::{
    extract::{Query, State},
    http::StatusCode,
    response::Json,
    routing::get,
    Router,
};
use qiqimanyou_server::{
    application::use_cases::user::get_user::GetUserCommand, shared::api_response::ApiResponse,
};
use serde_json::Value;

pub fn create_user_routes(app_state: AppState) -> Router {
    Router::new()
        .route(ApiPaths::USER_INFO, get(get_user_handler))
        .with_state(app_state)
}

pub async fn get_user_handler(
    State(state): State<AppState>,
    query: Query<GetUserCommand>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state.user_controller.get_user(query).await {
        Ok(response) => {
            tracing::info!("✅ [获取用户信息] 成功");
            Ok(Json(response))
        }
        Err(e) => {
            tracing::warn!("🚫 [获取用户信息] 失败: {:?}", e);
            let error_response = ApiResponse::from_domain_error(&e);
            let status_code = error_response.http_status();
            Err((status_code, Json(error_response)))
        }
    }
}
