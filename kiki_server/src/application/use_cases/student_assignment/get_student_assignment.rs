//! 获取学生作业详情用例
//! 负责根据学生作业ID查询聚合根并返回展示模型

use std::sync::Arc;

use serde::Deserialize;
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};
use crate::domain::StudentAssignmentRepository;
use crate::infrastructure::logging::Logger;

use super::StudentAssignmentView;

/// 查询单个学生作业的查询参数
#[derive(Debug, Deserialize)]
pub struct GetStudentAssignmentQuery {
    pub id: String,
}

/// 获取学生作业详情用例
pub struct GetStudentAssignmentUseCase {
    repository: Arc<dyn StudentAssignmentRepository>,
}

impl GetStudentAssignmentUseCase {
    pub fn new(repository: Arc<dyn StudentAssignmentRepository>) -> Self {
        Self { repository }
    }

    /// 执行查询流程
    pub async fn execute(&self, query: GetStudentAssignmentQuery) -> Result<StudentAssignmentView> {
        let id = Uuid::parse_str(&query.id)
            .map_err(|_| DomainError::Validation("学生作业ID格式不正确".to_string()))?;

        Logger::info(format!("🔍 [学生作业] 查询学生作业详情 - ID: {}", id));

        let entity = self
            .repository
            .find_by_id(&id)
            .await?
            .ok_or_else(|| DomainError::NotFound("未找到学生作业记录".to_string()))?;

        Logger::info(format!(
            "✅ [学生作业] 学生 {} 与作业 {} 的作业详情查询成功",
            entity.student_id(),
            entity.assignment_id()
        ));

        Ok(StudentAssignmentView::from(&entity))
    }
}
