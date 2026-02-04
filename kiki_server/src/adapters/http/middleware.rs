// 应用中间件模块
// 统一处理跨切面关注点：CORS、认证、日志、错误处理等
// 创建时间: 2025-08-06

use crate::framework::logging::Logger;
use crate::utils::jwt::JwtUtils;
use axum::body::to_bytes;
use axum::{
    body::Body,
    extract::Request,
    http::{header, HeaderValue, Method, StatusCode},
    middleware::Next,
    response::Response,
    Json,
};
use serde_json::{json, Value};
use std::time::Instant;
use tower_http::cors::CorsLayer;
use uuid::Uuid;

/// 请求响应数据日志中间件
///
/// 统一记录所有HTTP请求和响应的详细信息，包括请求体和响应体
/// 包括请求参数、响应数据、处理时间等
/// 创建时间: 2025-08-10
pub async fn request_response_data_log_middleware(request: Request, next: Next) -> Response {
    let start_time = Instant::now();

    // 生成请求ID
    let request_id = Uuid::new_v4().to_string();

    // 提取请求信息（在消费request前）
    let method = request.method().clone();
    let uri = request.uri().clone();
    let path = uri.path().to_string();
    let query = uri.query().unwrap_or("").to_string();
    let headers = request.headers().clone();

    // 提取客户端IP
    let client_ip = headers
        .get("x-forwarded-for")
        .or_else(|| headers.get("x-real-ip"))
        .and_then(|hv| hv.to_str().ok())
        .unwrap_or("unknown")
        .to_string();

    // 读取请求体
    let (parts, body) = request.into_parts();
    let body_bytes = to_bytes(body, usize::MAX).await.unwrap_or_default();
    let request_body = if body_bytes.is_empty() {
        Value::Null
    } else {
        serde_json::from_slice::<Value>(&body_bytes)
            .unwrap_or_else(|_| json!({"raw": String::from_utf8_lossy(&body_bytes)}))
    };

    // 重新构建请求
    let mut request_with_id = Request::from_parts(parts, Body::from(body_bytes.clone()));

    // 添加请求ID到header
    request_with_id
        .headers_mut()
        .insert("x-request-id", HeaderValue::from_str(&request_id).unwrap());

    // 记录格式化的请求日志
    let request_log = json!({
        "type": "HTTP_REQUEST",
        "request_id": request_id,
        "method": method.to_string(),
        "path": path,
        "query": if query.is_empty() { Value::Null } else { Value::String(query) },
        "client_ip": client_ip,
        "user_agent": headers.get("user-agent").and_then(|h| h.to_str().ok()).unwrap_or("unknown"),
        "content_type": headers.get("content-type").and_then(|h| h.to_str().ok()).unwrap_or("unknown"),
        "body": mask_sensitive_fields(request_body),
        "timestamp": chrono::Utc::now().to_rfc3339()
    });

    // 使用格式化的请求日志
    let formatted_request = serde_json::to_string_pretty(&request_log)
        .unwrap_or_else(|_| "无法格式化请求日志".to_string());
    Logger::info(&format!("📥 [REQUEST] {}", formatted_request));

    // 处理请求
    let response = next.run(request_with_id).await;

    // 计算处理时间
    let duration = start_time.elapsed();
    let status = response.status();

    // 读取响应体
    let (response_parts, response_body) = response.into_parts();
    let response_body_bytes = to_bytes(response_body, usize::MAX)
        .await
        .unwrap_or_default();
    let response_data = if response_body_bytes.is_empty() {
        Value::Null
    } else {
        serde_json::from_slice::<Value>(&response_body_bytes)
            .unwrap_or_else(|_| json!({"raw": String::from_utf8_lossy(&response_body_bytes)}))
    };

    // 记录格式化的响应日志
    let response_log = json!({
        "type": "HTTP_RESPONSE",
        "request_id": request_id,
        "method": method.to_string(),
        "path": path,
        "status_code": status.as_u16(),
        "status_text": status.canonical_reason().unwrap_or("Unknown"),
        "duration_ms": duration.as_millis(),
        "content_type": response_parts.headers.get("content-type").and_then(|h| h.to_str().ok()).unwrap_or("unknown"),
        "body": mask_sensitive_response_fields(response_data),
        "timestamp": chrono::Utc::now().to_rfc3339()
    });

    // 使用格式化的响应日志
    let formatted_response = serde_json::to_string_pretty(&response_log)
        .unwrap_or_else(|_| "无法格式化响应日志".to_string());
    Logger::info(&format!("📤 [RESPONSE] {}", formatted_response));

    // 如果是错误状态，记录额外的错误信息
    if status.is_client_error() || status.is_server_error() {
        let error_summary = json!({
            "type": "HTTP_ERROR",
            "request_id": request_id,
            "method": method.to_string(),
            "path": path,
            "status_code": status.as_u16(),
            "status_text": status.canonical_reason().unwrap_or("Unknown"),
            "duration_ms": duration.as_millis(),
            "timestamp": chrono::Utc::now().to_rfc3339()
        });
        let formatted_error = serde_json::to_string_pretty(&error_summary)
            .unwrap_or_else(|_| "无法格式化错误日志".to_string());
        Logger::warn(&format!("⚠️ [ERROR] {}", formatted_error));
    }

    // 重新构建响应
    Response::from_parts(response_parts, Body::from(response_body_bytes))
}

