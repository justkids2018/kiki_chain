// 老师作业控制器
// 提供老师维度学生作业查询接口

use serde_json::Value;
use std::sync::Arc;

use crate::application::use_cases::{
    GetStudentAssignmentsQuery, GetStudentAssignmentsUseCase, GetTeacherStudentAssignmentsQuery,
    GetTeacherStudentAssignmentsUseCase,
};
use crate::domain::errors::Result;
use crate::infrastructure::logging::Logger;
use crate::shared::api_response::ApiResponse;

/// 老师作业控制器
pub struct TeacherAssignmentController {
    teacher_use_case: Arc<GetTeacherStudentAssignmentsUseCase>,
    student_use_case: Arc<GetStudentAssignmentsUseCase>,
}

impl TeacherAssignmentController {
    pub fn new(
        teacher_use_case: Arc<GetTeacherStudentAssignmentsUseCase>,
        student_use_case: Arc<GetStudentAssignmentsUseCase>,
    ) -> Self {
        Self {
            teacher_use_case,
            student_use_case,
        }
    }

    /// 查询老师名下学生的作业情况
    pub async fn get_teacher_student_assignments(
        &self,
        teacher_uid: String,
    ) -> Result<ApiResponse<Value>> {
        Logger::info(format!(
            "📘 [老师作业控制器] 查询老师关联学生作业 - teacher_uid: {}",
            teacher_uid
        ));

        let query = GetTeacherStudentAssignmentsQuery { teacher_uid };
        let response = self.teacher_use_case.execute(query).await?;
        let payload = serde_json::to_value(response)?;

        Ok(ApiResponse::success(payload, "老师学生作业查询成功"))
    }

    /// 查询学生个人作业记录
    pub async fn get_student_assignments(&self, student_uid: String) -> Result<ApiResponse<Value>> {
        Logger::info(format!(
            "🧑‍🎓 [老师作业控制器] 查询学生作业 - student_uid: {}",
            student_uid
        ));

        let query = GetStudentAssignmentsQuery { student_uid };
        let response = self.student_use_case.execute(query).await?;
        let payload = serde_json::to_value(response)?;

        Ok(ApiResponse::success(payload, "学生作业查询成功"))
    }
}
