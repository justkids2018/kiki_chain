// 查看老师作业用例
// 处理学生查看指定老师所有作业的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::Result;
use crate::domain::repositories::AssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 查看老师作业查询
#[derive(Debug, Deserialize)]
pub struct ListTeacherAssignmentsQuery {
    pub student_id: String,
    pub teacher_id: String,
    pub status: Option<String>, // 可选的状态过滤，通常只显示已发布的
}

/// 老师作业列表项
#[derive(Debug, Serialize)]
pub struct TeacherAssignmentListItem {
    pub id: String,
    pub title: String,
    pub description: String,
    pub knowledge_points: String,
    pub status: String,
    pub created_at: String,
    pub updated_at: String,
}

/// 查看老师作业响应
#[derive(Debug, Serialize)]
pub struct ListTeacherAssignmentsResponse {
    pub assignments: Vec<TeacherAssignmentListItem>,
    pub total: usize,
    pub teacher_id: String,
}

/// 查看老师作业用例
/// 处理学生查看指定老师所有作业的业务流程
pub struct ListTeacherAssignmentsUseCase {
    assignment_repository: Arc<dyn AssignmentRepository>,
}

impl ListTeacherAssignmentsUseCase {
    pub fn new(assignment_repository: Arc<dyn AssignmentRepository>) -> Self {
        Self {
            assignment_repository,
        }
    }

    /// 执行获取老师作业列表
    pub async fn execute(
        &self,
        query: ListTeacherAssignmentsQuery,
    ) -> Result<ListTeacherAssignmentsResponse> {
        Logger::info(&format!(
            "获取老师作业列表 - 学生ID: {}, 老师ID: {}",
            query.student_id, query.teacher_id
        ));

        // 获取老师的所有作业
        let assignments = self
            .assignment_repository
            .find_by_teacher_id(&query.teacher_id)
            .await?;

        // 过滤状态（如果指定了状态，否则默认只显示已发布的作业）
        let status_filter = query.status.as_deref().unwrap_or("published");
        let filtered_assignments = assignments
            .into_iter()
            .filter(|assignment| assignment.status().to_string() == status_filter)
            .collect::<Vec<_>>();

        // 转换为响应格式
        let assignment_items: Vec<TeacherAssignmentListItem> = filtered_assignments
            .into_iter()
            .map(|assignment| TeacherAssignmentListItem {
                id: assignment.id().to_string(),
                title: assignment.title().to_string(),
                description: assignment.description().to_string(),
                knowledge_points: assignment.knowledge_points().to_string(),
                status: assignment.status().to_string(),
                created_at: assignment.created_at().to_rfc3339(),
                updated_at: assignment.updated_at().to_rfc3339(),
            })
            .collect();

        let total = assignment_items.len();

        Logger::info(&format!("老师作业列表获取成功 - 共{}个作业", total));

        Ok(ListTeacherAssignmentsResponse {
            assignments: assignment_items,
            total,
            teacher_id: query.teacher_id,
        })
    }
}
