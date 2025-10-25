// 设置默认老师用例
// 处理学生设置默认老师的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::TeacherStudentRepository;
use crate::infrastructure::logging::Logger;

/// 设置默认老师命令
#[derive(Debug, Deserialize)]
pub struct SetDefaultTeacherCommand {
    pub student_id: String,
    pub teacher_id: String,
}

/// 设置默认老师响应
#[derive(Debug, Serialize)]
pub struct SetDefaultTeacherResponse {
    pub message: String,
    pub teacher_id: String,
}

/// 设置默认老师用例
/// 处理学生设置默认老师的完整业务流程
pub struct SetDefaultTeacherUseCase {
    teacher_student_repository: Arc<dyn TeacherStudentRepository>,
}

impl SetDefaultTeacherUseCase {
    pub fn new(teacher_student_repository: Arc<dyn TeacherStudentRepository>) -> Self {
        Self {
            teacher_student_repository,
        }
    }

    /// 执行设置默认老师
    pub async fn execute(
        &self,
        command: SetDefaultTeacherCommand,
    ) -> Result<SetDefaultTeacherResponse> {
        // 1. 验证输入数据
        self.validate_command(&command)?;

        Logger::info(&format!(
            "设置默认老师开始 - 学生ID: {}, 老师ID: {}",
            command.student_id, command.teacher_id
        ));

        // 2. 验证师生关系是否存在
        let exists = self
            .teacher_student_repository
            .exists_relationship(&command.teacher_id, &command.student_id)
            .await?;

        if !exists {
            // 如果关系不存在，先创建师生关系
            self.teacher_student_repository
                .add_student(&command.teacher_id, &command.student_id)
                .await?;

            Logger::info("师生关系创建成功");
        }

        // 3. 设置为默认老师（这会自动取消其他老师的默认状态）
        self.teacher_student_repository
            .set_default_teacher(&command.student_id, &command.teacher_id)
            .await?;

        Logger::info(&format!(
            "默认老师设置成功 - 老师ID: {}",
            command.teacher_id
        ));

        // 4. 返回响应
        Ok(SetDefaultTeacherResponse {
            message: "默认老师设置成功".to_string(),
            teacher_id: command.teacher_id,
        })
    }

    /// 验证命令参数
    fn validate_command(&self, command: &SetDefaultTeacherCommand) -> Result<()> {
        if command.student_id.trim().is_empty() {
            return Err(DomainError::Validation("学生ID不能为空".to_string()));
        }

        if command.teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("老师ID不能为空".to_string()));
        }

        Ok(())
    }
}
