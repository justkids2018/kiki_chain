// 创建作业用例
// 处理老师创建作业的完整业务流程
// 遵循DDD架构标准和业务逻辑最佳实践

use serde::{Deserialize, Serialize};
use std::sync::Arc;
use std::time::Instant;
use uuid::Uuid;

use crate::domain::entities::{Assignment, AssignmentStatus};
use crate::domain::errors::{DomainError, Result};
use crate::domain::repositories::AssignmentRepository;
use crate::infrastructure::logging::Logger;

/// 创建作业命令
/// 包含创建作业所需的所有输入参数
#[derive(Debug, Deserialize)]
pub struct CreateAssignmentCommand {
    pub teacher_id: String,
    pub title: String,
    pub description: String,
    pub knowledge_points: String,
    /// 可选的初始状态，默认为草稿状态
    pub status: Option<String>,
}

/// 创建作业响应
#[derive(Debug, Serialize)]
pub struct CreateAssignmentResponse {
    pub id: String,
    pub teacher_id: String,
    pub title: String,
    pub description: String,
    pub knowledge_points: String,
    pub status: String,
    pub created_at: String,
    pub updated_at: String,
    pub message: String,
}

/// 创建作业用例
/// 处理老师创建新作业的完整业务流程
///
/// 业务规则：
/// 1. 登录时已验证老师角色
/// 2. 作业标题和知识点不能为空
/// 3. 作业标题不能超过255字符
pub struct CreateAssignmentUseCase {
    assignment_repository: Arc<dyn AssignmentRepository>,
}

impl CreateAssignmentUseCase {
    pub fn new(assignment_repository: Arc<dyn AssignmentRepository>) -> Self {
        Self {
            assignment_repository,
        }
    }

    /// 执行创建作业用例
    ///
    /// 业务流程：
    /// 1. 输入验证  
    /// 2. 解析作业状态
    /// 3. 创建作业实体
    /// 4. 数据持久化
    /// 5. 业务日志记录
    /// 6. 响应构造
    pub async fn execute(
        &self,
        command: CreateAssignmentCommand,
    ) -> Result<CreateAssignmentResponse> {
        let start_time = Instant::now();

        Logger::business_info(format!(
            "开始创建作业 - 老师ID: {}, 标题: {}",
            command.teacher_id, command.title
        ));

        // 1. 输入验证
        self.validate_command(&command)?;

        // 2. 解析作业状态
        let status = self.parse_assignment_status(&command.status)?;

        // 3. 创建作业实体
        let assignment = Assignment::new(
            Uuid::new_v4(),
            command.teacher_id.clone(),
            command.title.clone(),
            command.description.clone(),
            command.knowledge_points.clone(),
            status,
        );

        // 5. 数据持久化
        self.assignment_repository
            .save(&assignment)
            .await
            .map_err(|e| {
                Logger::error(format!(
                    "作业保存失败 - 老师ID: {}, 错误: {}",
                    command.teacher_id, e
                ));
                e
            })?;

        // 6. 记录成功日志和性能指标
        let elapsed = start_time.elapsed();
        Logger::business_info(format!(
            "作业创建成功 - ID: {}, 老师ID: {}",
            assignment.id(),
            assignment.teacher_id()
        ));
        Logger::info(format!("创建作业耗时: {}ms", elapsed.as_millis()));

        // 7. 构造响应
        Ok(CreateAssignmentResponse {
            id: assignment.id().to_string(),
            teacher_id: assignment.teacher_id().to_string(),
            title: assignment.title().to_string(),
            description: assignment.description().to_string(),
            knowledge_points: assignment.knowledge_points().to_string(),
            status: assignment.status().to_string(),
            created_at: assignment.created_at().to_rfc3339(),
            updated_at: assignment.updated_at().to_rfc3339(),
            message: "作业创建成功".to_string(),
        })
    }

    /// 验证命令参数
    ///
    /// 验证规则：
    /// - 老师ID不能为空
    /// - 作业标题不能为空且不超过255字符
    /// - 知识点不能为空
    fn validate_command(&self, command: &CreateAssignmentCommand) -> Result<()> {
        // 验证老师ID
        if command.teacher_id.trim().is_empty() {
            return Err(DomainError::Validation("老师ID不能为空".to_string()));
        }

        // 验证作业标题
        if command.title.trim().is_empty() {
            return Err(DomainError::Validation("作业标题不能为空".to_string()));
        }

        if command.title.len() > 255 {
            return Err(DomainError::Validation(
                "作业标题过长，不能超过255字符".to_string(),
            ));
        }

        // 验证知识点
        if command.knowledge_points.trim().is_empty() {
            return Err(DomainError::Validation("知识点不能为空".to_string()));
        }

        // 验证描述长度（可选但有限制）
        if command.description.len() > 2000 {
            return Err(DomainError::Validation(
                "作业描述过长，不能超过2000字符".to_string(),
            ));
        }

        Logger::business_info(format!("输入验证通过 - 老师ID: {}", command.teacher_id));
        Ok(())
    }

    /// 解析作业状态
    ///
    /// 如果没有指定状态，默认为草稿状态
    fn parse_assignment_status(&self, status_str: &Option<String>) -> Result<AssignmentStatus> {
        match status_str {
            Some(status) => match status.to_lowercase().as_str() {
                "draft" => Ok(AssignmentStatus::Draft),
                "published" => Ok(AssignmentStatus::Published),
                "archived" => Ok(AssignmentStatus::Archived),
                _ => {
                    Logger::warn(format!("无效的作业状态: {}", status));
                    Err(DomainError::Validation(format!(
                        "无效的作业状态: {}",
                        status
                    )))
                }
            },
            None => Ok(AssignmentStatus::Published), // 默认为草稿状态
        }
    }
}
