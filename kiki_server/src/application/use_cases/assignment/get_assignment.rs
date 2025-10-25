// 查看作业用例
// 处理获取单个作业详情的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::AssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 获取作业查询
#[derive(Debug, Deserialize)]
pub struct GetAssignmentQuery {
    pub assignment_id: String,
    pub teacher_id: String, // 验证权限用
}

/// 获取作业响应
#[derive(Debug, Serialize)]
pub struct GetAssignmentResponse {
    pub id: String,
    pub teacher_id: String,
    pub title: String,
    pub description: String,
    pub knowledge_points: String,
    pub status: String,
    pub created_at: String,
    pub updated_at: String,
}

/// 获取作业用例
/// 处理获取单个作业详情的业务流程
pub struct GetAssignmentUseCase {
    assignment_repository: Arc<dyn AssignmentRepository>,
}

impl GetAssignmentUseCase {
    pub fn new(assignment_repository: Arc<dyn AssignmentRepository>) -> Self {
        Self {
            assignment_repository,
        }
    }

    /// 执行获取作业
    pub async fn execute(&self, query: GetAssignmentQuery) -> Result<GetAssignmentResponse> {
        // 1. 验证输入数据
        self.validate_query(&query)?;

        Logger::info(&format!("获取作业详情 - ID: {}", query.assignment_id));

        // 2. 解析UUID
        let assignment_id = Uuid::parse_str(&query.assignment_id)
            .map_err(|_| DomainError::Validation("无效的作业ID格式".to_string()))?;

        // 3. 查找作业
        let assignment = self
            .assignment_repository
            .find_by_id(&assignment_id)
            .await?
            .ok_or_else(|| DomainError::NotFound("作业不存在".to_string()))?;

        // 4. 验证权限（只能查看自己的作业）
        if assignment.teacher_id() != &query.teacher_id {
            return Err(DomainError::PermissionDenied(
                "没有权限查看此作业".to_string(),
            ));
        }

        Logger::info(&format!("作业详情获取成功 - 标题: {}", assignment.title()));

        // 5. 返回响应
        Ok(GetAssignmentResponse {
            id: assignment.id().to_string(),
            teacher_id: assignment.teacher_id().to_string(),
            title: assignment.title().to_string(),
            description: assignment.description().to_string(),
            knowledge_points: assignment.knowledge_points().to_string(),
            status: assignment.status().to_string(),
            created_at: assignment.created_at().to_rfc3339(),
            updated_at: assignment.updated_at().to_rfc3339(),
        })
    }

    /// 验证查询参数
    fn validate_query(&self, query: &GetAssignmentQuery) -> Result<()> {
        if query.assignment_id.trim().is_empty() {
            return Err(DomainError::Validation("作业ID不能为空".to_string()));
        }

        if query.teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("老师ID不能为空".to_string()));
        }

        Ok(())
    }
}
