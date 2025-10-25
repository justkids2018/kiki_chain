// 师生关系查询用例
// 支持按照老师UID、学生UID或两者组合查询当前绑定关系

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::entities::User;
use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::{TeacherStudentRepository, UserRepository};
use crate::infrastructure::logging::Logger;

/// 师生关系查询参数
#[derive(Debug, Deserialize)]
pub struct QueryTeacherStudentRelationshipsQuery {
    pub teacher_uid: Option<String>,
    pub student_uid: Option<String>,
}

/// 师生关系列表项
#[derive(Debug, Serialize, Clone)]
pub struct TeacherStudentRelationshipItem {
    pub teacher_id: String,
    pub teacher_uid: String,
    pub teacher_name: String,
    pub teacher_email: String,
    pub teacher_phone: String,
    pub student_id: String,
    pub student_uid: String,
    pub student_name: String,
    pub student_email: String,
    pub student_phone: String,
    pub is_default: bool,
}

/// 师生关系查询响应
#[derive(Debug, Serialize)]
pub struct QueryTeacherStudentRelationshipsResponse {
    pub total: usize,
    pub relationships: Vec<TeacherStudentRelationshipItem>,
}

/// 师生关系查询用例
pub struct QueryTeacherStudentRelationshipsUseCase {
    teacher_student_repository: Arc<dyn TeacherStudentRepository>,
    user_repository: Arc<dyn UserRepository>,
}

impl QueryTeacherStudentRelationshipsUseCase {
    pub fn new(
        teacher_student_repository: Arc<dyn TeacherStudentRepository>,
        user_repository: Arc<dyn UserRepository>,
    ) -> Self {
        Self {
            teacher_student_repository,
            user_repository,
        }
    }

    pub async fn execute(
        &self,
        query: QueryTeacherStudentRelationshipsQuery,
    ) -> Result<QueryTeacherStudentRelationshipsResponse> {
        Logger::info("📋 [师生关系] 执行关系查询");
        self.validate_query(&query)?;

        let mut relationships = Vec::new();

        match (&query.teacher_uid, &query.student_uid) {
            (Some(teacher_uid), Some(student_uid)) => {
                relationships.extend(self.query_by_both(teacher_uid, student_uid).await?);
            }
            (Some(teacher_uid), None) => {
                relationships.extend(self.query_by_teacher(teacher_uid).await?);
            }
            (None, Some(student_uid)) => {
                relationships.extend(self.query_by_student(student_uid).await?);
            }
            (None, None) => unreachable!("已在 validate_query 中保证至少一个条件存在"),
        }

        Logger::info(&format!(
            "✅ [师生关系] 查询完成 - 共{}条记录",
            relationships.len()
        ));

        Ok(QueryTeacherStudentRelationshipsResponse {
            total: relationships.len(),
            relationships,
        })
    }

    fn validate_query(&self, query: &QueryTeacherStudentRelationshipsQuery) -> Result<()> {
        if query.teacher_uid.is_none() && query.student_uid.is_none() {
            return Err(DomainError::Validation(
                "查询条件至少需要提供teacher_uid或student_uid".to_string(),
            ));
        }
        Ok(())
    }

    async fn query_by_student(
        &self,
        student_uid: &str,
    ) -> Result<Vec<TeacherStudentRelationshipItem>> {
        let student = self
            .get_user_or_not_found(student_uid, "学生不存在")
            .await?;
        let teacher_uids = self
            .teacher_student_repository
            .get_teachers_by_student(student_uid)
            .await?;
        let default_teacher = self
            .teacher_student_repository
            .get_default_teacher(student_uid)
            .await?;

        let mut relationships = Vec::with_capacity(teacher_uids.len());
        for teacher_uid in teacher_uids {
            let teacher = self
                .get_user_or_not_found(&teacher_uid, "老师不存在")
                .await?;
            relationships.push(Self::build_relationship_item(
                &teacher,
                &student,
                default_teacher
                    .as_ref()
                    .map(|default| default == teacher.uid())
                    .unwrap_or(false),
            ));
        }

        Ok(relationships)
    }

    async fn query_by_teacher(
        &self,
        teacher_uid: &str,
    ) -> Result<Vec<TeacherStudentRelationshipItem>> {
        let teacher = self
            .get_user_or_not_found(teacher_uid, "老师不存在")
            .await?;
        let student_uids = self
            .teacher_student_repository
            .get_students_by_teacher(teacher_uid)
            .await?;

        let mut relationships = Vec::with_capacity(student_uids.len());
        for student_uid in student_uids {
            let student = self
                .get_user_or_not_found(&student_uid, "学生不存在")
                .await?;
            let default_teacher = self
                .teacher_student_repository
                .get_default_teacher(student.uid())
                .await?;
            let is_default = default_teacher
                .map(|default| default == teacher.uid())
                .unwrap_or(false);
            relationships.push(Self::build_relationship_item(
                &teacher, &student, is_default,
            ));
        }

        Ok(relationships)
    }

    async fn query_by_both(
        &self,
        teacher_uid: &str,
        student_uid: &str,
    ) -> Result<Vec<TeacherStudentRelationshipItem>> {
        // 先确保双方存在
        let teacher = self
            .get_user_or_not_found(teacher_uid, "老师不存在")
            .await?;
        let student = self
            .get_user_or_not_found(student_uid, "学生不存在")
            .await?;

        // 再确认关系是否存在
        let exists = self
            .teacher_student_repository
            .exists_relationship(teacher_uid, student_uid)
            .await?;

        if !exists {
            return Ok(vec![]);
        }

        let default_teacher = self
            .teacher_student_repository
            .get_default_teacher(student_uid)
            .await?;
        let is_default = default_teacher
            .map(|default| default == teacher.uid())
            .unwrap_or(false);

        Ok(vec![Self::build_relationship_item(
            &teacher, &student, is_default,
        )])
    }

    async fn get_user_or_not_found(&self, uid: &str, not_found_msg: &str) -> Result<User> {
        self.user_repository
            .find_by_uid(uid)
            .await?
            .ok_or_else(|| DomainError::NotFound(not_found_msg.to_string()))
    }

    fn build_relationship_item(
        teacher: &User,
        student: &User,
        is_default: bool,
    ) -> TeacherStudentRelationshipItem {
        TeacherStudentRelationshipItem {
            teacher_id: teacher.id().to_string(),
            teacher_uid: teacher.uid().to_string(),
            teacher_name: teacher.name().to_string(),
            teacher_email: teacher.email().to_string(),
            teacher_phone: teacher.phone().to_string(),
            student_id: student.id().to_string(),
            student_uid: student.uid().to_string(),
            student_name: student.name().to_string(),
            student_email: student.email().to_string(),
            student_phone: student.phone().to_string(),
            is_default,
        }
    }
}
