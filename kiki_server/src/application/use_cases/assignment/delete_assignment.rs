// 删除作业用例
// 处理老师删除作业的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::AssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 删除作业命令
#[derive(Debug, Deserialize)]
pub struct DeleteAssignmentCommand {
    pub assignment_id: String,
    pub teacher_id: String, // 验证权限用
}

/// 删除作业响应
#[derive(Debug, Serialize)]
pub struct DeleteAssignmentResponse {
    pub message: String,
}

/// 删除作业用例
/// 处理老师删除作业的完整业务流程
pub struct DeleteAssignmentUseCase {
    assignment_repository: Arc<dyn AssignmentRepository>,
}

impl DeleteAssignmentUseCase {
    pub fn new(assignment_repository: Arc<dyn AssignmentRepository>) -> Self {
        Self {
            assignment_repository,
        }
    }

    /// 执行删除作业
    pub async fn execute(
        &self,
        command: DeleteAssignmentCommand,
    ) -> Result<DeleteAssignmentResponse> {
        // 1. 验证输入数据
        self.validate_command(&command)?;

        Logger::info(&format!("删除作业开始 - ID: {}", command.assignment_id));

        // 2. 解析UUID
        let assignment_id = Uuid::parse_str(&command.assignment_id)
            .map_err(|_| DomainError::Validation("无效的作业ID格式".to_string()))?;

        // 3. 查找作业以验证权限
        let assignment = self
            .assignment_repository
            .find_by_id(&assignment_id)
            .await?
            .ok_or_else(|| DomainError::NotFound("作业不存在".to_string()))?;

        // 4. 验证权限（只能删除自己的作业）
        if assignment.teacher_id() != &command.teacher_id {
            return Err(DomainError::PermissionDenied(
                "没有权限删除此作业".to_string(),
            ));
        }

        // 5. 删除作业
        self.assignment_repository.delete(&assignment_id).await?;

        Logger::info(&format!("作业删除成功 - 标题: {}", assignment.title()));

        // 6. 返回响应
        Ok(DeleteAssignmentResponse {
            message: "作业删除成功".to_string(),
        })
    }

    /// 验证命令参数
    fn validate_command(&self, command: &DeleteAssignmentCommand) -> Result<()> {
        if command.assignment_id.trim().is_empty() {
            return Err(DomainError::Validation("作业ID不能为空".to_string()));
        }

        if command.teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("老师ID不能为空".to_string()));
        }

        Ok(())
    }
}
