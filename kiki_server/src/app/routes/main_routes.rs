// 主路由配置
// 整合所有业务模块的路由

use axum::{middleware, routing::get, Router};
use tracing::info;

use super::{
    assignment, auth, dify_key, student_assignment, teacher_assignment, teacher_student, user,
};
use crate::app::AppState;
use qiqimanyou_server::config::get_config;
use qiqimanyou_server::presentation::http::middleware::{
    create_cors_layer, error_handling_middleware, jwt_auth_middleware,
    request_response_data_log_middleware,
};

/// 创建应用主路由
///
/// 整合所有业务模块路由:
/// - 健康检查
/// - 认证模块路由
/// - 作业模块路由  
/// - 学生模块路由
///
/// ## 参数说明
/// - app_state: 应用状态容器，包含依赖注入的服务
///
/// ## 返回值
/// - Router: 配置好的主路由器
pub fn create_routes(app_state: AppState) -> Router {
    info!("🚀 [主路由] 开始初始化应用路由");

    // 获取配置
    let config = get_config().expect("无法获取配置");

    // 健康检查路由
    let health_routes = Router::new().route("/health", get(health_check));

    info!("  ├── ✅ 健康检查路由已注册");

    // 业务模块路由
    let auth_routes = auth::create_auth_routes(app_state.clone());
    let assignment_routes = assignment::create_assignment_routes(app_state.clone());
    let student_assignment_routes =
        student_assignment::create_student_assignment_routes(app_state.clone());
    let teacher_assignment_routes =
        teacher_assignment::create_teacher_assignment_routes(app_state.clone());
    let teacher_student_routes = teacher_student::create_teacher_student_routes(app_state.clone());
    let user_routes = user::create_user_routes(app_state.clone());
    let dify_key_routes = dify_key::create_dify_key_routes(app_state.clone());

    info!("  ├── 🔐 认证模块路由已注册");
    info!("  ├── 📝 作业模块路由已注册");
    info!("  ├── 📚 学生作业模块路由已注册");
    info!("  ├── 👩‍🏫 老师作业视图路由已注册");
    info!("  ├── 🧑‍🏫 师生关系模块路由已注册");
    info!("  ├── 👤 用户模块路由已注册");
    info!("  └── 🔑 Dify 密钥模块路由已注册");

    // 创建 CORS 中间件
    let cors_layer = create_cors_layer(config.cors_origins().to_vec());
    info!("  ├── 🌐 CORS 中间件已配置: {:?}", config.cors_origins());

    // 合并所有路由并添加中间件
    let app_router = Router::new()
        .merge(health_routes)
        .merge(auth_routes)
        .merge(assignment_routes)
        .merge(student_assignment_routes)
        .merge(teacher_assignment_routes)
        .merge(teacher_student_routes)
        .merge(user_routes)
        .merge(dify_key_routes)
        // 添加中间件层，注意顺序很重要
        .layer(middleware::from_fn(jwt_auth_middleware)) // JWT认证中间件
        .layer(middleware::from_fn(error_handling_middleware)) // 错误处理中间件
        .layer(middleware::from_fn(request_response_data_log_middleware)) // 请求响应日志中间件
        .layer(cors_layer); // CORS中间件

    info!("  ├── 🔐 JWT认证中间件已配置");
    info!("  ├── ⚠️ 错误处理中间件已配置");
    info!("  └── 📝 请求响应日志中间件已配置");

    info!("🎯 [主路由] 应用路由初始化完成");
    info!("  └── 所有模块路由已成功整合");

    app_router
}

/// 健康检查端点
///
/// ## 响应格式
/// ```json
/// {
///   "status": "OK",
///   "timestamp": "2024-08-09T10:30:00Z",
///   "version": "0.1.0"
/// }
/// ```
async fn health_check() -> axum::response::Json<serde_json::Value> {
    use serde_json::json;

    info!("💓 [健康检查] 系统状态检查");

    axum::response::Json(json!({
        "status": "OK",
        "timestamp": chrono::Utc::now(),
        "version": env!("CARGO_PKG_VERSION"),
        "service": "qiqimanyou_server"
    }))
}
