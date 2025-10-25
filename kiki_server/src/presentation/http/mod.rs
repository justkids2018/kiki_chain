// HTTP表现层模块
// 导出HTTP相关的控制器、处理器和中间件

pub mod assignment_controller;
pub mod auth_controller;
pub mod dify_key_controller;
pub mod middleware;
pub mod student_assignment_controller;
pub mod student_controller;
pub mod teacher_assignment_controller;
pub mod teacher_student_controller;
pub mod user;

pub use assignment_controller::AssignmentController;
pub use auth_controller::AuthController;
pub use dify_key_controller::DifyApiKeyController;
pub use student_assignment_controller::StudentAssignmentController;
pub use student_controller::StudentController;
pub use teacher_assignment_controller::TeacherAssignmentController;
pub use teacher_student_controller::TeacherStudentController;
pub use user::user_controller::UserController;
