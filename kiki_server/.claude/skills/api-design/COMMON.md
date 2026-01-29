# 通用 API 设计规范 (Common API Design Standards)

> **适用范围**: 所有项目的 RESTful API 设计
> **版本**: v1.0
> **最后更新**: 2026-01-19

---

## 📐 RESTful API 设计原则

### 1. 使用标准 HTTP 方法

| 方法 | 用途 | 示例 |
|------|------|------|
| GET | 获取资源 | `GET /api/v1/users/123` |
| POST | 创建资源 | `POST /api/v1/users` |
| PUT | 完整更新资源 | `PUT /api/v1/users/123` |
| PATCH | 部分更新资源 | `PATCH /api/v1/users/123` |
| DELETE | 删除资源 | `DELETE /api/v1/users/123` |

---

### 2. URL 设计规范

#### 使用名词，不使用动词
```
✅ GET  /api/v1/users
✅ POST /api/v1/users
❌ GET  /api/v1/getUsers
❌ POST /api/v1/createUser
```

#### 使用复数形式
```
✅ /api/v1/users
✅ /api/v1/products
❌ /api/v1/user
❌ /api/v1/product
```

#### 使用层级表示关系
```
✅ /api/v1/users/123/orders
✅ /api/v1/orders/456/items
```

---

### 3. 请求参数规范

#### 路径参数（必填资源标识）
```
GET /api/v1/users/{id}
DELETE /api/v1/orders/{orderId}
```

#### 查询参数（过滤、分页、排序）
```
GET /api/v1/users?page=1&limit=20&sort=created_at
GET /api/v1/products?category=electronics&min_price=100
```

#### 请求体（创建/更新数据）
```json
POST /api/v1/users
{
  "name": "Alice",
  "email": "alice@example.com",
  "password": "******"
}
```

---

### 4. 响应格式规范

#### 统一响应结构
```json
{
  "success": true,
  "data": { ... },
  "message": "操作成功",
  "errorcode": null
}
```

#### 错误响应
```json
{
  "success": false,
  "data": null,
  "message": "用户不存在",
  "errorcode": 201
}
```

---

### 5. HTTP 状态码规范

| 状态码 | 说明 | 使用场景 |
|--------|------|----------|
| 200 | OK | 成功获取资源 |
| 201 | Created | 成功创建资源 |
| 204 | No Content | 成功删除资源（无返回内容） |
| 400 | Bad Request | 请求参数错误 |
| 401 | Unauthorized | 未认证 |
| 403 | Forbidden | 无权限 |
| 404 | Not Found | 资源不存在 |
| 409 | Conflict | 资源冲突（如重复创建） |
| 500 | Internal Server Error | 服务器错误 |

---

### 6. 分页规范

#### 请求
```
GET /api/v1/users?page=1&limit=20
```

#### 响应
```json
{
  "success": true,
  "data": {
    "items": [ ... ],
    "total": 150,
    "page": 1,
    "limit": 20,
    "total_pages": 8
  }
}
```

---

### 7. 版本控制

**推荐：URL 路径版本**
```
✅ /api/v1/users
✅ /api/v2/users
```

**备选：Header 版本**
```
Header: API-Version: 1
```

---

### 8. API 文档模板

```markdown
## 接口名称：获取用户详情

**请求方法**：GET
**请求路径**：`/api/v1/users/{id}`

### 请求参数

#### 路径参数
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | int | 是 | 用户 ID |

#### 查询参数
无

### 请求示例
```
GET /api/v1/users/123
```

### 响应参数
| 字段名 | 类型 | 说明 |
|--------|------|------|
| uid | string | 用户唯一标识 |
| name | string | 用户姓名 |
| email | string | 邮箱 |

### 响应示例
```json
{
  "success": true,
  "data": {
    "uid": "user123",
    "name": "Alice",
    "email": "alice@example.com"
  },
  "message": "success"
}
```

### 状态码说明
- `200` - 成功
- `404` - 用户不存在
- `401` - 未登录

### 备注
- 需要登录认证（Bearer Token）
```

---

**版本**: v1.0
**最后更新**: 2026-01-19
