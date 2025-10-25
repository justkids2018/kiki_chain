// 更新会话ID用例
// 处理学生在作业详情页面更新会话ID的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::StudentAssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 更新会话ID命令
#[derive(Debug, Deserialize)]
pub struct UpdateConversationCommand {
    pub assignment_id: String,
    pub student_id: String,
    pub conversation_id: String,
}

/// 更新会话ID响应
#[derive(Debug, Serialize)]
pub struct UpdateConversationResponse {
    pub message: String,
    pub conversation_id: String,
    pub assignment_id: String,
}

/// 更新会话ID用例
/// 处理学生在作业详情页面更新会话ID的完整业务流程
pub struct UpdateConversationUseCase {
    student_assignment_repository: Arc<dyn StudentAssignmentRepository>,
}

impl UpdateConversationUseCase {
    pub fn new(student_assignment_repository: Arc<dyn StudentAssignmentRepository>) -> Self {
        Self {
            student_assignment_repository,
        }
    }

    /// 执行更新会话ID
    pub async fn execute(
        &self,
        command: UpdateConversationCommand,
    ) -> Result<UpdateConversationResponse> {
        // 1. 验证输入数据
        self.validate_command(&command)?;

        Logger::info(&format!(
            "更新会话ID开始 - 作业ID: {}, 学生ID: {}, 会话ID: {}",
            command.assignment_id, command.student_id, command.conversation_id
        ));

        // 2. 解析UUID
        let assignment_id = Uuid::parse_str(&command.assignment_id)
            .map_err(|_| DomainError::Validation("无效的作业ID格式".to_string()))?;

        // 3. 查找或创建学生作业记录
        let mut student_assignment = match self
            .student_assignment_repository
            .find_by_assignment_and_student(&assignment_id, &command.student_id)
            .await?
        {
            Some(sa) => sa,
            None => {
                // 如果学生作业记录不存在，创建新的记录
                Logger::info("学生作业记录不存在，创建新记录");
                let new_student_assignment = crate::domain::entities::StudentAssignment::new(
                    Uuid::new_v4(),
                    assignment_id,
                    command.student_id.clone(),
                    crate::domain::entities::StudentAssignmentStatus::NotStarted,
                    0,
                    0,
                    bigdecimal::BigDecimal::from(0),
                    bigdecimal::BigDecimal::from(0),
                    crate::domain::entities::StudentAssignment::default_evaluation_metrics(),
                    Some(command.conversation_id.clone()),
                );

                self.student_assignment_repository
                    .save(&new_student_assignment)
                    .await?;
                new_student_assignment
            }
        };

        // 4. 更新会话ID
        student_assignment.update_conversation_id(Some(command.conversation_id.clone()));

        // 5. 如果是第一次设置会话ID，标记为已开始
        if student_assignment.status()
            == &crate::domain::entities::StudentAssignmentStatus::NotStarted
        {
            student_assignment.start_assignment();
        }

        // 6. 保存更新
        self.student_assignment_repository
            .save(&student_assignment)
            .await?;

        Logger::info(&format!(
            "会话ID更新成功 - 会话ID: {}",
            command.conversation_id
        ));

        // 7. 返回响应
        Ok(UpdateConversationResponse {
            message: "会话ID更新成功".to_string(),
            conversation_id: command.conversation_id,
            assignment_id: command.assignment_id,
        })
    }

    /// 验证命令参数
    fn validate_command(&self, command: &UpdateConversationCommand) -> Result<()> {
        if command.assignment_id.trim().is_empty() {
            return Err(DomainError::Validation("作业ID不能为空".to_string()));
        }

        if command.student_id.trim().is_empty() {
            return Err(DomainError::Validation("学生ID不能为空".to_string()));
        }

        if command.conversation_id.trim().is_empty() {
            return Err(DomainError::Validation("会话ID不能为空".to_string()));
        }

        Ok(())
    }
}
