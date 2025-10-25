// 数据库配置模块
// 提供数据库连接池和配置

use crate::utils::errors::{Error, Result};
use sqlx::{postgres::PgPoolOptions, PgPool};

/// 获取数据库连接池
/// 使用环境变量或默认配置连接到远程PostgreSQL数据库
pub async fn get_database_pool() -> Result<PgPool> {
    let database_url = get_database_url();

    PgPoolOptions::new()
        .max_connections(10)
        .connect(&database_url)
        .await
        .map_err(|e| Error::Database(format!("数据库连接失败: {}", e)))
}

/// 构建数据库连接URL
/// 使用远程PostgreSQL配置: ip:82.156.34.186, user:qisd, password:qisd, database:edadb
fn get_database_url() -> String {
    std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgresql://qisd:qisd@82.156.34.186:5432/edadb".to_string())
}

/// 测试数据库连接
pub async fn test_database_connection() -> Result<()> {
    let pool = get_database_pool().await?;

    sqlx::query("SELECT 1")
        .execute(&pool)
        .await
        .map_err(|e| Error::Database(format!("数据库连接测试失败: {}", e)))?;

    Ok(())
}
