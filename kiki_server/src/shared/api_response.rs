// 统一API响应格式
// 定义标准的成功和失败响应结构

use axum::http::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

/// 统一API响应结构
#[derive(Debug, Serialize, Deserialize)]
pub struct ApiResponse<T = Value> {
    /// 操作是否成功
    pub success: bool,
    /// 响应数据（仅成功时存在）
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<T>,
    /// 错误码（仅失败时存在）
    #[serde(skip_serializing_if = "Option::is_none")]
    pub errorcode: Option<u32>,
    /// 响应消息
    pub message: String,
}

impl<T> ApiResponse<T>
where
    T: Serialize,
{
    /// 创建成功响应
    pub fn success(data: T, message: impl Into<String>) -> Self {
        Self {
            success: true,
            data: Some(data),
            errorcode: None,
            message: message.into(),
        }
    }

    /// 转换为JSON Value
    pub fn to_json(&self) -> Value {
        serde_json::to_value(self).unwrap_or_else(|_| {
            json!({
                "success": false,
                "errorcode": 500,
                "message": "序列化响应失败"
            })
        })
    }
}

impl ApiResponse<Value> {
    /// 创建失败响应
    pub fn error(errorcode: u32, message: impl Into<String>) -> Self {
        Self {
            success: false,
            data: None,
            errorcode: Some(errorcode),
            message: message.into(),
        }
    }
}

/// 错误码定义
pub struct ErrorCode;

impl ErrorCode {
    // 通用错误码 (100-199)
    pub const INVALID_REQUEST: u32 = 100;
    pub const MISSING_PARAMETER: u32 = 101;
    pub const INVALID_PARAMETER: u32 = 102;
    pub const VALIDATION_FAILED: u32 = 103;

    // 认证相关错误码 (200-299)
    pub const USER_ALREADY_EXISTS: u32 = 200;
    pub const USER_NOT_FOUND: u32 = 201;
    pub const INVALID_CREDENTIALS: u32 = 202;
    pub const PASSWORD_TOO_SHORT: u32 = 203;
    pub const INVALID_EMAIL: u32 = 204;
    pub const USERNAME_TAKEN: u32 = 205;
    pub const EMAIL_TAKEN: u32 = 206;

    // 业务逻辑错误码 (300-399)
    pub const BUSINESS_RULE_VIOLATION: u32 = 300;
    pub const INSUFFICIENT_PERMISSIONS: u32 = 301;

    // 系统错误码 (500-599)
    pub const INTERNAL_SERVER_ERROR: u32 = 500;
    pub const DATABASE_ERROR: u32 = 501;
    pub const EXTERNAL_SERVICE_ERROR: u32 = 502;
}

/// 响应工具函数
impl ApiResponse<Value> {
    /// 从领域错误创建失败响应
    pub fn from_domain_error(error: &crate::domain::errors::DomainError) -> Self {
        use crate::domain::errors::DomainError;

        match error {
            DomainError::Validation(msg) => {
                ApiResponse::<Value>::error(ErrorCode::VALIDATION_FAILED, msg.clone())
            }
            DomainError::Authentication(msg) => {
                ApiResponse::<Value>::error(ErrorCode::INVALID_CREDENTIALS, msg.clone())
            }
            DomainError::AlreadyExists(msg) => {
                ApiResponse::<Value>::error(ErrorCode::USER_ALREADY_EXISTS, msg.clone())
            }
            DomainError::NotFound(msg) => {
                ApiResponse::<Value>::error(ErrorCode::USER_NOT_FOUND, msg.clone())
            }
            DomainError::BusinessRule(msg) => {
                ApiResponse::<Value>::error(ErrorCode::INVALID_EMAIL, msg.clone())
            }
            DomainError::Infrastructure(msg) => ApiResponse::<Value>::error(
                ErrorCode::DATABASE_ERROR,
                format!("数据库错误: {}", msg),
            ),
            _ => ApiResponse::<Value>::error(ErrorCode::INTERNAL_SERVER_ERROR, "系统内部错误"),
        }
    }

    /// 获取对应的HTTP状态码
    pub fn http_status(&self) -> StatusCode {
        if self.success {
            return StatusCode::OK;
        }

        match self.errorcode.unwrap_or(500) {
            100..=199 => StatusCode::BAD_REQUEST,
            200..=299 => match self.errorcode.unwrap() {
                200 => StatusCode::CONFLICT,     // USER_ALREADY_EXISTS
                201 => StatusCode::NOT_FOUND,    // USER_NOT_FOUND
                202 => StatusCode::UNAUTHORIZED, // INVALID_CREDENTIALS
                _ => StatusCode::BAD_REQUEST,
            },
            300..=399 => StatusCode::FORBIDDEN,
            500..=599 => StatusCode::INTERNAL_SERVER_ERROR,
            _ => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}
