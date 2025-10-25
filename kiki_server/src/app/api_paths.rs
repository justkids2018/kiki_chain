// API路径常量 - 完整模块化版本
// 集中管理API路径，支持模块化路由架构

/// API路径常量
pub struct ApiPaths;

impl ApiPaths {
    // 健康检查
    pub const HEALTH: &'static str = "/health";

    // 认证相关路径
    pub const LOGIN: &'static str = "/api/auth/login";
    pub const REGISTER: &'static str = "/api/auth/register";
    pub const VERIFY_TOKEN: &'static str = "/api/auth/verify";
    // 用户相关路径
    pub const USER_INFO: &'static str = "/api/user";
    // 老师作业相关路径
    pub const TEACHER_ASSIGNMENTS: &'static str = "/api/teacher/assignments";
    pub const TEACHER_ASSIGNMENT_BY_ID: &'static str = "/api/teacher/assignments/{id}";
    pub const TEACHER_ASSIGNMENT_STUDENT_ASSIGNMENTS: &'static str =
        "/api/teachers/{teacher_uid}/student-assignments";
    pub const STUDENT_ASSIGNMENT_RECORDS: &'static str = "/api/students/{student_uid}/assignments";

    // Dify API Key 管理路径
    pub const DIFY_API_KEYS: &'static str = "/api/dify-api-keys";
    pub const DIFY_API_KEY_ITEM: &'static str = "/api/dify-api-keys/{id}";

    // 学生作业统一管理路径
    pub const STUDENT_ASSIGNMENT_COLLECTION: &'static str = "/api/student-assignments";
    pub const STUDENT_ASSIGNMENT_ITEM: &'static str = "/api/student-assignments/{id}";

    // 师生关系相关路径
    pub const TEACHER_STUDENT_RELATIONSHIPS: &'static str = "/api/teacher-student";
}
