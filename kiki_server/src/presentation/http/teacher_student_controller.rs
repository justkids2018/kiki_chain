// 师生关系控制器
// 负责处理老师与学生关系相关的HTTP请求

use serde_json::Value;
use std::sync::Arc;

use crate::application::use_cases::{
    AddTeacherStudentCommand, AddTeacherStudentUseCase, QueryTeacherStudentRelationshipsQuery,
    QueryTeacherStudentRelationshipsUseCase, RemoveTeacherStudentCommand,
    RemoveTeacherStudentUseCase, UpdateTeacherStudentCommand, UpdateTeacherStudentUseCase,
};
use crate::domain::errors::Result;
use crate::infrastructure::logging::Logger;
use crate::shared::api_response::ApiResponse;

/// 师生关系控制器
pub struct TeacherStudentController {
    query_use_case: Arc<QueryTeacherStudentRelationshipsUseCase>,
    add_use_case: Arc<AddTeacherStudentUseCase>,
    update_use_case: Arc<UpdateTeacherStudentUseCase>,
    remove_use_case: Arc<RemoveTeacherStudentUseCase>,
}

impl TeacherStudentController {
    pub fn new(
        query_use_case: Arc<QueryTeacherStudentRelationshipsUseCase>,
        add_use_case: Arc<AddTeacherStudentUseCase>,
        update_use_case: Arc<UpdateTeacherStudentUseCase>,
        remove_use_case: Arc<RemoveTeacherStudentUseCase>,
    ) -> Self {
        Self {
            query_use_case,
            add_use_case,
            update_use_case,
            remove_use_case,
        }
    }

    /// 查询师生关系
    pub async fn query_relationships(
        &self,
        teacher_uid: Option<String>,
        student_uid: Option<String>,
    ) -> Result<ApiResponse<Value>> {
        Logger::info("处理师生关系查询请求");

        let query = QueryTeacherStudentRelationshipsQuery {
            teacher_uid,
            student_uid,
        };

        let response = self.query_use_case.execute(query).await?;
        let payload = serde_json::to_value(response)?;
        Ok(ApiResponse::success(payload, "师生关系查询成功"))
    }

    /// 绑定老师与学生
    pub async fn add_relationship(&self, request: Value) -> Result<ApiResponse<Value>> {
        Logger::info("处理师生关系绑定请求");

        let command = AddTeacherStudentCommand {
            teacher_id: request
                .get("teacher_uid")
                .or_else(|| request.get("teacher_id"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            student_id: request
                .get("student_uid")
                .or_else(|| request.get("student_id"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            set_default: request
                .get("set_default")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
        };

        let response = self.add_use_case.execute(command).await?;
        let payload = serde_json::to_value(response)?;
        Ok(ApiResponse::success(payload, "师生关系绑定成功"))
    }

    /// 更新师生关系
    pub async fn update_relationship(&self, request: Value) -> Result<ApiResponse<Value>> {
        Logger::info("处理师生关系更新请求");

        let command = UpdateTeacherStudentCommand {
            student_id: request
                .get("student_uid")
                .or_else(|| request.get("student_id"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            current_teacher_id: request
                .get("current_teacher_uid")
                .or_else(|| request.get("current_teacher_id"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            new_teacher_id: request
                .get("new_teacher_uid")
                .or_else(|| request.get("new_teacher_id"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            set_default: request
                .get("set_default")
                .and_then(|v| v.as_bool())
                .unwrap_or(false),
        };

        let response = self.update_use_case.execute(command).await?;
        let payload = serde_json::to_value(response)?;
        Ok(ApiResponse::success(payload, "师生关系更新成功"))
    }

    /// 移除师生关系
    pub async fn remove_relationship(
        &self,
        teacher_uid: String,
        student_uid: String,
    ) -> Result<ApiResponse<Value>> {
        Logger::info(&format!(
            "处理师生关系解绑请求 - teacher: {}, student: {}",
            teacher_uid, student_uid
        ));

        let command = RemoveTeacherStudentCommand {
            teacher_id: teacher_uid,
            student_id: student_uid,
        };

        let response = self.remove_use_case.execute(command).await?;
        let payload = serde_json::to_value(response)?;
        Ok(ApiResponse::success(payload, "师生关系解绑成功"))
    }
}
