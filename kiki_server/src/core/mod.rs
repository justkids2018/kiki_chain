// 核心业务模块
// 存放实体、值对象、错误定义及端口接口

pub mod entities;
pub mod errors;
pub mod ports;
pub mod value_objects;

// 用例模块在后续阶段迁移
pub mod use_cases;

// 常用类型重新导出，方便上下层引用
pub use entities::User;
pub use errors::{DomainError, Result};
pub use ports::UserRepository;
pub use value_objects::{Email, UserId};
