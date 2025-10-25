// PostgreSQL用户仓储实现
// 实现domain层的UserRepository trait

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use sqlx::{PgPool, Row};

use crate::domain::entities::User;
use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::UserRepository;
use crate::domain::value_objects::UserId;

#[derive(Clone)]
pub struct PostgresUserRepository {
    pool: PgPool,
}

impl PostgresUserRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn save(&self, user: &User) -> Result<()> {
        // 使用 INSERT ... ON CONFLICT 来处理更新
        sqlx::query(
            r#"
            INSERT INTO "users" (id, uid, name, email, pwd, phone, created_at, updated_at, role_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            ON CONFLICT (id) DO UPDATE SET 
                uid = EXCLUDED.uid,
                name = EXCLUDED.name,
                email = EXCLUDED.email,
                pwd = EXCLUDED.pwd,
                phone = EXCLUDED.phone,
                updated_at = EXCLUDED.updated_at,
                role_id = EXCLUDED.role_id
            "#,
        )
        .bind(user.id())
        .bind(user.uid())
        .bind(user.name())
        .bind(user.email())
        .bind(user.pwd())
        .bind(user.phone())
        .bind(user.created_at())
        .bind(user.updated_at())
        .bind(user.role_id())
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("保存用户失败: {}", e)))?;

        Ok(())
    }

    async fn find_by_id(&self, id: &UserId) -> Result<Option<User>> {
        let row = sqlx::query("SELECT *  FROM \"users\" WHERE \"uid\" = $1")
            .bind(id.to_string())
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("查询用户失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = User::reconstruct(
                    row.get("id"),
                    row.get("uid"),
                    row.get("name"),
                    row.get("email"),
                    row.get("pwd"),
                    row.get("phone"),
                    row.get::<DateTime<Utc>, _>("created_at"),
                    row.get::<DateTime<Utc>, _>("updated_at"),
                    row.get("role_id"),
                )?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }

    async fn find_by_phone_and_pwd(&self, identifier: &str, pwd: &str) -> Result<Option<User>> {
        let row = sqlx::query(
            "SELECT * FROM \"users\" WHERE (\"uid\" = $1 OR \"phone\" = $1) AND \"pwd\" = $2",
        )
        .bind(identifier)
        .bind(pwd)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::Infrastructure(format!("登录查询失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = User::reconstruct(
                    row.get("id"),
                    row.get("uid"),
                    row.get("name"),
                    row.get("email"),
                    row.get("pwd"),
                    row.get("phone"),
                    row.get::<DateTime<Utc>, _>("created_at"),
                    row.get::<DateTime<Utc>, _>("updated_at"),
                    row.get("role_id"),
                )?;
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
                let user = User::reconstruct(
                    row.get("id"),
                    row.get("uid"),
                    row.get("name"),
                    row.get("email"),
                    row.get("pwd"),
                    row.get("phone"),
                    row.get::<DateTime<Utc>, _>("created_at"),
                    row.get::<DateTime<Utc>, _>("updated_at"),
                    row.get("role_id"),
                )?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }

    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>> {
        let row = sqlx::query("SELECT * FROM \"users\" WHERE \"uid\" = $1")
            .bind(uid)
            .fetch_optional(&self.pool)
            .await
            .map_err(|e| DomainError::Infrastructure(format!("通过UID查询用户失败: {}", e)))?;

        match row {
            Some(row) => {
                let user = User::reconstruct(
                    row.get("id"),
                    row.get("uid"),
                    row.get("name"),
                    row.get("email"),
                    row.get("pwd"),
                    row.get("phone"),
                    row.get::<DateTime<Utc>, _>("created_at"),
                    row.get::<DateTime<Utc>, _>("updated_at"),
                    row.get("role_id"),
                )?;
                Ok(Some(user))
            }
            None => Ok(None),
        }
    }

    async fn find_users_by_role(&self, role_id: i32) -> Result<Vec<User>> {
        let rows = sqlx::query("SELECT * FROM \"users\" WHERE \"role_id\" = $1")
            .bind(role_id)
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
                row.get("role_id"),
            )?;
            users.push(user);
        }
        Ok(users)
    }
}
