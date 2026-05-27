use axum::{
    extract::State,
    http::{header, HeaderMap, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use serde::Deserialize;
use sqlx::Row;
use tracing::{error, info};

use crate::framework::bootstrap::AppState;
use crate::shared::api_response::ApiResponse;
use crate::utils::jwt::JwtUtils;

#[derive(Debug, Deserialize)]
pub struct SubmitFeedbackRequest {
    pub feedback_type: Option<String>,
    pub content: String,
    pub contact: Option<String>,
    pub page: Option<String>,
}

/// POST /api/v1/mobile/feedback
pub async fn submit_feedback_handler(
    State(app_state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<SubmitFeedbackRequest>,
) -> Response {
    let claims = match extract_jwt_claims(&headers) {
        Ok(c) => c,
        Err(resp) => return resp,
    };

    let content = payload.content.trim();
    if content.len() < 2 {
        let r = ApiResponse::<serde_json::Value>::error(400, "反馈内容至少 2 个字符");
        return (StatusCode::BAD_REQUEST, Json(r)).into_response();
    }

    if content.len() > 2000 {
        let r = ApiResponse::<serde_json::Value>::error(400, "反馈内容不能超过 2000 字符");
        return (StatusCode::BAD_REQUEST, Json(r)).into_response();
    }

    let feedback_type = payload
        .feedback_type
        .as_deref()
        .unwrap_or("general")
        .trim()
        .to_string();
    let contact = payload.contact.as_deref().map(str::trim).filter(|v| !v.is_empty());
    let page = payload.page.as_deref().map(str::trim).filter(|v| !v.is_empty());

    info!(
        "📱 [反馈] 用户提交反馈: uid={}, type={}, page={:?}",
        claims.sub, feedback_type, page
    );

    match sqlx::query(
        r#"
        INSERT INTO user_feedback (user_id, feedback_type, content, contact, page, status)
        VALUES ($1, $2, $3, $4, $5, 'pending')
        RETURNING id, created_at
        "#,
    )
    .bind(&claims.sub)
    .bind(&feedback_type)
    .bind(content)
    .bind(contact)
    .bind(page)
    .fetch_one(&app_state.pool)
    .await
    {
        Ok(row) => {
            let id: i64 = row.get("id");
            let created_at: chrono::NaiveDateTime = row.get("created_at");
            let data = serde_json::json!({
                "id": id,
                "status": "pending",
                "created_at": created_at.and_utc().to_rfc3339()
            });
            (StatusCode::OK, Json(ApiResponse::success(data, "提交成功"))).into_response()
        }
        Err(e) => {
            error!("❌ [反馈] 提交失败: {}", e);
            let r = ApiResponse::<serde_json::Value>::error(500, format!("提交失败: {}", e));
            (StatusCode::INTERNAL_SERVER_ERROR, Json(r)).into_response()
        }
    }
}

fn extract_jwt_claims(headers: &HeaderMap) -> Result<crate::utils::jwt::Claims, Response> {
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
