// 用户 HTTP 处理器

use axum::{
    extract::{Request, State},
    http::{header, HeaderMap, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use std::sync::Arc;
use tracing::{error, info};

use crate::core::ports::UserRepository;
use crate::shared::api_response::ApiResponse;
use crate::utils::jwt::JwtUtils;

use super::dtos::{UpdateProfileRequest, UserProfileDto};

/// GET /api/v1/mobile/user/profile
/// 从 JWT Claims 获取用户 ID，然后查询数据库返回完整用户信息
pub async fn get_profile_handler(
    State(repo): State<Arc<dyn UserRepository>>,
    request: Request,
) -> Response {
    // 从 Authorization 头提取 JWT
    let claims = match extract_jwt_claims(&request) {
        Ok(c) => c,
        Err(resp) => return resp,
    };

    info!("📱 [用户] 获取用户信息: uid={}", claims.sub);

    match repo.find_by_uid(&claims.sub).await {
        Ok(Some(user)) => {
            let dto = UserProfileDto {
                uid: user.uid().to_string(),
                name: if user.name().is_empty() {
                    "暂无".to_string()
                } else {
                    user.name().to_string()
                },
                phone: user.phone().to_string(),
                email: user.email().to_string(),
                role_type: user.role_type(),
                is_vip: user.is_vip(),
                vip_expire_at: user.vip_expire_at().map(|t| t.to_rfc3339()),
                created_at: user.created_at().to_rfc3339(),
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Ok(None) => {
            let r = ApiResponse::<serde_json::Value>::error(404, "用户不存在");
            (StatusCode::NOT_FOUND, Json(r)).into_response()
        }
        Err(e) => {
            error!("❌ 获取用户失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("获取用户失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

/// PUT /api/v1/mobile/user/profile
pub async fn update_profile_handler(
    State(_repo): State<Arc<dyn UserRepository>>,
    headers: HeaderMap,
    Json(payload): Json<UpdateProfileRequest>,
) -> Response {
    let claims = match extract_jwt_claims_from_headers(&headers) {
        Ok(c) => c,
        Err(resp) => return resp,
    };

    info!("📱 [用户] 更新用户信息: uid={}", claims.sub);

    match _repo
        .update_profile(&claims.sub, payload.name.as_deref(), payload.email.as_deref())
        .await
    {
        Ok(Some(user)) => {
            let dto = UserProfileDto {
                uid: user.uid().to_string(),
                name: user.name().to_string(),
                phone: user.phone().to_string(),
                email: user.email().to_string(),
                role_type: user.role_type(),
                is_vip: user.is_vip(),
                vip_expire_at: user.vip_expire_at().map(|t| t.to_rfc3339()),
                created_at: user.created_at().to_rfc3339(),
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "更新成功"))).into_response()
        }
        Ok(None) => {
            let r = ApiResponse::<serde_json::Value>::error(404, "用户不存在");
            (StatusCode::NOT_FOUND, Json(r)).into_response()
        }
        Err(e) => {
            let r = ApiResponse::<serde_json::Value>::error(500, format!("更新用户失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

// ===== 辅助函数 =====

fn extract_jwt_claims(
    request: &Request,
) -> Result<crate::utils::jwt::Claims, Response> {
    extract_jwt_claims_from_headers(request.headers())
}

fn extract_jwt_claims_from_headers(
    headers: &HeaderMap,
) -> Result<crate::utils::jwt::Claims, Response> {
    let auth_header = headers
        .get(header::AUTHORIZATION)
        .and_then(|h| h.to_str().ok());

    match auth_header {
        Some(h) if h.starts_with("Bearer ") => {
            let token = &h[7..];
            JwtUtils::verify_token(token).map_err(|_| {
                let r = ApiResponse::<serde_json::Value>::error(401, "无效的令牌");
                (StatusCode::UNAUTHORIZED, Json(r)).into_response()
            })
        }
        _ => {
            let r = ApiResponse::<serde_json::Value>::error(401, "缺少认证令牌");
            Err((StatusCode::UNAUTHORIZED, Json(r)).into_response())
        }
    }
}
