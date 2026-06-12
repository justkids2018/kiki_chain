# 管理端接口文档

> **权限说明**：所有管理端接口需要管理员权限（role_type = 2），需要在请求头中携带管理员 token

## 目录

- [认证](#认证)
- [用户管理](#用户管理)
- [学习记录管理](#学习记录管理)
- [场景管理](#场景管理)
- [反馈管理](#反馈管理)
- [文件上传](#文件上传)

---

## 认证

### 管理员登录

**接口描述**：管理员登录接口

**请求方式**：POST

**接口路径**：`/api/v1/admin/auth/login`

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| identifier | string | 是 | 手机号或邮箱 | "admin@example.com" |
| password | string | 是 | 密码 | "admin123" |

**请求示例**：

```json
{
  "identifier": "admin@example.com",
  "password": "admin123"
}
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.uid | string | 管理员ID |
| data.name | string | 管理员名称 |
| data.token | string | JWT token |

**响应示例**：

```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "uid": "admin_001",
    "name": "管理员",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**错误响应示例**：

```json
{
  "success": false,
  "errorcode": 202,
  "message": "用户名或密码错误"
}
```

---

## 用户管理

### 获取用户列表

**接口描述**：获取所有用户列表

**请求方式**：GET

**接口路径**：`/api/v1/admin/users`

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**请求示例**：

```
GET /api/v1/admin/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data | array | 用户列表 |
| data[].uid | string | 用户ID |
| data[].name | string | 用户名 |
| data[].phone | string | 手机号 |
| data[].email | string | 邮箱 |
| data[].role_type | int | 角色类型（1=普通用户，2=管理员） |
| data[].is_vip | boolean | 是否VIP |
| data[].created_at | string | 创建时间 |

**响应示例**：

```json
{
  "success": true,
  "message": "获取成功",
  "data": [
    {
      "uid": "user_12345",
      "name": "张三",
      "phone": "13800138000",
      "email": "",
      "role_type": 1,
      "is_vip": false,
      "created_at": "2026-01-15T10:30:00Z"
    }
  ]
}
```

---

### 获取用户详情

**接口描述**：获取指定用户的详细信息，包含星星数量

**请求方式**：GET

**接口路径**：`/api/v1/admin/users/{id}`

**路径参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 用户ID |

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**请求示例**：

```
GET /api/v1/admin/users/user_12345
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.uid | string | 用户ID |
| data.name | string | 用户名 |
| data.phone | string | 手机号 |
| data.email | string | 邮箱 |
| data.role_type | int | 角色类型 |
| data.is_vip | boolean | 是否VIP |
| data.total_stars | int | 总星星数 ⭐ 新增字段 |
| data.created_at | string | 创建时间 |

**响应示例**：

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "uid": "user_12345",
    "name": "张三",
    "phone": "13800138000",
    "email": "user@example.com",
    "role_type": 1,
    "is_vip": false,
    "total_stars": 15,
    "created_at": "2026-01-15T10:30:00Z"
  }
}
```

**错误响应示例**：

```json
{
  "success": false,
  "errorcode": 404,
  "message": "用户不存在"
}
```

---

### 更新用户信息

**接口描述**：更新用户信息

**请求方式**：PATCH

**接口路径**：`/api/v1/admin/users/{id}/update`

**路径参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 用户ID |

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| name | string | 否 | 用户名 | "新名字" |
| password | string | 否 | 密码 | "newpass123" |
| is_vip | boolean | 否 | VIP状态 | true |

**请求示例**：

```json
{
  "name": "新名字",
  "is_vip": true
}
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.uid | string | 用户ID |

**响应示例**：

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "uid": "user_12345"
  }
}
```

---

## 学习记录管理

### 根据手机号查询学习记录

**接口描述**：根据手机号查询用户的完整学习记录，包括学习统计和各场景进度

**请求方式**：GET

**接口路径**：`/api/v1/admin/learning/phone/{phone}`

**路径参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| phone | string | 是 | 手机号 |

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**请求示例**：

```
GET /api/v1/admin/learning/phone/13800138000
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.user | object | 用户基本信息 |
| data.user.uid | string | 用户ID |
| data.user.name | string | 用户名 |
| data.user.phone | string | 手机号 |
| data.summary | object | 学习统计汇总 |
| data.summary.total_stars | int | 总星星数 |
| data.summary.total_score | int | 总积分 |
| data.summary.completed_scenes | int | 完成场景数 |
| data.summary.total_study_time | int | 总学习时长（秒） |
| data.summary.last_active_at | string | 最后活跃时间 |
| data.progress_list | array | 场景学习进度列表 |
| data.progress_list[].scene_id | string | 场景ID |
| data.progress_list[].total_regions | int | 总词数 |
| data.progress_list[].learned_count | int | 已学词数 |
| data.progress_list[].stars_earned | int | 获得星星数 |
| data.progress_list[].total_score | int | 场景积分 |
| data.progress_list[].is_completed | boolean | 是否完成 |
| data.progress_list[].first_learned_at | string | 首次学习时间 |
| data.progress_list[].last_learned_at | string | 最近学习时间 |
| data.progress_list[].total_study_time | int | 学习时长（秒） |

**响应示例**：

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "user": {
      "uid": "user_12345",
      "name": "张三",
      "phone": "13800138000"
    },
    "summary": {
      "total_stars": 15,
      "total_score": 15,
      "completed_scenes": 3,
      "total_study_time": 1800,
      "last_active_at": "2026-06-12T15:30:00Z"
    },
    "progress_list": [
      {
        "scene_id": "scene_zhiwuyuan",
        "total_regions": 8,
        "learned_count": 8,
        "stars_earned": 3,
        "total_score": 3,
        "is_completed": true,
        "first_learned_at": "2026-06-01T10:00:00Z",
        "last_learned_at": "2026-06-10T15:30:00Z",
        "total_study_time": 600
      },
      {
        "scene_id": "scene_farm",
        "total_regions": 10,
        "learned_count": 5,
        "stars_earned": 1,
        "total_score": 1,
        "is_completed": false,
        "first_learned_at": "2026-06-05T14:00:00Z",
        "last_learned_at": "2026-06-12T10:00:00Z",
        "total_study_time": 400
      }
    ]
  }
}
```

**错误响应示例**：

```json
{
  "success": false,
  "errorcode": 404,
  "message": "用户不存在"
}
```

**使用说明**：

1. 此接口返回用户的完整学习数据，包括：
   - 用户基本信息
   - 学习统计汇总（总星星数、完成场景数等）
   - 所有场景的学习进度列表（按最后学习时间倒序）

2. `progress_list` 为空数组表示用户尚未开始学习任何场景

3. 星星评级规则：
   - 0星：未学习或进度 < 30%
   - 1星：进度 30% - 60%
   - 2星：进度 60% - 90%
   - 3星：进度 100%（完成）

---

## 场景管理

### 获取场景分类列表

**接口描述**：获取所有场景分类

**请求方式**：GET

**接口路径**：`/api/v1/admin/scene/categories`

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**响应示例**：

```json
{
  "success": true,
  "message": "获取成功",
  "data": [
    {
      "id": "cat_001",
      "name": "动物世界",
      "description": "认识各种动物"
    }
  ]
}
```

---

### 创建场景分类

**接口描述**：创建新的场景分类

**请求方式**：POST

**接口路径**：`/api/v1/admin/scene/categories`

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| name | string | 是 | 分类名称 |
| description | string | 否 | 分类描述 |
| icon_url | string | 否 | 图标URL |
| sort_order | int | 否 | 排序序号 |

---

### 获取场景列表

**接口描述**：获取所有场景列表

**请求方式**：GET

**接口路径**：`/api/v1/admin/scene/scenes`

---

### 创建场景

**接口描述**：创建新场景

**请求方式**：POST

**接口路径**：`/api/v1/admin/scene/scenes`

---

## 反馈管理

### 获取反馈列表

**接口描述**：获取用户反馈列表

**请求方式**：GET

**接口路径**：`/api/v1/admin/feedback`

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**查询参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | string | 否 | 状态筛选：pending/processing/resolved/ignored |

**请求示例**：

```
GET /api/v1/admin/feedback?status=pending
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data | array | 反馈列表 |
| data[].id | int | 反馈ID |
| data[].user_id | string | 用户ID |
| data[].feedback_type | string | 反馈类型 |
| data[].content | string | 反馈内容 |
| data[].contact | string | 联系方式 |
| data[].page | string | 页面位置 |
| data[].status | string | 处理状态 |
| data[].created_at | string | 创建时间 |
| data[].updated_at | string | 更新时间 |

