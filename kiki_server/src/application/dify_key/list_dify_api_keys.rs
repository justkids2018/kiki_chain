//! 查询 Dify API Key 用例
//! 支持按类型过滤或获取全部密钥

use serde::Deserialize;
use serde::Serialize;

use crate::domain::dify_key::DifyApiKeyRepositoryArc;
use crate::domain::errors::{DomainError, Result};
use crate::infrastructure::logging::Logger;

use super::dto::DifyApiKeyView;

/// 密钥查询参数
#[derive(Debug, Deserialize)]
pub struct ListDifyApiKeysQuery {
    pub key_type: Option<String>,
}

/// 密钥列表响应
#[derive(Debug, Serialize)]
pub struct ListDifyApiKeysResponse {
    pub keys: Vec<DifyApiKeyView>,
}

/// 密钥查询用例
pub struct ListDifyApiKeysUseCase {
    repository: DifyApiKeyRepositoryArc,
}

impl ListDifyApiKeysUseCase {
    /// 构建用例实例
    pub fn new(repository: DifyApiKeyRepositoryArc) -> Self {
        Self { repository }
    }

    /// 执行查询
    pub async fn execute(&self, query: ListDifyApiKeysQuery) -> Result<ListDifyApiKeysResponse> {
        Logger::info("📄 [Dify Key] 查询密钥列表");

        let keys = if let Some(ref key_type) = query.key_type {
            if key_type.trim().is_empty() {
                return Err(DomainError::Validation("key_type 不能为空".to_string()));
            }
            self.repository.find_by_type(key_type).await?
        } else {
            self.repository.find_all().await?
        };

        let views: Vec<DifyApiKeyView> = keys.iter().map(DifyApiKeyView::from).collect();
        Logger::info(format!("✅ [Dify Key] 查询完成 数量={}", views.len()));

        Ok(ListDifyApiKeysResponse { keys: views })
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
    async fn execute_returns_all_keys_when_no_filter() {
        let repo = Arc::new(InMemoryRepo::new());
        for idx in 0..2 {
            let entity = DifyApiKeyFactory::create(DifyApiKeyCreateData {
                key_type: "dify".to_string(),
                key: format!("key-{}", idx),
                info: None,
            })
            .unwrap();
            repo.save(&entity).await.unwrap();
        }

        let use_case = ListDifyApiKeysUseCase::new(repo);
        let response = use_case
            .execute(ListDifyApiKeysQuery { key_type: None })
            .await
            .unwrap();

        assert_eq!(response.keys.len(), 2);
    }

    #[tokio::test]
    async fn execute_filters_by_type() {
        let repo = Arc::new(InMemoryRepo::new());
        let dify_key = DifyApiKeyFactory::create(DifyApiKeyCreateData {
            key_type: "dify".to_string(),
            key: "key-1".to_string(),
            info: None,
        })
        .unwrap();
        repo.save(&dify_key).await.unwrap();

        let other_key = DifyApiKeyFactory::create(DifyApiKeyCreateData {
            key_type: "other".to_string(),
            key: "key-2".to_string(),
            info: None,
        })
        .unwrap();
        repo.save(&other_key).await.unwrap();

        let use_case = ListDifyApiKeysUseCase::new(repo);
        let response = use_case
            .execute(ListDifyApiKeysQuery {
                key_type: Some("dify".to_string()),
            })
            .await
            .unwrap();

        assert_eq!(response.keys.len(), 1);
        assert_eq!(response.keys[0].key_type, "dify");
    }

    #[tokio::test]
    async fn execute_returns_error_when_type_empty() {
        let repo = Arc::new(InMemoryRepo::new());
        let use_case = ListDifyApiKeysUseCase::new(repo);

        let result = use_case
            .execute(ListDifyApiKeysQuery {
                key_type: Some(" ".to_string()),
            })
            .await;

        assert!(matches!(result, Err(DomainError::Validation(_))));
    }
}
