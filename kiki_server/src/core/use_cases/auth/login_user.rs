// 用户登录用例
// 编排用户登录的完整业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::core::entities::User;
use crate::core::errors::{DomainError, Result};
use crate::core::ports::UserRepository;
use crate::utils::JwtUtils;
use tracing::{info, warn};

/// 用户登录命令
#[derive(Debug, Deserialize)]
pub struct LoginUserCommand {
    pub identifier: String, // 可以手机号或邮箱
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct LoginUserResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub token: String,
    pub message: String,
    pub phone: String,
    pub role_id: i32,
}

/// 用户登录用例
/// 处理用户身份验证的完整业务流程
pub struct LoginUserUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl LoginUserUseCase {
    pub fn new(user_repository: Arc<dyn UserRepository>) -> Self {
        Self { user_repository }
    }

    /// 执行用户登录
    pub async fn execute(&self, command: LoginUserCommand) -> Result<LoginUserResponse> {
        // 1. 验证输入数据
        self.validate_command(&command)?;
        info!("用户登陆 {} ", "-----查询开始---------");

        // 2. 查找用户（通过手机号或邮箱）
        let user = self.find_user(&command.identifier).await?;
        info!("用户登陆 查询信息：{}", user.to_string());

        // 3. 验证密码
        self.verify_password(&user, &command.password)?;

        // 4. 更新时间戳并保存用户
        let mut updated_user = user.clone();
        updated_user.update_timestamp();
        self.user_repository.save(&updated_user).await?;

        // 5. 生成JWT令牌
        let token = JwtUtils::generate_token(&updated_user)?;

        // 6. 返回响应
        Ok(LoginUserResponse {
            uid: updated_user.uid().to_string(),
            name: updated_user.name().to_string(),
            email: updated_user.email().to_string(),
            token,
            message: "登录成功".to_string(),
            phone: updated_user.phone().to_string(),
            role_id: updated_user.role_id(),
        })
    }

    /// 验证命令参数
    fn validate_command(&self, command: &LoginUserCommand) -> Result<()> {
        if command.identifier.trim().is_empty() {
            return Err(DomainError::Validation("手机号或邮箱不能为空".to_string()));
        }

        if command.password.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }

        Ok(())
    }

    /// 查找用户（通过手机号或邮箱）
    async fn find_user(&self, identifier: &str) -> Result<User> {
        // 尝试作为手机号名查找
        if let Some(user) = self.user_repository.find_by_phone(identifier).await? {
            return Ok(user);
        }

        Err(DomainError::Authentication("用户或密码错误".to_string()))
    }

    /// 验证密码
    fn verify_password(&self, user: &User, password: &str) -> Result<()> {
        info!("🔍 [密码验证] 开始验证用户 {} 的密码", user.uid());
        info!("🔍 [密码验证] 输入密码长度: {}", password.len());
        info!("🔍 [密码验证] 数据库存储密码: {}", user.pwd());
        if user.pwd() != password {
            warn!("❌ [密码验证] 用户 {} 密码验证失败", user.uid());
            return Err(DomainError::Authentication("用户或密码错误".to_string()));
        }
        info!("✅ [密码验证] 用户 {} 密码验证成功", user.uid());
        Ok(())
    }
}
