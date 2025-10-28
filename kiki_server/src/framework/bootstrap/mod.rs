use sqlx::PgPool;

use crate::config::database::get_database_pool;
use crate::framework::logging::{LogConfig, Logger};

pub mod api_paths;
pub mod container;
pub mod routes;

pub use container::{AppState, DependencyContainer};
pub use routes::create_routes;

/// 初始化日志系统
pub fn init_logging() {
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
pub fn handle_startup_error(error_msg: &str) -> ! {
    Logger::error(format!("❌ 应用启动失败: {}", error_msg));
    Logger::error("💀 应用即将退出...");
    std::process::exit(1);
}
