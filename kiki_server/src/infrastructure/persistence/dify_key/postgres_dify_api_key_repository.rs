// PostgreSQL 实现的 Dify API Key 仓储
// 负责将领域聚合与数据库记录互相转换

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use sqlx::{PgPool, Row};
use uuid::Uuid;

use crate::domain::dify_key::{DifyApiKey, DifyApiKeyRepository, DifyApiKeyRepositoryArc};
use crate::domain::errors::{DomainError, Result};

/// PostgreSQL 版 Dify API Key 仓储
pub struct PostgresDifyApiKeyRepository {
    pool: PgPool,
}

impl PostgresDifyApiKeyRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    fn map_row_to_entity(row: &sqlx::postgres::PgRow) -> Result<DifyApiKey> {
        let id: Uuid = row.try_get("id")?;
        let key_type: String = row.try_get("type")?;
        let key: String = row.try_get("key")?;
        let info: Option<String> = row.try_get("info")?;
        let created_at: DateTime<Utc> = row.try_get("created_at")?;
        let updated_at: DateTime<Utc> = row.try_get("updated_at")?;

        Ok(DifyApiKey::reconstruct(
            id, key_type, key, info, created_at, updated_at,
        ))
    }

    fn convert_db_error(err: sqlx::Error) -> DomainError {
        if let sqlx::Error::Database(db_err) = &err {
            if db_err.code().as_deref() == Some("23505") {
                return DomainError::AlreadyExists("同类型下的密钥已存在".to_string());
            }
        }
        err.into()
    }
}

#[async_trait]
impl DifyApiKeyRepository for PostgresDifyApiKeyRepository {
    async fn save(&self, key: &DifyApiKey) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO api_keys (id, "type", "key", info, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            ON CONFLICT (id) DO UPDATE SET
                "type" = EXCLUDED."type",
                "key" = EXCLUDED."key",
                info = EXCLUDED.info,
                updated_at = EXCLUDED.updated_at
            "#,
        )
        .bind(key.id())
        .bind(key.key_type())
        .bind(key.key())
        .bind(key.info())
        .bind(key.created_at())
        .bind(key.updated_at())
        .execute(&self.pool)
        .await
        .map(|_| ())
        .map_err(Self::convert_db_error)
    }

    async fn find_by_id(&self, id: &Uuid) -> Result<Option<DifyApiKey>> {
        let row = sqlx::query(
            r#"
            SELECT id, "type", "key", info, created_at, updated_at
            FROM api_keys
            WHERE id = $1
            "#,
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(DomainError::from)?;

        match row {
            Some(row) => Ok(Some(Self::map_row_to_entity(&row)?)),
            None => Ok(None),
        }
    }

    async fn find_all(&self) -> Result<Vec<DifyApiKey>> {
        let rows = sqlx::query(
            r#"
            SELECT id, "type", "key", info, created_at, updated_at
            FROM api_keys
            ORDER BY created_at DESC
            "#,
        )
        .fetch_all(&self.pool)
        .await
        .map_err(DomainError::from)?;

        rows.iter()
            .map(Self::map_row_to_entity)
            .collect::<Result<Vec<_>>>()
    }

    async fn find_by_type(&self, key_type: &str) -> Result<Vec<DifyApiKey>> {
        let rows = sqlx::query(
            r#"
            SELECT id, "type", "key", info, created_at, updated_at
            FROM api_keys
            WHERE "type" = $1
            ORDER BY created_at DESC
            "#,
        )
        .bind(key_type)
        .fetch_all(&self.pool)
        .await
        .map_err(DomainError::from)?;

        rows.iter()
            .map(Self::map_row_to_entity)
            .collect::<Result<Vec<_>>>()
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM api_keys WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await
            .map(|_| ())
            .map_err(DomainError::from)
    }
}

/// 便捷的引用构造函数
pub fn create_dify_api_key_repository(pool: PgPool) -> DifyApiKeyRepositoryArc {
    std::sync::Arc::new(PostgresDifyApiKeyRepository::new(pool))
}
