// 通用工具类
// 提供密码哈希、验证等常用功能

use crate::domain::errors::{DomainError, Result};
use bcrypt::{hash, verify, DEFAULT_COST};

/// 通用工具类
/// 提供密码哈希、验证等常用功能
pub struct ToolUtils;

impl ToolUtils {
    /// 哈希密码
    pub fn hash_password(password: &str) -> Result<String> {
        hash(password, DEFAULT_COST)
            .map_err(|e| DomainError::Infrastructure(format!("密码哈希失败: {}", e)))
    }

    /// 验证密码
    pub fn verify_password(password: &str, hash: &str) -> Result<bool> {
        verify(password, hash)
            .map_err(|e| DomainError::Infrastructure(format!("密码验证失败: {}", e)))
    }
}
