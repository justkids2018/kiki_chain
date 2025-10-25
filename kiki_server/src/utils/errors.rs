// 错误处理和通用类型
use crate::infrastructure::Logger;
use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;
use thiserror::Error;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Database error: {0}")]
    Database(String),

    #[error("Validation error: {0}")]
    Validation(String),

    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Unauthorized: {0}")]
    Unauthorized(String),

    #[error("Forbidden: {0}")]
    Forbidden(String),

    #[error("Authentication error: {0}")]
    Authentication(String),

    #[error("Internal server error: {0}")]
    Internal(String),

    #[error("Bad request: {0}")]
    BadRequest(String),

    #[error("Conflict: {0}")]
    Conflict(String),

    #[error("Config error: missing environment variable {0}")]
    ConfigMissingEnv(&'static str),
}

impl IntoResponse for Error {
    fn into_response(self) -> Response {
        let (status, error_message) = match self {
            Error::Database(ref e) => {
                Logger::error(&format!("Database error: {}", e));
                (StatusCode::INTERNAL_SERVER_ERROR, "Internal server error")
            }
            Error::Validation(ref message) => (StatusCode::BAD_REQUEST, message.as_str()),
            Error::NotFound(ref message) => (StatusCode::NOT_FOUND, message.as_str()),
            Error::Unauthorized(ref message) => (StatusCode::UNAUTHORIZED, message.as_str()),
            Error::Forbidden(ref message) => (StatusCode::FORBIDDEN, message.as_str()),
            Error::Authentication(ref message) => (StatusCode::UNAUTHORIZED, message.as_str()),
            Error::Internal(ref message) => {
                Logger::error(&format!("Internal error: {}", message));
                (StatusCode::INTERNAL_SERVER_ERROR, "Internal server error")
            }
            Error::BadRequest(ref message) => (StatusCode::BAD_REQUEST, message.as_str()),
            Error::Conflict(ref message) => (StatusCode::CONFLICT, message.as_str()),
            Error::ConfigMissingEnv(var) => {
                Logger::error(&format!("Missing environment variable: {}", var));
                (StatusCode::INTERNAL_SERVER_ERROR, "Configuration error")
            }
        };

        let body = Json(json!({
            "error": error_message,
        }));

        (status, body).into_response()
    }
}

impl From<std::io::Error> for Error {
    fn from(err: std::io::Error) -> Self {
        Error::Internal(err.to_string())
    }
}

impl From<uuid::Error> for Error {
    fn from(err: uuid::Error) -> Self {
        Error::Validation(err.to_string())
    }
}
