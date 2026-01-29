use sqlx::PgPool;
use std::sync::Arc;

use crate::adapters::persistence::PostgresUserRepository;
use crate::core::ports::UserRepository;
use crate::core::use_cases::{LoginUserUseCase, RegisterUserUseCase};
use crate::framework::logging::Logger;

/// 应用状态容器
/// 直接包含 Use Cases，移除冗余的 Controller 层
#[derive(Clone)]
pub struct AppState {
    pub login_use_case: Arc<LoginUserUseCase>,
    pub register_use_case: Arc<RegisterUserUseCase>,
}

pub struct DependencyContainer {
    pub app_state: AppState,
}

impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        Logger::startup_info("🏗️  初始化依赖注入容器...");

        // 初始化 Repository
        let user_repository: Arc<dyn UserRepository> =
            Arc::new(PostgresUserRepository::new(pool.clone()));

        // 初始化 Use Cases
        let login_use_case = Arc::new(LoginUserUseCase::new(user_repository.clone()));
        let register_use_case = Arc::new(RegisterUserUseCase::new(user_repository.clone()));

        Logger::startup_info("✅ 依赖注入容器初始化完成");

        let app_state = AppState {
            login_use_case,
            register_use_case,
        };

        Self { app_state }
    }
}
