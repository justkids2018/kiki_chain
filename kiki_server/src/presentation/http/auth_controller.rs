// 认证控制器
// 处理HTTP请求并调用相应的用例

use serde_json::Value;
use std::sync::Arc;

use crate::application::use_cases::{
    LoginUserCommand, LoginUserUseCase, RegisterUserCommand, RegisterUserUseCase,
};
use crate::domain::errors::{DomainError, Result};
use crate::infrastructure::logging::Logger;
/// 认证控制器
/// 负责处理用户注册和登录的HTTP请求
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
        // 解析请求参数
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

        // 执行用例
        let response = self.login_use_case.execute(command).await?;

        // 将 LoginUserResponse 转换为 Value
        let response_value =
            Logger::to_json_value(response).map_err(DomainError::Infrastructure)?;

        // 直接返回业务数据，由handlers层统一处理响应格式
        Ok(response_value)
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
            role_id: request
                .get("role_id")
                .and_then(|v| v.as_i64())
                .unwrap_or(0) as i32,
        };

        let response = self.register_use_case.execute(command).await?;
        let response_value =
            Logger::to_json_value(response).map_err(DomainError::Infrastructure)?;

        Ok(response_value)
    }
}
