// PostgreSQL老师作业视图仓储实现
// 通过单次查询聚合老师关联学生及其作业信息

use std::collections::HashMap;

use async_trait::async_trait;
use bigdecimal::BigDecimal;
use serde_json::Value;
use sqlx::{types::Json, PgPool, Row};
use uuid::Uuid;

use crate::domain::entities::{StudentAssignment, StudentAssignmentStatus};
use crate::domain::errors::{DomainError, Result};
use crate::domain::teacher_assignment::{
    TeacherAssignmentQueryRepository, TeacherAssignmentStudentAssignmentSnapshot,
    TeacherAssignmentStudentAssignments, TeacherAssignmentStudentProfile,
};

/// PostgreSQL实现的老师作业视图仓储
pub struct PostgresTeacherAssignmentQueryRepository {
    pool: PgPool,
}

impl PostgresTeacherAssignmentQueryRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl TeacherAssignmentQueryRepository for PostgresTeacherAssignmentQueryRepository {
    async fn find_student_assignments_by_teacher(
        &self,
        teacher_uid: &str,
    ) -> Result<Vec<TeacherAssignmentStudentAssignments>> {
        let rows = sqlx::query(
            r#"
            SELECT
                u.uid AS student_uid,
                u.name AS student_name,
                u.phone AS student_phone,
                u.role_id AS student_role_id,
                sa.id AS student_assignment_id,
                sa.assignment_id,
                sa.status AS assignment_status,
                sa.dialog_rounds,
                sa.avg_thinking_time_ms,
                sa.knowledge_mastery_score,
                sa.thinking_depth_score,
                sa.evaluation_metrics,
                sa.started_at,
                sa.completed_at,
                a.title AS assignment_title
            FROM teacher_students ts
                JOIN users u ON ts.student_id = u.uid
                LEFT JOIN student_assignments sa ON sa.student_id = u.uid
                LEFT JOIN assignments a ON sa.assignment_id = a.id
            WHERE ts.teacher_id = $1
            ORDER BY u.uid ASC, sa.started_at DESC NULLS LAST, sa.id ASC
            "#,
        )
        .bind(teacher_uid)
        .fetch_all(&self.pool)
        .await
        .map_err(|err| DomainError::Infrastructure(err.to_string()))?;

        let mut aggregates: Vec<TeacherAssignmentStudentAssignments> = Vec::new();
        let mut index_by_student_uid: HashMap<String, usize> = HashMap::new();

        for row in rows {
            let student_uid: String = row
                .try_get("student_uid")
                .map_err(|err| DomainError::Infrastructure(format!("读取学生UID失败: {}", err)))?;
            let student_name: String = row
                .try_get("student_name")
                .map_err(|err| DomainError::Infrastructure(format!("读取学生姓名失败: {}", err)))?;
            let student_phone: String = row.try_get("student_phone").map_err(|err| {
                DomainError::Infrastructure(format!("读取学生手机号失败: {}", err))
            })?;
            let student_role_id: i32 = row
                .try_get("student_role_id")
                .map_err(|err| DomainError::Infrastructure(format!("读取学生角色失败: {}", err)))?;

            let index = if let Some(index) = index_by_student_uid.get(&student_uid) {
                *index
            } else {
                let profile = TeacherAssignmentStudentProfile::new(
                    student_uid.clone(),
                    student_name,
                    student_phone,
                    student_role_id,
                );
                aggregates.push(TeacherAssignmentStudentAssignments::new(
                    profile,
                    Vec::new(),
                ));
                let new_index = aggregates.len() - 1;
                index_by_student_uid.insert(student_uid.clone(), new_index);
                new_index
            };

            let assignment_id: Option<Uuid> =
                row.try_get("student_assignment_id").map_err(|err| {
                    DomainError::Infrastructure(format!("读取学生作业ID失败: {}", err))
                })?;
            if assignment_id.is_none() {
                continue;
            }

            let student_assignment_id = assignment_id.unwrap();
            let status_raw: Option<String> = row.try_get("assignment_status").map_err(|err| {
                DomainError::Infrastructure(format!("读取学生作业状态失败: {}", err))
            })?;
            let status = match status_raw.as_deref() {
                Some(raw) => raw.parse::<StudentAssignmentStatus>().map_err(|_| {
                    DomainError::Infrastructure(format!("无法解析学生作业状态: {}", raw))
                })?,
                None => StudentAssignmentStatus::default(),
            };

            let dialog_rounds = row
                .try_get::<Option<i32>, _>("dialog_rounds")
                .map_err(|err| DomainError::Infrastructure(format!("读取对话轮次失败: {}", err)))?
                .unwrap_or(0);
            let avg_thinking_time_ms = row
                .try_get::<Option<i64>, _>("avg_thinking_time_ms")
                .map_err(|err| {
                    DomainError::Infrastructure(format!("读取平均思考时间失败: {}", err))
                })?
                .unwrap_or(0);
            let knowledge_mastery_score = row
                .try_get::<Option<BigDecimal>, _>("knowledge_mastery_score")
                .map_err(|err| DomainError::Infrastructure(format!("读取知识掌握度失败: {}", err)))?
                .unwrap_or_else(|| BigDecimal::from(0));
            let thinking_depth_score = row
                .try_get::<Option<BigDecimal>, _>("thinking_depth_score")
                .map_err(|err| DomainError::Infrastructure(format!("读取思考深度失败: {}", err)))?
                .unwrap_or_else(|| BigDecimal::from(0));
            let evaluation_metrics = row
                .try_get::<Option<Json<Value>>, _>("evaluation_metrics")
                .map_err(|err| DomainError::Infrastructure(format!("读取评估指标失败: {}", err)))?
                .map(|json| json.0)
                .unwrap_or_else(StudentAssignment::default_evaluation_metrics);
            let started_at = row
                .try_get("started_at")
                .map_err(|err| DomainError::Infrastructure(format!("读取开始时间失败: {}", err)))?;
            let completed_at = row
                .try_get("completed_at")
                .map_err(|err| DomainError::Infrastructure(format!("读取完成时间失败: {}", err)))?;
            let assignment_ref_id = row
                .try_get::<Option<Uuid>, _>("assignment_id")
                .map_err(|err| DomainError::Infrastructure(format!("读取作业ID失败: {}", err)))?
                .ok_or_else(|| {
                    DomainError::Infrastructure(
                        "老师学生作业记录缺少对应的assignment_id".to_string(),
                    )
                })?;
            let assignment_title = row
                .try_get::<Option<String>, _>("assignment_title")
                .map_err(|err| DomainError::Infrastructure(format!("读取作业标题失败: {}", err)))?;

            let snapshot = TeacherAssignmentStudentAssignmentSnapshot::new(
                student_assignment_id,
                assignment_ref_id,
                assignment_title,
                status,
                dialog_rounds,
                avg_thinking_time_ms,
                knowledge_mastery_score,
                thinking_depth_score,
                evaluation_metrics,
                started_at,
                completed_at,
            );

            aggregates[index].add_assignment(snapshot);
        }

        Ok(aggregates)
    }

