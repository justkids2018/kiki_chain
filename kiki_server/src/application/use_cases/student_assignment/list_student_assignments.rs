//! 学生作业列表查询用例
//! 支持按照学生ID、作业ID、状态灵活过滤

use std::sync::Arc;

use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::domain::entities::StudentAssignmentStatus;
use crate::domain::errors::{DomainError, Result};
use crate::domain::StudentAssignmentRepository;
use crate::infrastructure::logging::Logger;

use super::StudentAssignmentView;

/// 学生作业查询参数
#[derive(Debug, Deserialize)]
pub struct ListStudentAssignmentsQuery {
    pub student_id: Option<String>,
    pub assignment_id: Option<String>,
    pub status: Option<String>,
}

/// 学生作业列表响应
#[derive(Debug, Serialize)]
pub struct ListStudentAssignmentsResponse {
    pub assignments: Vec<StudentAssignmentView>,
}

/// 学生作业列表查询用例
pub struct ListStudentAssignmentsUseCase {
    repository: Arc<dyn StudentAssignmentRepository>,
}

impl ListStudentAssignmentsUseCase {
    pub fn new(repository: Arc<dyn StudentAssignmentRepository>) -> Self {
        Self { repository }
    }

    /// 根据查询参数返回学生作业列表
    pub async fn execute(
        &self,
        query: ListStudentAssignmentsQuery,
    ) -> Result<ListStudentAssignmentsResponse> {
        Logger::info("📋 [学生作业] 开始查询学生作业列表");

        let assignment_uuid = match query.assignment_id {
            Some(ref id) => Some(
                Uuid::parse_str(id)
                    .map_err(|_| DomainError::Validation("assignment_id 格式不正确".to_string()))?,
            ),
            None => None,
        };

        let status_filter = match query.status.as_deref() {
            Some(value) => Some(
                value
                    .parse::<StudentAssignmentStatus>()
                    .map_err(|_| DomainError::Validation("状态过滤参数无效".to_string()))?,
            ),
            None => None,
        };

        let mut assignments = if let (Some(student_id), Some(assignment_id)) =
            (query.student_id.as_ref(), assignment_uuid)
        {
            Logger::info(format!(
                "  ├── 条件: 学生ID={}, 作业ID={}",
                student_id, assignment_id
            ));
            let mut result = Vec::new();
            if let Some(entity) = self
                .repository
                .find_by_assignment_and_student(&assignment_id, student_id)
                .await?
            {
                result.push(entity);
            }
            result
        } else if let Some(student_id) = query.student_id.as_ref() {
            Logger::info(format!("  ├── 条件: 学生ID={}", student_id));
            self.repository.find_by_student_id(student_id).await?
        } else if let Some(assignment_id) = assignment_uuid {
            Logger::info(format!("  ├── 条件: 作业ID={}", assignment_id));
            self.repository
                .find_by_assignment_id(&assignment_id)
                .await?
        } else {
            return Err(DomainError::Validation(
                "请至少提供 student_id 或 assignment_id 作为查询条件".to_string(),
            ));
        };

        if let Some(status) = status_filter {
            assignments.retain(|item| item.status() == &status);
        }

        let views = assignments
            .iter()
            .map(StudentAssignmentView::from)
            .collect::<Vec<_>>();

        Logger::info(format!("✅ [学生作业] 查询结果数量: {}", views.len()));

        Ok(ListStudentAssignmentsResponse { assignments: views })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;
    use std::collections::HashMap;
    use tokio::sync::Mutex;

    use crate::domain::entities::{StudentAssignment, StudentAssignmentStatus};
    use bigdecimal::BigDecimal;

    struct InMemoryStudentAssignmentRepository {
        store: Mutex<HashMap<Uuid, StudentAssignment>>,
    }

    impl InMemoryStudentAssignmentRepository {
        fn new() -> Self {
            Self {
                store: Mutex::new(HashMap::new()),
            }
        }

        async fn insert(&self, entity: StudentAssignment) {
            self.store.lock().await.insert(*entity.id(), entity);
        }
    }

    #[async_trait]
    impl StudentAssignmentRepository for InMemoryStudentAssignmentRepository {
        async fn save(&self, student_assignment: &StudentAssignment) -> Result<()> {
            self.insert(student_assignment.clone()).await;
            Ok(())
        }

        async fn find_by_id(&self, id: &Uuid) -> Result<Option<StudentAssignment>> {
            Ok(self.store.lock().await.get(id).cloned())
        }

        async fn find_by_assignment_and_student(
            &self,
            assignment_id: &Uuid,
            student_id: &str,
        ) -> Result<Option<StudentAssignment>> {
            let store = self.store.lock().await;
            Ok(store
                .values()
                .find(|item| {
                    item.assignment_id() == assignment_id && item.student_id() == student_id
                })
                .cloned())
        }

        async fn find_by_student_id(&self, student_id: &str) -> Result<Vec<StudentAssignment>> {
            let store = self.store.lock().await;
            Ok(store
                .values()
                .filter(|item| item.student_id() == student_id)
                .cloned()
                .collect())
        }

        async fn find_by_assignment_id(
            &self,
            assignment_id: &Uuid,
        ) -> Result<Vec<StudentAssignment>> {
            let store = self.store.lock().await;
            Ok(store
                .values()
                .filter(|item| item.assignment_id() == assignment_id)
                .cloned()
                .collect())
        }

        async fn delete(&self, id: &Uuid) -> Result<()> {
            self.store.lock().await.remove(id);
            Ok(())
        }
    }

    fn mock_student_assignment(
        assignment_id: Uuid,
        student_id: &str,
        status: StudentAssignmentStatus,
    ) -> StudentAssignment {
        StudentAssignment::reconstruct(
            Uuid::new_v4(),
            assignment_id,
            student_id.to_string(),
            status,
            0,
            0,
            BigDecimal::from(0),
            BigDecimal::from(0),
            StudentAssignment::default_evaluation_metrics(),
            None,
            None,
            None,
        )
    }

    #[tokio::test]
    async fn list_by_student_filters_status() {
        let repository = Arc::new(InMemoryStudentAssignmentRepository::new());
        let use_case = ListStudentAssignmentsUseCase::new(repository.clone());

        let assignment_a = Uuid::new_v4();
        let assignment_b = Uuid::new_v4();

        repository
            .insert(mock_student_assignment(
                assignment_a,
                "student-1",
                StudentAssignmentStatus::InProgress,
            ))
            .await;
        repository
            .insert(mock_student_assignment(
                assignment_b,
                "student-1",
                StudentAssignmentStatus::Completed,
            ))
            .await;

        let query = ListStudentAssignmentsQuery {
            student_id: Some("student-1".to_string()),
            assignment_id: None,
            status: Some("completed".to_string()),
        };

        let response = use_case.execute(query).await.unwrap();
        assert_eq!(response.assignments.len(), 1);
        assert_eq!(response.assignments[0].status, "completed");
    }
}
