// 管理端路由模块 - 仅 Admin 角色可访问

use axum::{
    extract::{Path, State},
    http::StatusCode,
    middleware,
    response::{IntoResponse, Response},
    routing::{get, put, patch},
    Json, Router,
};
use std::sync::Arc;
use sqlx::{PgPool, Row};
use tracing::info;

use crate::adapters::http::middleware::admin_auth_middleware;
use crate::adapters::http::scene::{
    admin_create_category_handler, admin_create_scene_handler,
    admin_delete_category_handler, admin_delete_scene_handler,
    admin_get_scene_detail_handler, admin_list_categories_handler,
    admin_list_scenes_handler, admin_update_category_handler,
    admin_update_scene_handler,
};
use crate::core::ports::UserRepository;
use crate::framework::bootstrap::{api_paths::ApiPaths, AppState};
use crate::shared::api_response::ApiResponse;

/// 创建管理端路由
pub fn create_admin_routes(app_state: AppState) -> Router {
    info!("🔧 [管理端模块] 初始化管理端路由");

    Router::new()
        // ===== 用户管理 =====
        .route(
            ApiPaths::ADMIN_USERS,
            get(admin_get_users_handler).with_state(app_state.clone()),
        )
        .route(
            ApiPaths::ADMIN_USER_DETAIL,
            get(admin_get_user_detail_handler).with_state(app_state.user_repository.clone()),
        )
        .route(
            ApiPaths::ADMIN_USER_UPDATE,
            patch(admin_update_user_handler).with_state(app_state.clone()),
        )
        // ===== 场景分类管理 =====
        .route(
            ApiPaths::ADMIN_SCENE_CATEGORIES,
            get(admin_list_categories_handler)
                .post(admin_create_category_handler)
                .with_state(app_state.admin_scene_uc.clone()),
        )
        .route(
            ApiPaths::ADMIN_SCENE_CATEGORY_DETAIL,
            put(admin_update_category_handler)
                .delete(admin_delete_category_handler)
                .with_state(app_state.admin_scene_uc.clone()),
        )
        // ===== 场景管理 =====
        .route(
            ApiPaths::ADMIN_SCENES,
            get(admin_list_scenes_handler)
                .post(admin_create_scene_handler)
                .with_state(app_state.admin_scene_uc.clone()),
        )
        .route(
            ApiPaths::ADMIN_SCENE_DETAIL,
            get(admin_get_scene_detail_handler)
                .put(admin_update_scene_handler)
                .delete(admin_delete_scene_handler)
                .with_state(app_state.admin_scene_uc.clone()),
        )
        .layer(middleware::from_fn(admin_auth_middleware))
}

// ===== 用户管理处理器 =====


async fn admin_get_users_handler(
    State(app_state): State<AppState>,
) -> Response {
    info!("🔧 [管理端] 获取用户列表");

    match sqlx::query("SELECT id, phone, nickname, created_at, role_type, is_vip FROM users ORDER BY created_at DESC")
        .fetch_all(&app_state.pool)
        .await
    {
        Ok(rows) => {
            let data: Vec<serde_json::Value> = rows
                .iter()
                .map(|row| {
                    serde_json::json!({
                        "uid": row.get::<String, _>("id"),
                        "name": row.get::<String, _>("nickname"),
                        "phone": row.get::<String, _>("phone"),
                        "email": "",
                        "role_type": row.get::<Option<i32>, _>("role_type").unwrap_or(1),
                        "is_vip": row.get::<Option<bool>, _>("is_vip").unwrap_or(false),
                        "created_at": row.get::<chrono::NaiveDateTime, _>("created_at").and_utc().to_rfc3339()
                    })
                })
                .collect();
            (StatusCode::OK, Json(ApiResponse::success(data, "获取成功"))).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}
async fn admin_get_user_detail_handler(
    State(repo): State<Arc<dyn UserRepository>>,
    Path(id): Path<String>,
) -> Response {
    info!("🔧 [管理端] 获取用户详情: {}", id);
    match repo.find_by_uid(&id).await {
        Ok(Some(user)) => {
            let data = serde_json::json!({
                "uid": user.uid(),
                "name": user.name(),
                "phone": user.phone(),
                "email": user.email(),
                "role_type": user.role_type(),
                "is_vip": user.is_vip(),
                "created_at": user.created_at().to_rfc3339()
            });
            (StatusCode::OK, Json(ApiResponse::success(data, "获取成功"))).into_response()
        }
        Ok(None) => {
            let r = ApiResponse::<serde_json::Value>::error(404, "用户不存在");
            (StatusCode::NOT_FOUND, Json(r)).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// 更新用户请求 DTO
#[derive(Debug, serde::Deserialize)]
struct UpdateUserRequest {
    name: Option<String>,
    password: Option<String>,
    is_vip: Option<bool>,
}

/// 更新用户信息处理器
async fn admin_update_user_handler(
    State(app_state): State<AppState>,
    Path(id): Path<String>,
    Json(payload): Json<UpdateUserRequest>,
) -> Response {
    info!("🔧 [管理端] 更新用户信息: {}", id);

    // 构建更新 SQL - 使用动态参数绑定
    let mut set_clauses = Vec::new();
    let mut param_index = 1;

    if payload.name.is_some() {
        set_clauses.push(format!("nickname = ${}", param_index));
        param_index += 1;
    }

    if payload.password.is_some() {
        set_clauses.push(format!("password_hash = ${}", param_index));
        param_index += 1;
    }

    if payload.is_vip.is_some() {
        set_clauses.push(format!("is_vip = ${}", param_index));
        param_index += 1;
    }

    if set_clauses.is_empty() {
        let r = ApiResponse::<serde_json::Value>::error(400, "没有需要更新的字段");
        return (StatusCode::BAD_REQUEST, Json(r)).into_response();
    }

    let sql = format!(
        "UPDATE users SET {} WHERE id = ${}",
        set_clauses.join(", "),
        param_index
    );

    info!("🔧 [管理端] 执行 SQL: {}", sql);

    // 执行更新 - 按顺序绑定参数
    let mut query = sqlx::query(&sql);

    if let Some(name) = &payload.name {
        query = query.bind(name);
    }

    if let Some(password) = &payload.password {
        query = query.bind(password);
    }

    if let Some(is_vip) = payload.is_vip {
        query = query.bind(is_vip);
    }

    query = query.bind(&id);

    match query.execute(&app_state.pool).await {
        Ok(result) => {
            if result.rows_affected() == 0 {
                let r = ApiResponse::<serde_json::Value>::error(404, "用户不存在");
                (StatusCode::NOT_FOUND, Json(r)).into_response()
            } else {
                info!("✅ [管理端] 用户 {} 更新成功", id);
                (
                    StatusCode::OK,
                    Json(ApiResponse::success(
                        serde_json::json!({"uid": id}),
                        "更新成功",
                    )),
                )
                    .into_response()
            }
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("更新失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}
