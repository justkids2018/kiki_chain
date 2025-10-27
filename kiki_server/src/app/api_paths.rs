// API路径常量 - 完整模块化版本
// 集中管理API路径，支持模块化路由架构

/// API路径常量
pub struct ApiPaths;

impl ApiPaths {
    // 健康检查
    pub const HEALTH: &'static str = "/health";

    // 认证相关路径
    pub const LOGIN: &'static str = "/api/auth/login";
}
