// 列表作业用例
// 处理获取老师作业列表的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::Result;
use crate::domain::repositories::AssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 列表作业查询
#[derive(Debug, Deserialize)]
pub struct ListAssignmentsQuery {
    pub teacher_id: String,
    pub status: Option<String>, // 可选的状态过滤
}

/// 作业列表项
#[derive(Debug, Serialize)]
pub struct AssignmentListItem {
    pub id: String,
    pub title: String,
    pub description: String,
    pub knowledge_points: String,
    pub status: String,
    pub created_at: String,
    pub updated_at: String,
}

/// 列表作业响应
#[derive(Debug, Serialize)]
pub struct ListAssignmentsResponse {
    pub assignments: Vec<AssignmentListItem>,
    pub total: usize,
}

/// 列表作业用例
/// 处理获取老师作业列表的业务流程
pub struct ListAssignmentsUseCase {
    assignment_repository: Arc<dyn AssignmentRepository>,
}

impl ListAssignmentsUseCase {
    pub fn new(assignment_repository: Arc<dyn AssignmentRepository>) -> Self {
        Self {
            assignment_repository,
        }
    }

    /// 执行获取作业列表
    pub async fn execute(&self, query: ListAssignmentsQuery) -> Result<ListAssignmentsResponse> {
        Logger::info(&format!("📝 [列表作业用例] 执行获取作业列表 - query: {:?}", query));
        Logger::info(&format!("获取作业列表 - 老师ID: {}", query.teacher_id));
        Logger::info(&format!("获取作业列表 - Status: {:?}", query.status));

        // 获取作业列表
        let assignments = self
            .assignment_repository
            .find_by_teacher_id(&query.teacher_id)
            .await?;

        // 过滤状态（如果指定了）
        let filtered_assignments = if let Some(status) = &query.status {
            assignments
                .into_iter()
                .filter(|assignment| assignment.status().to_string() == *status)
                .collect()
        } else {
            assignments
        };

        // 转换为响应格式
        let assignment_items: Vec<AssignmentListItem> = filtered_assignments
            .into_iter()
            .map(|assignment| AssignmentListItem {
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

        Logger::info(&format!("作业列表获取成功 - 共{}个作业", total));

        Ok(ListAssignmentsResponse {
            assignments: assignment_items,
            total,
        })
    }
}
