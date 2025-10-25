// 统一日志模块
// 整合日志配置、初始化和封装接口
// 按照DDD架构，日志作为基础设施服务

use serde::Serialize;
use serde_json::{to_value, Value};
use std::fmt::Display;
use tracing::Level;
use tracing_subscriber::{fmt, EnvFilter};

/// 日志级别枚举
#[derive(Debug, Clone, Copy)]
pub enum LogLevel {
    Trace,
    Debug,
    Info,
    Warn,
    Error,
}

/// 日志配置结构
#[derive(Debug, Clone)]
pub struct LogConfig {
    pub level: String,
    pub enable_colors: bool,
}

impl Default for LogConfig {
    fn default() -> Self {
        Self {
            level: "info".to_string(),
            enable_colors: true,
        }
    }
}

impl LogConfig {
    /// 开发环境配置
    pub fn development() -> Self {
        Self {
            level: "debug".to_string(),
            enable_colors: true,
        }
    }

    /// 生产环境配置
    pub fn production() -> Self {
        Self {
            level: "info".to_string(),
            enable_colors: false,
        }
    }

    /// 从环境变量创建配置
    pub fn from_env() -> Self {
        let level = std::env::var("LOG_LEVEL").unwrap_or_else(|_| "info".to_string());
        let enable_colors = std::env::var("LOG_COLORS")
            .unwrap_or_else(|_| "true".to_string())
            .parse()
            .unwrap_or(true);

        Self {
            level,
            enable_colors,
        }
    }
}

/// 统一日志服务
pub struct Logger;

impl Logger {
    /// 初始化日志系统
    pub fn init(config: &LogConfig) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        // 解析日志级别
        let level = match config.level.to_lowercase().as_str() {
            "trace" => Level::TRACE,
            "debug" => Level::DEBUG,
            "info" => Level::INFO,
            "warn" => Level::WARN,
            "error" => Level::ERROR,
            _ => Level::INFO,
        };

        // 设置环境过滤器
        let env_filter = EnvFilter::builder()
            .with_default_directive(level.into())
            .from_env_lossy();

        // 初始化日志订阅器
        let subscriber = fmt()
            .with_env_filter(env_filter)
            .with_target(true)
            .with_thread_ids(false)
            .with_file(false)
            .with_line_number(false)
            .with_ansi(config.enable_colors);

        subscriber.init();
        Ok(())
    }

    /// 快捷初始化 - 从环境变量
    pub fn init_from_env() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let config = LogConfig::from_env();
        Self::init(&config)
    }

    // === 基础日志方法 ===

    /// 信息日志
    pub fn info<T: Display>(message: T) {
        tracing::info!("{}", message);
    }

    /// 警告日志
    pub fn warn<T: Display>(message: T) {
        tracing::warn!("{}", message);
    }

    /// 错误日志
    pub fn error<T: Display>(message: T) {
        tracing::error!("{}", message);
    }

    /// 调试日志
    pub fn debug<T: Display>(message: T) {
        tracing::debug!("{}", message);
    }

    // === 结构化日志方法 ===

    /// JSON格式日志
    pub fn json(level: LogLevel, data: Value) {
        match level {
            LogLevel::Trace => tracing::trace!("{}", data),
            LogLevel::Debug => tracing::debug!("{}", data),
            LogLevel::Info => tracing::info!("{}", data),
            LogLevel::Warn => tracing::warn!("{}", data),
            LogLevel::Error => tracing::error!("{}", data),
        }
    }

    // === 业务分类日志方法 ===

    /// HTTP请求日志
    pub fn http_request(data: Value) {
        tracing::info!("📥 {}", data);
    }

    /// HTTP响应日志
    pub fn http_response(data: Value) {
        tracing::info!("📤 {}", data);
    }

    /// HTTP错误日志
    pub fn http_error(data: Value) {
        tracing::warn!("⚠️ {}", data);
    }

    /// 启动相关日志
    pub fn startup_info<T: Display>(message: T) {
        tracing::info!("🚀 {}", message);
    }

    /// 配置相关日志
    pub fn config_info<T: Display>(message: T) {
        tracing::info!("⚙️ {}", message);
    }

    /// 数据库相关日志
    pub fn database_info<T: Display>(message: T) {
        tracing::info!("🗄️ {}", message);
    }

    /// 数据库错误日志
    pub fn database_error<T: Display>(message: T) {
        tracing::error!("🚫 {}", message);
    }

    /// 业务逻辑日志
    pub fn business_info<T: Display>(message: T) {
        tracing::info!("🏢 {}", message);
    }

    /// 安全相关日志
    pub fn security_warn<T: Display>(message: T) {
        tracing::warn!("🔒 {}", message);
    }

    // === 工具方法 ===

    /// 将可序列化对象转换为JSON Value
    /// 统一处理序列化错误，避免在各个控制器中重复代码
    pub fn to_json_value<T: Serialize>(data: T) -> Result<Value, String> {
        to_value(data).map_err(|e| format!("序列化错误: {}", e))
    }
}

// === 便捷宏定义 ===

#[macro_export]
macro_rules! log_info {
    ($($arg:tt)*) => {
        $crate::infrastructure::logging::Logger::info(format!($($arg)*))
    };
}

#[macro_export]
macro_rules! log_warn {
    ($($arg:tt)*) => {
        $crate::infrastructure::logging::Logger::warn(format!($($arg)*))
    };
}

#[macro_export]
macro_rules! log_error {
    ($($arg:tt)*) => {
        $crate::infrastructure::logging::Logger::error(format!($($arg)*))
    };
}

#[macro_export]
macro_rules! log_debug {
    ($($arg:tt)*) => {
        $crate::infrastructure::logging::Logger::debug(format!($($arg)*))
    };
}

#[macro_export]
macro_rules! log_json {
    ($level:expr, $data:expr) => {
        $crate::infrastructure::logging::Logger::json($level, $data)
    };
}

/// 测试模块
#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_logger_config() {
        let config = LogConfig::development();
        assert_eq!(config.level, "debug");
        assert_eq!(config.enable_colors, true);
    }

    #[test]
    fn test_logger_methods() {
        // 这些测试需要在有日志系统初始化后运行
        Logger::info("测试信息日志");
        Logger::warn("测试警告日志");

        let json_data = json!({
            "type": "TEST",
            "message": "测试JSON日志"
        });
        Logger::json(LogLevel::Info, json_data);
    }
}
