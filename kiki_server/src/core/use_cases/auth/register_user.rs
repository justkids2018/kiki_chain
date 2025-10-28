// 用户注册用例
// 处理注册流程，包括验证、唯一性检查和持久化

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::core::entities::User;
use crate::core::errors::{DomainError, Result};
use crate::core::ports::UserRepository;
use tracing::info;

/// 用户注册命令
#[derive(Debug, Deserialize)]
pub struct RegisterUserCommand {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub password: String,
    pub role_id: i32,
}

/// 用户注册响应
#[derive(Debug, Serialize)]
pub struct RegisterUserResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub role_id: i32,
    pub message: String,
}

/// 用户注册用例
pub struct RegisterUserUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl RegisterUserUseCase {
    pub fn new(user_repository: Arc<dyn UserRepository>) -> Self {
        Self { user_repository }
    }

    /// 执行注册逻辑
    pub async fn execute(&self, command: RegisterUserCommand) -> Result<RegisterUserResponse> {
        self.validate_command(&command)?;
        info!("[用户注册] 开始执行注册流程");

        self.ensure_unique_uid(&command.uid).await?;
        self.ensure_unique_phone(&command.phone).await?;

        let user = User::new(
            command.uid.clone(),
            command.name.clone(),
            command.email.clone(),
            command.password.clone(),
            command.phone.clone(),
            command.role_id,
        )?;

        self.user_repository.save(&user).await?;
        info!("[用户注册] 用户 {} 注册成功", user.uid());

        Ok(RegisterUserResponse {
            uid: user.uid().to_string(),
            name: user.name().to_string(),
            email: user.email().to_string(),
            phone: user.phone().to_string(),
            role_id: user.role_id(),
            message: "注册成功".to_string(),
        })
    }

    fn validate_command(&self, command: &RegisterUserCommand) -> Result<()> {
        if command.uid.trim().is_empty() {
            return Err(DomainError::Validation("用户UID不能为空".to_string()));
        }
        if command.name.trim().is_empty() {
            return Err(DomainError::Validation("用户名不能为空".to_string()));
        }
        if command.phone.trim().is_empty() {
            return Err(DomainError::Validation("手机号不能为空".to_string()));
        }
        if command.password.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }
        Ok(())
    }

    async fn ensure_unique_uid(&self, uid: &str) -> Result<()> {
        if self.user_repository.find_by_uid(uid).await?.is_some() {
            return Err(DomainError::AlreadyExists("用户UID已存在".to_string()));
        }
        Ok(())
    }

    async fn ensure_unique_phone(&self, phone: &str) -> Result<()> {
        if self.user_repository.find_by_phone(phone).await?.is_some() {
            return Err(DomainError::AlreadyExists("手机号已被注册".to_string()));
        }
        Ok(())
    }
}
