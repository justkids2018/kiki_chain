// 认证控制器
// 负责处理用户注册和登录的HTTP请求

use serde_json::{to_value, Value};
use std::sync::Arc;

use crate::core::errors::{DomainError, Result};
use crate::core::use_cases::{
    LoginUserCommand, LoginUserUseCase, RegisterUserCommand, RegisterUserUseCase,
};

pub struct AuthController {
    login_use_case: Arc<LoginUserUseCase>,
    register_use_case: Arc<RegisterUserUseCase>,
}

impl AuthController {
    pub fn new(
        login_use_case: Arc<LoginUserUseCase>,
        register_use_case: Arc<RegisterUserUseCase>,
    ) -> Self {
        Self {
            login_use_case,
            register_use_case,
        }
    }

    /// 处理用户登录请求
    pub async fn login(&self, request: Value) -> Result<Value> {
        let command = LoginUserCommand {
            identifier: request
                .get("identifier")
                .or(request.get("phone"))
                .or(request.get("email"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            password: request
                .get("password")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
        };

        let response = self.login_use_case.execute(command).await?;
        to_value(response).map_err(|e| DomainError::Infrastructure(e.to_string()))
    }

    /// 处理用户注册请求
    pub async fn register(&self, request: Value) -> Result<Value> {
        let command = RegisterUserCommand {
            uid: request
                .get("uid")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            name: request
                .get("name")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            email: request
                .get("email")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            phone: request
                .get("phone")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            password: request
                .get("password")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            role_id: request.get("role_id").and_then(|v| v.as_i64()).unwrap_or(0) as i32,
        };

        let response = self.register_use_case.execute(command).await?;
        to_value(response).map_err(|e| DomainError::Infrastructure(e.to_string()))
    }
}
