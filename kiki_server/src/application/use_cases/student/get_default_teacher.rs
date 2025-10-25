// 获取默认老师用例
// 处理学生获取当前默认老师的业务流程

use serde::{Deserialize, Serialize};
use std::sync::Arc;

use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::{TeacherStudentRepository, UserRepository};
use crate::infrastructure::logging::Logger;

/// 获取默认老师查询
#[derive(Debug, Deserialize)]
pub struct GetDefaultTeacherQuery {
    pub student_id: String,
}

/// 获取默认老师响应
#[derive(Debug, Serialize)]
pub struct GetDefaultTeacherResponse {
    pub teacher_id: String,
    pub teacher_name: String,
    pub teacher_email: String,
    pub teacher_phone: String,
}

/// 获取默认老师用例
/// 处理学生获取当前默认老师的业务流程
pub struct GetDefaultTeacherUseCase {
    teacher_student_repository: Arc<dyn TeacherStudentRepository>,
    user_repository: Arc<dyn UserRepository>,
}

impl GetDefaultTeacherUseCase {
    pub fn new(
        teacher_student_repository: Arc<dyn TeacherStudentRepository>,
        user_repository: Arc<dyn UserRepository>,
    ) -> Self {
        Self {
            teacher_student_repository,
            user_repository,
        }
    }

    /// 执行获取默认老师
    pub async fn execute(
        &self,
        query: GetDefaultTeacherQuery,
    ) -> Result<Option<GetDefaultTeacherResponse>> {
        Logger::info(&format!("获取默认老师 - 学生ID: {}", query.student_id));

        // 1. 获取默认老师ID
        let default_teacher_id = self
            .teacher_student_repository
            .get_default_teacher(&query.student_id)
            .await?;

        if let Some(teacher_id) = default_teacher_id {
            // 2. 获取老师详细信息
            let teacher = self
                .user_repository
                .find_by_uid(&teacher_id)
                .await?
                .ok_or_else(|| DomainError::NotFound("默认老师信息不存在".to_string()))?;

            Logger::info(&format!("默认老师获取成功 - 老师: {}", teacher.name()));

            Ok(Some(GetDefaultTeacherResponse {
                teacher_id: teacher.uid().to_string(),
                teacher_name: teacher.name().to_string(),
                teacher_email: teacher.email().to_string(),
                teacher_phone: teacher.phone().to_string(),
            }))
        } else {
            Logger::info("学生暂无默认老师");
            Ok(None)
        }
    }
}
