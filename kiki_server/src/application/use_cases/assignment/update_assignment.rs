// 更新作业用例
// 处理老师更新作业的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;
use uuid::Uuid;

use crate::domain::entities::AssignmentStatus;
use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::AssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 更新作业命令
#[derive(Debug, Deserialize)]
pub struct UpdateAssignmentCommand {
    pub assignment_id: String,
    pub teacher_id: String, // 验证权限用
    pub title: Option<String>,
    pub description: Option<String>,
    pub knowledge_points: Option<String>,
    pub status: Option<String>,
}

/// 更新作业响应
#[derive(Debug, Serialize)]
pub struct UpdateAssignmentResponse {
    pub id: String,
    pub teacher_id: String,
    pub title: String,
    pub description: String,
    pub knowledge_points: String,
    pub status: String,
    pub created_at: String,
    pub updated_at: String,
}

/// 更新作业用例
/// 处理老师更新作业的完整业务流程
pub struct UpdateAssignmentUseCase {
    assignment_repository: Arc<dyn AssignmentRepository>,
}

impl UpdateAssignmentUseCase {
    pub fn new(assignment_repository: Arc<dyn AssignmentRepository>) -> Self {
        Self {
            assignment_repository,
        }
    }

    /// 执行更新作业
    pub async fn execute(
        &self,
        command: UpdateAssignmentCommand,
    ) -> Result<UpdateAssignmentResponse> {
        // 1. 验证输入数据
        self.validate_command(&command)?;

        Logger::info(&format!("更新作业开始 - ID: {}", command.assignment_id));

        // 2. 解析UUID
        let assignment_id = Uuid::parse_str(&command.assignment_id)
            .map_err(|_| DomainError::Validation("无效的作业ID格式".to_string()))?;

        // 3. 查找作业
        let mut assignment = self
            .assignment_repository
            .find_by_id(&assignment_id)
            .await?
            .ok_or_else(|| DomainError::NotFound("作业不存在".to_string()))?;

        // 4. 验证权限（只能更新自己的作业）
        if assignment.teacher_id() != &command.teacher_id {
            return Err(DomainError::PermissionDenied(
                "没有权限更新此作业".to_string(),
            ));
        }

        // 5. 更新字段
        if let Some(title) = command.title {
            assignment.update_title(title)?;
        }

        if let Some(description) = command.description {
            assignment.update_description(description);
        }

        if let Some(knowledge_points) = command.knowledge_points {
            assignment.update_knowledge_points(knowledge_points)?;
        }

        if let Some(status) = command.status {
            let new_status = self.parse_status(&status)?;
            assignment.update_status(new_status);
        }

        // 6. 保存更新
        self.assignment_repository.save(&assignment).await?;

        Logger::info(&format!("作业更新成功 - 标题: {}", assignment.title()));

        // 7. 返回响应
        Ok(UpdateAssignmentResponse {
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

    /// 验证命令参数
    fn validate_command(&self, command: &UpdateAssignmentCommand) -> Result<()> {
        if command.assignment_id.trim().is_empty() {
            return Err(DomainError::Validation("作业ID不能为空".to_string()));
        }

        if command.teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("老师ID不能为空".to_string()));
        }

        // 验证标题长度
        if let Some(title) = &command.title {
            if title.trim().is_empty() {
                return Err(DomainError::Validation("作业标题不能为空".to_string()));
            }
            if title.len() > 255 {
                return Err(DomainError::Validation(
                    "作业标题过长，不能超过255字符".to_string(),
                ));
            }
        }

        // 验证知识点
        if let Some(knowledge_points) = &command.knowledge_points {
            if knowledge_points.trim().is_empty() {
                return Err(DomainError::Validation("知识点不能为空".to_string()));
            }
        }

        Ok(())
    }

    /// 解析状态字符串
    fn parse_status(&self, status: &str) -> Result<AssignmentStatus> {
        match status.to_lowercase().as_str() {
            "draft" => Ok(AssignmentStatus::Draft),
            "published" => Ok(AssignmentStatus::Published),
            "archived" => Ok(AssignmentStatus::Archived),
            _ => Err(DomainError::Validation("无效的作业状态".to_string())),
        }
    }
}
