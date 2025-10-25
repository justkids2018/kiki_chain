// 作业模块 - 路由配置和处理器
// 包含作业相关的所有HTTP路由和处理逻辑

use axum::{
    extract::{Json as JsonExtract, Path, Query, State},
    http::{HeaderMap, StatusCode},
    response::Json,
    routing::{delete, get, post, put},
    Router,
};
use serde::Deserialize;
use serde_json::Value;
use tracing::{info, instrument, warn};
use uuid::Uuid;

use crate::app::{api_paths::ApiPaths, AppState};
use qiqimanyou_server::{shared::api_response::ApiResponse, utils::HttpUtils};

// =============================================================================
// 路由配置
// =============================================================================

/// 创建作业模块路由
///
/// ## 路由清单
/// - POST   /api/teacher/assignments          - 创建作业
/// - GET    /api/teacher/assignments          - 获取老师作业列表  
/// - GET    /api/teacher/assignments/:id      - 获取作业详情
/// - PUT    /api/teacher/assignments/:id      - 更新作业
/// - DELETE /api/teacher/assignments/:id      - 删除作业
pub fn create_assignment_routes(app_state: AppState) -> Router {
    info!("🏗️ [作业模块] 初始化作业路由");
    info!("  ├── 注册路由: POST   {}", ApiPaths::TEACHER_ASSIGNMENTS);
    info!("  ├── 注册路由: GET    {}", ApiPaths::TEACHER_ASSIGNMENTS);
    info!(
        "  ├── 注册路由: GET    {}",
        ApiPaths::TEACHER_ASSIGNMENT_BY_ID
    );
    info!(
        "  ├── 注册路由: PUT    {}",
        ApiPaths::TEACHER_ASSIGNMENT_BY_ID
    );
    info!(
        "  └── 注册路由: DELETE {}",
        ApiPaths::TEACHER_ASSIGNMENT_BY_ID
    );

    Router::new()
        .route(ApiPaths::TEACHER_ASSIGNMENTS, post(create_assignment))
        .route(ApiPaths::TEACHER_ASSIGNMENTS, get(get_teacher_assignments))
        .route(
            ApiPaths::TEACHER_ASSIGNMENT_BY_ID,
            get(get_assignment_by_id),
        )
        .route(ApiPaths::TEACHER_ASSIGNMENT_BY_ID, put(update_assignment))
        .route(
            ApiPaths::TEACHER_ASSIGNMENT_BY_ID,
            delete(delete_assignment),
        )
        .with_state(app_state)
}

// =============================================================================
// 处理器函数
// =============================================================================

