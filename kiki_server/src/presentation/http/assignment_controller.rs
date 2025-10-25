// 作业控制器
// 处理老师作业相关的HTTP请求
// 遵循DDD架构标准和表现层最佳实践

use serde_json::Value;
use std::sync::Arc;
use std::time::Instant;

use crate::application::use_cases::{
    CreateAssignmentCommand, CreateAssignmentUseCase, DeleteAssignmentCommand,
    DeleteAssignmentUseCase, GetAssignmentQuery, GetAssignmentUseCase, ListAssignmentsQuery,
    ListAssignmentsUseCase, UpdateAssignmentCommand, UpdateAssignmentUseCase,
};
use crate::domain::errors::Result;
use crate::infrastructure::logging::Logger;
use crate::shared::api_response::ApiResponse;

/// 作业控制器
///
/// 职责：
/// 1. 处理HTTP请求参数解析
/// 2. 调用相应的用例执行业务逻辑
/// 3. 将响应包装为统一的API格式
/// 4. 记录请求日志和性能指标
///
/// 注意：控制器不包含业务逻辑，只负责协调和转换
pub struct AssignmentController {
    create_use_case: Arc<CreateAssignmentUseCase>,
    get_use_case: Arc<GetAssignmentUseCase>,
    list_use_case: Arc<ListAssignmentsUseCase>,
    update_use_case: Arc<UpdateAssignmentUseCase>,
    delete_use_case: Arc<DeleteAssignmentUseCase>,
}

impl AssignmentController {
    pub fn new(
        create_use_case: Arc<CreateAssignmentUseCase>,
        get_use_case: Arc<GetAssignmentUseCase>,
        list_use_case: Arc<ListAssignmentsUseCase>,
        update_use_case: Arc<UpdateAssignmentUseCase>,
        delete_use_case: Arc<DeleteAssignmentUseCase>,
    ) -> Self {
        Self {
            create_use_case,
            get_use_case,
            list_use_case,
            update_use_case,
            delete_use_case,
        }
    }

    /// 创建作业
    ///
    /// 处理流程：
    /// 1. 记录请求日志
    /// 2. 解析和验证请求参数
    /// 3. 调用创建作业用例
    /// 4. 包装响应格式
    /// 5. 记录性能指标
    pub async fn create_assignment(
        &self,
        request: Value,
    ) -> Result<ApiResponse<serde_json::Value>> {
        let start_time = Instant::now();

        Logger::info("开始处理创建作业请求");

        // 解析请求参数
        let command = self.parse_create_assignment_request(request)?;

        Logger::info(format!(
            "创建作业请求参数 - 老师ID: {}, 标题: {}",
            command.teacher_id, command.title
        ));

        // 执行用例
        let response = self.create_use_case.execute(command).await.map_err(|e| {
            Logger::http_error(
                serde_json::to_value(format!("创建作业用例执行失败: {}", e)).unwrap_or_default(),
            );
            e
        })?;

        // 记录性能指标
        let elapsed = start_time.elapsed();
        Logger::info(format!("创建作业请求处理耗时: {}ms", elapsed.as_millis()));

        // 构造统一API响应
        Logger::info(format!("作业创建成功 - ID: {}", response.id));
        let api_response = ApiResponse::success(serde_json::to_value(response)?, "作业创建成功");
        Ok(api_response)
    }

    /// 获取作业详情
    pub async fn get_assignment(
        &self,
        assignment_id: String,
        teacher_id: String,
    ) -> Result<ApiResponse<serde_json::Value>> {
        let start_time = Instant::now();

        Logger::info(format!(
            "开始处理获取作业详情请求 - ID: {}, 老师ID: {}",
            assignment_id, teacher_id
        ));

        let query = GetAssignmentQuery {
            assignment_id: assignment_id.clone(),
            teacher_id,
        };

        // 执行用例
        let response = self.get_use_case.execute(query).await.map_err(|e| {
            Logger::http_error(
                serde_json::to_value(format!(
                    "获取作业详情用例执行失败 - ID: {}, 错误: {}",
                    assignment_id, e
                ))
                .unwrap_or_default(),
            );
            e
        })?;

        // 记录性能指标
        let elapsed = start_time.elapsed();
        Logger::info(format!(
            "获取作业详情请求处理耗时: {}ms",
            elapsed.as_millis()
        ));

        // 构造统一API响应
        Logger::info(format!("作业详情获取成功 - ID: {}", assignment_id));
        let api_response =
            ApiResponse::success(serde_json::to_value(response)?, "作业详情获取成功");
        Ok(api_response)
    }

