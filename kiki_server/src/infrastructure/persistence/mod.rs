// PostgreSQL持久化层模块
// 实现domain layer的repository接口

pub mod postgres_user_repository;

// 业务仓储模块
pub mod dify_key;
pub mod postgres_assignment_repositories;
pub mod postgres_teacher_assignment_repository;
pub mod postgres_teacher_student_repositories;

pub use dify_key::postgres_dify_api_key_repository::{
    create_dify_api_key_repository, PostgresDifyApiKeyRepository,
};
pub use postgres_assignment_repositories::{
    PostgresAssignmentRepository, PostgresStudentAssignmentRepository,
};
pub use postgres_teacher_assignment_repository::PostgresTeacherAssignmentQueryRepository;
pub use postgres_teacher_student_repositories::PostgresTeacherStudentRepository;
pub use postgres_user_repository::PostgresUserRepository;
