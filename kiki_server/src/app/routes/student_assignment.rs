// 学生作业模块 - 路由配置与处理器
// 提供学生作业统一管理的REST接口

use axum::{
    extract::{Json as JsonExtract, Path, Query, State},
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde::Deserialize;
use serde_json::Value;
use tracing::info;
use uuid::Uuid;

use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::shared::api_response::ApiResponse;

/// 学生作业列表查询参数
#[derive(Debug, Deserialize)]
pub struct StudentAssignmentQuery {
    pub student_id: Option<String>,
    pub assignment_id: Option<String>,
    pub status: Option<String>,
}

/// 注册学生作业相关路由
pub fn create_student_assignment_routes(app_state: AppState) -> Router {
    Router::new()
        .route(
            ApiPaths::STUDENT_ASSIGNMENT_COLLECTION,
            post(create_student_assignment).get(list_student_assignments),
        )
        .route(
            ApiPaths::STUDENT_ASSIGNMENT_ITEM,
            get(get_student_assignment)
                .put(update_student_assignment)
                .delete(delete_student_assignment),
        )
        .with_state(app_state)
}

async fn create_student_assignment(
    State(state): State<AppState>,
    JsonExtract(body): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state
        .student_assignment_controller
        .create_student_assignment(body)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn list_student_assignments(
    State(state): State<AppState>,
    Query(query): Query<StudentAssignmentQuery>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state
        .student_assignment_controller
        .list_student_assignments(query.student_id, query.assignment_id, query.status)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn get_student_assignment(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state
        .student_assignment_controller
        .get_student_assignment(id.to_string())
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn update_student_assignment(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    JsonExtract(body): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state
        .student_assignment_controller
        .update_student_assignment(id.to_string(), body)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn delete_student_assignment(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    match state
        .student_assignment_controller
        .delete_student_assignment(id.to_string())
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}
