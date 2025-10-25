// 领域层模块
// 包含核心业务逻辑，不依赖任何外部技术

pub mod entities;
pub mod errors;
pub mod repositories;
pub mod value_objects;

// 新增独立模块
pub mod assignment_repositories;
pub mod dify_key;
pub mod student_assignment;
pub mod teacher_assignment;
pub mod teacher_student_repositories;

// 重新导出核心类型
pub use dify_key::{
    DifyApiKey, DifyApiKeyCreateData, DifyApiKeyFactory, DifyApiKeyRepository,
    DifyApiKeyRepositoryArc, DifyApiKeyUpdateData, DifyApiKeyUpdater,
};
pub use entities::User;
pub use errors::{DomainError, Result};
pub use repositories::{StudentAssignmentRepository, UserRepository};
pub use teacher_assignment::{
    TeacherAssignmentQueryRepository, TeacherAssignmentQueryRepositoryArc,
    TeacherAssignmentStudentAssignmentSnapshot, TeacherAssignmentStudentAssignments,
    TeacherAssignmentStudentProfile,
};
pub use value_objects::{Email, UserId};