    async fn find_student_assignments_by_student(
        &self,
        student_uid: &str,
    ) -> Result<Option<TeacherAssignmentStudentAssignments>> {
        let rows = sqlx::query(
            r#"
            SELECT
                u.uid AS student_uid,
                u.name AS student_name,
                u.phone AS student_phone,
                u.role_id AS student_role_id,
                sa.id AS student_assignment_id,
                sa.assignment_id,
                sa.status AS assignment_status,
                sa.dialog_rounds,
                sa.avg_thinking_time_ms,
                sa.knowledge_mastery_score,
                sa.thinking_depth_score,
                sa.evaluation_metrics,
                sa.started_at,
                sa.completed_at,
                a.title AS assignment_title
            FROM users u
                LEFT JOIN student_assignments sa ON sa.student_id = u.uid
                LEFT JOIN assignments a ON sa.assignment_id = a.id
            WHERE u.uid = $1
            ORDER BY sa.started_at DESC NULLS LAST, sa.id ASC
            "#,
        )
        .bind(student_uid)
        .fetch_all(&self.pool)
        .await
        .map_err(|err| DomainError::Infrastructure(err.to_string()))?;

        if rows.is_empty() {
            return Ok(None);
        }

        let mut profile: Option<TeacherAssignmentStudentProfile> = None;
        let mut assignments: Vec<TeacherAssignmentStudentAssignmentSnapshot> = Vec::new();

        for row in rows {
            if profile.is_none() {
                let student_uid: String = row.try_get("student_uid").map_err(|err| {
                    DomainError::Infrastructure(format!("读取学生UID失败: {}", err))
                })?;
                let student_name: String = row.try_get("student_name").map_err(|err| {
                    DomainError::Infrastructure(format!("读取学生姓名失败: {}", err))
                })?;
                let student_phone: String = row.try_get("student_phone").map_err(|err| {
                    DomainError::Infrastructure(format!("读取学生手机号失败: {}", err))
                })?;
                let student_role_id: i32 = row.try_get("student_role_id").map_err(|err| {
                    DomainError::Infrastructure(format!("读取学生角色失败: {}", err))
                })?;

                profile = Some(TeacherAssignmentStudentProfile::new(
                    student_uid,
                    student_name,
                    student_phone,
                    student_role_id,
                ));
            }

            let assignment_id: Option<Uuid> =
                row.try_get("student_assignment_id").map_err(|err| {
                    DomainError::Infrastructure(format!("读取学生作业ID失败: {}", err))
                })?;

            // 学生可能还没有任何作业记录
            let Some(student_assignment_id) = assignment_id else {
                continue;
            };

            let status_raw: Option<String> = row.try_get("assignment_status").map_err(|err| {
                DomainError::Infrastructure(format!("读取学生作业状态失败: {}", err))
            })?;
            let status = match status_raw.as_deref() {
                Some(raw) => raw.parse::<StudentAssignmentStatus>().map_err(|_| {
                    DomainError::Infrastructure(format!("无法解析学生作业状态: {}", raw))
                })?,
                None => StudentAssignmentStatus::default(),
            };

            let dialog_rounds = row
                .try_get::<Option<i32>, _>("dialog_rounds")
                .map_err(|err| DomainError::Infrastructure(format!("读取对话轮次失败: {}", err)))?
                .unwrap_or(0);
            let avg_thinking_time_ms = row
                .try_get::<Option<i64>, _>("avg_thinking_time_ms")
                .map_err(|err| {
                    DomainError::Infrastructure(format!("读取平均思考时间失败: {}", err))
                })?
                .unwrap_or(0);
            let knowledge_mastery_score = row
                .try_get::<Option<BigDecimal>, _>("knowledge_mastery_score")
                .map_err(|err| DomainError::Infrastructure(format!("读取知识掌握度失败: {}", err)))?
                .unwrap_or_else(|| BigDecimal::from(0));
            let thinking_depth_score = row
                .try_get::<Option<BigDecimal>, _>("thinking_depth_score")
                .map_err(|err| DomainError::Infrastructure(format!("读取思考深度失败: {}", err)))?
                .unwrap_or_else(|| BigDecimal::from(0));
            let evaluation_metrics = row
                .try_get::<Option<Json<Value>>, _>("evaluation_metrics")
                .map_err(|err| DomainError::Infrastructure(format!("读取评估指标失败: {}", err)))?
                .map(|json| json.0)
                .unwrap_or_else(StudentAssignment::default_evaluation_metrics);
            let started_at = row
                .try_get("started_at")
                .map_err(|err| DomainError::Infrastructure(format!("读取开始时间失败: {}", err)))?;
            let completed_at = row
                .try_get("completed_at")
                .map_err(|err| DomainError::Infrastructure(format!("读取完成时间失败: {}", err)))?;
            let assignment_ref_id = row
                .try_get::<Option<Uuid>, _>("assignment_id")
                .map_err(|err| DomainError::Infrastructure(format!("读取作业ID失败: {}", err)))?
                .ok_or_else(|| {
                    DomainError::Infrastructure("学生作业记录缺少对应的assignment_id".to_string())
                })?;
            let assignment_title = row
                .try_get::<Option<String>, _>("assignment_title")
                .map_err(|err| DomainError::Infrastructure(format!("读取作业标题失败: {}", err)))?;

            let snapshot = TeacherAssignmentStudentAssignmentSnapshot::new(
                student_assignment_id,
                assignment_ref_id,
                assignment_title,
                status,
                dialog_rounds,
                avg_thinking_time_ms,
                knowledge_mastery_score,
                thinking_depth_score,
                evaluation_metrics,
                started_at,
                completed_at,
            );

            assignments.push(snapshot);
        }

        let Some(profile) = profile else {
            return Ok(None);
        };

        Ok(Some(TeacherAssignmentStudentAssignments::new(
            profile,
            assignments,
        )))
    }
}
