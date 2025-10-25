// DDD架构应用主入口
// 领域驱动设计 + 清洁架构的Rust Web应用
// 创建时间: 2025-08-06
// 最后修改: 2025-08-10

use qiqimanyou_server::utils::JwtUtils;
use tokio::net::TcpListener;

// 导入应用模块
mod app;
use app::{create_routes, handle_startup_error, init_database, init_logging, DependencyContainer};
// 导入配置模块
use qiqimanyou_server::config::AppConfig;
use qiqimanyou_server::infrastructure::logging::Logger;

/// 应用主入口
///
/// 按照DDD架构启动Web应用程序
/// 创建时间: 2025-08-06
/// 参数: 无
/// 返回: 无
#[tokio::main]
async fn main() {
    // 1. 初始化日志系统
    init_logging();
    Logger::startup_info("🚀 启动DDD架构应用");

    // 2. 加载配置
    let config = match AppConfig::load() {
        Ok(config) => {
            Logger::config_info(format!("✅ 配置加载成功 - 环境: {}", config.environment));
            config
        }
        Err(e) => handle_startup_error(&format!("配置加载失败: {}", e)),
    };

    // 3. 初始化数据库
    let pool = match init_database().await {
        Ok(pool) => pool,
        Err(e) => handle_startup_error(&format!("数据库初始化失败: {}", e)),
    };
    //3.1 初始化JWT
    JwtUtils::quick_init()
        .unwrap_or_else(|e| handle_startup_error(&format!("JWT初始化失败: {}", e)));

    // 4. 初始化依赖注入容器
    let app_state = DependencyContainer::new(pool).app_state;

    // 5. 创建路由
    let app = create_routes(app_state);

    // 6. 启动服务器
    let server_addr = format!("{}:{}", config.server.host, config.server.port);
    let listener = match TcpListener::bind(&server_addr).await {
        Ok(listener) => {
            Logger::startup_info(format!("🌐 服务器启动在 http://{}", server_addr));
            listener
        }
        Err(e) => handle_startup_error(&format!("端口绑定失败: {}", e)),
    };

    // 7. 运行应用
    Logger::startup_info("🎯 DDD应用启动完成，等待请求...");

    if let Err(e) = axum::serve(listener, app).await {
        handle_startup_error(&format!("服务器运行失败: {}", e));
    }
}
