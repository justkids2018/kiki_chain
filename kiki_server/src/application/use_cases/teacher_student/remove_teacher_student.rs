// 移除师生关系用例
// 处理学生解绑老师的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::TeacherStudentRepository;
use crate::infrastructure::logging::Logger;

/// 移除师生关系命令
#[derive(Debug, Deserialize)]
pub struct RemoveTeacherStudentCommand {
    pub student_id: String,
    pub teacher_id: String,
}

/// 移除师生关系响应
#[derive(Debug, Serialize)]
pub struct RemoveTeacherStudentResponse {
    pub message: String,
    pub student_id: String,
    pub teacher_id: String,
    pub was_default: bool,
}

/// 移除师生关系用例
pub struct RemoveTeacherStudentUseCase {
    teacher_student_repository: Arc<dyn TeacherStudentRepository>,
}

impl RemoveTeacherStudentUseCase {
    pub fn new(teacher_student_repository: Arc<dyn TeacherStudentRepository>) -> Self {
        Self {
            teacher_student_repository,
        }
    }

    pub async fn execute(
        &self,
        command: RemoveTeacherStudentCommand,
    ) -> Result<RemoveTeacherStudentResponse> {
        Logger::info("🗑️ [师生关系] 开始解绑老师");
        self.validate_command(&command)?;

        if !self
            .teacher_student_repository
            .exists_relationship(&command.teacher_id, &command.student_id)
            .await?
        {
            Logger::warn("⚠️  [师生关系] 待解绑的关系不存在");
            return Err(DomainError::NotFound("师生关系不存在".to_string()));
        }

        let current_default = self
            .teacher_student_repository
            .get_default_teacher(&command.student_id)
            .await?;
        let was_default = current_default
            .map(|teacher_id| teacher_id == command.teacher_id)
            .unwrap_or(false);

        self.teacher_student_repository
            .remove_student(&command.teacher_id, &command.student_id)
            .await?;

        Logger::info("✅ [师生关系] 老师解绑完成");

        Ok(RemoveTeacherStudentResponse {
            message: "师生关系解绑成功".to_string(),
            student_id: command.student_id,
            teacher_id: command.teacher_id,
            was_default,
        })
    }

    fn validate_command(&self, command: &RemoveTeacherStudentCommand) -> Result<()> {
        if command.student_id.trim().is_empty() {
            return Err(DomainError::Validation("学生ID不能为空".to_string()));
        }
        if command.teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("老师ID不能为空".to_string()));
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    use crate::domain::errors::DomainError;

    struct InMemoryTeacherStudentRepository {
        relationships: Mutex<Vec<(String, String, bool)>>,
    }

    impl InMemoryTeacherStudentRepository {
        fn new() -> Self {
            Self {
                relationships: Mutex::new(vec![]),
            }
        }
    }

    #[async_trait]
    impl TeacherStudentRepository for InMemoryTeacherStudentRepository {
        async fn add_student(&self, teacher_id: &str, student_id: &str) -> Result<()> {
            let mut guard = self.relationships.lock().await;
            for relation in guard.iter_mut() {
                if relation.1 == student_id {
                    relation.2 = false;
                }
            }
            guard.push((teacher_id.to_string(), student_id.to_string(), true));
            Ok(())
        }

        async fn exists_relationship(&self, teacher_id: &str, student_id: &str) -> Result<bool> {
            let guard = self.relationships.lock().await;
            Ok(guard
                .iter()
                .any(|(tid, sid, _)| tid == teacher_id && sid == student_id))
        }

        async fn set_default_teacher(&self, student_id: &str, teacher_id: &str) -> Result<()> {
            let mut guard = self.relationships.lock().await;
            for relation in guard.iter_mut() {
                if relation.1 == student_id {
                    relation.2 = relation.0 == teacher_id;
                }
            }
            Ok(())
        }

        async fn get_default_teacher(&self, student_id: &str) -> Result<Option<String>> {
            let guard = self.relationships.lock().await;
            Ok(guard
                .iter()
                .find(|(_tid, sid, is_default)| sid == student_id && *is_default)
                .map(|(tid, _, _)| tid.clone()))
        }

        async fn get_teachers_by_student(&self, student_id: &str) -> Result<Vec<String>> {
            let guard = self.relationships.lock().await;
            Ok(guard
                .iter()
                .filter(|(_, sid, _)| sid == student_id)
                .map(|(tid, _, _)| tid.clone())
                .collect())
        }

        async fn get_students_by_teacher(&self, teacher_id: &str) -> Result<Vec<String>> {
            let guard = self.relationships.lock().await;
            Ok(guard
                .iter()
                .filter(|(tid, _, _)| tid == teacher_id)
                .map(|(_, sid, _)| sid.clone())
                .collect())
        }

        async fn remove_student(&self, teacher_id: &str, student_id: &str) -> Result<()> {
            let mut guard = self.relationships.lock().await;
            let before = guard.len();
            guard.retain(|(tid, sid, _)| !(tid == teacher_id && sid == student_id));
            if guard.len() == before {
                return Err(DomainError::NotFound("关系不存在".to_string()));
            }
            Ok(())
        }
    }

    #[tokio::test]
    async fn remove_existing_relationship() {
        let repository = Arc::new(InMemoryTeacherStudentRepository::new());
        repository
            .add_student("teacher_a", "student_1")
            .await
            .unwrap();
        repository
            .set_default_teacher("student_1", "teacher_a")
            .await
            .unwrap();

        let use_case = RemoveTeacherStudentUseCase::new(repository.clone());
        let response = use_case
            .execute(RemoveTeacherStudentCommand {
                student_id: "student_1".to_string(),
                teacher_id: "teacher_a".to_string(),
            })
            .await
            .unwrap();

        assert!(response.was_default);
        assert!(!repository
            .exists_relationship("teacher_a", "student_1")
            .await
            .unwrap());
    }

    #[tokio::test]
    async fn removing_missing_relationship_returns_error() {
        let repository = Arc::new(InMemoryTeacherStudentRepository::new());
        let use_case = RemoveTeacherStudentUseCase::new(repository);

        let result = use_case
            .execute(RemoveTeacherStudentCommand {
                student_id: "student_1".to_string(),
                teacher_id: "teacher_a".to_string(),
            })
            .await;

        assert!(matches!(result, Err(DomainError::NotFound(_))));
    }
}