**响应示例**：

```json
{
  "success": true,
  "message": "获取成功",
  "data": [
    {
      "id": 123,
      "user_id": "user_12345",
      "feedback_type": "bug",
      "content": "发现一个问题...",
      "contact": "user@example.com",
      "page": "scene_detail",
      "status": "pending",
      "created_at": "2026-06-12T10:00:00Z",
      "updated_at": "2026-06-12T10:00:00Z"
    }
  ]
}
```

---

### 更新反馈状态

**接口描述**：更新反馈处理状态

**请求方式**：PATCH

**接口路径**：`/api/v1/admin/feedback/{id}/status`

**路径参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | int | 是 | 反馈ID |

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | string | 是 | 状态：pending/processing/resolved/ignored |

**请求示例**：

```json
{
  "status": "resolved"
}
```

**响应示例**：

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": 123,
    "status": "resolved"
  }
}
```

---

## 文件上传

### 获取上传凭证

**接口描述**：获取七牛云上传凭证，用于前端直传文件

**请求方式**：GET

**接口路径**：`/api/v1/admin/upload/token`

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | Bearer {token} |

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.token | string | 上传凭证 |
| data.upload_url | string | 上传地址 |
| data.domain | string | 资源访问域名 |

**响应示例**：

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "token": "qiniu_upload_token_xxx",
    "upload_url": "https://up-z2.qiniup.com",
    "domain": "https://img.keepthinking.me"
  }
}
```

**错误响应示例**：

```json
{
  "success": false,
  "errorcode": 503,
  "message": "七牛云服务未配置，请检查环境变量"
}
```

**使用说明**：

1. 前端调用此接口获取上传凭证
2. 使用返回的 `token` 和 `upload_url` 直传文件到七牛云
3. 上传成功后，通过 `domain` + 文件key 访问文件

---

## 错误码说明

| 错误码 | 说明 | HTTP状态码 |
|--------|------|------------|
| 100 | 请求错误 | 400 |
| 101 | 缺少参数 | 400 |
| 102 | 参数无效 | 400 |
| 103 | 验证失败 | 400 |
| 200 | 资源已存在 | 409 |
| 201 | 资源不存在 | 404 |
| 202 | 凭据无效 | 401 |
| 301 | 权限不足 | 403 |
| 500 | 服务器内部错误 | 500 |
| 501 | 数据库错误 | 500 |
| 503 | 服务不可用 | 503 |

---

**更新时间**：2026-06-12  
**维护人员**：后端开发团队