/// 创建作业
///
/// ## 请求体示例
/// ```json
/// {
///   "title": "数学作业1",
///   "description": "完成第一章练习题",
///   "knowledge_points": "加法运算,减法运算"
/// }
/// ```
#[instrument(skip(state, headers))]
async fn create_assignment(
    State(state): State<AppState>,
    headers: HeaderMap,
    JsonExtract(mut body): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("📝 [作业创建] 开始创建作业");

    // 从token中提取teacher_id
    let teacher_id = match HttpUtils::extract_user_id_from_headers(&headers) {
        Ok(id) => {
            info!("🔍 [作业创建] 从token提取到teacher_id: {}", id);
            id
        }
        Err(e) => {
            warn!("❌ [作业创建] 提取用户ID失败: {}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            return Err((status, Json(api_error)));
        }
    };

    // 将teacher_id注入到请求体中
    if let Some(obj) = body.as_object_mut() {
        obj.insert("teacher_id".to_string(), Value::String(teacher_id.clone()));
    }

    // 使用控制器处理请求
    match state.assignment_controller.create_assignment(body).await {
        Ok(response) => {
            info!("✅ [作业创建] 教师 {} 作业创建成功", teacher_id);
            Ok(Json(response))
        }
        Err(e) => {
            warn!("❌ [作业创建] 教师 {} 作业创建失败: {}", teacher_id, e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}

/// 获取老师作业列表
#[derive(Deserialize)]
pub struct AssignmentQuery {
    #[serde(rename = "teacher_id")]
    teacher_id: Option<String>,
    status: Option<String>, // 作业状态过滤
}

#[instrument(skip(state, headers, query), fields(teacher_id))]
async fn get_teacher_assignments(
    State(state): State<AppState>,
    headers: HeaderMap,
    Query(query): Query<AssignmentQuery>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    // 优先从query参数获取teacher_id，否则从token中提取
    let teacher_id = if let Some(ref tid) = query.teacher_id {
        tracing::Span::current().record("teacher_id", &tid[..]);
        tid.clone()
    } else {
        match HttpUtils::extract_user_id_from_headers(&headers) {
            Ok(id) => {
                tracing::Span::current().record("teacher_id", &id);
                id
            }
            Err(e) => {
                let api_error = ApiResponse::from_domain_error(&e);
                let status = api_error.http_status();
                return Err((status, Json(api_error)));
            }
        }
    };

    // 直接调用控制器，让控制器层负责业务日志
    match state
        .assignment_controller
        .list_assignments(teacher_id, query.status)
        .await
    {
        Ok(response) => Ok(Json(response)),
        Err(e) => {
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}

/// 获取作业详情
#[instrument(skip(state, headers), fields(assignment_id = %id))]
async fn get_assignment_by_id(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    headers: HeaderMap,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🔍 [作业详情] 获取作业详情 - ID: {}", id);

    // 从token中提取teacher_id
    let teacher_id = match HttpUtils::extract_user_id_from_headers(&headers) {
        Ok(id) => {
            info!("🔍 [作业详情] 从token提取到teacher_id: {}", id);
            id
        }
        Err(e) => {
            warn!("❌ [作业详情] 提取用户ID失败: {}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            return Err((status, Json(api_error)));
        }
    };

    // 使用控制器处理请求
    match state
        .assignment_controller
        .get_assignment(teacher_id.clone(), id.to_string())
        .await
    {
        Ok(response) => {
            info!("✅ [作业获取] 教师 {} 成功获取作业: {}", teacher_id, id);
            Ok(Json(response))
        }
        Err(e) => {
            warn!("❌ [作业获取] 教师 {} 获取作业失败: {}", teacher_id, e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}

/// 更新作业
/// 更新作业
#[instrument(skip(state, headers), fields(assignment_id = %id))]
async fn update_assignment(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    headers: HeaderMap,
    JsonExtract(body): JsonExtract<Value>,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    info!("🔄 [作业更新] 开始更新作业 - ID: {}", id);
    info!("  └── 更新数据: {:?}", body);

    // 从token中提取teacher_id
    let teacher_id = match HttpUtils::extract_user_id_from_headers(&headers) {
        Ok(id) => {
            info!("🔍 [作业更新] 从token提取到teacher_id: {}", id);
            id
        }
        Err(e) => {
            warn!("❌ [作业更新] 提取用户ID失败: {}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            return Err((status, Json(api_error)));
        }
    };

    // 使用控制器处理请求
    match state
        .assignment_controller
        .update_assignment(id.to_string(), body)
        .await
    {
        Ok(response) => {
            info!("✅ [作业更新] 教师 {} 更新作业 {} 成功", teacher_id, id);
            Ok(Json(response))
        }
        Err(e) => {
            warn!(
                "❌ [作业更新] 教师 {} 更新作业 {} 失败: {}",
                teacher_id, id, e
            );
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}

/// 删除作业
/// 删除作业
#[instrument(skip(state, headers), fields(assignment_id = %id))]
async fn delete_assignment(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    headers: HeaderMap,
) -> Result<Json<ApiResponse<Value>>, (StatusCode, Json<ApiResponse<Value>>)> {
    warn!("🗑️  [作业删除] 开始删除作业 - ID: {}", id);

    // 从token中提取teacher_id
    let teacher_id = match HttpUtils::extract_user_id_from_headers(&headers) {
        Ok(id) => {
            info!("🔍 [作业删除] 从token提取到teacher_id: {}", id);
            id
        }
        Err(e) => {
            warn!("❌ [作业删除] 提取用户ID失败: {}", e);
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            return Err((status, Json(api_error)));
        }
    };

    // 使用控制器处理请求
    match state
        .assignment_controller
        .delete_assignment(id.to_string(), teacher_id.clone())
        .await
    {
        Ok(response) => {
            warn!(
                "⚠️  [作业删除] 教师 {} 删除作业 {} 成功 - 操作不可逆",
                teacher_id, id
            );
            Ok(Json(response))
        }
        Err(e) => {
            warn!(
                "❌ [作业删除] 教师 {} 删除作业 {} 失败: {}",
                teacher_id, id, e
            );
            let api_error = ApiResponse::from_domain_error(&e);
            let status = api_error.http_status();
            Err((status, Json(api_error)))
        }
    }
}
