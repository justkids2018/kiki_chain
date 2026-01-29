# Hi Kiki 项目 API 设计规范

> **适用范围**: Hi Kiki 后端服务 API
> **架构**: Clean Architecture (4 Layers)
> **版本**: v2.0
> **最后更新**: 2026-01-19

---

## 🌐 Hi Kiki API 规范

### 1. 基础路径

所有 API 使用统一前缀：
```
/api/v1/{module}/{action}
```

**示例**:
```
/api/v1/auth/login
/api/v1/auth/register
/api/v1/users/{id}
```

---

### 2. 统一响应格式

#### 成功响应
```rust
// src/shared/api_response.rs
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub message: String,
    pub errorcode: Option<i32>,
}
```

**示例**:
```json
{
  "success": true,
  "data": {
    "uid": "user123",
    "name": "Alice",
    "token": "eyJ..."
  },
  "message": "登录成功",
  "errorcode": null
}
```

---

#### 错误响应
```json
{
  "success": false,
  "data": null,
  "message": "用户不存在或密码错误",
  "errorcode": 202
}
```

---

### 3. 错误码规范

| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
| 100-199 | 验证错误 | 400 |
| 200 | 用户已存在 | 409 |
| 201 | 用户不存在 | 404 |
| 202 | 认证失败 | 401 |
| 203 | 权限不足 | 403 |
| 500+ | 服务器错误 | 500 |

**定义位置**：`src/shared/api_response.rs`

---

### 4. 认证规范

#### JWT Token
```
Header: Authorization: Bearer {token}
```

#### 白名单（无需认证）
```rust
// src/adapters/http/middleware/jwt_auth_middleware.rs
const AUTH_WHITELIST: &[&str] = &[
    "/api/v1/auth/login",
    "/api/v1/auth/register",
];
```

---

### 5. 请求/响应 DTOs

**位置**: `src/adapters/http/{module}/dtos.rs`

**示例**:
```rust
// src/adapters/http/auth/dtos.rs

// 请求 DTO
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    #[serde(alias = "phone", alias = "email")]
    pub identifier: String,
    pub password: String,
}

// 响应 DTO
#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub uid: String,
    pub name: String,
    pub email: String,
    pub phone: String,
    pub token: String,
    pub role_id: i32,
    pub message: String,
}
```

---

### 6. API 文档生成规范

#### 模板
```markdown
## 接口名称：用户登录

**请求方法**：POST
**请求路径**：`/api/v1/auth/login`

### 请求参数

#### Body 参数（JSON）
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| identifier | string | 是 | 手机号或邮箱 |
| password | string | 是 | 密码 |

### 请求示例
```json
POST /api/v1/auth/login
{
  "identifier": "13800138000",
  "password": "password123"
}
```

### 响应参数
| 字段名 | 类型 | 说明 |
|--------|------|------|
| uid | string | 用户唯一标识 |
| name | string | 用户姓名 |
| email | string | 邮箱 |
| phone | string | 手机号 |
| token | string | JWT Token |
| role_id | int | 角色 ID |
| message | string | 提示信息 |

### 响应示例
```json
{
  "success": true,
  "data": {
    "uid": "user123",
    "name": "Alice",
    "email": "alice@example.com",
    "phone": "13800138000",
    "token": "eyJhbGc...",
    "role_id": 1,
    "message": "登录成功"
  },
  "message": "登录成功",
  "errorcode": null
}
```

### 状态码说明
- `200` - 登录成功
- `401` - 认证失败（用户不存在或密码错误）
- `400` - 参数验证失败

### 备注
- 支持手机号或邮箱登录
- Token 有效期：7 天
```

---

### 7. API 实现流程

```
1. 定义 DTOs
   ↓
2. 定义 Use Case Command/Response
   ↓
3. 实现 Use Case
   ↓
4. 实现 HTTP Handler
   ↓
5. 注册路由
   ↓
6. 生成 API 文档
```

---

## 📚 相关文档

- `doc/api/backend_api_documentation.md` - 完整 API 文档
- `src/shared/api_response.rs` - 统一响应格式
- `src/adapters/http/` - HTTP Handler 和 DTOs

---

**版本**: v2.0
**最后更新**: 2026-01-19
