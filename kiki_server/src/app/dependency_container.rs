// src/app/dependency_container.rs
// 依赖注入容器，负责组装所有依赖

use sqlx::PgPool;
use std::sync::Arc;

use qiqimanyou_server::application::use_cases::{
    user::get_user::GetUserUseCase, LoginUserUseCase, RegisterUserUseCase,
};
use qiqimanyou_server::domain::dify_key::DifyApiKeyRepositoryArc;
use qiqimanyou_server::domain::repositories::{
    AssignmentRepository, StudentAssignmentRepository, TeacherStudentRepository, UserRepository,
};
use qiqimanyou_server::domain::teacher_assignment::TeacherAssignmentQueryRepositoryArc;
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::infrastructure::persistence::{
    PostgresAssignmentRepository, PostgresDifyApiKeyRepository,
    PostgresStudentAssignmentRepository, PostgresTeacherAssignmentQueryRepository,
    PostgresTeacherStudentRepository, PostgresUserRepository,
};
use qiqimanyou_server::presentation::http::{
    AuthController, DifyApiKeyController, StudentAssignmentController, TeacherAssignmentController,
    TeacherStudentController, UserController,
};
use qiqimanyou_server::utils::jwt::JwtUtils;

use super::{
    AssignmentControllerFactory, DifyApiKeyControllerFactory, StudentAssignmentControllerFactory,
    StudentControllerFactory, TeacherAssignmentControllerFactory, TeacherStudentControllerFactory,
};

/// 应用状态容器
/// 包含所有依赖注入的服务和仓储
#[derive(Clone)]
pub struct AppState {
    // 表现层 - 控制器（包含了所有下层依赖）
    pub auth_controller: Arc<AuthController>,
    pub assignment_controller: Arc<qiqimanyou_server::presentation::http::AssignmentController>,
    pub student_controller: Arc<qiqimanyou_server::presentation::http::StudentController>,
    pub student_assignment_controller: Arc<StudentAssignmentController>,
    pub teacher_assignment_controller: Arc<TeacherAssignmentController>,
    pub teacher_student_controller: Arc<TeacherStudentController>,
    pub dify_api_key_controller: Arc<DifyApiKeyController>,
    pub user_controller: Arc<UserController>,
}

pub struct DependencyContainer {
    pub app_state: AppState,
}

impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        Logger::startup_info("🏗️  初始化DDD依赖注入容器...");

        // 初始化JWT配置
        if let Err(e) = JwtUtils::quick_init() {
            Logger::error(format!("JWT配置初始化失败: {}", e));
        } else {
            Logger::startup_info("🔐 JWT工具库初始化成功");
        }

        // 基础设施层 - 仓储实现
        let user_repository: Arc<dyn UserRepository> =
            Arc::new(PostgresUserRepository::new(pool.clone()));
        let assignment_repository: Arc<dyn AssignmentRepository> =
            Arc::new(PostgresAssignmentRepository::new(pool.clone()));
        let student_assignment_repository: Arc<dyn StudentAssignmentRepository> =
            Arc::new(PostgresStudentAssignmentRepository::new(pool.clone()));
        let teacher_assignment_repository: TeacherAssignmentQueryRepositoryArc =
            Arc::new(PostgresTeacherAssignmentQueryRepository::new(pool.clone()));
        let teacher_student_repository: Arc<dyn TeacherStudentRepository> =
            Arc::new(PostgresTeacherStudentRepository::new(pool.clone()));
        let dify_api_key_repository: DifyApiKeyRepositoryArc =
            Arc::new(PostgresDifyApiKeyRepository::new(pool.clone()));

        // 应用层 - 用例
        let register_use_case = Arc::new(RegisterUserUseCase::new(user_repository.clone()));
        let login_use_case = Arc::new(LoginUserUseCase::new(user_repository.clone()));
        let get_user_use_case = Arc::new(GetUserUseCase::new(user_repository.clone()));

        // 表现层 - 控制器 (需要先创建相关的用例)
        let auth_controller = Arc::new(AuthController::new(
            register_use_case.clone(),
            login_use_case.clone(),
        ));
        let user_controller = Arc::new(UserController::new(get_user_use_case));

        // 暂时使用工厂类创建控制器
        let assignment_controller =
            AssignmentControllerFactory::create(assignment_repository.clone());
        let student_controller = StudentControllerFactory::create(
            user_repository.clone(),
            teacher_student_repository.clone(),
            assignment_repository.clone(),
            student_assignment_repository.clone(),
        );
        let student_assignment_controller =
            StudentAssignmentControllerFactory::create(student_assignment_repository.clone());
        let teacher_assignment_controller =
            TeacherAssignmentControllerFactory::create(teacher_assignment_repository.clone());
        let teacher_student_controller = TeacherStudentControllerFactory::create(
            teacher_student_repository.clone(),
            user_repository.clone(),
        );
        let dify_api_key_controller =
            DifyApiKeyControllerFactory::create(dify_api_key_repository.clone());

        Logger::startup_info("✅ DDD依赖注入容器初始化完成");

        let app_state = AppState {
            // 表现层 - 控制器（内部包含了所有必要的依赖）
            auth_controller,
            assignment_controller,
            student_controller,
            student_assignment_controller,
            teacher_assignment_controller,
            teacher_student_controller,
            dify_api_key_controller,
            user_controller,
        };

        Self { app_state }
    }
}
