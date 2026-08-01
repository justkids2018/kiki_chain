// 端口定义
// 暴露业务内核所需的外部依赖接口（Repository / Gateway）

pub mod scene_repository;
pub mod subscription;
pub use scene_repository::SceneRepository;
pub use subscription::SubscriptionRepository;

use async_trait::async_trait;

use crate::core::entities::User;
use crate::core::errors::Result;
use crate::core::value_objects::UserId;

#[async_trait]
pub trait UserRepository: Send + Sync {
    /// 保存用户（新增或更新）
    async fn save(&self, user: &User) -> Result<()>;

    /// 根据用户ID查找用户
    async fn find_by_id(&self, id: &UserId) -> Result<Option<User>>;

    /// 根据uid查找用户
    async fn find_by_uid(&self, uid: &str) -> Result<Option<User>>;

    /// 根据邮箱或手机号和密码查找用户
    async fn find_by_phone_and_pwd(&self, identifier: &str, pwd: &str) -> Result<Option<User>>;

    /// 根据手机号查找用户
    async fn find_by_phone(&self, phone: &str) -> Result<Option<User>>;

    /// 根据角色查找用户
    async fn find_users_by_role(&self, role_id: i32) -> Result<Vec<User>>;

    /// 更新用户资料。默认实现用于尚未支持资料更新的测试仓储。
    async fn update_profile(
        &self,
        _uid: &str,
        _name: Option<&str>,
        _email: Option<&str>,
    ) -> Result<Option<User>> {
        Ok(None)
    }
}
