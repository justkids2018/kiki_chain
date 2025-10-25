// Dify API Key 路由配置
// 提供密钥的增删改查 HTTP 接口

use axum::{
    extract::{Json as JsonExtract, Path, Query, State},
    http::StatusCode,
    response::Json,
    routing::{post, put},
    Router,
};
use serde::Deserialize;
use serde_json::Value;
use tracing::info;

use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::shared::api_response::ApiResponse;

/// 密钥查询参数
#[derive(Debug, Deserialize)]
pub struct DifyKeyListQuery {
    #[serde(rename = "type")]
    pub key_type: Option<String>,
}

/// 注册 Dify API Key 路由
pub fn create_dify_key_routes(app_state: AppState) -> Router {
    Router::new()
        .route(
            ApiPaths::DIFY_API_KEYS,
            post(create_dify_api_key).get(list_dify_api_keys),
        )
        .route(
            ApiPaths::DIFY_API_KEY_ITEM,
            put(update_dify_api_key).delete(delete_dify_api_key),
        )
        .with_state(app_state)
}

async fn create_dify_api_key(
    State(state): State<AppState>,
    JsonExtract(body): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🆕 [Dify Key 路由] 创建密钥");

    match state
        .dify_api_key_controller
        .create_dify_api_key(body)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn list_dify_api_keys(
    State(state): State<AppState>,
    Query(query): Query<DifyKeyListQuery>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("📄 [Dify Key 路由] 查询密钥列表");

    match state
        .dify_api_key_controller
        .list_dify_api_keys(query.key_type)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn update_dify_api_key(
    State(state): State<AppState>,
    Path(id): Path<String>,
    JsonExtract(body): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🔄 [Dify Key 路由] 更新密钥 id={}", id);

    match state
        .dify_api_key_controller
        .update_dify_api_key(id, body)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn delete_dify_api_key(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🗑️ [Dify Key 路由] 删除密钥 id={}", id);

    match state.dify_api_key_controller.delete_dify_api_key(id).await {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}