    /// 获取作业列表
    pub async fn list_assignments(
        &self,
        teacher_id: String,
        status: Option<String>,
    ) -> Result<ApiResponse<serde_json::Value>> {
        let start_time = Instant::now();

        // 只记录关键业务信息，避免重复中间件已记录的信息
        Logger::info(format!("📋 [业务层] 查询作业列表 - 教师: {}", teacher_id));

        let query = ListAssignmentsQuery {
            teacher_id: teacher_id.clone(),
            status,
        };

        // 执行用例
        let response = self.list_use_case.execute(query).await.map_err(|e| {
            Logger::error(format!(
                "❌ [业务层] 作业列表查询失败 - 教师: {}, 错误: {}",
                teacher_id, e
            ));
            e
        })?;

        // 记录成功结果和性能指标
        let elapsed = start_time.elapsed();
        Logger::info(format!(
            "✅ [业务层] 作业列表查询成功 - 教师: {}, 数量: {}, 耗时: {}ms",
            teacher_id,
            response.assignments.len(),
            elapsed.as_millis()
        ));

        let api_response =
            ApiResponse::success(serde_json::to_value(response)?, "作业列表获取成功");
        Ok(api_response)
    }

    /// 更新作业
    pub async fn update_assignment(
        &self,
        assignment_id: String,
        request: Value,
    ) -> Result<ApiResponse<serde_json::Value>> {
        let start_time = Instant::now();

        Logger::info(format!("开始处理更新作业请求 - ID: {}", assignment_id));

        // 解析请求参数
        let command = UpdateAssignmentCommand {
            assignment_id: assignment_id.clone(),
            teacher_id: request
                .get("teacher_id")
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string(),
            title: request
                .get("title")
                .and_then(|v| v.as_str())
                .map(|s| s.to_string()),
            description: request
                .get("description")
                .and_then(|v| v.as_str())
                .map(|s| s.to_string()),
            knowledge_points: request
                .get("knowledge_points")
                .and_then(|v| v.as_str())
                .map(|s| s.to_string()),
            status: request
                .get("status")
                .and_then(|v| v.as_str())
                .map(|s| s.to_string()),
        };

        // 执行用例
        let response = self.update_use_case.execute(command).await.map_err(|e| {
            Logger::http_error(
                serde_json::to_value(format!(
                    "更新作业用例执行失败 - ID: {}, 错误: {}",
                    assignment_id, e
                ))
                .unwrap_or_default(),
            );
            e
        })?;

        // 记录性能指标
        let elapsed = start_time.elapsed();
        Logger::info(format!("更新作业请求处理耗时: {}ms", elapsed.as_millis()));

        // 构造统一API响应
        Logger::info(format!("作业更新成功 - ID: {}", assignment_id));
        let api_response = ApiResponse::success(serde_json::to_value(response)?, "作业更新成功");
        Ok(api_response)
    }

    /// 删除作业
    pub async fn delete_assignment(
        &self,
        assignment_id: String,
        teacher_id: String,
    ) -> Result<ApiResponse<serde_json::Value>> {
        let start_time = Instant::now();

        Logger::info(format!(
            "开始处理删除作业请求 - ID: {}, 老师ID: {}",
            assignment_id, teacher_id
        ));

        let command = DeleteAssignmentCommand {
            assignment_id: assignment_id.clone(),
            teacher_id,
        };

        // 执行用例
        let response = self.delete_use_case.execute(command).await.map_err(|e| {
            Logger::http_error(
                serde_json::to_value(format!(
                    "删除作业用例执行失败 - ID: {}, 错误: {}",
                    assignment_id, e
                ))
                .unwrap_or_default(),
            );
            e
        })?;

        // 记录性能指标
        let elapsed = start_time.elapsed();
        Logger::info(format!("删除作业请求处理耗时: {}ms", elapsed.as_millis()));

        // 构造统一API响应
        Logger::info(format!("作业删除成功 - ID: {}", assignment_id));
        let api_response = ApiResponse::success(serde_json::to_value(response)?, "作业删除成功");
        Ok(api_response)
    }

    /// 解析创建作业请求参数
    ///
    /// 从JSON请求中提取并验证创建作业所需的参数
    fn parse_create_assignment_request(&self, request: Value) -> Result<CreateAssignmentCommand> {
        let teacher_id = request
            .get("teacher_id")
            .and_then(|v| v.as_str())
            .ok_or_else(|| {
                crate::domain::errors::DomainError::Validation("缺少teacher_id参数".to_string())
            })?
            .to_string();

        let title = request
            .get("title")
            .and_then(|v| v.as_str())
            .ok_or_else(|| {
                crate::domain::errors::DomainError::Validation("缺少title参数".to_string())
            })?
            .to_string();

        let description = request
            .get("description")
            .and_then(|v| v.as_str())
            .unwrap_or("")
            .to_string();

        let knowledge_points = request
            .get("knowledge_points")
            .and_then(|v| v.as_str())
            .unwrap_or("")
            .to_string();

        Ok(CreateAssignmentCommand {
            teacher_id,
            title,
            description,
            knowledge_points,
            status: None, // 默认为草稿状态
        })
    }
}
