// 领域层值对象定义
// 定义业务概念中的值对象，具有不变性和值相等性

use regex::Regex;
use std::fmt;
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};

/// ID值对象
/// 封装用户的唯一标识符
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct UserId(String);

impl UserId {
    /// 创建新的UUID用户ID
    pub fn new_v4() -> Self {
        Self(Uuid::new_v4().to_string())
    }

    /// 从字符串创建用户ID
    pub fn new(id: String) -> Self {
        Self(id)
    }

    /// 从UUID创建用户ID
    pub fn from_uuid(uuid: Uuid) -> Self {
        Self(uuid.to_string())
    }

    /// 转换为字符串
    pub fn as_str(&self) -> &str {
        &self.0
    }

    /// 转换为UUID（如果是有效的UUID格式）
    pub fn as_uuid(&self) -> Result<Uuid> {
        Uuid::parse_str(&self.0).map_err(|_| DomainError::Validation("无效的UUID格式".to_string()))
    }
}

impl fmt::Display for UserId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<String> for UserId {
    fn from(id: String) -> Self {
        Self(id)
    }
}

impl From<Uuid> for UserId {
    fn from(uuid: Uuid) -> Self {
        Self(uuid.to_string())
    }
}

/// 邮箱值对象
/// 封装邮箱地址及其验证逻辑
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Email(String);

impl Email {
    /// 创建新的邮箱值对象
    pub fn new(email: &str) -> Result<Self> {
        let email = email.trim().to_lowercase();

        if email.is_empty() {
            return Err(DomainError::Validation("邮箱地址不能为空".to_string()));
        }

        // 简单的邮箱格式验证
        let email_regex = Regex::new(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .map_err(|_| DomainError::Validation("邮箱正则表达式编译失败".to_string()))?;

        if !email_regex.is_match(&email) {
            return Err(DomainError::Validation("邮箱格式无效".to_string()));
        }

        if email.len() > 254 {
            return Err(DomainError::Validation("邮箱地址过长".to_string()));
        }

        Ok(Self(email))
    }

    /// 获取邮箱字符串
    pub fn as_str(&self) -> &str {
        &self.0
    }

    /// 获取邮箱的域名部分
    pub fn domain(&self) -> &str {
        self.0.split('@').nth(1).unwrap_or("")
    }

    /// 获取邮箱的用户名部分
    pub fn local_part(&self) -> &str {
        self.0.split('@').next().unwrap_or("")
    }
}

impl fmt::Display for Email {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}
