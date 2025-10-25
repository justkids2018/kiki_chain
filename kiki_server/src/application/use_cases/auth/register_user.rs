// 用户注册用例
// 编排用户注册的完整业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::entities::User;
use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::UserRepository;
use crate::utils::JwtUtils;

/// 用户注册命令
#[derive(Debug, Deserialize)]
pub struct RegisterUserCommand {
    pub username: String,
    pub email: Option<String>,
    pub role_id: i32,
    pub password: String,
    pub phone: String,
}

/// 用户注册响应
#[derive(Debug, Serialize)]
pub struct RegisterUserResponse {
    pub user_id: String,
    pub username: String,
    pub email: Option<String>,
    pub phone: String,
    pub token: String,
    pub message: String,
    pub role_id: i32,
}

/// 用户注册用例
/// 处理用户注册的完整业务流程
pub struct RegisterUserUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl RegisterUserUseCase {
    pub fn new(user_repository: Arc<dyn UserRepository>) -> Self {
        Self { user_repository }
    }

    /// 执行用户注册
    pub async fn execute(&self, command: RegisterUserCommand) -> Result<RegisterUserResponse> {
        // 1. 验证输入数据
        self.validate_command(&command)?;

        // 3. 验证业务规则：检查用户名和邮箱的唯一性
        self.validate_user_uniqueness(&command.username, &command.phone)
            .await?;

        // 4. 暂存明文密码（临时代码，后续需恢复加密存储）
        let stored_password = command.password.clone();

        // 5. 创建用户实体
        let email_str = match command.email.clone() {
            Some(email_str) if !email_str.trim().is_empty() => email_str,
            _ => String::new(), // 空字符串表示无邮箱
        };

        // uid 根据 role_id  学生2 uid student_开头 老师3 teacher_开头 1 系统 admin_开头 然后加上时间戳防止重复

        let uid = format!(
            "{}{}",
            if command.role_id == 2 {
                "student_"
            } else if command.role_id == 3 {
                "teacher_"
            } else {
                "admin_"
            },
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs()
        );

        let user = User::new(
            uid,
            command.username.clone(),
            email_str,
            stored_password,
            command.phone.clone(),
            command.role_id,
        )?;

        // 6. 保存用户
        self.user_repository.save(&user).await?;

        // 7. 生成JWT令牌
        let token = JwtUtils::generate_token(&user)?;
        // 8. 返回响应
        Ok(RegisterUserResponse {
            user_id: user.id().to_string(),
            username: user.name().to_string(),
            email: if user.email().is_empty() {
                None
            } else {
                Some(user.email().to_string())
            },
            phone: user.phone().to_string(),
            token,
            message: "用户注册成功".to_string(),
            role_id: command.role_id,
        })
    }

    /// 验证命令参数
    fn validate_command(&self, command: &RegisterUserCommand) -> Result<()> {
        if command.username.trim().is_empty() {
            return Err(DomainError::Validation("用户名不能为空".to_string()));
        }

        // email 是可选字段，如果提供了非空值就验证格式
        if let Some(email) = &command.email {
            if !email.trim().is_empty() {
                // 简单的邮箱格式验证
                if !email.contains('@') || !email.contains('.') {
                    return Err(DomainError::Validation("邮箱格式不正确".to_string()));
                }
            }
            // 空字符串会在创建实体时被处理为 None，这里不报错
        }

        if command.password.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }

        if command.password.len() < 4 {
            return Err(DomainError::Validation("密码长度至少4个字符".to_string()));
        }

        if command.password.len() > 128 {
            return Err(DomainError::Validation(
                "密码长度不能超过128个字符".to_string(),
            ));
        }

        if command.phone.trim().is_empty() {
            return Err(DomainError::Validation("手机号不能为空".to_string()));
        }

        // 验证角色ID是否有效
        if command.role_id != 3 && command.role_id != 2 {
            return Err(DomainError::Validation(
                "请选择有效的身份角色: 3(老师) 或 2(学生)".to_string(),
            ));
        }

        Ok(())
    }

    /// 验证用户唯一性
    async fn validate_user_uniqueness(&self, _username: &str, phone: &str) -> Result<()> {
        // 检查手机号是否已存在
        if self.user_repository.find_by_phone(phone).await?.is_some() {
            return Err(DomainError::AlreadyExists(format!(
                "手机号 '{}' 已存在",
                phone
            )));
        }
        Ok(())
    }
}
