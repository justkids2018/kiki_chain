/// API路径常量
pub struct ApiPaths;

impl ApiPaths {
    // 健康检查
    pub const HEALTH: &'static str = "/health";

    // 认证路由（无需认证）
    pub const LOGIN: &'static str = "/api/v1/auth/login";
    pub const REGISTER: &'static str = "/api/v1/auth/register";

    // 移动端路由（需要User或Admin角色）
    pub const MOBILE_PREFIX: &'static str = "/api/v1/mobile";
    pub const MOBILE_PROFILE: &'static str = "/api/v1/mobile/profile";
    pub const MOBILE_USER_INFO: &'static str = "/api/v1/mobile/user/info";

    // 管理端路由（仅需Admin角色）
    pub const ADMIN_PREFIX: &'static str = "/api/v1/admin";
    pub const ADMIN_USERS: &'static str = "/api/v1/admin/users";
    pub const ADMIN_USER_DETAIL: &'static str = "/api/v1/admin/users/{id}";
}
