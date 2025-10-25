//! 创建学生作业用例
//! 负责处理新增学生作业的完整业务流程

use std::sync::Arc;

use bigdecimal::{BigDecimal, FromPrimitive};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use serde_json::{Map, Value};
use uuid::Uuid;

use crate::domain::entities::{StudentAssignment, StudentAssignmentStatus};
use crate::domain::errors::{DomainError, Result};
use crate::domain::student_assignment::{StudentAssignmentData, StudentAssignmentFactory};
use crate::domain::StudentAssignmentRepository;
use crate::infrastructure::logging::Logger;

use super::StudentAssignmentView;

/// 创建学生作业命令
#[derive(Debug, Deserialize)]
pub struct CreateStudentAssignmentCommand {
    pub assignment_id: String,
    pub student_id: String,
    pub status: Option<String>,
    pub dialog_rounds: Option<i32>,
    pub avg_thinking_time_ms: Option<i64>,
    pub knowledge_mastery_score: Option<f64>,
    pub thinking_depth_score: Option<f64>,
    pub evaluation_metrics: Option<Value>,
    pub conversation_id: Option<String>,
    pub started_at: Option<String>,
    pub completed_at: Option<String>,
}

/// 创建学生作业响应
#[derive(Debug, Serialize)]
pub struct CreateStudentAssignmentResponse {
    pub assignment: StudentAssignmentView,
}

/// 创建学生作业用例
pub struct CreateStudentAssignmentUseCase {
    repository: Arc<dyn StudentAssignmentRepository>,
}

impl CreateStudentAssignmentUseCase {
    pub fn new(repository: Arc<dyn StudentAssignmentRepository>) -> Self {
        Self { repository }
    }

    /// 执行创建学生作业流程
    pub async fn execute(
        &self,
        command: CreateStudentAssignmentCommand,
    ) -> Result<CreateStudentAssignmentResponse> {
        Logger::info("🆕 [学生作业] 开始创建学生作业记录");

        let data = self.build_domain_data(&command)?;

        if let Some(existing) = self
            .repository
            .find_by_assignment_and_student(&data.assignment_id, &data.student_id)
            .await?
        {
            Logger::warn(format!(
                "⚠️ [学生作业] 学生 {} 与作业 {} 记录已存在，跳过创建",
                existing.student_id(),
                existing.assignment_id()
            ));
            return Err(DomainError::AlreadyExists("学生作业记录已存在".to_string()));
        }

        let entity = StudentAssignmentFactory::create(data)?;

        self.repository.save(&entity).await?;
        Logger::info(format!(
            "✅ [学生作业] 学生 {} 与作业 {} 关联创建成功",
            entity.student_id(),
            entity.assignment_id()
        ));

        Ok(CreateStudentAssignmentResponse {
            assignment: StudentAssignmentView::from(&entity),
        })
    }

    fn build_domain_data(
        &self,
        command: &CreateStudentAssignmentCommand,
    ) -> Result<StudentAssignmentData> {
        let assignment_id = Uuid::parse_str(&command.assignment_id)
            .map_err(|_| DomainError::Validation("作业ID格式不正确".to_string()))?;
        let status = self.parse_status(command.status.as_deref())?;
        let knowledge_mastery_score =
            Self::parse_decimal(command.knowledge_mastery_score, "knowledge_mastery_score")?;
        let thinking_depth_score =
            Self::parse_decimal(command.thinking_depth_score, "thinking_depth_score")?;
        let started_at = Self::parse_datetime(command.started_at.as_deref())?;
        let completed_at = Self::parse_datetime(command.completed_at.as_deref())?;
        let evaluation_metrics = normalize_evaluation_metrics(command.evaluation_metrics.clone())?;

        Ok(StudentAssignmentData {
            assignment_id,
            student_id: command.student_id.clone(),
            status,
            dialog_rounds: command.dialog_rounds.unwrap_or_default(),
            avg_thinking_time_ms: command.avg_thinking_time_ms.unwrap_or_default(),
            knowledge_mastery_score,
            thinking_depth_score,
            evaluation_metrics,
            conversation_id: command.conversation_id.clone(),
            started_at,
            completed_at,
        })
    }

    fn parse_status(&self, status: Option<&str>) -> Result<StudentAssignmentStatus> {
        match status {
            Some(value) => value
                .parse()
                .map_err(|_| DomainError::Validation(format!("无效的学生作业状态: {}", value))),
            None => Ok(StudentAssignmentStatus::NotStarted),
        }
    }

    fn parse_decimal(value: Option<f64>, field: &str) -> Result<BigDecimal> {
        match value {
            Some(v) => BigDecimal::from_f64(v)
                .ok_or_else(|| DomainError::Validation(format!("{} 格式错误", field))),
            None => Ok(BigDecimal::from(0)),
        }
    }

    fn parse_datetime(value: Option<&str>) -> Result<Option<DateTime<Utc>>> {
        match value {
            Some(raw) => {
                let parsed = DateTime::parse_from_rfc3339(raw)
                    .map_err(|_| DomainError::Validation("时间格式必须为RFC3339".to_string()))?;
                Ok(Some(parsed.with_timezone(&Utc)))
            }
            None => Ok(None),
        }
    }
}

pub(super) fn normalize_evaluation_metrics(raw: Option<Value>) -> Result<Value> {
    match raw {
        Some(Value::String(text)) => {
            let parsed: Value = serde_json::from_str(&text).map_err(|_| {
                DomainError::Validation("evaluation_metrics 必须是合法的 JSON 字符串".to_string())
            })?;
            match parsed {
                Value::Object(mut map) => {
                    ensure_metric_keys(&mut map);
                    Ok(Value::Object(map))
                }
                Value::Null => Ok(StudentAssignment::default_evaluation_metrics()),
                other => Err(DomainError::Validation(format!(
                    "evaluation_metrics 必须为 JSON 对象，当前值: {}",
                    other
                ))),
            }
        }
        Some(Value::Object(mut map)) => {
            ensure_metric_keys(&mut map);
            Ok(Value::Object(map))
        }
        Some(Value::Null) | None => Ok(StudentAssignment::default_evaluation_metrics()),
        Some(other) => Err(DomainError::Validation(format!(
            "evaluation_metrics 必须为 JSON 对象，当前值: {}",
            other
        ))),
    }
}

fn ensure_metric_keys(map: &mut Map<String, Value>) {
    for key in StudentAssignment::EVALUATION_METRIC_KEYS {
        map.entry(key.to_string()).or_insert(Value::Null);
    }
}
