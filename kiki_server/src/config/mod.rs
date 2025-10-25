// 简化配置系统 - 只保留最必要的配置
//
// 设计原则：
// 1. 极简配置 - 只有环境、域名、日志、CORS、JWT
// 2. 环境变量优先 - 敏感信息只通过环境变量
// 3. 合理默认值 - 开箱即用
//
// 必需环境变量：
// - JWT_SECRET: JWT签名密钥
// - DATABASE_URL: 数据库连接

pub mod database;

use crate::utils::errors::{Error, Result};
use serde::Deserialize;
use std::env;
use std::sync::OnceLock;

/// 简化应用配置
///
/// 只包含最核心的配置项：
/// - 服务器配置（域名、端口、CORS）
/// - 安全配置（JWT）
///
/// 注意：
/// - environment 字段由环境变量决定，不在配置文件中设置
/// - 日志配置独立处理，不在此结构中
#[derive(Debug, Clone, Deserialize)]
pub struct AppConfig {
    /// 运行环境（由环境变量 ENVIRONMENT 设置）
    #[serde(skip)]
    pub environment: String,
    /// 服务器配置
    pub server: ServerConfig,
    /// 安全配置
    pub security: SecurityConfig,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
    pub cors_origins: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SecurityConfig {
    pub jwt_expiration_hours: u64,
}

impl AppConfig {
    /// 加载配置
    ///
    /// 简化配置加载流程：
    /// 1. 从环境变量或默认值获取环境类型
    /// 2. 直接加载 config/{environment}.toml 环境配置
    /// 3. 用环境变量覆盖配置文件中的设置
    /// 4. 验证必需环境变量
    pub fn load() -> Result<Self> {
        // 1. 加载 .env 文件
        let _ = dotenvy::dotenv();

        // 2. 获取环境类型
        let environment = env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string());

        // 3. 构建配置加载器
        let mut builder = config::Config::builder();

        // 4. 加载环境特定配置（必需）
        let env_config_path = format!("config/{}.toml", environment);
        if std::path::Path::new(&env_config_path).exists() {
            builder = builder.add_source(config::File::with_name(&env_config_path));
        } else {
            return Err(Error::Internal(format!(
                "Environment config file not found: {}. Available environments: development, pre-release, production", 
                env_config_path
            )));
        }

        // 6. 环境变量覆盖（最高优先级）
        // 5. 添加环境变量覆盖支持
        builder = builder.add_source(
            config::Environment::with_prefix("")
                .separator("_")
                .try_parsing(true), // 尝试解析数字类型
        );

        // 6. 构建配置
        let config = builder
            .build()
            .map_err(|e| Error::Internal(format!("Failed to build configuration: {}", e)))?;

        // 7. 反序列化
        let mut app_config: AppConfig = config
            .try_deserialize()
            .map_err(|e| Error::Internal(format!("Failed to parse configuration: {}", e)))?;

        // 8. 确保环境变量正确设置
        app_config.environment = environment;

        // 9. 验证配置
        app_config.validate()?;

        Ok(app_config)
    }

    /// 验证配置
    fn validate(&self) -> Result<()> {
        // 检查必需环境变量
        env::var("JWT_SECRET")
            .map_err(|_| Error::Internal("JWT_SECRET environment variable required".to_string()))?;

        env::var("DATABASE_URL").map_err(|_| {
            Error::Internal("DATABASE_URL environment variable required".to_string())
        })?;

        if self.server.port == 0 {
            return Err(Error::Internal("Invalid port number".to_string()));
        }

        Ok(())
    }

    /// 获取服务器地址
    pub fn server_address(&self) -> String {
        format!("{}:{}", self.server.host, self.server.port)
    }

    /// 获取JWT密钥
    ///
    /// # JWT_SECRET 环境变量作用：
    /// - **签名**：用户登录成功后，使用此密钥对JWT进行数字签名
    /// - **验证**：客户端请求时，使用此密钥验证JWT的有效性和完整性
    /// - **安全**：密钥泄露会导致JWT可被恶意伪造，严重威胁系统安全
    ///
    /// # 安全建议：
    /// - 使用64位以上的强随机字符串
    /// - 绝对不要硬编码在代码中
    /// - 生产环境定期更换（建议每6个月）
    /// - 不同环境使用不同的密钥
    pub fn jwt_secret(&self) -> Result<String> {
        env::var("JWT_SECRET")
            .map_err(|_| Error::Internal("JWT_SECRET environment variable required".to_string()))
    }

    /// 获取数据库连接URL
    ///
    /// # DATABASE_URL 环境变量格式：
    /// postgresql://用户名:密码@主机:端口/数据库名
    ///
    /// # 示例：
    /// - 本地开发：`postgresql://app_user:password@localhost:5432/app_db`
    /// - Docker：`postgresql://app_user:password@postgres:5432/app_db`  
    /// - 云服务：`postgresql://user:pass@cloud.host:5432/db`
    pub fn database_url(&self) -> Result<String> {
        env::var("DATABASE_URL")
            .map_err(|_| Error::Internal("DATABASE_URL environment variable required".to_string()))
    }

    /// JWT过期时间（秒）
    /// 将配置中的小时转换为秒，便于JWT库使用
    pub fn jwt_expiration_seconds(&self) -> u64 {
        self.security.jwt_expiration_hours * 3600
    }

    /// 判断是否为开发环境
    /// 用于启用开发专用功能：详细错误信息、热重载等
    pub fn is_development(&self) -> bool {
        self.environment == "development"
    }

    /// 判断是否为预发布环境  
    /// 用于启用测试功能：模拟数据、测试接口等
    pub fn is_pre_release(&self) -> bool {
        self.environment == "pre-release"
    }

    /// 判断是否为生产环境
    /// 用于启用生产优化：缓存、监控、限流等
    pub fn is_production(&self) -> bool {
        self.environment == "production"
    }

    /// 获取CORS允许的源域名列表
    /// 用于Axum CORS中间件配置
    pub fn cors_origins(&self) -> &[String] {
        &self.server.cors_origins
    }

    /// 获取静态文件目录路径
    /// 用于Axum静态文件服务配置
    pub fn web_folder(&self) -> &str {
        "./web-folder"
    }

    /// 获取当前环境名称
    /// 用于日志记录和调试信息显示
    pub fn environment_name(&self) -> &str {
        &self.environment
    }
}

// 全局单例
static GLOBAL_CONFIG: OnceLock<AppConfig> = OnceLock::new();

/// 获取全局配置
pub fn get_config() -> Result<&'static AppConfig> {
    GLOBAL_CONFIG.get_or_init(|| {
        AppConfig::load().unwrap_or_else(|e| {
            eprintln!("❌ Configuration error: {}", e);
            std::process::exit(1);
        })
    });

    Ok(GLOBAL_CONFIG.get().unwrap())
}

/// 初始化配置
pub fn init_config() -> Result<()> {
    get_config()?;
    Ok(())
}
