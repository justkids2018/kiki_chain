use chrono::{DateTime, Utc};
use serde::Serialize;
use uuid::Uuid;

use crate::core::errors::{DomainError, Result};

/// 用户实体
/// 只保留基础登录所需的字段和行为
#[derive(Debug, Clone, Serialize)]
pub struct User {
    id: Uuid,
    uid: String,
    name: String,
    email: String,
    pwd: String,
    phone: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
    role_id: i32,
}

impl User {
    /// 格式化展示用户关键信息，便于日志记录
    pub fn to_string(&self) -> String {
        format!(
            "User {{ id: {}, uid: {}, name: {}, email: {}, phone: {}, created_at: {}, updated_at: {}, role_id: {} }}",
            self.id,
            self.uid,
            self.name,
            self.email,
            self.phone,
            self.created_at,
            self.updated_at,
            self.role_id
        )
    }

    /// 创建新用户
    pub fn new(
        uid: String,
        name: String,
        email: String,
        pwd: String,
        phone: String,
        role_id: i32,
    ) -> Result<Self> {
        if name.trim().is_empty() {
            return Err(DomainError::Validation("用户名不能为空".to_string()));
        }
        if pwd.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }
        if uid.trim().is_empty() && phone.trim().is_empty() {
            return Err(DomainError::Validation(
                "邮箱和手机号不能同时为空".to_string(),
            ));
        }

        let now = Utc::now();

        Ok(Self {
            id: Uuid::new_v4(),
            uid,
            name,
            email,
            pwd,
            phone,
            created_at: now,
            updated_at: now,
            role_id,
        })
    }

    /// 从数据库记录重建用户实体
    #[allow(clippy::too_many_arguments)]
    pub fn reconstruct(
        id: Uuid,
        uid: String,
        name: String,
        email: String,
        pwd: String,
        phone: String,
        created_at: DateTime<Utc>,
        updated_at: DateTime<Utc>,
        role_id: i32,
    ) -> Result<Self> {
        Ok(Self {
            id,
            uid,
            name,
            email,
            pwd,
            phone,
            created_at,
            updated_at,
            role_id,
        })
    }

    /// 更新更新时间戳
    pub fn update_timestamp(&mut self) {
        self.updated_at = Utc::now();
    }

    /// 修改密码
    pub fn update_password(&mut self, new_pwd: String) -> Result<()> {
        if new_pwd.trim().is_empty() {
            return Err(DomainError::Validation("密码不能为空".to_string()));
        }
        self.pwd = new_pwd;
        self.updated_at = Utc::now();
        Ok(())
    }

    /// 修改用户标识
    pub fn update_uid(&mut self, new_uid: String) {
        self.uid = new_uid;
        self.updated_at = Utc::now();
    }

    /// 修改手机号
    pub fn update_phone(&mut self, new_phone: String) {
        self.phone = new_phone;
        self.updated_at = Utc::now();
    }

    pub fn id(&self) -> Uuid {
        self.id
    }
    pub fn uid(&self) -> &str {
        &self.uid
    }
    pub fn name(&self) -> &str {
        &self.name
    }
    pub fn email(&self) -> &str {
        &self.email
    }
    pub fn pwd(&self) -> &str {
        &self.pwd
    }
    pub fn phone(&self) -> &str {
        &self.phone
    }
    pub fn created_at(&self) -> DateTime<Utc> {
        self.created_at
    }
    pub fn updated_at(&self) -> DateTime<Utc> {
        self.updated_at
    }
    pub fn role_id(&self) -> i32 {
        self.role_id
    }
}
