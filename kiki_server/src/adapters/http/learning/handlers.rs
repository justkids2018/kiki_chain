// 学习进度 HTTP 处理器

use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use std::sync::Arc;
use tracing::{error, info};

use crate::core::use_cases::learning::{
    GetProgressUseCase, SubmitProgressUseCase, GetUserSummaryUseCase, GetUserProgressListUseCase,
    SubmitProgressCommand,
};
use crate::shared::api_response::ApiResponse;

use super::dtos::*;

/// GET /api/v1/learning/progress/:user_id/:scene_id
pub async fn get_progress_handler(
    State(uc): State<Arc<GetProgressUseCase>>,
    Path((user_id, scene_id)): Path<(String, String)>,
) -> Response {
    info!("📚 [学习] 获取进度: user={}, scene={}", user_id, scene_id);

    match uc.execute(&user_id, &scene_id).await {
        Ok(Some(progress)) => {
            let dto = ProgressResponseDto::from(&progress);
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Ok(None) => {
            let r = ApiResponse::<serde_json::Value>::error(404, "未找到学习进度".to_string());
            (StatusCode::NOT_FOUND, Json(r)).into_response()
        }
        Err(e) => {
            error!("❌ 获取进度失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取进度失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// POST /api/v1/learning/progress/batch
pub async fn submit_progress_handler(
    State(uc): State<Arc<SubmitProgressUseCase>>,
    Json(req): Json<SubmitProgressRequestDto>,
) -> Response {
    info!("💾 [学习] 批量提交: user={}, scene={}, stars={}",
          req.user_id, req.scene_id, req.stars_earned);

    // 转换DTO
    let cmd = SubmitProgressCommand {
        user_id: req.user_id,
        scene_id: req.scene_id,
        learned_regions: req.learned_regions.into_iter().map(Into::into).collect(),
        stars_earned: req.stars_earned,
        is_completed: req.is_completed,
        study_time: req.study_time,
    };

    match uc.execute(cmd).await {
        Ok(result) => {
            let dto = SubmitProgressResponseDto {
                total_stars: result.total_stars,
                total_score: result.total_score,
                user_total_stars: result.user_total_stars,
                user_total_score: result.user_total_score,
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "保存成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 提交进度失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("提交进度失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/learning/user/:user_id/summary
pub async fn get_user_summary_handler(
    State(uc): State<Arc<GetUserSummaryUseCase>>,
    Path(user_id): Path<String>,
) -> Response {
    info!("📊 [学习] 获取用户汇总: user={}", user_id);

    match uc.execute(&user_id).await {
        Ok(Some(summary)) => {
            let dto = UserSummaryResponseDto::from(&summary);
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Ok(None) => {
            // 返回空汇总
            let dto = UserSummaryResponseDto {
                user_id,
                total_stars: 0,
                total_score: 0,
                completed_scenes: 0,
                total_study_time: 0,
                last_active_at: None,
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 获取用户汇总失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取用户汇总失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/learning/progress/user/:user_id/all
pub async fn get_user_progress_list_handler(
    State(uc): State<Arc<GetUserProgressListUseCase>>,
    Path(user_id): Path<String>,
) -> Response {
    info!("📚 [学习] 获取所有场景进度: user={}", user_id);

    match uc.execute(&user_id).await {
        Ok(progresses) => {
            let dtos: Vec<ProgressResponseDto> = progresses.iter().map(ProgressResponseDto::from).collect();
            (StatusCode::OK, Json(ApiResponse::success(dtos, "获取成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 获取所有场景进度失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取所有场景进度失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// GET /api/v1/learning/progress/phone/:phone/all
pub async fn get_user_progress_by_phone_handler(
    State(uc): State<Arc<GetUserProgressListUseCase>>,
    State(user_repo): State<Arc<dyn crate::core::ports::UserRepository>>,
    Path(phone): Path<String>,
) -> Response {
    info!("📚 [学习] 根据手机号获取所有场景进度: phone={}", phone);

    // 先通过手机号查找用户
    let user = match user_repo.find_by_phone(&phone).await {
        Ok(Some(u)) => u,
        Ok(None) => {
            let r = ApiResponse::<serde_json::Value>::error(404, "用户不存在");
            return (StatusCode::NOT_FOUND, Json(r)).into_response();
        }
        Err(e) => {
            error!("❌ 查找用户失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("查找用户失败: {}", e));
            return (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response();
        }
    };

    let user_id = user.uid();

    match uc.execute(user_id).await {
        Ok(progresses) => {
            let dtos: Vec<ProgressResponseDto> = progresses.iter().map(ProgressResponseDto::from).collect();
            (StatusCode::OK, Json(ApiResponse::success(dtos, "获取成功"))).into_response()
        }
        Err(e) => {
            error!("❌ 获取所有场景进度失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取所有场景进度失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}
