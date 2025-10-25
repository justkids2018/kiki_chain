// 作业相关仓储接口定义
// 独立模块，不影响原有用户仓储逻辑

use async_trait::async_trait;
use uuid::Uuid;

use crate::domain::entities::{Assignment, StudentAssignment};
use crate::domain::errors::Result;

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
