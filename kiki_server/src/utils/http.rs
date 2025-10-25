// HTTP工具类
// 提供HTTP请求相关的通用工具方法
// 创建时间: 2025-09-15

use crate::domain::errors::{DomainError, Result};
use crate::utils::JwtUtils;
use axum::http::HeaderMap;

/// HTTP工具类
/// 提供从HTTP请求中提取信息的便捷方法
pub struct HttpUtils;

impl HttpUtils {
    /// 从Authorization头中提取用户ID
    ///
    /// 自动处理Bearer token格式验证和JWT解析
    ///
    /// ## 参数
    /// - headers: HTTP请求头
    ///
    /// ## 返回
    /// - Ok(String): 提取到的用户ID
    /// - Err(DomainError): 认证失败或token无效
    ///
    /// ## 示例
    /// ```rust
    /// let user_id = HttpUtils::extract_user_id_from_headers(&headers)?;
    /// ```
    pub fn extract_user_id_from_headers(headers: &HeaderMap) -> Result<String> {
        // 获取Authorization头
        let auth_header = headers
            .get("authorization")
            .and_then(|header| header.to_str().ok())
            .ok_or_else(|| DomainError::Authentication("缺少Authorization头".to_string()))?;

        // 验证Bearer格式
        if !auth_header.starts_with("Bearer ") {
            return Err(DomainError::Authentication(
                "Authorization头格式错误".to_string(),
            ));
        }

        // 提取token
        let token = &auth_header[7..];

        // 从JWT中提取用户ID
        JwtUtils::extract_user_id(token)
    }

    /// 从Authorization头中提取token字符串
    ///
    /// ## 参数
    /// - headers: HTTP请求头
    ///
    /// ## 返回
    /// - Ok(String): 提取到的token字符串
    /// - Err(DomainError): 认证失败
    pub fn extract_token_from_headers(headers: &HeaderMap) -> Result<String> {
        let auth_header = headers
            .get("authorization")
            .and_then(|header| header.to_str().ok())
            .ok_or_else(|| DomainError::Authentication("缺少Authorization头".to_string()))?;

        if !auth_header.starts_with("Bearer ") {
            return Err(DomainError::Authentication(
                "Authorization头格式错误".to_string(),
            ));
        }

        Ok(auth_header[7..].to_string())
    }
}
