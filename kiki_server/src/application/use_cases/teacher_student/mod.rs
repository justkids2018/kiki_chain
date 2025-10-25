// 老师-学生关系用例模块
// 提供师生关系相关的业务能力

pub mod add_teacher_student;
pub mod query_teacher_student_relationships;
pub mod remove_teacher_student;
pub mod update_teacher_student;

pub use add_teacher_student::*;
pub use query_teacher_student_relationships::*;
pub use remove_teacher_student::*;
pub use update_teacher_student::*;
