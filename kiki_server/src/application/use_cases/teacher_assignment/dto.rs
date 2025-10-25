//! 老师作业视图DTO定义
//! 将领域层聚合转换为表现层友好的结构

use serde::Serialize;
use serde_json::Value;

use crate::domain::teacher_assignment::{
    TeacherAssignmentStudentAssignmentSnapshot, TeacherAssignmentStudentAssignments,
    TeacherAssignmentStudentProfile,
};

/// 学生基础信息视图
#[derive(Debug, Serialize, Clone)]
pub struct TeacherAssignmentStudentProfileView {
    pub uid: String,
    pub name: String,
    pub phone: String,
    pub role_id: i32,
}

impl From<&TeacherAssignmentStudentProfile> for TeacherAssignmentStudentProfileView {
    fn from(profile: &TeacherAssignmentStudentProfile) -> Self {
        Self {
            uid: profile.uid().to_string(),
            name: profile.name().to_string(),
            phone: profile.phone().to_string(),
            role_id: profile.role_id(),
        }
    }
}

/// 学生作业信息视图
#[derive(Debug, Serialize, Clone)]
pub struct TeacherAssignmentStudentAssignmentView {
    pub student_assignment_id: String,
    pub assignment_id: String,
    pub assignment_title: Option<String>,
    pub status: String,
    pub dialog_rounds: i32,
    pub avg_thinking_time_ms: i64,
    pub knowledge_mastery_score: String,
    pub thinking_depth_score: String,
    pub evaluation_metrics: Value,
    pub started_at: Option<String>,
    pub completed_at: Option<String>,
}

impl From<&TeacherAssignmentStudentAssignmentSnapshot> for TeacherAssignmentStudentAssignmentView {
    fn from(snapshot: &TeacherAssignmentStudentAssignmentSnapshot) -> Self {
        Self {
            student_assignment_id: snapshot.id().to_string(),
            assignment_id: snapshot.assignment_id().to_string(),
            assignment_title: snapshot.assignment_title().map(|title| title.to_string()),
            status: snapshot.status().to_string(),
            dialog_rounds: snapshot.dialog_rounds(),
            avg_thinking_time_ms: snapshot.avg_thinking_time_ms(),
            knowledge_mastery_score: snapshot.knowledge_mastery_score().to_string(),
            thinking_depth_score: snapshot.thinking_depth_score().to_string(),
            evaluation_metrics: snapshot.evaluation_metrics().clone(),
            started_at: snapshot.started_at().map(|ts| ts.to_rfc3339()),
            completed_at: snapshot.completed_at().map(|ts| ts.to_rfc3339()),
        }
    }
}

/// 按学生聚合的作业视图
#[derive(Debug, Serialize, Clone)]
pub struct TeacherAssignmentStudentAssignmentsView {
    pub student: TeacherAssignmentStudentProfileView,
    pub assignments: Vec<TeacherAssignmentStudentAssignmentView>,
}

impl From<&TeacherAssignmentStudentAssignments> for TeacherAssignmentStudentAssignmentsView {
    fn from(aggregate: &TeacherAssignmentStudentAssignments) -> Self {
        let student = TeacherAssignmentStudentProfileView::from(aggregate.student());
        let assignments = aggregate
            .assignments()
            .iter()
            .map(TeacherAssignmentStudentAssignmentView::from)
            .collect();

        Self {
            student,
            assignments,
        }
    }
}
