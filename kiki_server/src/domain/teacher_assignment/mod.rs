// 老师作业视图领域模块
// 定义老师维度聚合结构与仓储抽象，支持老师查看学生作业明细

use std::sync::Arc;

use async_trait::async_trait;
use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use serde_json::Value;
use uuid::Uuid;

use crate::domain::entities::StudentAssignmentStatus;
use crate::domain::errors::Result;

/// 学生基础信息快照
#[derive(Debug, Clone)]
pub struct TeacherAssignmentStudentProfile {
    uid: String,
    name: String,
    phone: String,
    role_id: i32,
}

impl TeacherAssignmentStudentProfile {
    /// 构造学生基础信息
    pub fn new(
        uid: impl Into<String>,
        name: impl Into<String>,
        phone: impl Into<String>,
        role_id: i32,
    ) -> Self {
        Self {
            uid: uid.into(),
            name: name.into(),
            phone: phone.into(),
            role_id,
        }
    }

    pub fn uid(&self) -> &str {
        &self.uid
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn phone(&self) -> &str {
        &self.phone
    }

    pub fn role_id(&self) -> i32 {
        self.role_id
    }
}

/// 学生作业信息快照
#[derive(Debug, Clone)]
pub struct TeacherAssignmentStudentAssignmentSnapshot {
    id: Uuid,
    assignment_id: Uuid,
    assignment_title: Option<String>,
    status: StudentAssignmentStatus,
    dialog_rounds: i32,
    avg_thinking_time_ms: i64,
    knowledge_mastery_score: BigDecimal,
    thinking_depth_score: BigDecimal,
    evaluation_metrics: Value,
    started_at: Option<DateTime<Utc>>,
    completed_at: Option<DateTime<Utc>>,
}

impl TeacherAssignmentStudentAssignmentSnapshot {
    /// 构造作业快照
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        id: Uuid,
        assignment_id: Uuid,
        assignment_title: Option<String>,
        status: StudentAssignmentStatus,
        dialog_rounds: i32,
        avg_thinking_time_ms: i64,
        knowledge_mastery_score: BigDecimal,
        thinking_depth_score: BigDecimal,
        evaluation_metrics: Value,
        started_at: Option<DateTime<Utc>>,
        completed_at: Option<DateTime<Utc>>,
    ) -> Self {
        Self {
            id,
            assignment_id,
            assignment_title,
            status,
            dialog_rounds,
            avg_thinking_time_ms,
            knowledge_mastery_score,
            thinking_depth_score,
            evaluation_metrics,
            started_at,
            completed_at,
        }
    }

    pub fn id(&self) -> &Uuid {
        &self.id
    }

    pub fn assignment_id(&self) -> &Uuid {
        &self.assignment_id
    }

    pub fn assignment_title(&self) -> Option<&str> {
        self.assignment_title.as_deref()
    }

    pub fn status(&self) -> &StudentAssignmentStatus {
        &self.status
    }

    pub fn dialog_rounds(&self) -> i32 {
        self.dialog_rounds
    }

    pub fn avg_thinking_time_ms(&self) -> i64 {
        self.avg_thinking_time_ms
    }

    pub fn knowledge_mastery_score(&self) -> &BigDecimal {
        &self.knowledge_mastery_score
    }

    pub fn thinking_depth_score(&self) -> &BigDecimal {
        &self.thinking_depth_score
    }

    pub fn evaluation_metrics(&self) -> &Value {
        &self.evaluation_metrics
    }

    pub fn started_at(&self) -> Option<&DateTime<Utc>> {
        self.started_at.as_ref()
    }

    pub fn completed_at(&self) -> Option<&DateTime<Utc>> {
        self.completed_at.as_ref()
    }
}

/// 老师维度学生作业聚合
#[derive(Debug, Clone)]
pub struct TeacherAssignmentStudentAssignments {
    student: TeacherAssignmentStudentProfile,
    assignments: Vec<TeacherAssignmentStudentAssignmentSnapshot>,
}

impl TeacherAssignmentStudentAssignments {
    /// 构造学生作业聚合
    pub fn new(
        student: TeacherAssignmentStudentProfile,
        assignments: Vec<TeacherAssignmentStudentAssignmentSnapshot>,
    ) -> Self {
        Self {
            student,
            assignments,
        }
    }

    pub fn student(&self) -> &TeacherAssignmentStudentProfile {
        &self.student
    }

    pub fn assignments(&self) -> &[TeacherAssignmentStudentAssignmentSnapshot] {
        &self.assignments
    }

    /// 追加一条作业快照
    pub fn add_assignment(&mut self, assignment: TeacherAssignmentStudentAssignmentSnapshot) {
        self.assignments.push(assignment);
    }
}

/// 老师作业视图查询仓储抽象
#[async_trait]
pub trait TeacherAssignmentQueryRepository: Send + Sync {
    /// 根据老师UID查询其所管理学生的作业视图
    async fn find_student_assignments_by_teacher(
        &self,
        teacher_uid: &str,
    ) -> Result<Vec<TeacherAssignmentStudentAssignments>>;

    /// 根据学生UID查询其个人作业视图
    async fn find_student_assignments_by_student(
        &self,
        student_uid: &str,
    ) -> Result<Option<TeacherAssignmentStudentAssignments>>;
}

/// 共享引用类型定义，便于依赖注入
pub type TeacherAssignmentQueryRepositoryArc = Arc<dyn TeacherAssignmentQueryRepository>;