/// 屏蔽请求中的敏感字段
fn mask_sensitive_fields(mut data: Value) -> Value {
    if let Some(obj) = data.as_object_mut() {
        for (key, value) in obj.iter_mut() {
            if key.to_lowercase().contains("password")
                || key.to_lowercase().contains("token")
                || key.to_lowercase().contains("secret")
            {
                *value = json!("***masked***");
            }
        }
    }
    data
}

/// 屏蔽响应中的敏感字段
fn mask_sensitive_response_fields(mut data: Value) -> Value {
    if let Some(obj) = data.as_object_mut() {
        // 递归处理嵌套对象
        mask_nested_sensitive_fields(obj);
    }
    data
}

/// 递归屏蔽嵌套对象中的敏感字段
fn mask_nested_sensitive_fields(obj: &mut serde_json::Map<String, Value>) {
    for (key, value) in obj.iter_mut() {
        if key.to_lowercase().contains("token") {
            // 对token进行部分脱敏，只显示前后几位
            if let Some(token_str) = value.as_str() {
                if token_str.len() > 16 {
                    let masked = format!(
                        "{}...{}",
                        &token_str[..8],
                        &token_str[token_str.len() - 8..]
                    );
                    *value = json!(masked);
                } else {
                    *value = json!("***masked***");
                }
            }
        } else if value.is_object() {
            if let Some(nested_obj) = value.as_object_mut() {
                mask_nested_sensitive_fields(nested_obj);
            }
        } else if value.is_array() {
            if let Some(array) = value.as_array_mut() {
                for item in array {
                    if let Some(nested_obj) = item.as_object_mut() {
                        mask_nested_sensitive_fields(nested_obj);
                    }
                }
            }
        }
    }
}

/// 错误处理中间件
///
/// 统一处理应用程序错误，返回标准化的错误响应
/// 创建时间: 2025-08-06
/// 参数: request - HTTP请求, next - 下一个处理器
/// 返回: HTTP响应
pub async fn error_handling_middleware(request: Request<Body>, next: Next) -> Response {
    let response = next.run(request).await;

    // 如果是错误状态码，记录日志
    if response.status().is_client_error() || response.status().is_server_error() {
        Logger::http_error(json!({
            "status": response.status().as_u16(),
            "message": "HTTP请求处理出错"
        }));
    }

    response
}

/// 创建CORS层
///
/// 配置跨域资源共享，允许前端访问API
/// 创建时间: 2025-08-06
/// 参数: allowed_origins - 允许的源域名列表
/// 返回: CORS层配置
pub fn create_cors_layer(allowed_origins: Vec<String>) -> CorsLayer {
    let origins: Result<Vec<HeaderValue>, _> = allowed_origins
        .into_iter()
        .map(|origin| origin.parse())
        .collect();

    match origins {
        Ok(origins) => CorsLayer::new()
            .allow_origin(origins)
            .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
            .allow_headers([header::CONTENT_TYPE, header::AUTHORIZATION, header::ACCEPT])
            .allow_credentials(true),
        Err(e) => {
            Logger::warn(format!("CORS配置错误: {}", e));
            // 返回默认的宽松CORS配置
            CorsLayer::permissive()
        }
    }
}

