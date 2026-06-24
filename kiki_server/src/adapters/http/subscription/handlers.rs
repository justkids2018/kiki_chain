use axum::{
    extract::{Path, Query, State},
    http::{header, HeaderMap, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use std::sync::Arc;
use tracing::{error, info};

use crate::core::use_cases::{
    ConfirmOrderCommand, CreateOrderCommand, ProductQuery, ResolveChannelCommand,
    SubscriptionUseCase,
};
use crate::shared::api_response::ApiResponse;
use crate::utils::jwt::JwtUtils;

use super::dtos::*;

pub async fn resolve_channel_handler(
    State(uc): State<Arc<SubscriptionUseCase>>,
    Json(req): Json<ResolveChannelRequest>,
) -> Response {
    info!(
        "💳 [订阅] 解析渠道: region={}, platform={}",
        req.region, req.platform
    );

    let resolution = uc.resolve_channel(ResolveChannelCommand {
        region: req.region,
        platform: req.platform,
        distribution_channel: req.distribution_channel,
        client_capabilities: req.client_capabilities,
    });

    (
        StatusCode::OK,
        Json(ApiResponse::success(
            serde_json::Value::from(resolution),
            "解析成功",
        )),
    )
        .into_response()
}

pub async fn list_products_handler(
    State(uc): State<Arc<SubscriptionUseCase>>,
    Query(query): Query<ProductsQuery>,
) -> Response {
    let product_query = ProductQuery {
        region: query.region.unwrap_or_else(|| "cn".to_string()),
        platform: query.platform.unwrap_or_else(|| "ios".to_string()),
        distribution_channel: query.distribution_channel,
    };

    match uc.list_products(product_query).await {
        Ok((payment_channel, products)) => {
            let dto = ProductsResponse {
                payment_channel,
                products,
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Err(e) => domain_error_response(e),
    }
}

pub async fn get_entitlement_handler(
    State(uc): State<Arc<SubscriptionUseCase>>,
    headers: HeaderMap,
) -> Response {
    let claims = match extract_jwt_claims(&headers) {
        Ok(c) => c,
        Err(resp) => return resp,
    };

    match uc.get_entitlement(&claims.sub).await {
        Ok(entitlement) => {
            let dto = EntitlementResponse::from(entitlement);
            (StatusCode::OK, Json(ApiResponse::success(dto, "获取成功"))).into_response()
        }
        Err(e) => domain_error_response(e),
    }
}

pub async fn create_order_handler(
    State(uc): State<Arc<SubscriptionUseCase>>,
    headers: HeaderMap,
    Json(req): Json<CreateOrderRequest>,
) -> Response {
    let claims = match extract_jwt_claims(&headers) {
        Ok(c) => c,
        Err(resp) => return resp,
    };

    match uc
        .create_order(CreateOrderCommand {
            user_id: claims.sub,
            product_id: req.product_id,
            region: req.region,
            platform: req.platform,
            distribution_channel: req.distribution_channel,
        })
        .await
    {
        Ok(order) => {
            let dto = OrderResponse::from(order);
            (
                StatusCode::CREATED,
                Json(ApiResponse::success(dto, "创建成功")),
            )
                .into_response()
        }
        Err(e) => domain_error_response(e),
    }
}

pub async fn confirm_order_handler(
    State(uc): State<Arc<SubscriptionUseCase>>,
    Path(order_id): Path<String>,
    headers: HeaderMap,
    Json(req): Json<ConfirmOrderRequest>,
) -> Response {
    let claims = match extract_jwt_claims(&headers) {
        Ok(c) => c,
        Err(resp) => return resp,
    };

    match uc
        .confirm_order(ConfirmOrderCommand {
            user_id: claims.sub,
            order_id,
            purchase_token: req.purchase_token,
            sandbox: req.sandbox,
        })
        .await
    {
        Ok(order) => {
            let dto = ConfirmOrderResponse {
                order_id: order.order_id,
                status: order.status,
                is_vip: true,
                vip_expire_at: order.vip_expire_at.map(|dt| dt.to_rfc3339()),
            };
            (StatusCode::OK, Json(ApiResponse::success(dto, "确认成功"))).into_response()
        }
        Err(e) => domain_error_response(e),
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

fn domain_error_response(e: crate::core::errors::DomainError) -> Response {
    error!("❌ [订阅] 请求失败: {}", e);
    let r = ApiResponse::from_domain_error(&e);
    let status = r.http_status();
    (status, Json(r)).into_response()
}
