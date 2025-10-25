// Dify API Key 控制器工厂
// 负责装配密钥相关的应用用例与控制器

use std::sync::Arc;

use qiqimanyou_server::application::dify_key::{
    CreateDifyApiKeyUseCase, DeleteDifyApiKeyUseCase, ListDifyApiKeysUseCase,
    UpdateDifyApiKeyUseCase,
};
use qiqimanyou_server::domain::dify_key::DifyApiKeyRepositoryArc;
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::presentation::http::DifyApiKeyController;

pub struct DifyApiKeyControllerFactory;

impl DifyApiKeyControllerFactory {
    pub fn create(repository: DifyApiKeyRepositoryArc) -> Arc<DifyApiKeyController> {
        Logger::info("🔑 [Dify Key 模块] 初始化密钥控制器");

        let create_use_case = Arc::new(CreateDifyApiKeyUseCase::new(repository.clone()));
        Logger::info("  ├── ✅ 创建密钥用例装配完成");

        let list_use_case = Arc::new(ListDifyApiKeysUseCase::new(repository.clone()));
        Logger::info("  ├── ✅ 查询密钥用例装配完成");

        let update_use_case = Arc::new(UpdateDifyApiKeyUseCase::new(repository.clone()));
        Logger::info("  ├── ✅ 更新密钥用例装配完成");

        let delete_use_case = Arc::new(DeleteDifyApiKeyUseCase::new(repository));
        Logger::info("  └── ✅ 删除密钥用例装配完成");

        Arc::new(DifyApiKeyController::new(
            create_use_case,
            list_use_case,
            update_use_case,
            delete_use_case,
        ))
    }
}
