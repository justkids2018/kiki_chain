/// API路径常量（Axum 0.8 使用 {param} 语法）
pub struct ApiPaths;

impl ApiPaths {
    // 健康检查
    pub const HEALTH: &'static str = "/health";

    // 认证路由（无需认证）
    pub const LOGIN: &'static str = "/api/v1/auth/login";
    pub const REGISTER: &'static str = "/api/v1/auth/register";
    pub const AUTH_VERIFY: &'static str = "/api/v1/auth/verify";
    pub const AUTH_LOGOUT: &'static str = "/api/v1/auth/logout";

    // 移动端路由前缀
    pub const MOBILE_PREFIX: &'static str = "/api/v1/mobile";

    // 移动端 - 用户
    pub const MOBILE_USER_PROFILE: &'static str = "/api/v1/mobile/user/profile";

    // 移动端 - 场景
    pub const MOBILE_SCENE_CATEGORIES: &'static str = "/api/v1/mobile/scene/categories";
    pub const MOBILE_SCENE_BY_CATEGORY: &'static str = "/api/v1/mobile/scene/categories/{category_id}/scenes";
    pub const MOBILE_SCENE_DETAIL: &'static str = "/api/v1/mobile/scene/{scene_id}";
    pub const MOBILE_SCENE_SEARCH: &'static str = "/api/v1/mobile/scene/search";
    pub const MOBILE_SCENE_RECOMMENDATIONS: &'static str = "/api/v1/mobile/scene/recommendations";

    // 管理端路由前缀
    pub const ADMIN_PREFIX: &'static str = "/api/v1/admin";

    // 管理端 - 认证（无需认证）
    pub const ADMIN_LOGIN: &'static str = "/api/v1/admin/auth/login";

    // 管理端 - 用户
    pub const ADMIN_USERS: &'static str = "/api/v1/admin/users";
    pub const ADMIN_USER_DETAIL: &'static str = "/api/v1/admin/users/{id}";
    pub const ADMIN_USER_UPDATE: &'static str = "/api/v1/admin/users/{id}/update";

    // 管理端 - 场景分类
    pub const ADMIN_SCENE_CATEGORIES: &'static str = "/api/v1/admin/scene/categories";
    pub const ADMIN_SCENE_CATEGORY_DETAIL: &'static str = "/api/v1/admin/scene/categories/{id}";

    // 管理端 - 场景
    pub const ADMIN_SCENES: &'static str = "/api/v1/admin/scene/scenes";
    pub const ADMIN_SCENE_DETAIL: &'static str = "/api/v1/admin/scene/scenes/{id}";

    // 管理端 - 文件上传
    pub const ADMIN_UPLOAD_TOKEN: &'static str = "/api/v1/admin/upload/token";
    pub const ADMIN_UPLOAD_IMAGE: &'static str = "/api/v1/admin/upload/image";
}
