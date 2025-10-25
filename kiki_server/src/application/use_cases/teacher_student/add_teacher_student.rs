// 添加师生关系用例
// 按照DDD用例模式封装学生绑定老师的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::{TeacherStudentRepository, UserRepository};
use crate::infrastructure::logging::Logger;

/// 添加师生关系命令
/// 封装创建师生关系所需的输入参数
#[derive(Debug, Deserialize)]
pub struct AddTeacherStudentCommand {
    pub student_id: String,
    pub teacher_id: String,
    pub set_default: bool,
}

/// 添加师生关系响应
/// 返回本次操作的执行结果
#[derive(Debug, Serialize)]
pub struct AddTeacherStudentResponse {
    pub message: String,
    pub teacher_id: String,
    pub student_id: String,
    pub is_default: bool,
}

/// 添加师生关系用例
/// 负责协调仓储完成业务流程：校验 → 建立关系 → 处理默认老师
pub struct AddTeacherStudentUseCase {
    teacher_student_repository: Arc<dyn TeacherStudentRepository>,
    user_repository: Arc<dyn UserRepository>,
}

impl AddTeacherStudentUseCase {
    /// 构建用例实例
    pub fn new(
        teacher_student_repository: Arc<dyn TeacherStudentRepository>,
        user_repository: Arc<dyn UserRepository>,
    ) -> Self {
        Self {
            teacher_student_repository,
            user_repository,
        }
    }

    /// 执行添加师生关系的主流程
    pub async fn execute(
        &self,
        command: AddTeacherStudentCommand,
    ) -> Result<AddTeacherStudentResponse> {
        Logger::info("🎓 [师生关系] 开始绑定老师");
        self.validate_command(&command)?;

        // 校验老师与学生是否存在
        self.ensure_teacher_exists(&command.teacher_id).await?;
        self.ensure_student_exists(&command.student_id).await?;

        let previous_default = self
            .teacher_student_repository
            .get_default_teacher(&command.student_id)
            .await?;

        // 校验关系是否已存在
        if self
            .teacher_student_repository
            .exists_relationship(&command.teacher_id, &command.student_id)
            .await?
        {
            Logger::warn("⚠️  [师生关系] 关系已存在，跳过重复绑定");

            let mut is_default = previous_default
                .as_ref()
                .map(|teacher_uid| teacher_uid == &command.teacher_id)
                .unwrap_or(false);

            if command.set_default && !is_default {
                Logger::info("⭐ [师生关系] 已有关系，更新默认老师");
                self.teacher_student_repository
                    .set_default_teacher(&command.student_id, &command.teacher_id)
                    .await?;
                is_default = true;
            }

            return Ok(AddTeacherStudentResponse {
                message: if is_default {
                    "老师已绑定且为默认老师".to_string()
                } else {
                    "老师已绑定".to_string()
                },
                teacher_id: command.teacher_id,
                student_id: command.student_id,
                is_default,
            });
        }

        // 记录之前的默认老师后创建新的师生关系
        self.teacher_student_repository
            .add_student(&command.teacher_id, &command.student_id)
            .await?;

        // 默认情况下 add_student 会将新老师设置为默认
        let mut is_default = true;

        if !command.set_default {
            if let Some(previous_default_teacher) = previous_default {
                if previous_default_teacher != command.teacher_id {
                    Logger::info("🔄 [师生关系] 恢复原默认老师");
                    self.teacher_student_repository
                        .set_default_teacher(&command.student_id, &previous_default_teacher)
                        .await?;
                    is_default = false;
                }
            }
        }

        Logger::info("✅ [师生关系] 老师绑定成功");

        Ok(AddTeacherStudentResponse {
            message: if is_default {
                "老师绑定成功并设为默认".to_string()
            } else {
                "老师绑定成功".to_string()
            },
            teacher_id: command.teacher_id,
            student_id: command.student_id,
            is_default,
        })
    }

