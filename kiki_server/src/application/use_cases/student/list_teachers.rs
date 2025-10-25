// 查看老师列表用例
// 处理学生查看所有老师列表的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::Result;
use crate::domain::repositories::UserRepository;
use crate::infrastructure::logging::Logger;

/// 查看老师列表查询
#[derive(Debug, Deserialize)]
pub struct ListTeachersQuery {
    pub student_id: String, // 可能用于未来的权限验证
}

/// 老师列表项
#[derive(Debug, Serialize)]
pub struct TeacherListItem {
    pub id: String,
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
}

/// 查看老师列表响应
#[derive(Debug, Serialize)]
pub struct ListTeachersResponse {
    pub teachers: Vec<TeacherListItem>,
    pub total: usize,
}

/// 查看老师列表用例
/// 处理学生查看所有老师列表的业务流程
pub struct ListTeachersUseCase {
    user_repository: Arc<dyn UserRepository>,
}

impl ListTeachersUseCase {
    pub fn new(user_repository: Arc<dyn UserRepository>) -> Self {
        Self { user_repository }
    }

    /// 执行获取老师列表
    pub async fn execute(&self, query: ListTeachersQuery) -> Result<ListTeachersResponse> {
        Logger::info(&format!("获取老师列表 - 学生ID: {}", query.student_id));

        // 获取所有老师（role_id = 3表示老师角色）
        let teachers = self.user_repository.find_users_by_role(3).await?;

        // 转换为响应格式
        let teacher_items: Vec<TeacherListItem> = teachers
            .into_iter()
            .map(|teacher| TeacherListItem {
                id: teacher.id().to_string(),
                uid: teacher.uid().to_string(),
                name: teacher.name().to_string(),
                email: teacher.email().to_string(),
                phone: teacher.phone().to_string(),
            })
            .collect();

        let total = teacher_items.len();

        Logger::info(&format!("老师列表获取成功 - 共{}位老师", total));

        Ok(ListTeachersResponse {
            teachers: teacher_items,
            total,
        })
    }
}
