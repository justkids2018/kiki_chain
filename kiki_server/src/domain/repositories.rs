// 领域层仓储接口定义
// 定义数据访问的抽象接口，由基础设施层实现

use async_trait::async_trait;
use uuid::Uuid;

use crate::domain::entities::{Assignment, StudentAssignment, User};
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

/// 作业仓储接口
#[async_trait]
pub trait AssignmentRepository: Send + Sync {
    /// 保存作业（新增或更新）
    async fn save(&self, assignment: &Assignment) -> Result<()>;

    /// 根据作业ID查找作业
    async fn find_by_id(&self, id: &Uuid) -> Result<Option<Assignment>>;

    /// 根据老师ID查找作业列表
    async fn find_by_teacher_id(&self, teacher_id: &str) -> Result<Vec<Assignment>>;

    /// 删除作业
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

/// 学生作业仓储接口
#[async_trait]
pub trait StudentAssignmentRepository: Send + Sync {
    /// 保存学生作业（新增或更新）
    async fn save(&self, student_assignment: &StudentAssignment) -> Result<()>;

    /// 根据学生作业ID查找单条记录
    async fn find_by_id(&self, id: &Uuid) -> Result<Option<StudentAssignment>>;

    /// 根据作业ID和学生ID查找学生作业
    async fn find_by_assignment_and_student(
        &self,
        assignment_id: &Uuid,
        student_id: &str,
    ) -> Result<Option<StudentAssignment>>;

    /// 根据学生ID查找所有作业
    async fn find_by_student_id(&self, student_id: &str) -> Result<Vec<StudentAssignment>>;

    /// 根据作业ID查找所有学生作业
    async fn find_by_assignment_id(&self, assignment_id: &Uuid) -> Result<Vec<StudentAssignment>>;

    /// 删除学生作业记录
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

/// 师生关系仓储接口
#[async_trait]
pub trait TeacherStudentRepository: Send + Sync {
    /// 添加师生关系
    async fn add_student(&self, teacher_id: &str, student_id: &str) -> Result<()>;

    /// 检查师生关系是否存在
    async fn exists_relationship(&self, teacher_id: &str, student_id: &str) -> Result<bool>;

    /// 设置默认老师
    async fn set_default_teacher(&self, student_id: &str, teacher_id: &str) -> Result<()>;

    /// 获取学生的默认老师
    async fn get_default_teacher(&self, student_id: &str) -> Result<Option<String>>;

    /// 获取学生的所有老师
    async fn get_teachers_by_student(&self, student_id: &str) -> Result<Vec<String>>;

    /// 获取老师的所有学生
    async fn get_students_by_teacher(&self, teacher_id: &str) -> Result<Vec<String>>;

    /// 移除现有的师生关系
    async fn remove_student(&self, teacher_id: &str, student_id: &str) -> Result<()>;
}
