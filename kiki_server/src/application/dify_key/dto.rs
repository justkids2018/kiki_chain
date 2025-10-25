//! Dify API Key DTO 定义
//! 面向表现层的序列化结构体

use serde::Serialize;

use crate::domain::dify_key::DifyApiKey;

/// Dify API Key 视图对象
/// 对外暴露的字段全部为字符串，方便序列化
#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct DifyApiKeyView {
    pub id: String,
    pub key_type: String,
    pub key: String,
    pub info: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

impl From<&DifyApiKey> for DifyApiKeyView {
    fn from(entity: &DifyApiKey) -> Self {
        Self {
            id: entity.id().to_string(),
            key_type: entity.key_type().to_string(),
            key: entity.key().to_string(),
            info: entity.info().cloned(),
            created_at: entity.created_at().to_rfc3339(),
            updated_at: entity.updated_at().to_rfc3339(),
        }
    }
}
