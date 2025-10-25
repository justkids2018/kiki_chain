// PostgreSQL作业仓储实现
// 独立模块，按照SQL表结构实现数据库操作

use async_trait::async_trait;
use bigdecimal::BigDecimal;
use chrono::{DateTime, Utc};
use serde_json::Value;
use sqlx::{types::Json, PgPool, Row};
use uuid::Uuid;

use crate::domain::{
    entities::{Assignment, StudentAssignment},
    errors::Result,
    repositories::{AssignmentRepository, StudentAssignmentRepository},
};

/// PostgreSQL作业仓储实现
pub struct PostgresAssignmentRepository {
    pool: PgPool,
}

impl PostgresAssignmentRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl AssignmentRepository for PostgresAssignmentRepository {
    async fn save(&self, assignment: &Assignment) -> Result<()> {
        // 根据SQL表结构：id, teacher_id, title, description, knowledge_points, status, created_at, updated_at
        sqlx::query(
            r#"
            INSERT INTO assignments (id, teacher_id, title, description, knowledge_points, status, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            ON CONFLICT (id) DO UPDATE SET
                title = EXCLUDED.title,
                description = EXCLUDED.description,
                knowledge_points = EXCLUDED.knowledge_points,
                status = EXCLUDED.status,
                updated_at = EXCLUDED.updated_at
            "#
        )
        .bind(assignment.id())
        .bind(assignment.teacher_id())
        .bind(assignment.title())
        .bind(assignment.description())
        .bind(assignment.knowledge_points())
        .bind(assignment.status().to_string())
        .bind(assignment.created_at())
        .bind(assignment.updated_at())
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn find_by_id(&self, id: &Uuid) -> Result<Option<Assignment>> {
        let row = sqlx::query(
            "SELECT id, teacher_id, title, description, knowledge_points, status, created_at, updated_at \
             FROM assignments WHERE id = $1"
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await?;

        if let Some(row) = row {
            let description: Option<String> = row.get("description");
            let created_at: Option<DateTime<Utc>> = row.get("created_at");
            let updated_at: Option<DateTime<Utc>> = row.get("updated_at");
            let status: String = row.get("status");

            let assignment = Assignment::reconstruct(
                row.get("id"),
                row.get("teacher_id"),
                row.get("title"),
                description.unwrap_or_default(),
                row.get("knowledge_points"),
                status.parse().unwrap_or_default(),
                created_at.unwrap_or_else(Utc::now),
                updated_at.unwrap_or_else(Utc::now),
            );
            Ok(Some(assignment))
        } else {
            Ok(None)
        }
    }

    async fn find_by_teacher_id(&self, teacher_id: &str) -> Result<Vec<Assignment>> {
        let rows = sqlx::query(
            "SELECT id, teacher_id, title, description, knowledge_points, status, created_at, updated_at \
             FROM assignments WHERE teacher_id = $1 ORDER BY created_at DESC"
        )
        .bind(teacher_id)
        .fetch_all(&self.pool)
        .await?;

        let assignments = rows
            .into_iter()
            .map(|row| {
                let description: Option<String> = row.get("description");
                let created_at: Option<DateTime<Utc>> = row.get("created_at");
                let updated_at: Option<DateTime<Utc>> = row.get("updated_at");
                let status: String = row.get("status");

                Assignment::reconstruct(
                    row.get("id"),
                    row.get("teacher_id"),
                    row.get("title"),
                    description.unwrap_or_default(),
                    row.get("knowledge_points"),
                    status.parse().unwrap_or_default(),
                    created_at.unwrap_or_else(Utc::now),
                    updated_at.unwrap_or_else(Utc::now),
                )
            })
            .collect();

        Ok(assignments)
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM assignments WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

/// PostgreSQL学生作业仓储实现
pub struct PostgresStudentAssignmentRepository {
    pool: PgPool,
}

impl PostgresStudentAssignmentRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl StudentAssignmentRepository for PostgresStudentAssignmentRepository {
    async fn save(&self, student_assignment: &StudentAssignment) -> Result<()> {
        // 根据SQL表结构：id, assignment_id, student_id, status, dialog_rounds, avg_thinking_time_ms,
        // knowledge_mastery_score, thinking_depth_score, conversation_id, started_at, completed_at
        sqlx::query(
            r#"
            INSERT INTO student_assignments (
                id, assignment_id, student_id, status, dialog_rounds,
                avg_thinking_time_ms, knowledge_mastery_score, thinking_depth_score,
                evaluation_metrics, conversation_id, started_at, completed_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            ON CONFLICT (id) DO UPDATE SET
                status = EXCLUDED.status,
                dialog_rounds = EXCLUDED.dialog_rounds,
                avg_thinking_time_ms = EXCLUDED.avg_thinking_time_ms,
                knowledge_mastery_score = EXCLUDED.knowledge_mastery_score,
                thinking_depth_score = EXCLUDED.thinking_depth_score,
                evaluation_metrics = EXCLUDED.evaluation_metrics,
                conversation_id = EXCLUDED.conversation_id,
                started_at = EXCLUDED.started_at,
                completed_at = EXCLUDED.completed_at
            "#,
        )
        .bind(student_assignment.id())
        .bind(student_assignment.assignment_id())
        .bind(student_assignment.student_id())
        .bind(student_assignment.status().to_string())
        .bind(student_assignment.dialog_rounds())
        .bind(student_assignment.avg_thinking_time_ms())
        .bind(student_assignment.knowledge_mastery_score())
        .bind(student_assignment.thinking_depth_score())
        .bind(Json(student_assignment.evaluation_metrics().clone()))
        .bind(student_assignment.conversation_id().as_deref())
        .bind(student_assignment.started_at().as_ref())
        .bind(student_assignment.completed_at().as_ref())
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn find_by_id(&self, id: &Uuid) -> Result<Option<StudentAssignment>> {
        let row = sqlx::query(
            "SELECT id, assignment_id, student_id, status, dialog_rounds, avg_thinking_time_ms,
             knowledge_mastery_score, thinking_depth_score,
             evaluation_metrics, conversation_id, started_at, completed_at
             FROM student_assignments WHERE id = $1",
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await?;

        if let Some(row) = row {
            let status: String = row.get("status");
            let metrics: Json<Value> = row.get("evaluation_metrics");
            let student_assignment = StudentAssignment::reconstruct(
                row.get("id"),
                row.get("assignment_id"),
                row.get("student_id"),
                status.parse().unwrap_or_default(),
                row.get("dialog_rounds"),
                row.get::<Option<i64>, _>("avg_thinking_time_ms")
                    .unwrap_or(0),
                row.get::<Option<BigDecimal>, _>("knowledge_mastery_score")
                    .unwrap_or_else(|| BigDecimal::from(0)),
                row.get::<Option<BigDecimal>, _>("thinking_depth_score")
                    .unwrap_or_else(|| BigDecimal::from(0)),
                metrics.0,
                row.get::<Option<String>, _>("conversation_id"),
                row.get("started_at"),
                row.get("completed_at"),
            );
            Ok(Some(student_assignment))
        } else {
            Ok(None)
        }
    }

    async fn find_by_assignment_and_student(
        &self,
        assignment_id: &Uuid,
        student_id: &str,
    ) -> Result<Option<StudentAssignment>> {
        let row = sqlx::query(
            "SELECT id, assignment_id, student_id, status, dialog_rounds, avg_thinking_time_ms,
             knowledge_mastery_score, thinking_depth_score,
             evaluation_metrics, conversation_id, started_at, completed_at
             FROM student_assignments WHERE assignment_id = $1 AND student_id = $2",
        )
        .bind(assignment_id)
        .bind(student_id)
        .fetch_optional(&self.pool)
        .await?;

        if let Some(row) = row {
            let status: String = row.get("status");
            let metrics: Json<Value> = row.get("evaluation_metrics");
            let student_assignment = StudentAssignment::reconstruct(
                row.get("id"),
                row.get("assignment_id"),
                row.get("student_id"),
                status.parse().unwrap_or_default(),
                row.get("dialog_rounds"),
                row.get::<Option<i64>, _>("avg_thinking_time_ms")
                    .unwrap_or(0),
                row.get::<Option<BigDecimal>, _>("knowledge_mastery_score")
                    .unwrap_or_else(|| BigDecimal::from(0)),
                row.get::<Option<BigDecimal>, _>("thinking_depth_score")
                    .unwrap_or_else(|| BigDecimal::from(0)),
                metrics.0,
                row.get::<Option<String>, _>("conversation_id"),
                row.get("started_at"),
                row.get("completed_at"),
            );
            Ok(Some(student_assignment))
        } else {
            Ok(None)
        }
    }

    async fn find_by_student_id(&self, student_id: &str) -> Result<Vec<StudentAssignment>> {
        let rows = sqlx::query(
            "SELECT id, assignment_id, student_id, status, dialog_rounds, avg_thinking_time_ms,
             knowledge_mastery_score, thinking_depth_score,
             evaluation_metrics, conversation_id, started_at, completed_at
             FROM student_assignments WHERE student_id = $1 ORDER BY started_at DESC",
        )
        .bind(student_id)
        .fetch_all(&self.pool)
        .await?;

        let student_assignments = rows
            .into_iter()
            .map(|row| {
                let status: String = row.get("status");
                let metrics: Json<Value> = row.get("evaluation_metrics");
                StudentAssignment::reconstruct(
                    row.get("id"),
                    row.get("assignment_id"),
                    row.get("student_id"),
                    status.parse().unwrap_or_default(),
                    row.get("dialog_rounds"),
                    row.get::<Option<i64>, _>("avg_thinking_time_ms")
                        .unwrap_or(0),
                    row.get::<Option<BigDecimal>, _>("knowledge_mastery_score")
                        .unwrap_or_else(|| BigDecimal::from(0)),
                    row.get::<Option<BigDecimal>, _>("thinking_depth_score")
                        .unwrap_or_else(|| BigDecimal::from(0)),
                    metrics.0,
                    row.get::<Option<String>, _>("conversation_id"),
                    row.get("started_at"),
                    row.get("completed_at"),
                )
            })
            .collect();

        Ok(student_assignments)
    }

    async fn find_by_assignment_id(&self, assignment_id: &Uuid) -> Result<Vec<StudentAssignment>> {
        let rows = sqlx::query(
            "SELECT id, assignment_id, student_id, status, dialog_rounds, avg_thinking_time_ms,
             knowledge_mastery_score, thinking_depth_score,
             evaluation_metrics, conversation_id, started_at, completed_at
             FROM student_assignments WHERE assignment_id = $1 ORDER BY started_at DESC",
        )
        .bind(assignment_id)
        .fetch_all(&self.pool)
        .await?;

        let student_assignments = rows
            .into_iter()
            .map(|row| {
                let status: String = row.get("status");
                let metrics: Json<Value> = row.get("evaluation_metrics");
                StudentAssignment::reconstruct(
                    row.get("id"),
                    row.get("assignment_id"),
                    row.get("student_id"),
                    status.parse().unwrap_or_default(),
                    row.get("dialog_rounds"),
                    row.get::<Option<i64>, _>("avg_thinking_time_ms")
                        .unwrap_or(0),
                    row.get::<Option<BigDecimal>, _>("knowledge_mastery_score")
                        .unwrap_or_else(|| BigDecimal::from(0)),
                    row.get::<Option<BigDecimal>, _>("thinking_depth_score")
                        .unwrap_or_else(|| BigDecimal::from(0)),
                    metrics.0,
                    row.get::<Option<String>, _>("conversation_id"),
                    row.get("started_at"),
                    row.get("completed_at"),
                )
            })
            .collect();

        Ok(student_assignments)
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM student_assignments WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}
