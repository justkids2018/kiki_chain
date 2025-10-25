// 师生关系模块 - 路由配置和处理器
// 提供老师与学生关系相关的HTTP接口

use axum::{
    extract::{Json as JsonExtract, Query, State},
    http::StatusCode,
    response::Json,
    routing::get,
    Router,
};
use serde::Deserialize;
use serde_json::Value;
use tracing::{info, instrument, warn};

use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::{domain::errors::DomainError, shared::api_response::ApiResponse};

#[derive(Debug, Deserialize)]
pub struct TeacherStudentQuery {
    pub teacher_uid: Option<String>,
    pub student_uid: Option<String>,
}

/// 创建师生关系路由
///
/// - GET    /api/teacher-student                 查询师生关系
/// - POST   /api/teacher-student                 新增师生关系
/// - PUT    /api/teacher-student                 更新师生关系
/// - DELETE /api/teacher-student                 删除师生关系
pub fn create_teacher_student_routes(app_state: AppState) -> Router {
    info!("👩‍🏫 [师生关系模块] 初始化路由");
    info!(
        "  ├── 注册路由: GET    {}",
        ApiPaths::TEACHER_STUDENT_RELATIONSHIPS
    );
    info!(
        "  ├── 注册路由: POST   {}",
        ApiPaths::TEACHER_STUDENT_RELATIONSHIPS
    );
    info!(
        "  ├── 注册路由: PUT    {}",
        ApiPaths::TEACHER_STUDENT_RELATIONSHIPS
    );
    info!(
        "  └── 注册路由: DELETE {}",
        ApiPaths::TEACHER_STUDENT_RELATIONSHIPS
    );

    Router::new()
        .route(
            ApiPaths::TEACHER_STUDENT_RELATIONSHIPS,
            get(query_relationships)
                .post(add_relationship)
                .put(update_relationship)
                .delete(remove_relationship),
        )
        .with_state(app_state)
}

/// 查询师生关系
#[instrument(skip(state))]
async fn query_relationships(
    State(state): State<AppState>,
    Query(query): Query<TeacherStudentQuery>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!(
        "📋 [师生关系] 查询请求参数: teacher_uid={:?}, student_uid={:?}",
        query.teacher_uid, query.student_uid
    );
    match state
        .teacher_student_controller
        .query_relationships(query.teacher_uid.clone(), query.student_uid.clone())
        .await
    {
        Ok(api_response) => Ok(Json(api_response)),
        Err(error) => {
            warn!("🚫 [师生关系] 查询失败: {:?}", error);
            let api_error = ApiResponse::from_domain_error(&error);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

/// 新增师生关系
#[instrument(skip(state, request))]
async fn add_relationship(
    State(state): State<AppState>,
    JsonExtract(request): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("➕ [师生关系] 绑定请求");
    match state
        .teacher_student_controller
        .add_relationship(request)
        .await
    {
        Ok(api_response) => Ok(Json(api_response)),
        Err(error) => {
            warn!("🚫 [师生关系] 绑定失败: {:?}", error);
            let api_error = ApiResponse::from_domain_error(&error);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

/// 更新师生关系
#[instrument(skip(state, request))]
async fn update_relationship(
    State(state): State<AppState>,
    JsonExtract(request): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🔄 [师生关系] 更新请求");
    match state
        .teacher_student_controller
        .update_relationship(request)
        .await
    {
        Ok(api_response) => Ok(Json(api_response)),
        Err(error) => {
            warn!("🚫 [师生关系] 更新失败: {:?}", error);
            let api_error = ApiResponse::from_domain_error(&error);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}

/// 移除师生关系
#[instrument(skip(state))]
async fn remove_relationship(
    State(state): State<AppState>,
    Query(query): Query<TeacherStudentQuery>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🗑️ [师生关系] 解绑请求");
    let teacher_uid = query.teacher_uid.unwrap_or_default();
    let student_uid = query.student_uid.unwrap_or_default();

    if teacher_uid.is_empty() || student_uid.is_empty() {
        warn!("🚫 [师生关系] 解绑失败: teacher_uid或student_uid缺失");
        let error = DomainError::Validation("teacher_uid和student_uid不能为空".to_string());
        let api_error = ApiResponse::from_domain_error(&error);
        return Err((api_error.http_status(), Json(api_error)));
    }

    match state
        .teacher_student_controller
        .remove_relationship(teacher_uid, student_uid)
        .await
    {
        Ok(api_response) => Ok(Json(api_response)),
        Err(error) => {
            warn!("🚫 [师生关系] 解绑失败: {:?}", error);
            let api_error = ApiResponse::from_domain_error(&error);
            Err((api_error.http_status(), Json(api_error)))
        }
    }
}
