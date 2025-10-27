// 领域层仓储接口定义
// 定义数据访问的抽象接口，由基础设施层实现

use async_trait::async_trait;

use crate::domain::entities::User;
use crate::domain::errors::Result;
use crate::domain::value_objects::UserId;

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
}
