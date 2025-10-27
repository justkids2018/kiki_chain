// src/app/dependency_container.rs
// 依赖注入容器，负责组装所有依赖

use sqlx::PgPool;
use std::sync::Arc;

use qiqimanyou_server::application::use_cases::{LoginUserUseCase, RegisterUserUseCase};
use qiqimanyou_server::domain::repositories::UserRepository;
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::infrastructure::persistence::PostgresUserRepository;
use qiqimanyou_server::presentation::http::AuthController;

/// 应用状态容器
/// 包含所有依赖注入的服务和仓储
#[derive(Clone)]
pub struct AppState {
    // 表现层 - 控制器（包含了所有下层依赖）
    pub auth_controller: Arc<AuthController>,
}

pub struct DependencyContainer {
    pub app_state: AppState,
}

impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        Logger::startup_info("🏗️  初始化DDD依赖注入容器...");

        // 基础设施层 - 仓储实现
        let user_repository: Arc<dyn UserRepository> =
            Arc::new(PostgresUserRepository::new(pool.clone()));

        // 应用层 - 用例
        let login_use_case = Arc::new(LoginUserUseCase::new(user_repository.clone()));
        let register_use_case = Arc::new(RegisterUserUseCase::new(user_repository.clone()));

        // 表现层 - 控制器 (需要先创建相关的用例)
        let auth_controller =
            Arc::new(AuthController::new(login_use_case.clone(), register_use_case.clone()));

        Logger::startup_info("✅ DDD依赖注入容器初始化完成");

        let app_state = AppState {
            // 表现层 - 控制器（内部包含了所有必要的依赖）
            auth_controller,
        };

        Self { app_state }
    }
}
