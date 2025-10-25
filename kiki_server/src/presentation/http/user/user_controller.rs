use crate::{
    application::use_cases::user::get_user::{GetUserCommand, GetUserResponse, GetUserUseCase},
    domain::errors::Result,
    shared::api_response::{ApiResponse, ErrorCode},
};
use axum::extract::Query;
use serde_json::{json, Value};
use std::sync::Arc;

pub struct UserController {
    get_user_use_case: Arc<GetUserUseCase>,
}

impl UserController {
    pub fn new(get_user_use_case: Arc<GetUserUseCase>) -> Self {
        Self { get_user_use_case }
    }

    /// 获取用户信息
    /// 支持通过uid或role_id查询用户信息
    /// 返回统一的ApiResponse格式
    pub async fn get_user(
        &self,
        Query(command): Query<GetUserCommand>,
    ) -> Result<ApiResponse<Value>> {
        // 验证查询参数
        if command.uid.is_none() && command.role_id.is_none() {
            return Ok(ApiResponse::error(
                ErrorCode::MISSING_PARAMETER,
                "缺少查询参数：需要提供uid或role_id",
            ));
        }

        // 执行业务逻辑
        let response = self.get_user_use_case.execute(command).await?;

        // 格式化响应数据
        let (json_response, message) = match response {
            GetUserResponse::User(Some(user)) => {
                (json!({ "user": user }), "获取用户信息成功".to_string())
            }
            GetUserResponse::User(None) => {
                return Ok(ApiResponse::error(
                    ErrorCode::USER_NOT_FOUND,
                    "未找到指定的用户",
                ));
            }
            GetUserResponse::Users(users) => {
                if users.is_empty() {
                    (json!({ "users": [] }), "没有找到符合条件的用户".to_string())
                } else {
                    (
                        json!({ "users": users }),
                        format!("获取用户列表成功，共{}个用户", users.len()),
                    )
                }
            }
        };

        Ok(ApiResponse::success(json_response, message))
    }
}
