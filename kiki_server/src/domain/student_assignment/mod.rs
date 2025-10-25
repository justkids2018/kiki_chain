// 学生作业领域服务模块
// 提供创建与更新学生作业聚合根的领域规则封装

use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use serde_json::Value;
use uuid::Uuid;

use crate::domain::entities::{StudentAssignment, StudentAssignmentStatus};
use crate::domain::errors::{DomainError, Result};

/// 学生作业创建所需的数据载体
/// 由应用层完成原始输入校验后传入领域层
#[derive(Debug, Clone)]
pub struct StudentAssignmentData {
    pub assignment_id: Uuid,
    pub student_id: String,
    pub status: StudentAssignmentStatus,
    pub dialog_rounds: i32,
    pub avg_thinking_time_ms: i64,
    pub knowledge_mastery_score: BigDecimal,
    pub thinking_depth_score: BigDecimal,
    pub evaluation_metrics: Value,
    pub conversation_id: Option<String>,
    pub started_at: Option<DateTime<Utc>>,
    pub completed_at: Option<DateTime<Utc>>,
}

/// 学生作业更新所需的数据载体
/// 所有字段均为可选，按需更新
#[derive(Debug, Default, Clone)]
pub struct StudentAssignmentUpdateData {
    pub status: Option<StudentAssignmentStatus>,
    pub dialog_rounds: Option<i32>,
    pub avg_thinking_time_ms: Option<i64>,
    pub knowledge_mastery_score: Option<BigDecimal>,
    pub thinking_depth_score: Option<BigDecimal>,
    pub evaluation_metrics: Option<Value>,
    pub conversation_id: Option<Option<String>>,
    pub started_at: Option<Option<DateTime<Utc>>>,
    pub completed_at: Option<Option<DateTime<Utc>>>,
}

/// 学生作业构建器
/// 负责根据领域规则构建聚合根实例
pub struct StudentAssignmentFactory;

impl StudentAssignmentFactory {
    /// 根据输入数据创建学生作业实体
    pub fn create(data: StudentAssignmentData) -> Result<StudentAssignment> {
        Self::validate_common(
            &data.student_id,
            data.dialog_rounds,
            data.avg_thinking_time_ms,
        )?;
        Self::validate_score(&data.knowledge_mastery_score, "knowledge_mastery_score")?;
        Self::validate_score(&data.thinking_depth_score, "thinking_depth_score")?;
        validate_metrics_object(&data.evaluation_metrics)?;
        Self::validate_timeline(data.started_at.as_ref(), data.completed_at.as_ref())?;

        Ok(StudentAssignment::reconstruct(
            Uuid::new_v4(),
            data.assignment_id,
            data.student_id,
            data.status,
            data.dialog_rounds,
            data.avg_thinking_time_ms,
            data.knowledge_mastery_score,
            data.thinking_depth_score,
            data.evaluation_metrics,
            data.conversation_id,
            data.started_at,
            data.completed_at,
        ))
    }

    fn validate_common(
        student_id: &str,
        dialog_rounds: i32,
        avg_thinking_time_ms: i64,
    ) -> Result<()> {
        if student_id.trim().is_empty() {
            return Err(DomainError::Validation("学生ID不能为空".to_string()));
        }
        if dialog_rounds < 0 {
            return Err(DomainError::Validation("对话轮次不能为负数".to_string()));
        }
        if avg_thinking_time_ms < 0 {
            return Err(DomainError::Validation(
                "平均思考时间不能为负数".to_string(),
            ));
        }
        Ok(())
    }

    fn validate_score(score: &BigDecimal, field_name: &str) -> Result<()> {
        if score < &BigDecimal::from(0) {
            return Err(DomainError::Validation(format!(
                "{} 不能为负数",
                field_name
            )));
        }
        Ok(())
    }

    fn validate_timeline(
        started_at: Option<&DateTime<Utc>>,
        completed_at: Option<&DateTime<Utc>>,
    ) -> Result<()> {
        if let (Some(start), Some(end)) = (started_at, completed_at) {
            if end < start {
                return Err(DomainError::Validation(
                    "完成时间不能早于开始时间".to_string(),
                ));
            }
        }
        Ok(())
    }
}

/// 学生作业更新器
/// 负责在领域层内安全地更新实体状态
pub struct StudentAssignmentUpdater;

impl StudentAssignmentUpdater {
    /// 按更新数据修改实体，保持领域规则一致
    pub fn apply(target: &mut StudentAssignment, data: StudentAssignmentUpdateData) -> Result<()> {
        if let Some(status) = data.status {
            target.set_status(status);
        }

        if let Some(rounds) = data.dialog_rounds {
            if rounds < 0 {
                return Err(DomainError::Validation("对话轮次不能为负数".to_string()));
            }
            target.set_dialog_rounds(rounds);
        }

        if let Some(avg) = data.avg_thinking_time_ms {
            if avg < 0 {
                return Err(DomainError::Validation(
                    "平均思考时间不能为负数".to_string(),
                ));
            }
            target.set_avg_thinking_time_ms(avg);
        }

        if let Some(score) = data.knowledge_mastery_score {
            if score < BigDecimal::from(0) {
                return Err(DomainError::Validation(
                    "knowledge_mastery_score 不能为负数".to_string(),
                ));
            }
            target.set_knowledge_mastery_score(score);
        }

        if let Some(score) = data.thinking_depth_score {
            if score < BigDecimal::from(0) {
                return Err(DomainError::Validation(
                    "thinking_depth_score 不能为负数".to_string(),
                ));
            }
            target.set_thinking_depth_score(score);
        }

        if let Some(metrics) = data.evaluation_metrics {
            validate_metrics_object(&metrics)?;
            target.set_evaluation_metrics(metrics);
        }

        if let Some(conversation_id) = data.conversation_id {
            target.update_conversation_id(conversation_id);
        }

        if let Some(started_at) = data.started_at {
            target.set_started_at(started_at);
        }

        if let Some(completed_at) = data.completed_at {
            if let Some(end_time) = completed_at.clone() {
                if let Some(start_time) = target.started_at().as_ref() {
                    if end_time < *start_time {
                        return Err(DomainError::Validation(
                            "完成时间不能早于开始时间".to_string(),
                        ));
                    }
                }
            }
            target.set_completed_at(completed_at);
        }

        Ok(())
    }
}

fn validate_metrics_object(metrics: &Value) -> Result<()> {
    match metrics {
        Value::Object(map) => {
            for key in crate::domain::entities::StudentAssignment::EVALUATION_METRIC_KEYS.iter() {
                if !map.contains_key(*key) {
                    return Err(DomainError::Validation(format!(
                        "evaluation_metrics 缺少必需字段 {}",
                        key
                    )));
                }
            }
            Ok(())
        }
        _ => Err(DomainError::Validation(
            "evaluation_metrics 必须为 JSON 对象".to_string(),
        )),
    }
}
