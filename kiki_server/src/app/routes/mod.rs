// 路由模块 - 简洁统一的单文件结构
// 每个业务域一个文件，包含路由配置和处理器

pub mod assignment; // 作业模块：路由+处理器
pub mod auth; // 认证模块：路由+处理器
pub mod dify_key; // Dify API Key 模块：路由+处理器
pub mod main_routes; // 主路由配置
pub mod student_assignment; // 学生作业模块：路由+处理器
pub mod teacher_assignment; // 老师作业视图模块：路由+处理器
pub mod teacher_student; // 师生关系模块：路由+处理器
pub mod user; // 用户模块：路由+处理器

// 统一导出主路由创建函数
pub use main_routes::create_routes;
