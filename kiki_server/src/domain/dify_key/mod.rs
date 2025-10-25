// Dify API Key 领域模块
// 定义密钥聚合、工厂、更新器与仓储抽象，确保密钥管理符合领域规则

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};

/// Dify API Key 聚合根
/// 表示一条可供外部系统调用的密钥记录
#[derive(Debug, Clone)]
pub struct DifyApiKey {
    id: Uuid,
    key_type: String,
    key: String,
    info: Option<String>,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

impl DifyApiKey {
    /// 通过已有字段重建聚合根（用于持久化还原）
    pub fn reconstruct(
        id: Uuid,
        key_type: String,
        key: String,
        info: Option<String>,
        created_at: DateTime<Utc>,
        updated_at: DateTime<Utc>,
    ) -> Self {
        Self {
            id,
            key_type,
            key,
            info,
            created_at,
            updated_at,
        }
    }

    /// 全量更新可修改字段后自动刷新更新时间戳
    pub fn apply_updates(
        &mut self,
        key_type: Option<String>,
        key: Option<String>,
        info: Option<Option<String>>,
    ) {
        if let Some(new_type) = key_type {
            self.key_type = new_type;
        }
        if let Some(new_key) = key {
            self.key = new_key;
        }
        if let Some(new_info) = info {
            self.info = new_info;
        }
        self.updated_at = Utc::now();
    }

    /// 获取唯一标识
    pub fn id(&self) -> &Uuid {
        &self.id
    }

    /// 获取密钥类型
    pub fn key_type(&self) -> &str {
        &self.key_type
    }

    /// 获取密钥值
    pub fn key(&self) -> &str {
        &self.key
    }

    /// 获取备注信息
    pub fn info(&self) -> Option<&String> {
        self.info.as_ref()
    }

    /// 获取创建时间
    pub fn created_at(&self) -> &DateTime<Utc> {
        &self.created_at
    }

    /// 获取最近更新时间
    pub fn updated_at(&self) -> &DateTime<Utc> {
        &self.updated_at
    }
}

/// 用于构建密钥的领域数据载体
#[derive(Debug, Clone)]
pub struct DifyApiKeyCreateData {
    pub key_type: String,
    pub key: String,
    pub info: Option<String>,
}

/// 密钥更新载体，所有字段可选
#[derive(Debug, Default, Clone)]
pub struct DifyApiKeyUpdateData {
    pub key_type: Option<String>,
    pub key: Option<String>,
    pub info: Option<Option<String>>,
}

/// 密钥领域工厂，负责校验输入并创建聚合根
pub struct DifyApiKeyFactory;

impl DifyApiKeyFactory {
    /// 根据输入创建新的密钥记录
    pub fn create(data: DifyApiKeyCreateData) -> Result<DifyApiKey> {
        Self::validate_key_type(&data.key_type)?;
        Self::validate_key(&data.key)?;
        Self::validate_info(data.info.as_ref())?;

        let now = Utc::now();
        Ok(DifyApiKey::reconstruct(
            Uuid::new_v4(),
            data.key_type,
            data.key,
            data.info,
            now,
            now,
        ))
    }

    fn validate_key_type(key_type: &str) -> Result<()> {
        if key_type.trim().is_empty() {
            return Err(DomainError::Validation("密钥类型不能为空".to_string()));
        }
        if key_type.len() > 50 {
            return Err(DomainError::Validation(
                "密钥类型长度不能超过50字符".to_string(),
            ));
        }
        Ok(())
    }

    fn validate_key(key: &str) -> Result<()> {
        if key.trim().is_empty() {
            return Err(DomainError::Validation("密钥内容不能为空".to_string()));
        }
        if key.len() > 255 {
            return Err(DomainError::Validation(
                "密钥内容长度不能超过255字符".to_string(),
            ));
        }
        Ok(())
    }

    fn validate_info(info: Option<&String>) -> Result<()> {
        if let Some(value) = info {
            if value.len() > 1024 {
                return Err(DomainError::Validation(
                    "备注信息长度不能超过1024字符".to_string(),
                ));
            }
        }
        Ok(())
    }
}

/// 密钥更新器，应用更新载体到聚合根
pub struct DifyApiKeyUpdater;

impl DifyApiKeyUpdater {
    /// 根据更新载体修改聚合根
    pub fn apply(target: &mut DifyApiKey, data: DifyApiKeyUpdateData) -> Result<()> {
        if let Some(ref key_type) = data.key_type {
            DifyApiKeyFactory::validate_key_type(key_type)?;
        }
        if let Some(ref key) = data.key {
            DifyApiKeyFactory::validate_key(key)?;
        }
        if let Some(ref info) = data.info {
            DifyApiKeyFactory::validate_info(info.as_ref())?;
        }

        target.apply_updates(data.key_type, data.key, data.info);
        Ok(())
    }
}

/// Dify API Key 仓储接口
/// 隔离持久化细节，供应用层调用
#[async_trait]
pub trait DifyApiKeyRepository: Send + Sync {
    /// 保存或更新密钥
    async fn save(&self, key: &DifyApiKey) -> Result<()>;

    /// 根据标识查询单条密钥
    async fn find_by_id(&self, id: &Uuid) -> Result<Option<DifyApiKey>>;

    /// 查询全部密钥
    async fn find_all(&self) -> Result<Vec<DifyApiKey>>;

    /// 根据类型过滤密钥
    async fn find_by_type(&self, key_type: &str) -> Result<Vec<DifyApiKey>>;

    /// 删除密钥记录
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

/// 便于依赖注入的共享引用类型
pub type DifyApiKeyRepositoryArc = std::sync::Arc<dyn DifyApiKeyRepository>;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn factory_creates_key_with_valid_data() {
        let data = DifyApiKeyCreateData {
            key_type: "dify".to_string(),
            key: "test-key".to_string(),
            info: Some("用于测试的密钥".to_string()),
        };

        let result = DifyApiKeyFactory::create(data);
        assert!(result.is_ok());
    }

    #[test]
    fn factory_rejects_empty_type() {
        let data = DifyApiKeyCreateData {
            key_type: " ".to_string(),
            key: "test-key".to_string(),
            info: None,
        };

        let result = DifyApiKeyFactory::create(data);
        assert!(matches!(result, Err(DomainError::Validation(_))));
    }

    #[test]
    fn updater_updates_fields() {
        let mut entity = DifyApiKeyFactory::create(DifyApiKeyCreateData {
            key_type: "dify".to_string(),
            key: "old".to_string(),
            info: None,
        })
        .unwrap();

        let update = DifyApiKeyUpdateData {
            key_type: Some("new-type".to_string()),
            key: Some("new-key".to_string()),
            info: Some(Some("说明".to_string())),
        };

        DifyApiKeyUpdater::apply(&mut entity, update).unwrap();

        assert_eq!(entity.key_type(), "new-type");
        assert_eq!(entity.key(), "new-key");
        assert_eq!(entity.info(), Some(&"说明".to_string()));
    }
}
