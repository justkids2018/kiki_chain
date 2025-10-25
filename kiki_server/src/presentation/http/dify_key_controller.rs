// Dify API Key 控制器
// 负责HTTP层与应用层用例的协同

use serde_json::Value;
use std::sync::Arc;

use crate::application::use_cases::{
    CreateDifyApiKeyCommand, CreateDifyApiKeyUseCase, DeleteDifyApiKeyCommand,
    DeleteDifyApiKeyUseCase, ListDifyApiKeysQuery, ListDifyApiKeysUseCase, UpdateDifyApiKeyCommand,
    UpdateDifyApiKeyUseCase,
};
use crate::domain::errors::{DomainError, Result};
use crate::infrastructure::logging::Logger;
use crate::shared::api_response::ApiResponse;

/// Dify API Key 控制器
/// - 解析HTTP入参
/// - 调用应用层用例
/// - 输出统一响应结构
pub struct DifyApiKeyController {
    create_use_case: Arc<CreateDifyApiKeyUseCase>,
    list_use_case: Arc<ListDifyApiKeysUseCase>,
    update_use_case: Arc<UpdateDifyApiKeyUseCase>,
    delete_use_case: Arc<DeleteDifyApiKeyUseCase>,
}

impl DifyApiKeyController {
    pub fn new(
        create_use_case: Arc<CreateDifyApiKeyUseCase>,
        list_use_case: Arc<ListDifyApiKeysUseCase>,
        update_use_case: Arc<UpdateDifyApiKeyUseCase>,
        delete_use_case: Arc<DeleteDifyApiKeyUseCase>,
    ) -> Self {
        Self {
            create_use_case,
            list_use_case,
            update_use_case,
            delete_use_case,
        }
    }

    /// 创建密钥
    pub async fn create_dify_api_key(&self, request: Value) -> Result<ApiResponse<Value>> {
        Logger::info("🆕 [Dify Key 控制器] 收到创建密钥请求");

        let command: CreateDifyApiKeyCommand = serde_json::from_value(request)?;
        let response = self.create_use_case.execute(command).await?;
        let payload = serde_json::to_value(response.key)?;

        Ok(ApiResponse::success(payload, "Dify 密钥创建成功"))
    }

    /// 查询密钥列表，支持类型过滤
    pub async fn list_dify_api_keys(&self, key_type: Option<String>) -> Result<ApiResponse<Value>> {
        Logger::info("📄 [Dify Key 控制器] 查询密钥列表");

        let query = ListDifyApiKeysQuery { key_type };
        let response = self.list_use_case.execute(query).await?;
        let payload = serde_json::to_value(response.keys)?;

        Ok(ApiResponse::success(payload, "Dify 密钥查询成功"))
    }

    /// 更新密钥
    pub async fn update_dify_api_key(
        &self,
        id: String,
        mut request: Value,
    ) -> Result<ApiResponse<Value>> {
        Logger::info(format!("🔄 [Dify Key 控制器] 更新密钥 id={}", id));

        if let Some(obj) = request.as_object_mut() {
            obj.insert("id".to_string(), Value::String(id.clone()));
        } else {
            return Err(DomainError::Validation("请求体必须为JSON对象".to_string()));
        }

        let command: UpdateDifyApiKeyCommand = serde_json::from_value(request)?;
        let response = self.update_use_case.execute(command).await?;
        let payload = serde_json::to_value(response.key)?;

        Ok(ApiResponse::success(payload, "Dify 密钥更新成功"))
    }

    /// 删除密钥
    pub async fn delete_dify_api_key(&self, id: String) -> Result<ApiResponse<Value>> {
        Logger::info(format!("🗑️ [Dify Key 控制器] 删除密钥 id={}", id));

        let command = DeleteDifyApiKeyCommand { id };
        let response = self.delete_use_case.execute(command).await?;
        let payload = serde_json::to_value(response)?;

        Ok(ApiResponse::success(payload, "Dify 密钥删除成功"))
    }
}
