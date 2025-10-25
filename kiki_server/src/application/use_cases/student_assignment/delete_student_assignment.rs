//! 删除学生作业用例
//! 负责根据ID删除学生作业记录

use std::sync::Arc;

use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::domain::errors::{DomainError, Result};
use crate::domain::StudentAssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 删除学生作业命令
#[derive(Debug, Deserialize)]
pub struct DeleteStudentAssignmentCommand {
    pub id: String,
}

/// 删除学生作业响应
#[derive(Debug, Serialize)]
pub struct DeleteStudentAssignmentResponse {
    pub id: String,
    pub message: String,
}

/// 删除学生作业用例
pub struct DeleteStudentAssignmentUseCase {
    repository: Arc<dyn StudentAssignmentRepository>,
}

impl DeleteStudentAssignmentUseCase {
    pub fn new(repository: Arc<dyn StudentAssignmentRepository>) -> Self {
        Self { repository }
    }

    /// 执行删除流程
    pub async fn execute(
        &self,
        command: DeleteStudentAssignmentCommand,
    ) -> Result<DeleteStudentAssignmentResponse> {
        let id = Uuid::parse_str(&command.id)
            .map_err(|_| DomainError::Validation("学生作业ID格式不正确".to_string()))?;

        Logger::info(format!("🗑️ [学生作业] 删除学生作业 - ID: {}", id));

        if self.repository.find_by_id(&id).await?.is_none() {
            return Err(DomainError::NotFound("学生作业记录不存在".to_string()));
        }

        self.repository.delete(&id).await?;

        Logger::info(format!("✅ [学生作业] 删除成功 - ID: {}", id));

        Ok(DeleteStudentAssignmentResponse {
            id: id.to_string(),
            message: "学生作业删除成功".to_string(),
        })
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

    #[tokio::test]
    async fn delete_existing_assignment() {
        let repository = Arc::new(InMemoryStudentAssignmentRepository::new());
        let use_case = DeleteStudentAssignmentUseCase::new(repository.clone());

        let entity = StudentAssignment::reconstruct(
            Uuid::new_v4(),
            Uuid::new_v4(),
            "student-1".to_string(),
            StudentAssignmentStatus::NotStarted,
            0,
            0,
            BigDecimal::from(0),
            BigDecimal::from(0),
            StudentAssignment::default_evaluation_metrics(),
            None,
            None,
            None,
        );
        let id = entity.id().to_string();
        repository.insert(entity).await;

        let response = use_case
            .execute(DeleteStudentAssignmentCommand { id: id.clone() })
            .await
            .unwrap();
        assert_eq!(response.id, id);
    }
}
