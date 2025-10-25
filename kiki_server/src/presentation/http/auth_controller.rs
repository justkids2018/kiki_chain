// 认证控制器
// 处理HTTP请求并调用相应的用例

use serde_json::Value;
use std::sync::Arc;

use crate::application::use_cases::{LoginUserCommand, RegisterUserCommand};
use crate::application::use_cases::{LoginUserUseCase, RegisterUserUseCase};
use crate::domain::errors::Result;
use crate::infrastructure::logging::Logger;
/// 认证控制器
/// 负责处理用户注册和登录的HTTP请求
pub struct AuthController {
    register_use_case: Arc<RegisterUserUseCase>,
    login_use_case: Arc<LoginUserUseCase>,
}

impl AuthController {
    pub fn new(
        register_use_case: Arc<RegisterUserUseCase>,
        login_use_case: Arc<LoginUserUseCase>,
    ) -> Self {
        Self {
            register_use_case,
            login_use_case,
        }
    }

    /// 处理用户注册请求
    pub async fn register(&self, request: Value) -> Result<Value> {
        // 解析请求参数
        let command = RegisterUserCommand {
            username: request
                .get("username")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            email: request
                .get("email")
                .and_then(|v| v.as_str())
                .map(|s| s.to_string())
                .filter(|s| !s.trim().is_empty()),
            password: request
                .get("password")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            phone: request
                .get("phone")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            role_id: request.get("role_id").and_then(|v| v.as_i64()).unwrap_or(2) as i32, // 默认为学生角色
        };

        // 执行用例
        let response = self.register_use_case.execute(command).await?;

        // 将 RegisterUserResponse 转换为 Value
        let response_value = Logger::to_json_value(response)
            .map_err(|e| crate::domain::errors::DomainError::Infrastructure(e))?;

        // 直接返回业务数据，由handlers层统一处理响应格式
        Ok(response_value)
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
        let response_value = Logger::to_json_value(response)
            .map_err(|e| crate::domain::errors::DomainError::Infrastructure(e))?;

        // 直接返回业务数据，由handlers层统一处理响应格式
        Ok(response_value)
    }
}
