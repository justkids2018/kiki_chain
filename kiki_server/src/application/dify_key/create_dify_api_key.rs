//! 创建 Dify API Key 用例
//! 负责协调领域工厂与仓储，完成密钥落库

use serde::Deserialize;
use serde::Serialize;

use crate::domain::dify_key::{DifyApiKeyCreateData, DifyApiKeyFactory, DifyApiKeyRepositoryArc};
use crate::domain::errors::Result;
use crate::infrastructure::logging::Logger;

use super::dto::DifyApiKeyView;

/// 创建密钥命令
#[derive(Debug, Deserialize)]
pub struct CreateDifyApiKeyCommand {
    pub key_type: String,
    pub key: String,
    pub info: Option<String>,
}

/// 创建密钥响应
#[derive(Debug, Serialize)]
pub struct CreateDifyApiKeyResponse {
    pub key: DifyApiKeyView,
}

/// 创建密钥用例
pub struct CreateDifyApiKeyUseCase {
    repository: DifyApiKeyRepositoryArc,
}

impl CreateDifyApiKeyUseCase {
    /// 构建用例实例
    pub fn new(repository: DifyApiKeyRepositoryArc) -> Self {
        Self { repository }
    }

    /// 执行创建流程
    pub async fn execute(
        &self,
        command: CreateDifyApiKeyCommand,
    ) -> Result<CreateDifyApiKeyResponse> {
        Logger::info("🔐 [Dify Key] 开始创建密钥");

        let data = DifyApiKeyCreateData {
            key_type: command.key_type,
            key: command.key,
            info: command.info,
        };

        let entity = DifyApiKeyFactory::create(data)?;
        self.repository.save(&entity).await?;

        let view = DifyApiKeyView::from(&entity);
        Logger::info(format!(
            "✅ [Dify Key] 密钥创建成功 id={} type={}",
            view.id, view.key_type
        ));

        Ok(CreateDifyApiKeyResponse { key: view })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;
    use std::collections::HashMap;
    use std::sync::Arc;
    use tokio::sync::Mutex;
    use uuid::Uuid;

    use crate::domain::dify_key::{DifyApiKey, DifyApiKeyRepository};
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
            Ok(self
                .store
                .lock()
                .await
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
    async fn execute_creates_key_successfully() {
        let repo = Arc::new(InMemoryRepo::new());
        let use_case = CreateDifyApiKeyUseCase::new(repo);

        let response = use_case
            .execute(CreateDifyApiKeyCommand {
                key_type: "dify".to_string(),
                key: "key-1".to_string(),
                info: Some("测试".to_string()),
            })
            .await
            .unwrap();

        assert_eq!(response.key.key_type, "dify");
        assert_eq!(response.key.key, "key-1");
        assert_eq!(response.key.info, Some("测试".to_string()));
    }

    #[tokio::test]
    async fn execute_fails_when_factory_validation_fails() {
        let repo = Arc::new(InMemoryRepo::new());
        let use_case = CreateDifyApiKeyUseCase::new(repo);

        let result = use_case
            .execute(CreateDifyApiKeyCommand {
                key_type: "".to_string(),
                key: "key-1".to_string(),
                info: None,
            })
            .await;

        assert!(matches!(result, Err(DomainError::Validation(_))));
    }
}
