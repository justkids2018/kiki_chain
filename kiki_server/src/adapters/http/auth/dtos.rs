// HTTP 请求/响应 DTOs
// 提供类型安全的 API 接口定义

use serde::{Deserialize, Serialize};

// ==================== 登录 ====================

/// 登录请求
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    /// 登录标识（手机号或邮箱）
    #[serde(alias = "phone", alias = "email")]
    pub identifier: String,

    /// 密码
    pub password: String,
}

/// 登录响应
#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub token: String,
    pub role_id: i32,
    pub message: String,
}

// ==================== 注册 ====================

/// 注册请求
#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub password: String,

    #[serde(default)]
    pub role_id: i32,
}

/// 注册响应
#[derive(Debug, Serialize)]
pub struct RegisterResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub message: String,
}

// ==================== 类型转换 ====================

impl From<crate::core::use_cases::LoginUserResponse> for LoginResponse {
    fn from(response: crate::core::use_cases::LoginUserResponse) -> Self {
        Self {
            uid: response.uid,
            name: response.name,
            email: response.email,
            phone: response.phone,
            token: response.token,
            role_id: response.role_id,
            message: response.message,
        }
    }
}

impl From<crate::core::use_cases::RegisterUserResponse> for RegisterResponse {
    fn from(response: crate::core::use_cases::RegisterUserResponse) -> Self {
        Self {
            uid: response.uid,
            name: response.name,
            email: response.email,
            phone: response.phone,
            message: response.message,
        }
    }
}
