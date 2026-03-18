// 场景 HTTP 处理器

use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use std::sync::Arc;
use tracing::{error, info};
use uuid::Uuid;

use crate::core::use_cases::scene::{
    AdminSceneUseCase, CreateCategoryCommand, CreateSceneCommand, GetCategoriesUseCase,
    GetRecommendationsUseCase, GetSceneDetailUseCase, GetScenesByCategoryUseCase,
    SearchScenesCommand, SearchScenesUseCase, UpdateCategoryCommand, UpdateSceneCommand,
};
use crate::shared::api_response::ApiResponse;

use super::dtos::*;

// ===== 移动端处理器 =====

/// GET /api/v1/mobile/scene/categories
pub async fn get_categories_handler(
    State(uc): State<Arc<GetCategoriesUseCase>>,
) -> Response {
    info!("📱 [场景] 获取分类列表");
    match uc.execute().await {
        Ok(categories) => {
            let dtos: Vec<SceneCategoryDto> = categories.iter().map(SceneCategoryDto::from).collect();
            (StatusCode::OK, Json(ApiResponse::success(dtos, "获取成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 获取分类失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取分类失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/mobile/scene/categories/:category_id/scenes
pub async fn get_scenes_by_category_handler(
    State(uc): State<Arc<GetScenesByCategoryUseCase>>,
    Path(category_id): Path<String>,
) -> Response {
    info!("📱 [场景] 获取分类{}下的场景", category_id);
    match uc.execute(&category_id).await {
        Ok(scenes) => {
            let dtos: Vec<SceneDto> = scenes.iter().map(SceneDto::from).collect();
            (StatusCode::OK, Json(ApiResponse::success(dtos, "获取成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 获取场景失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取场景失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/mobile/scene/:scene_id
pub async fn get_scene_detail_handler(
    State(uc): State<Arc<GetSceneDetailUseCase>>,
    Path(scene_id): Path<String>,
) -> Response {
    info!("📱 [场景] 获取场景详情: {}", scene_id);
    match uc.execute(&scene_id).await {
        Ok(Some(detail)) => {
            let dto = SceneDetailDto::from(detail);
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Ok(None) => {
            let r = ApiResponse::<serde_json::Value>::error(404, "场景不存在");
            (StatusCode::NOT_FOUND, Json(r)).into_response()
        }
        Err(e) => {
            error!("❌ 获取场景详情失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取场景详情失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/mobile/scene/search?keyword=&page=&pageSize=
pub async fn search_scenes_handler(
    State(uc): State<Arc<SearchScenesUseCase>>,
    Query(params): Query<SearchQuery>,
) -> Response {
    let keyword = params.keyword.unwrap_or_default();
    let page = params.page.unwrap_or(1);
    let page_size = params.page_size.unwrap_or(20);

    info!("📱 [场景] 搜索: keyword={}", keyword);

    let cmd = SearchScenesCommand { keyword, page, page_size };
    match uc.execute(cmd).await {
        Ok(result) => {
            let dto = SearchScenesDto {
                total: result.total,
                page: result.page,
                page_size: result.page_size,
                scenes: result.scenes.iter().map(SceneDto::from).collect(),
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "搜索成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 搜索失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("搜索失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/mobile/scene/recommendations?limit=
pub async fn get_recommendations_handler(
    State(uc): State<Arc<GetRecommendationsUseCase>>,
    Query(params): Query<RecommendationsQuery>,
) -> Response {
    let limit = params.limit.unwrap_or(10);
    info!("📱 [场景] 获取推荐, limit={}", limit);

    match uc.execute(limit).await {
        Ok(scenes) => {
            let dtos: Vec<SceneDto> = scenes.iter().map(SceneDto::from).collect();
            (StatusCode::OK, Json(ApiResponse::success(dtos, "获取成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 获取推荐失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取推荐失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

// ===== 管理端处理器 =====

/// GET /api/v1/admin/scene/categories
pub async fn admin_list_categories_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
) -> Response {
    info!("🔧 [管理] 获取所有分类");
    match uc.list_categories().await {
        Ok(categories) => {
            let dtos: Vec<SceneCategoryDto> = categories.iter().map(SceneCategoryDto::from).collect();
            (StatusCode::OK, Json(ApiResponse::success(dtos, "获取成功"))).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// POST /api/v1/admin/scene/categories
pub async fn admin_create_category_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Json(req): Json<CreateCategoryRequest>,
) -> Response {
    info!("🔧 [管理] 创建分类: {}", req.name);
    let id = req.id.unwrap_or_else(|| format!("cat_{}", Uuid::new_v4().to_string().replace('-', "")[..12].to_string()));
    let cmd = CreateCategoryCommand {
        id,
        name: req.name,
        icon: req.icon,
        cover_image: req.cover_image,
        description: req.description,
        display_order: req.display_order.unwrap_or(0),
        is_new: req.is_new.unwrap_or(false),
    };
    match uc.create_category(cmd).await {
        Ok(category) => {
            let dto = SceneCategoryDto::from(&category);
            (StatusCode::CREATED, Json(ApiResponse::success(dto, "创建成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 创建分类失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// PUT /api/v1/admin/scene/categories/:id
pub async fn admin_update_category_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Path(id): Path<String>,
    Json(req): Json<UpdateCategoryRequest>,
) -> Response {
    info!("🔧 [管理] 更新分类: {}", id);
    let cmd = UpdateCategoryCommand {
        id,
        name: req.name,
        icon: req.icon,
        cover_image: req.cover_image,
        description: req.description,
        display_order: req.display_order,
        is_new: req.is_new,
        is_visible: req.is_visible,
    };
    match uc.update_category(cmd).await {
        Ok(category) => {
            let dto = SceneCategoryDto::from(&category);
            (StatusCode::OK, Json(ApiResponse::success(dto, "更新成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 更新分类失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// DELETE /api/v1/admin/scene/categories/:id
pub async fn admin_delete_category_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Path(id): Path<String>,
) -> Response {
    info!("🔧 [管理] 删除分类: {}", id);
    match uc.delete_category(&id).await {
        Ok(()) => {
            (StatusCode::OK, Json(ApiResponse::success(serde_json::json!({}), "删除成功"))).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/admin/scene/scenes
pub async fn admin_list_scenes_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Query(params): Query<AdminListQuery>,
) -> Response {
    let page = params.page.unwrap_or(1);
    let page_size = params.page_size.unwrap_or(20);
    let category_id = params.category_id.clone();

    info!("🔧 [管理] 获取场景列表, page={}, category_id={:?}", page, category_id);

    match uc.list_scenes_by_category(page, page_size, category_id.as_deref()).await {
        Ok((scenes, total)) => {
            let dto = SearchScenesDto {
                total,
                page,
                page_size,
                scenes: scenes.iter().map(SceneDto::from).collect(),
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// POST /api/v1/admin/scene/scenes
pub async fn admin_create_scene_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Json(req): Json<CreateSceneRequest>,
) -> Response {
    info!("🔧 [管理] 创建场景: {}", req.name);
    let id = req.id.unwrap_or_else(|| format!("scene_{}", Uuid::new_v4().to_string().replace('-', "")[..12].to_string()));
    let cmd = CreateSceneCommand {
        id,
        category_id: req.category_id,
        name: req.name,
        name_en: req.name_en,
        cover_image: req.cover_image,
        interactive_image: req.interactive_image,
        description: req.description,
        context: req.context,
        display_order: req.display_order.unwrap_or(0),
        is_new: req.is_new.unwrap_or(false),
        items_data: req.items_data,
    };
    match uc.create_scene(cmd).await {
        Ok(scene) => {
            let dto = SceneDto::from(&scene);
            (StatusCode::CREATED, Json(ApiResponse::success(dto, "创建成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 创建场景失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// PUT /api/v1/admin/scene/scenes/:id
pub async fn admin_update_scene_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Path(id): Path<String>,
    Json(req): Json<UpdateSceneRequest>,
) -> Response {
    info!("🔧 [管理] 更新场景: {}", id);
    let cmd = UpdateSceneCommand {
        id,
        name: req.name,
        name_en: req.name_en,
        cover_image: req.cover_image,
        interactive_image: req.interactive_image,
        description: req.description,
        context: req.context,
        display_order: req.display_order,
        is_new: req.is_new,
        is_visible: req.is_visible,
        items_data: req.items_data,
    };
    match uc.update_scene(cmd).await {
        Ok(scene) => {
            let dto = SceneDto::from(&scene);
            (StatusCode::OK, Json(ApiResponse::success(dto, "更新成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 更新场景失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// DELETE /api/v1/admin/scene/scenes/:id
pub async fn admin_delete_scene_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Path(id): Path<String>,
) -> Response {
    info!("🔧 [管理] 删除场景: {}", id);
    match uc.delete_scene(&id).await {
        Ok(()) => {
            (StatusCode::OK, Json(ApiResponse::success(serde_json::json!({}), "删除成功"))).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/admin/scene/scenes/:id
pub async fn admin_get_scene_detail_handler(
    State(uc): State<Arc<AdminSceneUseCase>>,
    Path(id): Path<String>,
) -> Response {
    match uc.get_scene_detail(&id).await {
        Ok(Some(detail)) => {
            let dto = SceneDetailDto::from(detail);
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Ok(None) => {
            let r = ApiResponse::<serde_json::Value>::error(404, "场景不存在");
            (StatusCode::NOT_FOUND, Json(r)).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("{}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}