    /// 校验命令参数
    fn validate_command(&self, command: &AddTeacherStudentCommand) -> Result<()> {
        if command.student_id.trim().is_empty() {
            return Err(DomainError::Validation("学生ID不能为空".to_string()));
        }
        if command.teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("老师ID不能为空".to_string()));
        }
        Ok(())
    }

    /// 确认老师存在
    async fn ensure_teacher_exists(&self, teacher_id: &str) -> Result<()> {
        match self.user_repository.find_by_uid(teacher_id).await? {
            Some(_) => Ok(()),
            None => Err(DomainError::NotFound("老师不存在".to_string())),
        }
    }

    /// 确认学生存在
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
                .find(|(_, sid, is_default)| sid == student_id && *is_default)
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

    fn fixture_user(uid: &str) -> User {
        User::new(
            uid.to_string(),
            format!("User-{}", uid),
            format!("{}@example.com", uid),
            "pwd".to_string(),
            format!("{}-phone", uid),
            2,
        )
        .unwrap()
    }

    fn setup_use_case() -> (
        AddTeacherStudentUseCase,
        Arc<InMemoryTeacherStudentRepository>,
    ) {
        let repo = Arc::new(InMemoryTeacherStudentRepository::new());
        let mut users = HashMap::new();
        users.insert("teacher_a".to_string(), fixture_user("teacher_a"));
        users.insert("teacher_b".to_string(), fixture_user("teacher_b"));
        users.insert("student_1".to_string(), fixture_user("student_1"));
        let user_repo = Arc::new(InMemoryUserRepository::new(users));
        let use_case = AddTeacherStudentUseCase::new(repo.clone(), user_repo);
        (use_case, repo)
    }

    #[tokio::test]
    async fn bind_teacher_sets_as_default_by_default() {
        let (use_case, _repo) = setup_use_case();

        let response = use_case
            .execute(AddTeacherStudentCommand {
                student_id: "student_1".to_string(),
                teacher_id: "teacher_a".to_string(),
                set_default: true,
            })
            .await
            .unwrap();

        assert!(response.is_default);
        assert_eq!(response.teacher_id, "teacher_a");
        assert_eq!(response.student_id, "student_1");
    }

    #[tokio::test]
    async fn bind_teacher_without_changing_default_restores_previous() {
        let (use_case, repo) = setup_use_case();
        repo.add_student("teacher_a", "student_1").await.unwrap();

        let response = use_case
            .execute(AddTeacherStudentCommand {
                student_id: "student_1".to_string(),
                teacher_id: "teacher_b".to_string(),
                set_default: false,
            })
            .await
            .unwrap();

        assert!(!response.is_default);
        let default_teacher = repo
            .get_default_teacher("student_1")
            .await
            .unwrap()
            .unwrap();
        assert_eq!(default_teacher, "teacher_a");
    }

    #[tokio::test]
    async fn duplicate_relationship_returns_success() {
        let (use_case, repo) = setup_use_case();
        repo.add_student("teacher_a", "student_1").await.unwrap();

        let response = use_case
            .execute(AddTeacherStudentCommand {
                student_id: "student_1".to_string(),
                teacher_id: "teacher_a".to_string(),
                set_default: false,
            })
            .await
            .unwrap();

        assert!(response.is_default);
        assert_eq!(response.message, "老师已绑定且为默认老师");
    }

    #[tokio::test]
    async fn duplicate_relationship_can_update_default() {
        let (use_case, repo) = setup_use_case();
        repo.add_student("teacher_a", "student_1").await.unwrap();
        repo.set_default_teacher("student_1", "teacher_a")
            .await
            .unwrap();

        // 添加第二位老师并设为默认
        repo.add_student("teacher_b", "student_1").await.unwrap();
        repo.set_default_teacher("student_1", "teacher_a")
            .await
            .unwrap();

        let response = use_case
            .execute(AddTeacherStudentCommand {
                student_id: "student_1".to_string(),
                teacher_id: "teacher_b".to_string(),
                set_default: true,
            })
            .await
            .unwrap();

        assert!(response.is_default);
        let default_teacher = repo
            .get_default_teacher("student_1")
            .await
            .unwrap()
            .unwrap();
        assert_eq!(default_teacher, "teacher_b");
    }
}
