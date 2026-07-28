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
    pub role_type: i32,
}

/// 用户注册响应
#[derive(Debug, Serialize)]
pub struct RegisterUserResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub role_type: i32,
    pub is_vip: bool,
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

        let role_type = self.normalize_role_type(command.role_type)?;

        let user = User::new(
            command.uid.clone(),
            command.name.clone(),
            command.email.clone(),
            command.password.clone(),
            command.phone.clone(),
            role_type,
        )?;

        self.user_repository.save(&user).await?;
        info!("[用户注册] 用户 {} 注册成功", user.uid());

        Ok(RegisterUserResponse {
            uid: user.uid().to_string(),
            name: user.name().to_string(),
            email: user.email().to_string(),
            phone: user.phone().to_string(),
            role_type: user.role_type(),
            is_vip: user.is_vip(),
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

    fn normalize_role_type(&self, role_type: i32) -> Result<i32> {
        match role_type {
            0 | 1 => Ok(1),
            2 => Ok(2),
            _ => Err(DomainError::Validation("用户角色类型无效".to_string())),
        }
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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::ports::UserRepository;
    use crate::core::value_objects::UserId;
    use async_trait::async_trait;
    use std::sync::Mutex;

    #[derive(Default)]
    struct MockUserRepository {
        saved_role_type: Mutex<Option<i32>>,
    }

    #[async_trait]
    impl UserRepository for MockUserRepository {
        async fn save(&self, user: &User) -> Result<()> {
            *self.saved_role_type.lock().unwrap() = Some(user.role_type());
            Ok(())
        }

        async fn find_by_id(&self, _id: &UserId) -> Result<Option<User>> {
            Ok(None)
        }

        async fn find_by_uid(&self, _uid: &str) -> Result<Option<User>> {
            Ok(None)
        }

        async fn find_by_phone_and_pwd(
            &self,
            _identifier: &str,
            _pwd: &str,
        ) -> Result<Option<User>> {
            Ok(None)
        }

        async fn find_by_phone(&self, _phone: &str) -> Result<Option<User>> {
            Ok(None)
        }

        async fn find_users_by_role(&self, _role_id: i32) -> Result<Vec<User>> {
            Ok(Vec::new())
        }
    }

    #[tokio::test]
    async fn register_treats_legacy_role_type_zero_as_user() {
        let repository = Arc::new(MockUserRepository::default());
        let use_case = RegisterUserUseCase::new(repository.clone());

        let response = use_case
            .execute(RegisterUserCommand {
                uid: "kiki_test_legacy_role".to_string(),
                name: "Kiki Test".to_string(),
                email: "".to_string(),
                phone: "13900000001".to_string(),
                password: "abc123".to_string(),
                role_type: 0,
            })
            .await
            .expect("legacy role_type=0 should register as a normal user");

        assert_eq!(response.role_type, 1);
        assert_eq!(*repository.saved_role_type.lock().unwrap(), Some(1));
    }

    #[tokio::test]
    async fn register_rejects_unknown_role_type_before_save() {
        let repository = Arc::new(MockUserRepository::default());
        let use_case = RegisterUserUseCase::new(repository.clone());

        let error = use_case
            .execute(RegisterUserCommand {
                uid: "kiki_test_invalid_role".to_string(),
                name: "Kiki Test".to_string(),
                email: "".to_string(),
                phone: "13900000002".to_string(),
                password: "abc123".to_string(),
                role_type: 9,
            })
            .await
            .expect_err("unknown role_type should be rejected");

        assert!(matches!(error, DomainError::Validation(_)));
        assert_eq!(*repository.saved_role_type.lock().unwrap(), None);
    }
}
