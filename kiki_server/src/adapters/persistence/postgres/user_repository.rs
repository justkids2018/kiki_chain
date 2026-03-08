// PostgreSQL 用户仓储实现
// 对接 core::ports::UserRepository，负责用户数据的持久化

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use sqlx::{PgPool, Row};

use crate::core::entities::User;
use crate::core::errors::{DomainError, Result};
use crate::core::ports::UserRepository;
use crate::core::value_objects::UserId;

#[derive(Clone)]
pub struct PostgresUserRepository {
    pool: PgPool,
}

impl PostgresUserRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    /// 从数据库行映射到User实体
    /// 数据库列名: id, phone, password_hash, nickname, role_type, is_vip, vip_expire_at, created_at, last_login_at
    /// User实体字段: id(UUID), uid(String), name, email, pwd, phone, created_at, updated_at, role_type, is_vip, vip_expire_at
    fn map_row_to_user(row: &sqlx::postgres::PgRow) -> Result<User> {
        use chrono::NaiveDateTime;
        use uuid::Uuid;

        // 从数据库读取id字符串
        let id_str: String = row.get("id");

        // 尝试解析为UUID，如果失败则生成新的UUID
        let id_uuid = Uuid::parse_str(&id_str).unwrap_or_else(|_| Uuid::new_v4());

        // 读取TIMESTAMP并转换为DateTime<Utc>
        let created_at_naive: NaiveDateTime = row.get("created_at");
        let created_at = DateTime::from_naive_utc_and_offset(created_at_naive, Utc);

        // 读取last_login_at，可能为NULL
        let updated_at = row
            .try_get::<NaiveDateTime, _>("last_login_at")
            .ok()
            .map(|naive| DateTime::from_naive_utc_and_offset(naive, Utc))
            .unwrap_or_else(|| Utc::now());

        // 读取vip_expire_at，可能为NULL
        let vip_expire_at = row
            .try_get::<NaiveDateTime, _>("vip_expire_at")
            .ok()
            .map(|naive| DateTime::from_naive_utc_and_offset(naive, Utc));

        // 读取role_type (已在SQL中CAST为integer)
        let role_type: i32 = row.get("role_type");

        User::reconstruct(
            id_uuid,                                            // UUID id
            id_str,                                             // 使用id字符串作为uid
            row.get("nickname"),                                // nickname → name
            row.try_get("email").unwrap_or_else(|_| String::new()), // email可能不存在
            row.get("password_hash"),                           // password_hash → pwd
            row.get("phone"),
            created_at,
            updated_at,
            role_type,
            row.get("is_vip"),
            vip_expire_at,
        )
    }
}

#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn save(&self, user: &User) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO "users" (id, phone, password_hash, nickname, role_type, is_vip, vip_expire_at, created_at, last_login_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            ON CONFLICT (id) DO UPDATE SET
                phone = EXCLUDED.phone,
                password_hash = EXCLUDED.password_hash,
                nickname = EXCLUDED.nickname,
                role_type = EXCLUDED.role_type,
                is_vip = EXCLUDED.is_vip,
                vip_expire_at = EXCLUDED.vip_expire_at,
                last_login_at = EXCLUDED.last_login_at
            "#,
        )
        .bind(user.uid())  // 使用uid作为id
        .bind(user.phone())
        .bind(user.pwd())  // 映射到password_hash
        .bind(user.name()) // 映射到nickname
        .bind(user.role_type())
        .bind(user.is_vip())
        .bind(user.vip_expire_at())
        .bind(user.created_at())
        .bind(user.updated_at())  // 映射到last_login_at
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("保存用户失败: {}", e)))?;

        Ok(())
    }

    async fn find_by_id(&self, id: &UserId) -> Result<Option<User>> {
        let row = sqlx::query("SELECT * FROM \"users\" WHERE \"id\" = $1")
            .bind(id.to_string())
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("查询用户失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = Self::map_row_to_user(&row)?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }

    async fn find_by_phone_and_pwd(&self, identifier: &str, pwd: &str) -> Result<Option<User>> {
        let row = sqlx::query(
            "SELECT * FROM \"users\" WHERE \"phone\" = $1 AND \"password_hash\" = $2",
        )
        .bind(identifier)
        .bind(pwd)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("登录查询失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = Self::map_row_to_user(&row)?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }

    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>> {
        let row = sqlx::query("SELECT * FROM \"users\" WHERE \"phone\" = $1")
            .bind(phone)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("通过手机号查询用户失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = Self::map_row_to_user(&row)?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }

    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>> {
        let row = sqlx::query("SELECT * FROM \"users\" WHERE \"id\" = $1")
            .bind(uid)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("通过UID查询用户失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = Self::map_row_to_user(&row)?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }

    async fn find_users_by_role(&self, role_type: i32) -> Result<Vec<User>> {
        let rows = sqlx::query("SELECT * FROM \"users\" WHERE \"role_type\" = $1")
            .bind(role_type)
            .fetch_all(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("通过角色查询用户失败: {}", e)))?;

        let mut users = Vec::new();
        for row in rows {
            let user = User::reconstruct(
                row.get("id"),
                row.get("uid"),
                row.get("name"),
                row.get("email"),
                row.get("pwd"),
                row.get("phone"),
                row.get::<DateTime<Utc>, _>("created_at"),
                row.get::<DateTime<Utc>, _>("updated_at"),
                row.get("role_type"),
                row.get("is_vip"),
                row.get("vip_expire_at"),
            )?;
            users.push(user);
        }
        Ok(users)
    }
}
