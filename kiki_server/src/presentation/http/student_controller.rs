// 学生控制器
// 处理学生相关的HTTP请求

use serde_json::Value;
use std::sync::Arc;

use crate::application::use_cases::{
    GetDefaultTeacherQuery, GetDefaultTeacherUseCase, ListTeacherAssignmentsQuery,
    ListTeacherAssignmentsUseCase, ListTeachersQuery, ListTeachersUseCase,
    SetDefaultTeacherCommand, SetDefaultTeacherUseCase, UpdateConversationCommand,
    UpdateConversationUseCase,
};
use crate::domain::errors::Result;
use crate::infrastructure::logging::Logger;
use crate::shared::api_response::ApiResponse;

/// 学生控制器
/// 负责处理学生相关的HTTP请求
pub struct StudentController {
    list_teachers_use_case: Arc<ListTeachersUseCase>,
    set_default_teacher_use_case: Arc<SetDefaultTeacherUseCase>,
    get_default_teacher_use_case: Arc<GetDefaultTeacherUseCase>,
    list_teacher_assignments_use_case: Arc<ListTeacherAssignmentsUseCase>,
    update_conversation_use_case: Arc<UpdateConversationUseCase>,
}

impl StudentController {
    pub fn new(
        list_teachers_use_case: Arc<ListTeachersUseCase>,
        set_default_teacher_use_case: Arc<SetDefaultTeacherUseCase>,
        get_default_teacher_use_case: Arc<GetDefaultTeacherUseCase>,
        list_teacher_assignments_use_case: Arc<ListTeacherAssignmentsUseCase>,
        update_conversation_use_case: Arc<UpdateConversationUseCase>,
    ) -> Self {
        Self {
            list_teachers_use_case,
            set_default_teacher_use_case,
            get_default_teacher_use_case,
            list_teacher_assignments_use_case,
            update_conversation_use_case,
        }
    }

    /// 获取老师列表
    pub async fn list_teachers(&self, student_id: String) -> Result<Value> {
        Logger::info(&format!("处理获取老师列表请求 - 学生ID: {}", student_id));

        let query = ListTeachersQuery { student_id };

        // 执行用例
        let response = self.list_teachers_use_case.execute(query).await?;

        // 包装成ApiResponse
        let api_response = ApiResponse::success(response, "老师列表获取成功");
        Ok(serde_json::to_value(api_response)?)
    }

    /// 设置默认老师
    pub async fn set_default_teacher(&self, request: Value) -> Result<Value> {
        Logger::info("处理设置默认老师请求");

        // 解析请求参数
        let command = SetDefaultTeacherCommand {
            student_id: request
                .get("student_id")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            teacher_id: request
                .get("teacher_id")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
        };

        // 执行用例
        let response = self.set_default_teacher_use_case.execute(command).await?;

        // 包装成ApiResponse
        let api_response = ApiResponse::success(response, "默认老师设置成功");
        Ok(serde_json::to_value(api_response)?)
    }

    /// 获取默认老师
    pub async fn get_default_teacher(&self, student_id: String) -> Result<Value> {
        Logger::info(&format!("处理获取默认老师请求 - 学生ID: {}", student_id));

        let query = GetDefaultTeacherQuery { student_id };

        // 执行用例
        let response = self.get_default_teacher_use_case.execute(query).await?;

        // 包装成ApiResponse
        let api_response = ApiResponse::success(response, "默认老师获取成功");
        Ok(serde_json::to_value(api_response)?)
    }

    /// 获取老师的作业列表
    pub async fn list_teacher_assignments(
        &self,
        student_id: String,
        teacher_id: String,
        status: Option<String>,
    ) -> Result<Value> {
        Logger::info(&format!(
            "处理获取老师作业列表请求 - 学生ID: {}, 老师ID: {}",
            student_id, teacher_id
        ));

        let query = ListTeacherAssignmentsQuery {
            student_id,
            teacher_id,
            status,
        };

        // 执行用例
        let response = self
            .list_teacher_assignments_use_case
            .execute(query)
            .await?;

        // 包装成ApiResponse
        let api_response = ApiResponse::success(response, "老师作业列表获取成功");
        Ok(serde_json::to_value(api_response)?)
    }

    /// 更新会话ID
    pub async fn update_conversation(&self, request: Value) -> Result<Value> {
        Logger::info("处理更新会话ID请求");

        // 解析请求参数
        let command = UpdateConversationCommand {
            assignment_id: request
                .get("assignment_id")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            student_id: request
                .get("student_id")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            conversation_id: request
                .get("conversation_id")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
        };

        // 执行用例
        let response = self.update_conversation_use_case.execute(command).await?;

        // 包装成ApiResponse
        let api_response = ApiResponse::success(response, "会话ID更新成功");
        Ok(serde_json::to_value(api_response)?)
    }
}
