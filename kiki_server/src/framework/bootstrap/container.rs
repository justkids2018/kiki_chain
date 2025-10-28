use sqlx::PgPool;
use std::sync::Arc;

use crate::adapters::http::auth::{AuthController, AuthControllerProvider};
use crate::adapters::persistence::PostgresUserRepository;
use crate::core::ports::UserRepository;
use crate::core::use_cases::{LoginUserUseCase, RegisterUserUseCase};
use crate::framework::logging::Logger;

/// 应用状态容器
/// 包含所有依赖注入的服务和仓储
#[derive(Clone)]
pub struct AppState {
    pub auth_controller: Arc<AuthController>,
}

pub struct DependencyContainer {
    pub app_state: AppState,
}

impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        Logger::startup_info("🏗️  初始化依赖注入容器...");

        let user_repository: Arc<dyn UserRepository> =
            Arc::new(PostgresUserRepository::new(pool.clone()));

        let login_use_case = Arc::new(LoginUserUseCase::new(user_repository.clone()));
        let register_use_case = Arc::new(RegisterUserUseCase::new(user_repository.clone()));

        let auth_controller = Arc::new(AuthController::new(
            login_use_case.clone(),
            register_use_case.clone(),
        ));

        Logger::startup_info("✅ 依赖注入容器初始化完成");

        let app_state = AppState { auth_controller };

        Self { app_state }
    }
}

impl AuthControllerProvider for AppState {
    fn auth_controller(&self) -> Arc<AuthController> {
        self.auth_controller.clone()
    }
}
