// 领域层错误定义
// 定义业务逻辑相关的错误类型

use thiserror::Error;

pub type Result<T> = std::result::Result<T, DomainError>;

#[derive(Debug, Error)]
pub enum DomainError {
    #[error("验证错误: {0}")]
    Validation(String),

    #[error("业务规则违反: {0}")]
    BusinessRule(String),

    #[error("实体未找到: {0}")]
    NotFound(String),

    #[error("实体已存在: {0}")]
    AlreadyExists(String),

    #[error("无效状态: {0}")]
    InvalidState(String),

    #[error("基础设施错误: {0}")]
    Infrastructure(String),

    #[error("认证错误: {0}")]
    Authentication(String),

    #[error("权限拒绝: {0}")]
    PermissionDenied(String),

    #[error("授权错误: {0}")]
    Authorization(String),
}

impl From<DomainError> for crate::utils::errors::Error {
    fn from(domain_error: DomainError) -> Self {
        match domain_error {
            DomainError::Validation(msg) => crate::utils::errors::Error::Validation(msg),
            DomainError::BusinessRule(msg) => crate::utils::errors::Error::BadRequest(msg),
            DomainError::NotFound(msg) => crate::utils::errors::Error::NotFound(msg),
            DomainError::AlreadyExists(msg) => crate::utils::errors::Error::Conflict(msg),
            DomainError::InvalidState(msg) => crate::utils::errors::Error::BadRequest(msg),
            DomainError::Infrastructure(msg) => crate::utils::errors::Error::Database(msg),
            DomainError::Authentication(msg) => crate::utils::errors::Error::Authentication(msg),
            DomainError::PermissionDenied(msg) => crate::utils::errors::Error::Forbidden(msg),
            DomainError::Authorization(msg) => crate::utils::errors::Error::Forbidden(msg),
        }
    }
}

impl From<serde_json::Error> for DomainError {
    fn from(error: serde_json::Error) -> Self {
        DomainError::Infrastructure(format!("JSON序列化错误: {}", error))
    }
}

impl From<sqlx::Error> for DomainError {
    fn from(error: sqlx::Error) -> Self {
        DomainError::Infrastructure(format!("数据库操作错误: {}", error))
    }
}
