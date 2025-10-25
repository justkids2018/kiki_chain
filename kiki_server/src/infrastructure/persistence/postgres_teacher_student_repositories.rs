// PostgreSQL师生关系仓储实现
// 独立模块，实现师生关系相关的数据库操作

use async_trait::async_trait;
use sqlx::{PgPool, Row};

use crate::domain::{
    errors::{DomainError, Result},
    repositories::TeacherStudentRepository,
};

/// PostgreSQL师生关系仓储实现
pub struct PostgresTeacherStudentRepository {
    pool: PgPool,
}

impl PostgresTeacherStudentRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl TeacherStudentRepository for PostgresTeacherStudentRepository {
    async fn add_student(&self, teacher_id: &str, student_id: &str) -> Result<()> {
        // 清除现有默认老师，确保唯一默认
        sqlx::query("UPDATE teacher_students SET is_default = FALSE WHERE student_id = $1")
            .bind(student_id)
            .execute(&self.pool)
            .await?;

        sqlx::query(
            r#"
            INSERT INTO teacher_students (teacher_id, student_id, created_at, is_default)
            VALUES ($1, $2, NOW(), TRUE)
            ON CONFLICT (teacher_id, student_id) DO NOTHING
            "#,
        )
        .bind(teacher_id)
        .bind(student_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn exists_relationship(&self, teacher_id: &str, student_id: &str) -> Result<bool> {
        let row = sqlx::query(
            "SELECT COUNT(*) AS cnt FROM teacher_students WHERE teacher_id = $1 AND student_id = $2"
        )
        .bind(teacher_id)
        .bind(student_id)
        .fetch_one(&self.pool)
        .await?;

        let count: i64 = row.get::<i64, _>("cnt");
        Ok(count > 0)
    }

    async fn set_default_teacher(&self, student_id: &str, teacher_id: &str) -> Result<()> {
        // 先清除该学生的其他默认老师
        sqlx::query("UPDATE teacher_students SET is_default = FALSE WHERE student_id = $1")
            .bind(student_id)
            .execute(&self.pool)
            .await?;

        // 设置新的默认老师
        sqlx::query(
            "UPDATE teacher_students SET is_default = TRUE WHERE teacher_id = $1 AND student_id = $2"
        )
        .bind(teacher_id)
        .bind(student_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn get_default_teacher(&self, student_id: &str) -> Result<Option<String>> {
        let row = sqlx::query(
            "SELECT teacher_id FROM teacher_students WHERE student_id = $1 AND is_default = TRUE",
        )
        .bind(student_id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(row.map(|r| r.get::<String, _>("teacher_id")))
    }

    async fn get_teachers_by_student(&self, student_id: &str) -> Result<Vec<String>> {
        let rows = sqlx::query(
            "SELECT teacher_id FROM teacher_students WHERE student_id = $1 ORDER BY created_at DESC"
        )
        .bind(student_id)
        .fetch_all(&self.pool)
        .await?;

        Ok(rows
            .into_iter()
            .map(|row| row.get::<String, _>("teacher_id"))
            .collect())
    }

    async fn get_students_by_teacher(&self, teacher_id: &str) -> Result<Vec<String>> {
        let rows = sqlx::query(
            "SELECT student_id FROM teacher_students WHERE teacher_id = $1 ORDER BY created_at DESC"
        )
        .bind(teacher_id)
        .fetch_all(&self.pool)
        .await?;

        Ok(rows
            .into_iter()
            .map(|row| row.get::<String, _>("student_id"))
            .collect())
    }

    async fn remove_student(&self, teacher_id: &str, student_id: &str) -> Result<()> {
        let result =
            sqlx::query("DELETE FROM teacher_students WHERE teacher_id = $1 AND student_id = $2")
                .bind(teacher_id)
                .bind(student_id)
                .execute(&self.pool)
                .await?;

        if result.rows_affected() == 0 {
            return Err(DomainError::NotFound("待移除的师生关系不存在".to_string()));
        }

        Ok(())
    }
}
