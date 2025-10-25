// 师生关系仓储接口定义
// 独立模块，专门处理师生关系逻辑

use crate::domain::errors::Result;
use async_trait::async_trait;

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
