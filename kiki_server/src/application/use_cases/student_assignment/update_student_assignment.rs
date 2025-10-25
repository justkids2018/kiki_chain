//! 更新学生作业用例
//! 负责根据输入指令更新学生作业的业务状态

use std::sync::Arc;

use bigdecimal::{BigDecimal, FromPrimitive};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use uuid::Uuid;

use crate::domain::entities::StudentAssignmentStatus;
use crate::domain::errors::{DomainError, Result};
use crate::domain::student_assignment::{StudentAssignmentUpdateData, StudentAssignmentUpdater};
use crate::domain::StudentAssignmentRepository;
use crate::infrastructure::logging::Logger;

use super::{create_student_assignment::normalize_evaluation_metrics, StudentAssignmentView};

/// 更新学生作业命令
#[derive(Debug, Deserialize)]
pub struct UpdateStudentAssignmentCommand {
    pub id: String,
    pub status: Option<String>,
    pub dialog_rounds: Option<i32>,
    pub avg_thinking_time_ms: Option<i64>,
    pub knowledge_mastery_score: Option<f64>,
    pub thinking_depth_score: Option<f64>,
    pub evaluation_metrics: Option<Value>,
    pub conversation_id: Option<Option<String>>,
    pub started_at: Option<Option<String>>,
    pub completed_at: Option<Option<String>>,
}

/// 更新学生作业响应
#[derive(Debug, Serialize)]
pub struct UpdateStudentAssignmentResponse {
    pub assignment: StudentAssignmentView,
}

/// 更新学生作业用例
pub struct UpdateStudentAssignmentUseCase {
    repository: Arc<dyn StudentAssignmentRepository>,
}

impl UpdateStudentAssignmentUseCase {
    pub fn new(repository: Arc<dyn StudentAssignmentRepository>) -> Self {
        Self { repository }
    }

    /// 执行更新流程
    pub async fn execute(
        &self,
        command: UpdateStudentAssignmentCommand,
    ) -> Result<UpdateStudentAssignmentResponse> {
        let id = Uuid::parse_str(&command.id)
            .map_err(|_| DomainError::Validation("学生作业ID格式不正确".to_string()))?;

        Logger::info(format!("🔄 [学生作业] 更新学生作业 - ID: {}", id));

        let mut entity = self
            .repository
            .find_by_id(&id)
            .await?
            .ok_or_else(|| DomainError::NotFound("未找到需要更新的学生作业".to_string()))?;

        let update_data = self.build_update_data(&command)?;
        StudentAssignmentUpdater::apply(&mut entity, update_data)?;

        self.repository.save(&entity).await?;
        Logger::info(format!(
            "✅ [学生作业] 学生 {} 与作业 {} 更新成功",
            entity.student_id(),
            entity.assignment_id()
        ));

        Ok(UpdateStudentAssignmentResponse {
            assignment: StudentAssignmentView::from(&entity),
        })
    }

    fn build_update_data(
        &self,
        command: &UpdateStudentAssignmentCommand,
    ) -> Result<StudentAssignmentUpdateData> {
        let status =
            match command.status.as_deref() {
                Some(value) => Some(value.parse::<StudentAssignmentStatus>().map_err(|_| {
                    DomainError::Validation(format!("无效的学生作业状态: {}", value))
                })?),
                None => None,
            };

        let knowledge_mastery_score =
            Self::parse_decimal(command.knowledge_mastery_score, "knowledge_mastery_score")?;
        let thinking_depth_score =
            Self::parse_decimal(command.thinking_depth_score, "thinking_depth_score")?;

        let started_at = Self::parse_optional_datetime(command.started_at.as_ref())?;
        let completed_at = Self::parse_optional_datetime(command.completed_at.as_ref())?;
        let evaluation_metrics = match command.evaluation_metrics.clone() {
            Some(value) => Some(normalize_evaluation_metrics(Some(value))?),
            None => None,
        };

        Ok(StudentAssignmentUpdateData {
            status,
            dialog_rounds: command.dialog_rounds,
            avg_thinking_time_ms: command.avg_thinking_time_ms,
            knowledge_mastery_score,
            thinking_depth_score,
            evaluation_metrics,
            conversation_id: command.conversation_id.clone(),
            started_at,
            completed_at,
        })
    }

    fn parse_decimal(value: Option<f64>, field: &str) -> Result<Option<BigDecimal>> {
        match value {
            Some(v) => Ok(Some(BigDecimal::from_f64(v).ok_or_else(|| {
                DomainError::Validation(format!("{} 格式错误", field))
            })?)),
            None => Ok(None),
        }
    }

    fn parse_optional_datetime(
        value: Option<&Option<String>>,
    ) -> Result<Option<Option<DateTime<Utc>>>> {
        match value {
            Some(Some(raw)) => {
                let parsed = DateTime::parse_from_rfc3339(raw)
                    .map_err(|_| DomainError::Validation("时间格式必须为RFC3339".to_string()))?;
                Ok(Some(Some(parsed.with_timezone(&Utc))))
            }
            Some(None) => Ok(Some(None)),
            None => Ok(None),
        }
    }
}
