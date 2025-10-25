// 老师作业模块路由配置
// 提供老师维度学生作业查询接口

use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::Json,
    routing::get,
    Router,
};
use tracing::info;

use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::shared::api_response::ApiResponse;

/// 注册老师作业相关路由
pub fn create_teacher_assignment_routes(app_state: AppState) -> Router {
    Router::new()
        .route(
            ApiPaths::TEACHER_ASSIGNMENT_STUDENT_ASSIGNMENTS,
            get(get_teacher_student_assignments),
        )
        .route(
            ApiPaths::STUDENT_ASSIGNMENT_RECORDS,
            get(get_student_assignments),
        )
        .with_state(app_state)
}

async fn get_teacher_student_assignments(
    State(state): State<AppState>,
    Path(teacher_uid): Path<String>,
) -> Result<Json<ApiResponse<serde_json::Value>>, (StatusCode, Json<ApiResponse<serde_json::Value>>)>
{
    info!("👩‍🏫 [老师作业路由] 查询学生作业 teacher_uid={}", teacher_uid);

    match state
        .teacher_assignment_controller
        .get_teacher_student_assignments(teacher_uid)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

async fn get_student_assignments(
    State(state): State<AppState>,
    Path(student_uid): Path<String>,
) -> Result<Json<ApiResponse<serde_json::Value>>, (StatusCode, Json<ApiResponse<serde_json::Value>>)>
{
    info!("🧑‍🎓 [老师作业路由] 查询学生作业 student_uid={}", student_uid);

    match state
        .teacher_assignment_controller
        .get_student_assignments(student_uid)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(err) => {
            let api_error = ApiResponse::from_domain_error(&err);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}
