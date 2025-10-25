//! 老师作业视图用例模块
//! 负责封装老师维度学生作业查询能力

pub mod dto;
pub mod get_student_assignments;
pub mod get_teacher_student_assignments;

pub use dto::{
    TeacherAssignmentStudentAssignmentView, TeacherAssignmentStudentAssignmentsView,
    TeacherAssignmentStudentProfileView,
};
pub use get_student_assignments::{
    GetStudentAssignmentsQuery, GetStudentAssignmentsResponse, GetStudentAssignmentsUseCase,
};
pub use get_teacher_student_assignments::{
    GetTeacherStudentAssignmentsQuery, GetTeacherStudentAssignmentsResponse,
    GetTeacherStudentAssignmentsUseCase,
};
