
### 开发规范

### 新业务开发指南



根据本项目的DDD 架构，依据用户信息查询为例，提供开发新业务的指南

#### 1、添加路由 main_routes.rs 中增加用户信息路由
```
pub fn create_routes(app_state: AppState) -> Router {
    ....
    let user_routes = user::create_user_routes(app_state.clone());
    
    let app_router = Router::new()
        .merge(user_routes)
        .....    
    app_router
}
```

#### 2、创建 user.rs，根据需求增加请求方法

```
pub fn create_user_routes(app_state: Arc<AppState>) -> Router {
    Router::new()
        .route("/api/user", get(get_user_handler))
        .with_state(app_state)
}

```

###  请求的结果都要返回结构 api_response.rs 方式里的 success和，error 两种方式

```
  /// 创建成功响应
  pub fn success(data: T, message: impl Into<String>) -> Self {
      Self {
          success: true,
          data: Some(data),
          errorcode: None,
          message: message.into(),
      }
  }
  /// 创建失败响应
  pub fn error(errorcode: u32, message: impl Into<String>) -> ApiResponse<Value> {
      ApiResponse {
          success: false,
          data: None,
          errorcode: Some(errorcode),
          message: message.into(),
      }
  }
```