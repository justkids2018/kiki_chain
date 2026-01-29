// 认证模块 HTTP 处理器
// 直接调用 Use Case，移除冗余的 Controller 层

use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use std::sync::Arc;
use tracing::{error, info};

use crate::core::use_cases::{
    LoginUserCommand, LoginUserUseCase, RegisterUserCommand, RegisterUserUseCase,
};
use crate::shared::api_response::ApiResponse;

use super::dtos::{LoginRequest, LoginResponse, RegisterRequest, RegisterResponse};

// ==================== HTTP 处理器 ====================

/// 用户登录处理器
pub async fn login_handler(
    State(login_use_case): State<Arc<LoginUserUseCase>>,
    Json(request): Json<LoginRequest>,
) -> Response {
    info!("📥 登录请求: identifier={}", request.identifier);

    // 构造 Use Case 命令
    let command = LoginUserCommand {
        identifier: request.identifier,
        password: request.password,
    };

    // 执行 Use Case
    match login_use_case.execute(command).await {
        Ok(response) => {
            info!("✅ 登录成功: uid={}", response.uid);
            let dto: LoginResponse = response.into();
            let api_response = ApiResponse::success(dto, "登录成功");
            (StatusCode::OK, Json(api_response)).into_response()
        }
        Err(e) => {
            error!("❌ 登录失败: {}", e);
            let api_response = ApiResponse::from_domain_error(&e);
            let status = api_response.http_status();
            (status, Json(api_response)).into_response()
        }
    }
}

/// 用户注册处理器
pub async fn register_handler(
    State(register_use_case): State<Arc<RegisterUserUseCase>>,
    Json(request): Json<RegisterRequest>,
) -> Response {
    info!("📥 注册请求: uid={}", request.uid);

    // 构造 Use Case 命令
    let command = RegisterUserCommand {
        uid: request.uid,
        name: request.name,
        email: request.email,
        phone: request.phone,
        password: request.password,
        role_id: request.role_id,
    };

    // 执行 Use Case
    match register_use_case.execute(command).await {
        Ok(response) => {
            info!("✅ 注册成功: uid={}", response.uid);
            let dto: RegisterResponse = response.into();
            let api_response = ApiResponse::success(dto, "注册成功");
            (StatusCode::CREATED, Json(api_response)).into_response()
        }
        Err(e) => {
            error!("❌ 注册失败: {}", e);
            let api_response = ApiResponse::from_domain_error(&e);
            let status = api_response.http_status();
            (status, Json(api_response)).into_response()
        }
    }
}
