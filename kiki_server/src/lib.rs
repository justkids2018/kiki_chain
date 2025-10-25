// DDD + Clean Architecture 领域驱动设计库
// 奇迹漫游记后端服务核心库
// 创建时间: 2025-08-06

// DDD架构分层模块
pub mod application; // 应用层 - 用例和服务
pub mod domain; // 领域层 - 核心业务逻辑
pub mod infrastructure; // 基础设施层 - 技术实现
pub mod presentation; // 表现层 - HTTP接口

// 配置和工具模块
pub mod config; // 配置管理
pub mod shared;
pub mod utils; // 工具函数 // 共享模块 - 跨层通用组件

// 重新导出常用类型
pub use utils::errors::{Error, Result};
