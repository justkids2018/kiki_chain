pub mod scene;

pub use scene::{Scene, SceneCategory, SceneDetail, SceneItem};

use chrono::{DateTime, Utc};
use serde::Serialize;
use uuid::Uuid;

use crate::core::errors::{DomainError, Result};
use crate::core::value_objects::UserRole;

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
    role_type: i32,
    is_vip: bool,
    vip_expire_at: Option<DateTime<Utc>>,
}

impl User {
    /// 格式化展示用户关键信息，便于日志记录
    pub fn to_string(&self) -> String {
        format!(
            "User {{ id: {}, uid: {}, name: {}, email: {}, phone: {}, created_at: {}, updated_at: {}, role_type: {}, is_vip: {} }}",
            self.id,
            self.uid,
            self.name,
            self.email,
            self.phone,
            self.created_at,
            self.updated_at,
            self.role_type,
            self.is_vip
        )
    }

    /// 创建新用户
    pub fn new(
        uid: String,
        name: String,
        email: String,
        pwd: String,
        phone: String,
        role_type: i32,
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
            role_type,
            is_vip: false,
            vip_expire_at: None,
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
        role_type: i32,
        is_vip: bool,
        vip_expire_at: Option<DateTime<Utc>>,
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
            role_type,
            is_vip,
            vip_expire_at,
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
    pub fn role_type(&self) -> i32 {
        self.role_type
    }
    pub fn is_vip(&self) -> bool {
        self.is_vip
    }
    pub fn vip_expire_at(&self) -> Option<DateTime<Utc>> {
        self.vip_expire_at
    }

    /// 获取用户角色枚举
    pub fn role(&self) -> Result<UserRole> {
        UserRole::from_i32(self.role_type)
    }

    /// 检查是否为管理员
    pub fn is_admin(&self) -> bool {
        self.role_type == UserRole::Admin.to_i32()
    }

    /// 检查是否为普通用户
    pub fn is_user(&self) -> bool {
        self.role_type == UserRole::User.to_i32()
    }

    /// 检查 VIP 是否有效（未过期）
    pub fn is_vip_valid(&self) -> bool {
        if !self.is_vip {
            return false;
        }
        match self.vip_expire_at {
            Some(expire_at) => Utc::now() < expire_at,
            None => true, // 永久 VIP
        }
    }

    /// 设置 VIP 状态
    pub fn set_vip(&mut self, expire_at: Option<DateTime<Utc>>) {
        self.is_vip = true;
        self.vip_expire_at = expire_at;
        self.updated_at = Utc::now();
    }

    /// 取消 VIP 状态
    pub fn cancel_vip(&mut self) {
        self.is_vip = false;
        self.vip_expire_at = None;
        self.updated_at = Utc::now();
    }
}