/// 标准化错误响应
///
/// 创建统一格式的错误响应JSON
/// 创建时间: 2025-08-06
/// 参数: status - HTTP状态码, error_code - 错误码, message - 错误消息
/// 返回: JSON响应
pub fn create_error_response(
    status: StatusCode,
    error_code: &str,
    message: &str,
) -> (StatusCode, Json<Value>) {
    let error_response = json!({
        "error": {
            "code": error_code,
            "message": message,
            "status": status.as_u16(),
            "timestamp": chrono::Utc::now().to_rfc3339()
        }
    });

    (status, Json(error_response))
}

/// JWT认证中间件
///
/// 验证JWT token，提取用户信息
/// 支持白名单机制，登录和注册接口跳过认证
/// 创建时间: 2025-08-06
/// 参数: request - HTTP请求, next - 下一个处理器
/// 返回: HTTP响应
pub async fn jwt_auth_middleware(
    request: Request<Body>,
    next: Next,
) -> Result<Response, (StatusCode, Json<Value>)> {
    let path = request.uri().path();

    // 白名单路径，这些路径不需要JWT认证
    let whitelist_paths = vec!["/api/auth/login", "/health"];

    // 检查是否在白名单中
    if whitelist_paths
        .iter()
        .any(|&whitelist_path| path == whitelist_path)
    {
        Logger::info(format!("🔓 [JWT中间件] 白名单路径跳过认证: {}", path));
        return Ok(next.run(request).await);
    }

    // 从Authorization头获取token
    let auth_header = request
        .headers()
        .get(header::AUTHORIZATION)
        .and_then(|header| header.to_str().ok());

    if let Some(auth_header) = auth_header {
        if auth_header.starts_with("Bearer ") {
            let token = &auth_header[7..];

            // 使用JWT工具库验证token
            match JwtUtils::verify_token(token) {
                Ok(claims) => {
                    Logger::info(format!(
                        "🔐 [JWT中间件] Token验证通过: 用户ID={}, 手机号={}",
                        claims.sub, claims.phone
                    ));
                    Ok(next.run(request).await)
                }
                Err(e) => {
                    Logger::warn(format!(
                        "⚠️ [JWT中间件] Token验证失败: {} - 路径: {}",
                        e, path
                    ));
                    Err(create_error_response(
                        StatusCode::UNAUTHORIZED,
                        "INVALID_TOKEN",
                        "无效的JWT令牌",
                    ))
                }
            }
        } else {
            Logger::warn(format!("⚠️ [JWT中间件] Authorization头格式错误: {}", path));
            Err(create_error_response(
                StatusCode::UNAUTHORIZED,
                "INVALID_AUTH_HEADER",
                "Authorization头格式错误",
            ))
        }
    } else {
        Logger::warn(format!("⚠️ [JWT中间件] 缺少Authorization头: {}", path));
        Err(create_error_response(
            StatusCode::UNAUTHORIZED,
            "MISSING_AUTH_TOKEN",
            "缺少Authorization头",
        ))
    }
}

/// 限流中间件
///
/// 基于IP地址的简单限流
/// 创建时间: 2025-08-06
/// 参数: request - HTTP请求, next - 下一个处理器
/// 返回: HTTP响应
pub async fn rate_limit_middleware(
    request: Request<Body>,
    next: Next,
) -> Result<Response, (StatusCode, Json<Value>)> {
    // TODO: 实现基于Redis的分布式限流
    // 目前先简单放行

    Ok(next.run(request).await)
}

