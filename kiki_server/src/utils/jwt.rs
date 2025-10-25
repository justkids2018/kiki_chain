// JWT工具库
// 提供JWT令牌的生成和验证功能，支持全应用公共调用
// 创建时间: 2025-09-14

use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use std::sync::OnceLock;

use crate::domain::entities::User;
use crate::domain::errors::{DomainError, Result};

/// JWT配置结构
#[derive(Debug, Clone)]
pub struct JwtConfig {
    pub secret: String,
    pub expiry_hours: i64,
}

/// 全局JWT配置实例
static JWT_CONFIG: OnceLock<JwtConfig> = OnceLock::new();

/// JWT声明结构
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub sub: String, // 用户ID
    pub phone: String,
    pub email: String,
    pub exp: i64, // 过期时间
    pub iat: i64, // 签发时间
}

/// JWT工具类
pub struct JwtUtils;

impl JwtUtils {
    /// 初始化JWT配置
    ///
    /// 应该在应用启动时调用一次
    /// 参数: config - JWT配置
    pub fn init(config: JwtConfig) -> Result<()> {
        JWT_CONFIG
            .set(config)
            .map_err(|_| DomainError::Infrastructure("JWT配置已初始化".to_string()))?;
        Ok(())
    }

    /// 获取JWT配置
    fn get_config() -> Result<&'static JwtConfig> {
        JWT_CONFIG
            .get()
            .ok_or_else(|| DomainError::Infrastructure("JWT配置未初始化".to_string()))
    }

    /// 获取JWT密钥
    ///
    /// 从环境变量或配置文件获取JWT密钥
    /// 返回: JWT密钥字符串
    pub fn get_jwt_secret() -> String {
        std::env::var("JWT_SECRET")
            .or_else(|_| std::env::var("jwt_secret"))
            .unwrap_or_else(|_| {
                // 生产环境应该从配置文件或安全存储获取
                "qiqimanyou-default-jwt-secret-key-2025".to_string()
            })
    }

    /// 创建默认JWT配置
    ///
    /// 返回: 默认的JWT配置
    pub fn create_default_config() -> JwtConfig {
        JwtConfig {
            secret: Self::get_jwt_secret(),
            expiry_hours: 24, // 24小时过期
        }
    }

    /// 生成JWT令牌
    ///
    /// 为用户生成JWT访问令牌
    /// 参数: user - 用户实体
    /// 返回: JWT令牌字符串
    pub fn generate_token(user: &User) -> Result<String> {
        let config = Self::get_config()?;
        let now = Utc::now();
        let exp = now + Duration::hours(config.expiry_hours);

        let claims = Claims {
            sub: user.uid().to_string(),
            phone: user.phone().to_string(),
            email: user.email().to_string(),
            exp: exp.timestamp(),
            iat: now.timestamp(),
        };

        encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(config.secret.as_ref()),
        )
        .map_err(|e| DomainError::Infrastructure(format!("JWT生成失败: {}", e)))
    }

    /// 验证JWT令牌
    ///
    /// 验证JWT令牌的有效性并解析声明
    /// 参数: token - JWT令牌字符串
    /// 返回: JWT声明结构
    pub fn verify_token(token: &str) -> Result<Claims> {
        let config = Self::get_config()?;

        decode::<Claims>(
            token,
            &DecodingKey::from_secret(config.secret.as_ref()),
            &Validation::default(),
        )
        .map(|token_data| token_data.claims)
        .map_err(|e| DomainError::Authentication(format!("JWT验证失败: {}", e)))
    }

    /// 验证令牌是否过期
    ///
    /// 检查JWT令牌是否已过期
    /// 参数: claims - JWT声明
    /// 返回: 是否过期
    pub fn is_token_expired(claims: &Claims) -> bool {
        let now = Utc::now().timestamp();
        claims.exp < now
    }

    /// 从令牌中提取用户ID
    ///
    /// 从JWT令牌中安全提取用户ID
    /// 参数: token - JWT令牌字符串
    /// 返回: 用户ID字符串
    pub fn extract_user_id(token: &str) -> Result<String> {
        let claims = Self::verify_token(token)?;

        if Self::is_token_expired(&claims) {
            return Err(DomainError::Authentication("令牌已过期".to_string()));
        }

        Ok(claims.sub)
    }

    /// 刷新令牌
    ///
    /// 基于现有令牌生成新的令牌（如果原令牌有效且未过期太久）
    /// 参数: token - 原JWT令牌, user - 用户实体
    /// 返回: 新的JWT令牌
    pub fn refresh_token(token: &str, user: &User) -> Result<String> {
        let claims = Self::verify_token(token)?;

        // 检查原令牌是否在刷新窗口内（例如过期前1小时或过期后1小时内）
        let now = Utc::now().timestamp();
        let refresh_window = 3600; // 1小时

        if claims.exp + refresh_window < now {
            return Err(DomainError::Authentication(
                "令牌过期太久，无法刷新".to_string(),
            ));
        }

        // 生成新令牌
        Self::generate_token(user)
    }
}

/// JWT工具便捷函数
impl JwtUtils {
    /// 快速初始化（使用默认配置）
    pub fn quick_init() -> Result<()> {
        let config = Self::create_default_config();
        Self::init(config)
    }
}
