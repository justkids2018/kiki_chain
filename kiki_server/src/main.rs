// Clean Architecture 应用主入口
// 创建时间: 2025-08-06

use qiqimanyou_server::framework::bootstrap::{
    create_routes, handle_startup_error, init_database, init_logging, DependencyContainer,
};
use qiqimanyou_server::utils::JwtUtils;
use tokio::net::TcpListener;

use qiqimanyou_server::config::AppConfig;
use qiqimanyou_server::framework::logging::Logger;

#[tokio::main]
async fn main() {
    init_logging();
    Logger::startup_info("🚀 启动Clean Architecture应用");

    let config = match AppConfig::load() {
        Ok(config) => {
            Logger::config_info(format!("✅ 配置加载成功 - 环境: {}", config.environment));
            config
        }
        Err(e) => handle_startup_error(&format!("配置加载失败: {}", e)),
    };

    let pool = match init_database().await {
        Ok(pool) => pool,
        Err(e) => handle_startup_error(&format!("数据库初始化失败: {}", e)),
    };

    JwtUtils::quick_init()
        .unwrap_or_else(|e| handle_startup_error(&format!("JWT初始化失败: {}", e)));

    let app_state = DependencyContainer::new(pool).app_state;
    let app = create_routes(app_state);

    let server_addr = format!("{}:{}", config.server.host, config.server.port);
    let listener = match TcpListener::bind(&server_addr).await {
        Ok(listener) => {
            Logger::startup_info(format!("🌐 服务器启动在 http://{}", server_addr));
            listener
        }
        Err(e) => handle_startup_error(&format!("端口绑定失败: {}", e)),
    };

    Logger::startup_info("🎯 应用启动完成，等待请求...");

    if let Err(e) = axum::serve(listener, app).await {
        handle_startup_error(&format!("服务器运行失败: {}", e));
    }
}