/// 从请求中提取JWT Claims
///
/// 辅助函数，用于从Authorization头中提取并验证JWT token
/// 创建时间: 2026-01-29
/// 参数: request - HTTP请求
/// 返回: JWT Claims或错误响应
fn extract_claims(request: &Request<Body>) -> Result<crate::utils::jwt::Claims, (StatusCode, Json<Value>)> {
    let path = request.uri().path();

    // 从Authorization头获取token
    let auth_header = request
        .headers()
        .get(header::AUTHORIZATION)
        .and_then(|header| header.to_str().ok());

    if let Some(auth_header) = auth_header {
        if auth_header.starts_with("Bearer ") {
            let token = &auth_header[7..];

            // 使用JWT工具库验证token
            match JwtUtils::verify_token(token) {
                Ok(claims) => {
                    Logger::info(format!(
                        "🔐 [认证] Token验证通过: 用户ID={}, 角色={}",
                        claims.sub, claims.role_type
                    ));
                    Ok(claims)
                }
                Err(e) => {
                    Logger::warn(format!(
                        "⚠️ [认证] Token验证失败: {} - 路径: {}",
                        e, path
                    ));
                    Err(create_error_response(
                        StatusCode::UNAUTHORIZED,
                        "INVALID_TOKEN",
                        "无效的JWT令牌",
                    ))
                }
            }
        } else {
            Logger::warn(format!("⚠️ [认证] Authorization头格式错误: {}", path));
            Err(create_error_response(
                StatusCode::UNAUTHORIZED,
                "INVALID_AUTH_HEADER",
                "Authorization头格式错误",
            ))
        }
    } else {
        Logger::warn(format!("⚠️ [认证] 缺少Authorization头: {}", path));
        Err(create_error_response(
            StatusCode::UNAUTHORIZED,
            "MISSING_AUTH_TOKEN",
            "缺少Authorization头",
        ))
    }
}

/// 管理端认证中间件
///
/// 仅允许Admin角色(role_type=2)访问
/// 用于保护管理端API端点
/// 创建时间: 2026-01-29
/// 参数: request - HTTP请求, next - 下一个处理器
/// 返回: HTTP响应
pub async fn admin_auth_middleware(
    request: Request<Body>,
    next: Next,
) -> Result<Response, (StatusCode, Json<Value>)> {
    let path = request.uri().path().to_string();

    // 提取并验证JWT claims
    let claims = extract_claims(&request)?;

    // 检查角色是否为Admin (role_type == 2)
    if claims.role_type == 2 {
        Logger::info(format!(
            "✅ [管理端认证] Admin用户 {} 访问: {}",
            claims.sub, path
        ));
        Ok(next.run(request).await)
    } else {
        Logger::warn(format!(
            "❌ [管理端认证] 非Admin用户 {} (角色={}) 尝试访问管理端: {}",
            claims.sub, claims.role_type, path
        ));
        Err(create_error_response(
            StatusCode::FORBIDDEN,
            "INSUFFICIENT_PERMISSIONS",
            "需要管理员权限",
        ))
    }
}

/// 移动端认证中间件
///
/// 允许User(role_type=1)和Admin(role_type=2)角色访问
/// 用于保护移动端API端点
/// 创建时间: 2026-01-29
/// 参数: request - HTTP请求, next - 下一个处理器
/// 返回: HTTP响应
pub async fn mobile_auth_middleware(
    request: Request<Body>,
    next: Next,
) -> Result<Response, (StatusCode, Json<Value>)> {
    let path = request.uri().path().to_string();

    // 提取并验证JWT claims
    let claims = extract_claims(&request)?;

    // 允许User(1)和Admin(2)角色
    if claims.role_type == 1 || claims.role_type == 2 {
        Logger::info(format!(
            "✅ [移动端认证] 用户 {} (角色={}) 访问: {}",
            claims.sub, claims.role_type, path
        ));
        Ok(next.run(request).await)
    } else {
        Logger::warn(format!(
            "❌ [移动端认证] 无效角色 {} (角色={}) 尝试访问: {}",
            claims.sub, claims.role_type, path
        ));
        Err(create_error_response(
            StatusCode::FORBIDDEN,
            "INVALID_ROLE",
            "无效的用户角色",
        ))
    }
}
