use sqlx::PgPool;
use std::sync::Arc;

use crate::adapters::persistence::{
    PostgresLearningProgressRepository, PostgresSceneRepository, PostgresSubscriptionRepository,
    PostgresUserRepository,
};
use crate::adapters::storage::QiniuService;
use crate::core::ports::{SceneRepository, UserRepository};
use crate::core::repositories::learning::LearningProgressRepository;
use crate::core::use_cases::learning::{
    GetProgressUseCase, GetUserProgressListUseCase, GetUserSummaryUseCase, SubmitProgressUseCase,
};
use crate::core::use_cases::{
    AdminSceneUseCase, GetCategoriesUseCase, GetRecommendationsUseCase, GetSceneDetailUseCase,
    GetScenesByCategoryUseCase, LoginUserUseCase, RegisterUserUseCase, SearchScenesUseCase,
    SubscriptionUseCase,
};
use crate::framework::logging::Logger;

/// 应用状态容器
#[derive(Clone)]
pub struct AppState {
    // 数据库连接池
    pub pool: PgPool,

    // 认证用例
    pub login_use_case: Arc<LoginUserUseCase>,
    pub register_use_case: Arc<RegisterUserUseCase>,

    // 场景用例（移动端）
    pub get_categories_uc: Arc<GetCategoriesUseCase>,
    pub get_scenes_by_category_uc: Arc<GetScenesByCategoryUseCase>,
    pub get_scene_detail_uc: Arc<GetSceneDetailUseCase>,
    pub search_scenes_uc: Arc<SearchScenesUseCase>,
    pub get_recommendations_uc: Arc<GetRecommendationsUseCase>,

    // 管理端用例
    pub admin_scene_uc: Arc<AdminSceneUseCase>,

    // 学习进度用例
    pub get_progress_uc: Arc<GetProgressUseCase>,
    pub submit_progress_uc: Arc<SubmitProgressUseCase>,
    pub get_user_summary_uc: Arc<GetUserSummaryUseCase>,
    pub get_user_progress_list_uc: Arc<GetUserProgressListUseCase>,

    // 订阅用例
    pub subscription_uc: Arc<SubscriptionUseCase>,

    // 用户仓储（供 profile 接口使用）
    pub user_repository: Arc<dyn UserRepository>,

    // 七牛云存储服务
    pub qiniu_service: Option<Arc<QiniuService>>,
}

pub struct DependencyContainer {
    pub app_state: AppState,
}

impl DependencyContainer {
    pub fn new(pool: PgPool) -> Self {
        Logger::startup_info("🏗️  初始化依赖注入容器...");

        // 初始化 Repositories
        let user_repository: Arc<dyn UserRepository> =
            Arc::new(PostgresUserRepository::new(pool.clone()));
        let scene_repository: Arc<dyn SceneRepository> =
            Arc::new(PostgresSceneRepository::new(pool.clone()));
        let learning_repository: Arc<dyn LearningProgressRepository> =
            Arc::new(PostgresLearningProgressRepository::new(pool.clone()));
        let subscription_repository = Arc::new(PostgresSubscriptionRepository::new(pool.clone()));

        // 认证用例
        let login_use_case = Arc::new(LoginUserUseCase::new(user_repository.clone()));
        let register_use_case = Arc::new(RegisterUserUseCase::new(user_repository.clone()));

        // 场景用例（移动端）
        let get_categories_uc = Arc::new(GetCategoriesUseCase::new(scene_repository.clone()));
        let get_scenes_by_category_uc =
            Arc::new(GetScenesByCategoryUseCase::new(scene_repository.clone()));
        let get_scene_detail_uc = Arc::new(GetSceneDetailUseCase::new(scene_repository.clone()));
        let search_scenes_uc = Arc::new(SearchScenesUseCase::new(scene_repository.clone()));
        let get_recommendations_uc =
            Arc::new(GetRecommendationsUseCase::new(scene_repository.clone()));

        // 学习进度用例
        let get_progress_uc = Arc::new(GetProgressUseCase::new(learning_repository.clone()));
        let submit_progress_uc = Arc::new(SubmitProgressUseCase::new(learning_repository.clone()));
        let get_user_summary_uc = Arc::new(GetUserSummaryUseCase::new(learning_repository.clone()));
        let get_user_progress_list_uc =
            Arc::new(GetUserProgressListUseCase::new(learning_repository.clone()));

        // 订阅用例
        let subscription_uc = Arc::new(SubscriptionUseCase::new(
            subscription_repository.clone(),
            user_repository.clone(),
        ));

        // 管理端用例
        let admin_scene_uc = Arc::new(AdminSceneUseCase::new(scene_repository.clone()));

        // 七牛云服务（可选）
        let qiniu_service = match QiniuService::from_env() {
            Ok(service) => {
                Logger::startup_info("✅ 七牛云服务初始化成功");
                Some(Arc::new(service))
            }
            Err(e) => {
                Logger::startup_info(&format!("⚠️  七牛云服务未配置: {}", e));
                None
            }
        };

        Logger::startup_info("✅ 依赖注入容器初始化完成");

        let app_state = AppState {
            pool: pool.clone(),
            login_use_case,
            register_use_case,
            get_categories_uc,
            get_scenes_by_category_uc,
            get_scene_detail_uc,
            search_scenes_uc,
            get_recommendations_uc,
            admin_scene_uc,
            get_progress_uc,
            submit_progress_uc,
            get_user_summary_uc,
            get_user_progress_list_uc,
            subscription_uc,
            user_repository,
            qiniu_service,
        };

        Self { app_state }
    }
}
