// 路由模块
// 仅保留基础认证相关的路由

pub mod auth; // 认证模块：路由+处理器
pub mod main_routes; // 主路由配置

// 统一导出主路由创建函数
pub use main_routes::create_routes;
