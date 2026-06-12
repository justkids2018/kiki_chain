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
    pub role_type: i32,
    pub is_vip: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub vip_expire_at: Option<String>,
    pub message: String,
}

// ==================== 注册 ====================

/// 注册请求
#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub uid: String,

    #[serde(default)]
    pub name: String,

    pub email: String,
    pub phone: String,
    pub password: String,

    #[serde(default = "default_role_type")]
    pub role_type: i32,
}

/// 默认角色类型：普通用户
fn default_role_type() -> i32 {
    1
}

/// 注册响应
#[derive(Debug, Serialize)]
pub struct RegisterResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub role_type: i32,
    pub is_vip: bool,
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
            role_type: response.role_type,
            is_vip: response.is_vip,
            vip_expire_at: response.vip_expire_at,
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
            role_type: response.role_type,
            is_vip: response.is_vip,
            message: response.message,
        }
    }
}
