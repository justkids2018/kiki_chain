// 老师作业控制器工厂
// 负责装配老师作业相关用例与控制器

use std::sync::Arc;

use qiqimanyou_server::application::use_cases::{
    GetStudentAssignmentsUseCase, GetTeacherStudentAssignmentsUseCase,
};
use qiqimanyou_server::domain::teacher_assignment::TeacherAssignmentQueryRepositoryArc;
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::presentation::http::TeacherAssignmentController;

/// 老师作业控制器工厂
pub struct TeacherAssignmentControllerFactory;

impl TeacherAssignmentControllerFactory {
    pub fn create(
        teacher_assignment_repository: TeacherAssignmentQueryRepositoryArc,
    ) -> Arc<TeacherAssignmentController> {
        Logger::info("👩‍🏫 [老师作业模块] 初始化老师作业控制器");

        let teacher_use_case = Arc::new(GetTeacherStudentAssignmentsUseCase::new(
            teacher_assignment_repository.clone(),
        ));
        Logger::info("  ├── ✅ 老师作业查询用例装配完成");

        let student_use_case = Arc::new(GetStudentAssignmentsUseCase::new(
            teacher_assignment_repository,
        ));
        Logger::info("  └── ✅ 学生作业查询用例装配完成");

        Arc::new(TeacherAssignmentController::new(
            teacher_use_case,
            student_use_case,
        ))
    }
}
