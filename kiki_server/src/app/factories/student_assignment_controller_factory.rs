// 学生作业控制器工厂
// 负责组装学生作业相关控制器及其依赖用例

use std::sync::Arc;

use qiqimanyou_server::application::use_cases::{
    CreateStudentAssignmentUseCase, DeleteStudentAssignmentUseCase, GetStudentAssignmentUseCase,
    ListStudentAssignmentsUseCase, UpdateStudentAssignmentUseCase,
};
use qiqimanyou_server::domain::StudentAssignmentRepository;
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::presentation::http::StudentAssignmentController;

/// 学生作业控制器工厂
pub struct StudentAssignmentControllerFactory;

impl StudentAssignmentControllerFactory {
    /// 创建学生作业控制器
    pub fn create(
        student_assignment_repository: Arc<dyn StudentAssignmentRepository>,
    ) -> Arc<StudentAssignmentController> {
        Logger::info("📚 [学生作业模块] 初始化学生作业控制器");

        let create_use_case = Arc::new(CreateStudentAssignmentUseCase::new(
            student_assignment_repository.clone(),
        ));
        let get_use_case = Arc::new(GetStudentAssignmentUseCase::new(
            student_assignment_repository.clone(),
        ));
        let list_use_case = Arc::new(ListStudentAssignmentsUseCase::new(
            student_assignment_repository.clone(),
        ));
        let update_use_case = Arc::new(UpdateStudentAssignmentUseCase::new(
            student_assignment_repository.clone(),
        ));
        let delete_use_case = Arc::new(DeleteStudentAssignmentUseCase::new(
            student_assignment_repository,
        ));

        Logger::info("  ├── ✅ 创建学生作业用例完成");
        Logger::info("  ├── ✅ 查询学生作业详情用例完成");
        Logger::info("  ├── ✅ 列表查询用例完成");
        Logger::info("  ├── ✅ 更新学生作业用例完成");
        Logger::info("  └── ✅ 删除学生作业用例完成");

        Arc::new(StudentAssignmentController::new(
            create_use_case,
            get_use_case,
            list_use_case,
            update_use_case,
            delete_use_case,
        ))
    }
}
