//! 删除 Dify API Key 用例
//! 负责校验标识并执行硬删除

use serde::Deserialize;
use serde::Serialize;
use uuid::Uuid;

use crate::domain::dify_key::DifyApiKeyRepositoryArc;
use crate::domain::errors::{DomainError, Result};
use crate::infrastructure::logging::Logger;

/// 删除密钥命令
#[derive(Debug, Deserialize)]
pub struct DeleteDifyApiKeyCommand {
    pub id: String,
}

/// 删除密钥响应
#[derive(Debug, Serialize)]
pub struct DeleteDifyApiKeyResponse {
    pub id: String,
}

/// 删除密钥用例
pub struct DeleteDifyApiKeyUseCase {
    repository: DifyApiKeyRepositoryArc,
}

impl DeleteDifyApiKeyUseCase {
    /// 构建用例实例
    pub fn new(repository: DifyApiKeyRepositoryArc) -> Self {
        Self { repository }
    }

    /// 执行删除流程
    pub async fn execute(
        &self,
        command: DeleteDifyApiKeyCommand,
    ) -> Result<DeleteDifyApiKeyResponse> {
        Logger::info(format!("🗑️ [Dify Key] 删除密钥 id={}", command.id));

        let id = Uuid::parse_str(&command.id)
            .map_err(|_| DomainError::Validation("密钥ID格式不正确".to_string()))?;

        // 确保存在，避免静默删除
        if self.repository.find_by_id(&id).await?.is_none() {
            return Err(DomainError::NotFound("密钥不存在".to_string()));
        }

        self.repository.delete(&id).await?;
        Logger::info(format!("✅ [Dify Key] 密钥删除成功 id={}", command.id));

        Ok(DeleteDifyApiKeyResponse { id: command.id })
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
    async fn execute_deletes_existing_key() {
        let repo = Arc::new(InMemoryRepo::new());
        let entity = DifyApiKeyFactory::create(DifyApiKeyCreateData {
            key_type: "dify".to_string(),
            key: "to-delete".to_string(),
            info: None,
        })
        .unwrap();
        let id = entity.id().to_string();
        repo.save(&entity).await.unwrap();

        let use_case = DeleteDifyApiKeyUseCase::new(repo.clone());
        let response = use_case
            .execute(DeleteDifyApiKeyCommand { id: id.clone() })
            .await
            .unwrap();

        assert_eq!(response.id, id);
        assert!(repo
            .find_by_id(&Uuid::parse_str(&id).unwrap())
            .await
            .unwrap()
            .is_none());
    }

    #[tokio::test]
    async fn execute_returns_validation_error_for_invalid_id() {
        let repo = Arc::new(InMemoryRepo::new());
        let use_case = DeleteDifyApiKeyUseCase::new(repo);

        let result = use_case
            .execute(DeleteDifyApiKeyCommand {
                id: "bad-id".to_string(),
            })
            .await;

        assert!(matches!(result, Err(DomainError::Validation(_))));
    }

    #[tokio::test]
    async fn execute_returns_not_found_when_missing() {
        let repo = Arc::new(InMemoryRepo::new());
        let use_case = DeleteDifyApiKeyUseCase::new(repo);

        let result = use_case
            .execute(DeleteDifyApiKeyCommand {
                id: Uuid::new_v4().to_string(),
            })
            .await;

        assert!(matches!(result, Err(DomainError::NotFound(_))));
    }
}
