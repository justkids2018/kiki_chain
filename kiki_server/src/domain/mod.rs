// 领域层模块
// 包含核心业务逻辑，不依赖任何外部技术

pub mod entities;
pub mod errors;
pub mod repositories;
pub mod value_objects;

// 重新导出核心类型
pub use entities::User;
pub use errors::{DomainError, Result};
pub use repositories::UserRepository;
pub use value_objects::{Email, UserId};
