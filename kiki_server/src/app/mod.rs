// DDD架构应用初始化模块
// 负责应用启动时的各种初始化操作

use sqlx::PgPool;

use qiqimanyou_server::config::database::get_database_pool;
use qiqimanyou_server::infrastructure::logging::Logger;

// 子模块
pub mod api_paths;

// 新的模块化路由架构
pub mod routes;

// 导出路由创建函数
pub use routes::create_routes;

mod dependency_container;
pub use dependency_container::{AppState, DependencyContainer};

/// 初始化日志系统
/// 使用环境变量配置日志
pub fn init_logging() {
    use qiqimanyou_server::infrastructure::logging::{LogConfig, Logger};

    let environment = std::env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string());

    let config = match environment.as_str() {
        "production" => LogConfig::production(),
        "development" => LogConfig::development(),
        _ => LogConfig::from_env(),
    };

    if let Err(e) = Logger::init(&config) {
        eprintln!("❌ 日志系统初始化失败: {}", e);
        std::process::exit(1);
    }

    Logger::config_info(format!("✅ 日志系统初始化完成 - 环境: {}", environment));
}

/// 初始化数据库连接池
///
/// 连接到远程PostgreSQL数据库并创建连接池
/// 创建时间: 2025-08-06
/// 参数: 无
/// 返回: Result<PgPool, Box<dyn std::error::Error>>
pub async fn init_database() -> Result<PgPool, Box<dyn std::error::Error>> {
    Logger::database_info("🔗 正在连接数据库...");

    let pool = match get_database_pool().await {
        Ok(pool) => pool,
        Err(e) => {
            Logger::database_error(format!("❌ 数据库连接失败: {}", e));
            return Err(e.into());
        }
    };
    Logger::database_info("✅ 数据库连接成功");
    Ok(pool)
}

/// 应用启动失败处理
///
/// 当关键组件初始化失败时的统一错误处理
/// 创建时间: 2025-08-06
/// 参数: error_msg - 错误消息
/// 返回: 无 (程序退出)
pub fn handle_startup_error(error_msg: &str) -> ! {
    Logger::error(format!("❌ 应用启动失败: {}", error_msg));
    Logger::error("💀 应用即将退出...");
    std::process::exit(1);
}
