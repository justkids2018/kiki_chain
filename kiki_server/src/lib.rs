// DDD + Clean Architecture 领域驱动设计库
// 奇迹漫游记后端服务核心库
// 创建时间: 2025-08-06

// Clean Architecture 内核模块
pub mod core;

// 技术适配层（实现 core::ports 的具体技术方案）
pub mod adapters;

// 框架层（启动、配置、日志等应用基础设施）
pub mod framework;

// 配置和工具模块
pub mod config; // 配置管理
pub mod shared;
pub mod utils; // 工具函数 // 共享模块 - 跨层通用组件

// 重新导出常用类型
pub use utils::errors::{Error, Result};

// 便捷导出框架层日志工具
pub use framework::{LogConfig, LogLevel, Logger};
