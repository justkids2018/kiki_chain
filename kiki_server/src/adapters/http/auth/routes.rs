use std::sync::Arc;

use axum::{
    extract::{Json as JsonExtract, State},
    http::StatusCode,
    response::Json,
};
use serde_json::Value;
use tracing::{info, instrument, warn};

use crate::adapters::http::auth::controller::AuthController;
use crate::shared::api_response::ApiResponse;

/// 提供认证控制器的状态抽象
pub trait AuthControllerProvider: Clone + Send + Sync + 'static {
    fn auth_controller(&self) -> Arc<AuthController>;
}

/// 登录处理器
#[instrument(skip(state, request))]
pub async fn login<S>(
    State(state): State<S>,
    JsonExtract(request): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)>
where
    S: AuthControllerProvider,
{
    info!("🔐 [用户登录] 开始登录流程");
    let controller = state.auth_controller();
    match controller.login(request).await {
        Ok(response_value) => {
            info!("✅ [用户登录] 登录成功");
            Ok(Json(ApiResponse::success(
                response_value,
                "登录成功".to_string(),
            )))
        }
        Err(e) => {
            warn!("🚫 [用户登录] 登录失败: {:?}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}

/// 注册处理器
#[instrument(skip(state, request))]
pub async fn register<S>(
    State(state): State<S>,
    JsonExtract(request): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)>
where
    S: AuthControllerProvider,
{
    info!("🆕 [用户注册] 开始注册流程");
    let controller = state.auth_controller();
    match controller.register(request).await {
        Ok(response_value) => {
            info!("✅ [用户注册] 注册成功");
            Ok(Json(ApiResponse::success(
                response_value,
                "注册成功".to_string(),
            )))
        }
        Err(e) => {
            warn!("🚫 [用户注册] 注册失败: {:?}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}
