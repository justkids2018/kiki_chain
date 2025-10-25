//! 更新 Dify API Key 用例
//! 处理类型、密钥值以及备注信息的变更

use serde::Deserialize;
use serde::Serialize;
use uuid::Uuid;

use crate::domain::dify_key::{DifyApiKeyRepositoryArc, DifyApiKeyUpdateData, DifyApiKeyUpdater};
use crate::domain::errors::{DomainError, Result};
use crate::infrastructure::logging::Logger;

use super::dto::DifyApiKeyView;

/// 更新密钥命令
#[derive(Debug, Deserialize)]
pub struct UpdateDifyApiKeyCommand {
    pub id: String,
    pub key_type: Option<String>,
    pub key: Option<String>,
    pub info: Option<Option<String>>,
}

/// 更新密钥响应
#[derive(Debug, Serialize)]
pub struct UpdateDifyApiKeyResponse {
    pub key: DifyApiKeyView,
}

/// 更新密钥用例
pub struct UpdateDifyApiKeyUseCase {
    repository: DifyApiKeyRepositoryArc,
}

impl UpdateDifyApiKeyUseCase {
    /// 构建用例实例
    pub fn new(repository: DifyApiKeyRepositoryArc) -> Self {
        Self { repository }
    }

    /// 执行更新流程
    pub async fn execute(
        &self,
        command: UpdateDifyApiKeyCommand,
    ) -> Result<UpdateDifyApiKeyResponse> {
        Logger::info(format!("🛠️ [Dify Key] 更新密钥 id={}", command.id));

        let id = Uuid::parse_str(&command.id)
            .map_err(|_| DomainError::Validation("密钥ID格式不正确".to_string()))?;

        let mut entity = self
            .repository
            .find_by_id(&id)
            .await?
            .ok_or_else(|| DomainError::NotFound("密钥不存在".to_string()))?;

        let update_data = DifyApiKeyUpdateData {
            key_type: command.key_type,
            key: command.key,
            info: command.info,
        };

        DifyApiKeyUpdater::apply(&mut entity, update_data)?;
        self.repository.save(&entity).await?;

        let view = DifyApiKeyView::from(&entity);
        Logger::info(format!(
            "✅ [Dify Key] 密钥更新成功 id={} type={}",
            view.id, view.key_type
        ));

        Ok(UpdateDifyApiKeyResponse { key: view })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;
    use std::collections::HashMap;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    use crate::domain::dify_key::{
        DifyApiKey, DifyApiKeyCreateData, DifyApiKeyFactory, DifyApiKeyRepository,
    };
    use crate::domain::errors::{DomainError, Result as DomainResult};

    struct InMemoryRepo {
        store: Mutex<HashMap<Uuid, DifyApiKey>>,
    }

    impl InMemoryRepo {
        fn new() -> Self {
            Self {
                store: Mutex::new(HashMap::new()),
            }
        }
    }

    #[async_trait]
    impl DifyApiKeyRepository for InMemoryRepo {
        async fn save(&self, key: &DifyApiKey) -> DomainResult<()> {
            let mut store = self.store.lock().await;
            if store.values().any(|item| {
                item.key_type() == key.key_type()
                    && item.key() == key.key()
                    && item.id() != key.id()
            }) {
                return Err(DomainError::AlreadyExists("密钥已存在".to_string()));
            }
            store.insert(*key.id(), key.clone());
            Ok(())
        }

        async fn find_by_id(&self, id: &Uuid) -> DomainResult<Option<DifyApiKey>> {
            Ok(self.store.lock().await.get(id).cloned())
        }

        async fn find_all(&self) -> DomainResult<Vec<DifyApiKey>> {
            Ok(self.store.lock().await.values().cloned().collect())
        }

        async fn find_by_type(&self, key_type: &str) -> DomainResult<Vec<DifyApiKey>> {
            let store = self.store.lock().await;
            Ok(store
                .values()
                .filter(|item| item.key_type() == key_type)
                .cloned()
                .collect())
        }

        async fn delete(&self, id: &Uuid) -> DomainResult<()> {
            self.store.lock().await.remove(id);
            Ok(())
        }
    }

    #[tokio::test]
    async fn execute_updates_existing_key() {
        let repo = Arc::new(InMemoryRepo::new());
        let entity = DifyApiKeyFactory::create(DifyApiKeyCreateData {
            key_type: "dify".to_string(),
            key: "old".to_string(),
            info: Some("备注".to_string()),
        })
        .unwrap();
        let id = entity.id().to_string();
        repo.save(&entity).await.unwrap();

        let use_case = UpdateDifyApiKeyUseCase::new(repo.clone());
        let response = use_case
            .execute(UpdateDifyApiKeyCommand {
                id: id.clone(),
                key_type: Some("new-type".to_string()),
                key: Some("new-key".to_string()),
                info: Some(None),
            })
            .await
            .unwrap();

        assert_eq!(response.key.key_type, "new-type");
        assert_eq!(response.key.info, None);

        let stored = repo
            .find_by_id(&Uuid::parse_str(&id).unwrap())
            .await
            .unwrap()
            .unwrap();
        assert_eq!(stored.key_type(), "new-type");
        assert_eq!(stored.info(), None);
    }

    #[tokio::test]
    async fn execute_returns_error_for_invalid_id() {
        let repo = Arc::new(InMemoryRepo::new());
        let use_case = UpdateDifyApiKeyUseCase::new(repo);

        let result = use_case
            .execute(UpdateDifyApiKeyCommand {
                id: "invalid".to_string(),
                key_type: None,
                key: None,
                info: None,
            })
            .await;

        assert!(matches!(result, Err(DomainError::Validation(_))));
    }

    #[tokio::test]
    async fn execute_returns_not_found_for_missing_entity() {
        let repo = Arc::new(InMemoryRepo::new());
        let use_case = UpdateDifyApiKeyUseCase::new(repo);
        let result = use_case
            .execute(UpdateDifyApiKeyCommand {
                id: Uuid::new_v4().to_string(),
                key_type: Some("type".to_string()),
                key: None,
                info: None,
            })
            .await;

        assert!(matches!(result, Err(DomainError::NotFound(_))));
    }
}
