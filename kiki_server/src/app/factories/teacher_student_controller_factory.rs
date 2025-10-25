// 师生关系控制器工厂
// 负责组装师生关系控制器及其依赖

use std::sync::Arc;

use qiqimanyou_server::application::use_cases::{
    AddTeacherStudentUseCase, QueryTeacherStudentRelationshipsUseCase, RemoveTeacherStudentUseCase,
    UpdateTeacherStudentUseCase,
};
use qiqimanyou_server::domain::repositories::{TeacherStudentRepository, UserRepository};
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::presentation::http::TeacherStudentController;

pub struct TeacherStudentControllerFactory;

impl TeacherStudentControllerFactory {
    pub fn create(
        teacher_student_repository: Arc<dyn TeacherStudentRepository>,
        user_repository: Arc<dyn UserRepository>,
    ) -> Arc<TeacherStudentController> {
        Logger::info("👩‍🏫 [师生关系模块] 开始初始化控制器");

        let query_use_case = Arc::new(QueryTeacherStudentRelationshipsUseCase::new(
            teacher_student_repository.clone(),
            user_repository.clone(),
        ));
        let add_use_case = Arc::new(AddTeacherStudentUseCase::new(
            teacher_student_repository.clone(),
            user_repository.clone(),
        ));
        let update_use_case = Arc::new(UpdateTeacherStudentUseCase::new(
            teacher_student_repository.clone(),
            user_repository.clone(),
        ));
        let remove_use_case =
            Arc::new(RemoveTeacherStudentUseCase::new(teacher_student_repository));

        Logger::info("  ├── ✅ 查询用例已初始化");
        Logger::info("  ├── ✅ 新增用例已初始化");
        Logger::info("  ├── ✅ 更新用例已初始化");
        Logger::info("  └── ✅ 删除用例已初始化");

        Arc::new(TeacherStudentController::new(
            query_use_case,
            add_use_case,
            update_use_case,
            remove_use_case,
        ))
    }
}
