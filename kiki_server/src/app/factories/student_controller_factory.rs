// 学生控制器工厂
// 负责创建和配置学生相关的控制器及其依赖

use qiqimanyou_server::application::use_cases::{
    GetDefaultTeacherUseCase, ListTeacherAssignmentsUseCase, ListTeachersUseCase,
    SetDefaultTeacherUseCase, UpdateConversationUseCase,
};
use qiqimanyou_server::domain::repositories::{
    AssignmentRepository, StudentAssignmentRepository, TeacherStudentRepository, UserRepository,
};
use qiqimanyou_server::infrastructure::logging::Logger;
use qiqimanyou_server::presentation::http::StudentController;
use std::sync::Arc;

/// 学生控制器工厂
///
/// 专门负责创建学生模块的控制器和相关用例
/// 封装了学生模块的完整依赖关系管理
pub struct StudentControllerFactory;

impl StudentControllerFactory {
    /// 创建学生控制器实例
    ///
    /// 包含所有学生相关的用例初始化和依赖注入
    ///
    /// # 参数
    /// * `user_repository` - 用户仓储接口实现
    /// * `assignment_repository` - 作业仓储接口实现
    /// * `student_assignment_repository` - 学生作业仓储接口实现
    ///
    /// # 返回值
    /// * `Arc<StudentController>` - 配置完成的学生控制器
    pub fn create(
        user_repository: Arc<dyn UserRepository>,
        teacher_student_repository: Arc<dyn TeacherStudentRepository>,
        assignment_repository: Arc<dyn AssignmentRepository>,
        student_assignment_repository: Arc<dyn StudentAssignmentRepository>,
    ) -> Arc<StudentController> {
        Logger::info("🎓 [学生模块] 开始初始化学生控制器");

        // 创建学生相关的用例
        let list_teachers_use_case = Self::create_list_teachers_use_case(user_repository.clone());
        let set_default_teacher_use_case =
            Self::create_set_default_teacher_use_case(teacher_student_repository.clone());
        let get_default_teacher_use_case = Self::create_get_default_teacher_use_case(
            teacher_student_repository.clone(),
            user_repository.clone(),
        );
        let list_teacher_assignments_use_case =
            Self::create_list_teacher_assignments_use_case(assignment_repository.clone());
        let update_conversation_use_case =
            Self::create_update_conversation_use_case(student_assignment_repository.clone());
        Logger::info("  ├── ✅ 列出教师用例已初始化");
        Logger::info("  ├── ✅ 设置默认教师用例已初始化");
        Logger::info("  ├── ✅ 获取默认教师用例已初始化");
        Logger::info("  ├── ✅ 列出教师作业用例已初始化");
        Logger::info("  └── ✅ 更新对话用例已初始化");

        // 创建学生控制器
        let controller = Arc::new(StudentController::new(
            list_teachers_use_case,
            set_default_teacher_use_case,
            get_default_teacher_use_case,
            list_teacher_assignments_use_case,
            update_conversation_use_case,
        ));

        Logger::info("🎯 [学生模块] 学生控制器初始化完成");
        controller
    }

    /// 创建"列出教师"用例
    fn create_list_teachers_use_case(
        user_repository: Arc<dyn UserRepository>,
    ) -> Arc<ListTeachersUseCase> {
        Arc::new(ListTeachersUseCase::new(user_repository))
    }

    /// 创建"设置默认教师"用例
    fn create_set_default_teacher_use_case(
        teacher_student_repository: Arc<dyn TeacherStudentRepository>,
    ) -> Arc<SetDefaultTeacherUseCase> {
        Arc::new(SetDefaultTeacherUseCase::new(teacher_student_repository))
    }

    /// 创建"获取默认教师"用例
    fn create_get_default_teacher_use_case(
        teacher_student_repository: Arc<dyn TeacherStudentRepository>,
        user_repository: Arc<dyn UserRepository>,
    ) -> Arc<GetDefaultTeacherUseCase> {
        Arc::new(GetDefaultTeacherUseCase::new(
            teacher_student_repository,
            user_repository,
        ))
    }

    /// 创建"列出教师作业"用例
    fn create_list_teacher_assignments_use_case(
        assignment_repository: Arc<dyn AssignmentRepository>,
    ) -> Arc<ListTeacherAssignmentsUseCase> {
        Arc::new(ListTeacherAssignmentsUseCase::new(assignment_repository))
    }

    /// 创建"更新对话"用例
    fn create_update_conversation_use_case(
        student_assignment_repository: Arc<dyn StudentAssignmentRepository>,
    ) -> Arc<UpdateConversationUseCase> {
        Arc::new(UpdateConversationUseCase::new(
            student_assignment_repository,
        ))
    }
}
