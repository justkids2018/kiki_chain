//! 学生作业用例层数据传输对象
//! 负责在应用层与表现层之间传递标准化数据结构

use serde::Serialize;
use serde_json::Value;

use crate::domain::entities::StudentAssignment;

/// 学生作业对外展示模型
#[derive(Debug, Clone, Serialize, PartialEq)]
pub struct StudentAssignmentView {
    pub id: String,
    pub assignment_id: String,
    pub student_id: String,
    pub status: String,
    pub dialog_rounds: i32,
    pub avg_thinking_time_ms: i64,
    pub knowledge_mastery_score: String,
    pub thinking_depth_score: String,
    pub conversation_id: Option<String>,
    pub started_at: Option<String>,
    pub completed_at: Option<String>,
    pub evaluation_metrics: Value,
}

impl From<&StudentAssignment> for StudentAssignmentView {
    fn from(entity: &StudentAssignment) -> Self {
        Self {
            id: entity.id().to_string(),
            assignment_id: entity.assignment_id().to_string(),
            student_id: entity.student_id().to_string(),
            status: entity.status().to_string(),
            dialog_rounds: entity.dialog_rounds(),
            avg_thinking_time_ms: entity.avg_thinking_time_ms(),
            knowledge_mastery_score: entity.knowledge_mastery_score().to_string(),
            thinking_depth_score: entity.thinking_depth_score().to_string(),
            conversation_id: entity.conversation_id().clone(),
            started_at: entity.started_at().map(|ts| ts.to_rfc3339()),
            completed_at: entity.completed_at().map(|ts| ts.to_rfc3339()),
            evaluation_metrics: entity.evaluation_metrics().clone(),
        }
    }
}
