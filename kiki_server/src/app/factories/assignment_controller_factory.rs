// 作业控制器工厂
// 负责创建和配置作业相关的控制器及其依赖

use qiqimanyou_server::application::use_cases::{
    CreateAssignmentUseCase, DeleteAssignmentUseCase, GetAssignmentUseCase, ListAssignmentsUseCase,
    UpdateAssignmentUseCase,
};
use qiqimanyou_server::domain::repositories::AssignmentRepository;
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::presentation::http::AssignmentController;
use std::sync::Arc;

/// 作业控制器工厂
///
/// 专门负责创建作业模块的控制器和相关用例
/// 封装了作业模块的完整依赖关系管理
pub struct AssignmentControllerFactory;

impl AssignmentControllerFactory {
    /// 创建作业控制器实例
    ///
    /// 包含所有作业相关的用例初始化和依赖注入
    ///
    /// # 参数
    /// * `assignment_repository` - 作业仓储接口实现
    ///
    /// # 返回值
    /// * `Arc<AssignmentController>` - 配置完成的作业控制器
    pub fn create(
        assignment_repository: Arc<dyn AssignmentRepository>,
    ) -> Arc<AssignmentController> {
        Logger::info("🏗️ [作业模块] 开始初始化作业控制器");

        // 创建作业相关的用例
        let create_use_case = Self::create_create_use_case(assignment_repository.clone());
        let get_use_case = Self::create_get_use_case(assignment_repository.clone());
        let list_use_case = Self::create_list_use_case(assignment_repository.clone());
        let update_use_case = Self::create_update_use_case(assignment_repository.clone());
        let delete_use_case = Self::create_delete_use_case(assignment_repository.clone());

        Logger::info("  ├── ✅ 创建作业用例已初始化");
        Logger::info("  ├── ✅ 获取作业用例已初始化");
        Logger::info("  ├── ✅ 列表作业用例已初始化");
        Logger::info("  ├── ✅ 更新作业用例已初始化");
        Logger::info("  └── ✅ 删除作业用例已初始化");

        // 创建作业控制器
        let controller = Arc::new(AssignmentController::new(
            create_use_case,
            get_use_case,
            list_use_case,
            update_use_case,
            delete_use_case,
        ));

        Logger::info("🎯 [作业模块] 作业控制器初始化完成");
        controller
    }

    /// 创建"创建作业"用例
    fn create_create_use_case(
        assignment_repository: Arc<dyn AssignmentRepository>,
    ) -> Arc<CreateAssignmentUseCase> {
        Arc::new(CreateAssignmentUseCase::new(assignment_repository))
    }

    /// 创建"获取作业"用例
    fn create_get_use_case(
        assignment_repository: Arc<dyn AssignmentRepository>,
    ) -> Arc<GetAssignmentUseCase> {
        Arc::new(GetAssignmentUseCase::new(assignment_repository))
    }

    /// 创建"列表作业"用例
    fn create_list_use_case(
        assignment_repository: Arc<dyn AssignmentRepository>,
    ) -> Arc<ListAssignmentsUseCase> {
        Arc::new(ListAssignmentsUseCase::new(assignment_repository))
    }

    /// 创建"更新作业"用例
    fn create_update_use_case(
        assignment_repository: Arc<dyn AssignmentRepository>,
    ) -> Arc<UpdateAssignmentUseCase> {
        Arc::new(UpdateAssignmentUseCase::new(assignment_repository))
    }

    /// 创建"删除作业"用例
    fn create_delete_use_case(
        assignment_repository: Arc<dyn AssignmentRepository>,
    ) -> Arc<DeleteAssignmentUseCase> {
        Arc::new(DeleteAssignmentUseCase::new(assignment_repository))
    }
}
