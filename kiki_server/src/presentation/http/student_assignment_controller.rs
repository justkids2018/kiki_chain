// 学生作业控制器
// 聚焦于协调HTTP层与应用用例的交互，不包含业务逻辑

use serde_json::Value;
use std::sync::Arc;

use crate::application::use_cases::{
    CreateStudentAssignmentCommand, CreateStudentAssignmentUseCase, DeleteStudentAssignmentCommand,
    DeleteStudentAssignmentUseCase, GetStudentAssignmentQuery, GetStudentAssignmentUseCase,
    ListStudentAssignmentsQuery, ListStudentAssignmentsUseCase, UpdateStudentAssignmentCommand,
    UpdateStudentAssignmentUseCase,
};
use crate::domain::errors::{DomainError, Result};
use crate::infrastructure::logging::Logger;
use crate::shared::api_response::ApiResponse;

/// 学生作业控制器
/// - 负责请求解析与响应封装
/// - 调用对应用例执行业务逻辑
/// - 统一记录请求处理日志
pub struct StudentAssignmentController {
    create_use_case: Arc<CreateStudentAssignmentUseCase>,
    get_use_case: Arc<GetStudentAssignmentUseCase>,
    list_use_case: Arc<ListStudentAssignmentsUseCase>,
    update_use_case: Arc<UpdateStudentAssignmentUseCase>,
    delete_use_case: Arc<DeleteStudentAssignmentUseCase>,
}

impl StudentAssignmentController {
    pub fn new(
        create_use_case: Arc<CreateStudentAssignmentUseCase>,
        get_use_case: Arc<GetStudentAssignmentUseCase>,
        list_use_case: Arc<ListStudentAssignmentsUseCase>,
        update_use_case: Arc<UpdateStudentAssignmentUseCase>,
        delete_use_case: Arc<DeleteStudentAssignmentUseCase>,
    ) -> Self {
        Self {
            create_use_case,
            get_use_case,
            list_use_case,
            update_use_case,
            delete_use_case,
        }
    }

    /// 创建学生作业记录
    pub async fn create_student_assignment(&self, request: Value) -> Result<ApiResponse<Value>> {
        Logger::info("🆕 [学生作业控制器] 收到创建学生作业请求");

        let command: CreateStudentAssignmentCommand = serde_json::from_value(request)?;
        let response = self.create_use_case.execute(command).await?;
        let payload = serde_json::to_value(response.assignment)?;

        Ok(ApiResponse::success(payload, "学生作业创建成功"))
    }

    /// 获取单个学生作业详情
    pub async fn get_student_assignment(&self, id: String) -> Result<ApiResponse<Value>> {
        Logger::info(format!("🔍 [学生作业控制器] 查询学生作业 - ID: {}", id));

        let query = GetStudentAssignmentQuery { id };
        let result = self.get_use_case.execute(query).await?;
        let payload = serde_json::to_value(result)?;

        Ok(ApiResponse::success(payload, "学生作业详情获取成功"))
    }

    /// 查询学生作业列表
    pub async fn list_student_assignments(
        &self,
        student_id: Option<String>,
        assignment_id: Option<String>,
        status: Option<String>,
    ) -> Result<ApiResponse<Value>> {
        Logger::info("📋 [学生作业控制器] 查询学生作业列表");

        let query = ListStudentAssignmentsQuery {
            student_id,
            assignment_id,
            status,
        };

        let response = self.list_use_case.execute(query).await?;
        let payload = serde_json::to_value(response.assignments)?;

        Ok(ApiResponse::success(payload, "学生作业列表获取成功"))
    }

    /// 更新学生作业记录
    pub async fn update_student_assignment(
        &self,
        id: String,
        mut request: Value,
    ) -> Result<ApiResponse<Value>> {
        Logger::info(format!("🔄 [学生作业控制器] 更新学生作业 - ID: {}", id));

        if let Some(obj) = request.as_object_mut() {
            obj.insert("id".to_string(), Value::String(id.clone()));
        } else {
            return Err(DomainError::Validation("请求体必须为JSON对象".to_string()));
        }

        let command: UpdateStudentAssignmentCommand = serde_json::from_value(request)?;
        let response = self.update_use_case.execute(command).await?;
        let payload = serde_json::to_value(response.assignment)?;

        Ok(ApiResponse::success(payload, "学生作业更新成功"))
    }

    /// 删除学生作业
    pub async fn delete_student_assignment(&self, id: String) -> Result<ApiResponse<Value>> {
        Logger::info(format!("🗑️ [学生作业控制器] 删除学生作业 - ID: {}", id));

        let command = DeleteStudentAssignmentCommand { id };
        let response = self.delete_use_case.execute(command).await?;
        let payload = serde_json::to_value(response)?;

        Ok(ApiResponse::success(payload, "学生作业删除成功"))
    }
}
