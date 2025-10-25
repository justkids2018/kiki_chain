//! 学生查看个人作业用例
//! 复用老师视角的聚合结构，为学生提供作业明细查询

use serde::{Deserialize, Serialize};

use crate::domain::errors::{DomainError, Result};
use crate::domain::teacher_assignment::TeacherAssignmentQueryRepositoryArc;
use crate::infrastructure::logging::Logger;

use super::TeacherAssignmentStudentAssignmentsView;

/// 学生作业查询参数
#[derive(Debug, Deserialize)]
pub struct GetStudentAssignmentsQuery {
    pub student_uid: String,
}

/// 学生作业查询结果
#[derive(Debug, Serialize)]
pub struct GetStudentAssignmentsResponse {
    pub student: TeacherAssignmentStudentAssignmentsView,
}

/// 学生作业查询用例
pub struct GetStudentAssignmentsUseCase {
    repository: TeacherAssignmentQueryRepositoryArc,
}

impl GetStudentAssignmentsUseCase {
    pub fn new(repository: TeacherAssignmentQueryRepositoryArc) -> Self {
        Self { repository }
    }

    /// 执行查询
    pub async fn execute(
        &self,
        query: GetStudentAssignmentsQuery,
    ) -> Result<GetStudentAssignmentsResponse> {
        Logger::info("🧑‍🎓 [学生作业] 开始查询学生个人作业信息");
        self.validate(&query)?;

        let Some(aggregate) = self
            .repository
            .find_student_assignments_by_student(&query.student_uid)
            .await?
        else {
            return Err(DomainError::NotFound("学生信息不存在".to_string()));
        };

        Logger::info(format!(
            "✅ [学生作业] 查询完成 - 学生: {}, 作业数量: {}",
            query.student_uid,
            aggregate.assignments().len()
        ));

        Ok(GetStudentAssignmentsResponse {
            student: TeacherAssignmentStudentAssignmentsView::from(&aggregate),
        })
    }

    fn validate(&self, query: &GetStudentAssignmentsQuery) -> Result<()> {
        if query.student_uid.trim().is_empty() {
            return Err(DomainError::Validation("student_uid 不能为空".to_string()));
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;
    use bigdecimal::BigDecimal;
    use chrono::{TimeZone, Utc};
    use serde_json::json;
    use std::collections::HashMap;
    use std::sync::Arc;
    use tokio::sync::Mutex;
    use uuid::Uuid;

    use crate::domain::entities::StudentAssignmentStatus;
    use crate::domain::errors::Result as DomainResult;
    use crate::domain::teacher_assignment::{
        TeacherAssignmentQueryRepository, TeacherAssignmentStudentAssignmentSnapshot,
        TeacherAssignmentStudentAssignments, TeacherAssignmentStudentProfile,
    };

    struct InMemoryTeacherAssignmentRepository {
        store: Mutex<HashMap<String, TeacherAssignmentStudentAssignments>>,
    }

    impl InMemoryTeacherAssignmentRepository {
        fn new() -> Self {
            Self {
                store: Mutex::new(HashMap::new()),
            }
        }

        async fn insert(&self, record: TeacherAssignmentStudentAssignments) {
            self.store
                .lock()
                .await
                .insert(record.student().uid().to_string(), record);
        }
    }

    #[async_trait]
    impl TeacherAssignmentQueryRepository for InMemoryTeacherAssignmentRepository {
        async fn find_student_assignments_by_teacher(
            &self,
            _teacher_uid: &str,
        ) -> DomainResult<Vec<TeacherAssignmentStudentAssignments>> {
            Ok(self.store.lock().await.values().cloned().collect())
        }

        async fn find_student_assignments_by_student(
            &self,
            student_uid: &str,
        ) -> DomainResult<Option<TeacherAssignmentStudentAssignments>> {
            Ok(self.store.lock().await.get(student_uid).cloned())
        }
    }

    #[tokio::test]
    async fn execute_returns_student_assignments() {
        let repository = Arc::new(InMemoryTeacherAssignmentRepository::new());
        let use_case = GetStudentAssignmentsUseCase::new(repository.clone());

        let student_profile =
            TeacherAssignmentStudentProfile::new("student-1", "张三", "18800000000", 3);
        let assignment_snapshot = TeacherAssignmentStudentAssignmentSnapshot::new(
            Uuid::new_v4(),
            Uuid::new_v4(),
            Some("数学思维练习".to_string()),
            StudentAssignmentStatus::Completed,
            5,
            1200,
            BigDecimal::from(95),
            BigDecimal::from(88),
            json!({
                "three_student_rate": 0.9,
                "three_proposition_quality": 0.8,
                "two_student_chain": 0.7,
                "two_cover_rate": 0.6
            }),
            Some(Utc.with_ymd_and_hms(2024, 9, 1, 8, 0, 0).unwrap()),
            Some(Utc.with_ymd_and_hms(2024, 9, 1, 9, 0, 0).unwrap()),
        );

        repository
            .insert(TeacherAssignmentStudentAssignments::new(
                student_profile,
                vec![assignment_snapshot],
            ))
            .await;

        let response = use_case
            .execute(GetStudentAssignmentsQuery {
                student_uid: "student-1".to_string(),
            })
            .await
            .unwrap();

        assert_eq!(response.student.student.uid, "student-1");
        assert_eq!(response.student.assignments.len(), 1);
        assert_eq!(response.student.assignments[0].status, "completed");
    }

    #[tokio::test]
    async fn execute_returns_not_found_when_student_missing() {
        let repository = Arc::new(InMemoryTeacherAssignmentRepository::new());
        let use_case = GetStudentAssignmentsUseCase::new(repository);

        let result = use_case
            .execute(GetStudentAssignmentsQuery {
                student_uid: "missing".to_string(),
            })
            .await;

        assert!(matches!(result, Err(DomainError::NotFound(_))));
    }

    #[tokio::test]
    async fn validate_rejects_empty_student_uid() {
        let repository = Arc::new(InMemoryTeacherAssignmentRepository::new());
        let use_case = GetStudentAssignmentsUseCase::new(repository);

        let result = use_case
            .execute(GetStudentAssignmentsQuery {
                student_uid: "  ".to_string(),
            })
            .await;

        assert!(matches!(result, Err(DomainError::Validation(_))));
    }
}
