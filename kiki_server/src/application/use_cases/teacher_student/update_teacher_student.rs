// 更新师生关系用例
// 支持变更学生绑定老师的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::{TeacherStudentRepository, UserRepository};
use crate::infrastructure::logging::Logger;

/// 更新师生关系命令
#[derive(Debug, Deserialize)]
pub struct UpdateTeacherStudentCommand {
    pub student_id: String,
    pub current_teacher_id: String,
    pub new_teacher_id: String,
    pub set_default: bool,
}

/// 更新师生关系响应
#[derive(Debug, Serialize)]
pub struct UpdateTeacherStudentResponse {
    pub message: String,
    pub student_id: String,
    pub previous_teacher_id: String,
    pub new_teacher_id: String,
    pub is_default: bool,
}

/// 更新师生关系用例
/// 流程：参数校验 → 校验关系存在 → 移除旧关系 → 建立新关系 → 处理默认老师
pub struct UpdateTeacherStudentUseCase {
    teacher_student_repository: Arc<dyn TeacherStudentRepository>,
    user_repository: Arc<dyn UserRepository>,
}

impl UpdateTeacherStudentUseCase {
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
        command: UpdateTeacherStudentCommand,
    ) -> Result<UpdateTeacherStudentResponse> {
        Logger::info("🔄 [师生关系] 开始更新老师绑定");
        self.validate_command(&command)?;

        // 确认目标老师、学生存在
        self.ensure_teacher_exists(&command.new_teacher_id).await?;
        self.ensure_student_exists(&command.student_id).await?;

        // 校验旧关系是否存在
        if !self
            .teacher_student_repository
            .exists_relationship(&command.current_teacher_id, &command.student_id)
            .await?
        {
            Logger::warn("⚠️  [师生关系] 待更新的关系不存在");
            return Err(DomainError::NotFound("原师生关系不存在".to_string()));
        }

        // 记录更新前是否为默认老师
        let current_default = self
            .teacher_student_repository
            .get_default_teacher(&command.student_id)
            .await?;
        let was_default = current_default
            .map(|default_teacher| default_teacher == command.current_teacher_id)
            .unwrap_or(false);

        // 移除旧关系
        self.teacher_student_repository
            .remove_student(&command.current_teacher_id, &command.student_id)
            .await?;

        // 添加新关系，避免重复添加导致冲突
        if !self
            .teacher_student_repository
            .exists_relationship(&command.new_teacher_id, &command.student_id)
            .await?
        {
            self.teacher_student_repository
                .add_student(&command.new_teacher_id, &command.student_id)
                .await?;
        }

        let should_set_default = command.set_default || was_default;
        if should_set_default {
            Logger::info("⭐ [师生关系] 更新默认老师");
            self.teacher_student_repository
                .set_default_teacher(&command.student_id, &command.new_teacher_id)
                .await?;
        }

        Logger::info("✅ [师生关系] 老师更新成功");

        Ok(UpdateTeacherStudentResponse {
            message: "师生关系更新成功".to_string(),
            student_id: command.student_id,
            previous_teacher_id: command.current_teacher_id,
            new_teacher_id: command.new_teacher_id,
            is_default: should_set_default,
        })
    }

    fn validate_command(&self, command: &UpdateTeacherStudentCommand) -> Result<()> {
        if command.student_id.trim().is_empty() {
            return Err(DomainError::Validation("学生ID不能为空".to_string()));
        }
        if command.current_teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("当前老师ID不能为空".to_string()));
        }
        if command.new_teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("新的老师ID不能为空".to_string()));
        }
        if command.current_teacher_id == command.new_teacher_id {
            return Err(DomainError::Validation(
                "新的老师ID不能与当前老师相同".to_string(),
            ));
        }
        Ok(())
    }

    async fn ensure_teacher_exists(&self, teacher_id: &str) -> Result<()> {
        match self.user_repository.find_by_uid(teacher_id).await? {
            Some(_) => Ok(()),
            None => Err(DomainError::NotFound("老师不存在".to_string())),
        }
    }

    async fn ensure_student_exists(&self, student_id: &str) -> Result<()> {
        match self.user_repository.find_by_uid(student_id).await? {
            Some(_) => Ok(()),
            None => Err(DomainError::NotFound("学生不存在".to_string())),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;
    use std::collections::HashMap;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    use crate::domain::entities::User;
    use crate::domain::value_objects::UserId;

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
                .any(|(t, s, _)| t == teacher_id && s == student_id))
        }

        async fn set_default_teacher(&self, student_id: &str, teacher_id: &str) -> Result<()> {
            let mut guard = self.relationships.lock().await;
            for relationship in guard.iter_mut() {
                if relationship.1 == student_id {
                    relationship.2 = relationship.0 == teacher_id;
                }
            }
            Ok(())
        }

        async fn get_default_teacher(&self, student_id: &str) -> Result<Option<String>> {
            let guard = self.relationships.lock().await;
            Ok(guard
                .iter()
                .find(|(_teacher_id, sid, is_default)| sid == student_id && *is_default)
                .map(|(teacher_id, _, _)| teacher_id.clone()))
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
            guard.retain(|(tid, sid, _)| !(tid == teacher_id && sid == student_id));
            Ok(())
        }
    }

    struct InMemoryUserRepository {
        users: HashMap<String, User>,
    }

    impl InMemoryUserRepository {
        fn new(users: HashMap<String, User>) -> Self {
            Self { users }
        }
    }

    #[async_trait]
    impl UserRepository for InMemoryUserRepository {
        async fn save(&self, _user: &User) -> Result<()> {
            Ok(())
        }

        async fn find_by_id(&self, _id: &UserId) -> Result<Option<User>> {
            Ok(None)
        }

        async fn find_by_uid(&self, uid: &str) -> Result<Option<User>> {
            Ok(self.users.get(uid).cloned())
        }

        async fn find_by_phone_and_pwd(
            &self,
            _identifier: &str,
            _pwd: &str,
        ) -> Result<Option<User>> {
            Ok(None)
        }

        async fn find_by_phone(&self, _phone: &str) -> Result<Option<User>> {
            Ok(None)
        }

        async fn find_users_by_role(&self, _role_id: i32) -> Result<Vec<User>> {
            Ok(vec![])
        }
    }

    fn fixture_user(uid: &str, role_id: i32) -> User {
        User::new(
            uid.to_string(),
            format!("User-{}", uid),
            format!("{}@example.com", uid),
            "pwd".to_string(),
            format!("{}-phone", uid),
            role_id,
        )
        .unwrap()
    }

    #[tokio::test]
    async fn update_relationship_and_keep_default() {
        let repository = Arc::new(InMemoryTeacherStudentRepository::new());
        let mut users = HashMap::new();
        users.insert("teacher_a".to_string(), fixture_user("teacher_a", 2));
        users.insert("teacher_b".to_string(), fixture_user("teacher_b", 2));
        users.insert("student_1".to_string(), fixture_user("student_1", 3));
        let user_repository = Arc::new(InMemoryUserRepository::new(users));

        repository
            .add_student("teacher_a", "student_1")
            .await
            .unwrap();
        repository
            .set_default_teacher("student_1", "teacher_a")
            .await
            .unwrap();

        let use_case = UpdateTeacherStudentUseCase::new(repository.clone(), user_repository);
        let response = use_case
            .execute(UpdateTeacherStudentCommand {
                student_id: "student_1".to_string(),
                current_teacher_id: "teacher_a".to_string(),
                new_teacher_id: "teacher_b".to_string(),
                set_default: false,
            })
            .await
            .unwrap();

        assert_eq!(response.student_id, "student_1");
        assert_eq!(response.previous_teacher_id, "teacher_a");
        assert_eq!(response.new_teacher_id, "teacher_b");
        assert!(response.is_default);
    }

    #[tokio::test]
    async fn forbid_update_if_relationship_missing() {
        let repository = Arc::new(InMemoryTeacherStudentRepository::new());
        let mut users = HashMap::new();
        users.insert("teacher_b".to_string(), fixture_user("teacher_b", 2));
        users.insert("student_1".to_string(), fixture_user("student_1", 3));
        let user_repository = Arc::new(InMemoryUserRepository::new(users));

        let use_case = UpdateTeacherStudentUseCase::new(repository, user_repository);
        let result = use_case
            .execute(UpdateTeacherStudentCommand {
                student_id: "student_1".to_string(),
                current_teacher_id: "teacher_a".to_string(),
                new_teacher_id: "teacher_b".to_string(),
                set_default: false,
            })
            .await;

        assert!(matches!(result, Err(DomainError::NotFound(_))));
    }
}
