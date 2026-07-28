# 奇奇满有系统 - 后端API文档

**版本**: v1.0
**更新时间**: 2025年9月15日
**基于**: DDD架构标准

## 📋 目录
- [认证模块](#认证模块)
- [用户管理模块](#用户管理模块)
- [老师功能模块](#老师功能模块)
- [学生作业模块](#学生作业模块)
- [学生功能模块](#学生功能模块)
- [师生关系模块](#师生关系模块)
- [通用响应格式](#通用响应格式)
- [错误码说明](#错误码说明)

---

## 🔐 认证模块

### 用户登录
**端点**: `POST /api/auth/login`
**描述**: 用户身份验证，支持老师和学生角色
**认证**: 无需认证

#### 请求参数
```json
{
  "identifier": "13800138000",
  "password": "password123"
}
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "uid": "teacher_1726112233",
    "name": "张老师",
    "email": "teacher@example.com",
    "phone": "13800138000",
    "role_id": 2,
    "message": "登录成功",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "登录成功"
}
```

#### 错误响应 (401)
```json
{
  "success": false,
  "errorcode": 202,
  "message": "用户名/邮箱或密码错误"
}
```
> 登录失败时 `data` 字段省略，HTTP 状态码与 `errorcode` 一致。

### 用户注册
**端点**: `POST /api/v1/auth/register`
**描述**: 新用户注册。移动端普通用户请传 `role_type: 1`；管理员角色为 `2`。兼容旧客户端：`role_type` 省略或传 `0` 时按普通用户 `1` 处理。
**认证**: 无需认证

#### 请求参数
```json
{
  "uid": "kiki_1726112233",
  "name": "张三",
  "email": "",
  "phone": "13800138000",
  "password": "password123",
  "role_type": 1
}
```

#### 成功响应 (201)
```json
{
  "success": true,
  "data": {
    "uid": "kiki_1726112233",
    "name": "张三",
    "email": "",
    "phone": "13800138000",
    "role_type": 1,
    "is_vip": false,
    "message": "注册成功"
  },
  "message": "注册成功"
}
```

#### 错误响应 (409)
```json
{
  "success": false,
  "errorcode": 200,
  "message": "手机号 '13800138000' 已存在"
}
```
> 当注册信息冲突或校验失败时，将返回对应的 `errorcode` 与匹配的 HTTP 状态码。

### 令牌验证
**端点**: `GET /api/auth/verify`
**描述**: 验证JWT令牌的有效性
**认证**: Bearer Token

#### 请求头
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "valid": true,
    "user_id": "user_uid_123",
    "name": "张老师",
    "email": "teacher@example.com"
  },
  "message": "令牌有效"
}
```

---

## 👤 用户管理模块

### 获取用户信息
**端点**: `GET /api/user`
**描述**: 根据uid或role_id查询用户信息
**认证**: Bearer Token

#### 请求参数
```
?uid=123456          // 根据用户ID查询单个用户
?role_id=1           // 根据角色ID查询用户列表
```

#### 成功响应 - 单个用户 (200)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "uid": "123456",
      "name": "张三",
      "email": "zhangsan@example.com",
      "phone": "13888888888",
      "created_at": "2025-01-15T10:30:00Z",
      "updated_at": "2025-01-15T10:30:00Z",
      "role_id": 1
    }
  },
  "message": "获取用户信息成功"
}
```

#### 成功响应 - 用户列表 (200)
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "uid": "123456",
        "name": "张三",
        "email": "zhangsan@example.com",
        "phone": "13888888888",
        "created_at": "2025-01-15T10:30:00Z",
        "updated_at": "2025-01-15T10:30:00Z",
        "role_id": 1
      }
    ]
  },
  "message": "获取用户列表成功，共1个用户"
}
```

#### 成功响应 - 空结果 (200)
```json
{
  "success": true,
  "data": {
    "users": []
  },
  "message": "没有找到符合条件的用户"
}
```

#### 错误响应 - 参数缺失 (400)
```json
{
  "success": false,
  "errorcode": 101,
  "message": "缺少查询参数：需要提供uid或role_id"
}
```

#### 错误响应 - 用户不存在 (404)
```json
{
  "success": false,
  "errorcode": 201,
  "message": "未找到指定的用户"
}
```

---

## 👨‍🏫 老师功能模块

### 创建作业
**端点**: `POST /api/teacher/assignments`
**描述**: 老师创建新作业
**认证**: Bearer Token (老师角色)

#### 请求头
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

#### 请求参数
```json
{
  "title": "数学作业1",
  "description": "完成第一章练习题，包括加法和减法运算",
  "knowledge_points": "加法运算,减法运算,数学基础",
  "teacher_id": "teacher_uid_123",
  "status": "draft"
}
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "assignment_uuid_123",
    "teacher_id": "teacher_uid_123",
    "title": "数学作业1",
    "description": "完成第一章练习题，包括加法和减法运算",
    "knowledge_points": "加法运算,减法运算,数学基础",
    "status": "draft",
    "created_at": "2025-09-13T10:30:00Z",
    "updated_at": "2025-09-13T10:30:00Z"
  },
  "message": "作业创建成功"
}
```

### 获取作业列表
**端点**: `GET /api/teacher/assignments`
**描述**: 获取老师创建的所有作业列表
**认证**: Bearer Token (老师角色) 或通过查询参数 teacher_id 指定老师

#### 请求参数
```
?status=published         // 可选查询参数: draft, published
?teacher_id=teacher_uid  // 可选，指定老师ID，支持跨账号查询
```

> **说明**：
> - 不传 `teacher_id` 时，默认根据当前登录老师（token）查询。
> - 传 `teacher_id` 时，返回该老师的作业列表（需有权限）。

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "assignments": [
      {
        "id": "assignment_uuid_123",
        "title": "数学作业1",
        "description": "完成第一章练习题",
        "knowledge_points": "加法运算,减法运算",
        "status": "published",
        "created_at": "2025-09-13T10:30:00Z",
        "updated_at": "2025-09-13T10:30:00Z"
      }
    ],
    "total": 1
  },
  "message": "获取作业列表成功"
}
```

### 获取作业详情
**端点**: `GET /api/teacher/assignments/{id}`
**描述**: 获取指定作业的详细信息
**认证**: Bearer Token (老师角色)

#### 路径参数
- `{id}`: 作业UUID

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "assignment_uuid_123",
    "teacher_id": "teacher_uid_123",
    "title": "数学作业1",
    "description": "完成第一章练习题，包括加法和减法运算",
    "knowledge_points": "加法运算,减法运算,数学基础",
    "status": "published",
    "created_at": "2025-09-13T10:30:00Z",
    "updated_at": "2025-09-13T10:30:00Z"
  },
  "message": "获取作业详情成功"
}
```

### 更新作业
**端点**: `PUT /api/teacher/assignments/{id}`
**描述**: 更新作业信息
**认证**: Bearer Token (老师角色)

#### 路径参数
- `{id}`: 作业UUID

#### 请求参数
```json
{
  "title": "数学作业1（修订版）",
  "description": "完成第一章练习题，增加乘法运算",
  "knowledge_points": "加法运算,减法运算,乘法运算",
  "status": "published"
}
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "assignment_uuid_123",
    "title": "数学作业1（修订版）",
    "description": "完成第一章练习题，增加乘法运算",
    "knowledge_points": "加法运算,减法运算,乘法运算",
    "status": "published",
    "updated_at": "2025-09-13T11:00:00Z"
  },
  "message": "作业更新成功"
}
```

### 删除作业
**端点**: `DELETE /api/teacher/assignments/{id}`
**描述**: 删除指定作业（不可逆操作）
**认证**: Bearer Token (老师角色)

#### 路径参数
- `{id}`: 作业UUID

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "assignment_uuid_123",
    "deleted": true
  },
  "message": "作业删除成功"
}
```

### 查询老师关联学生作业
**端点**: `GET /api/teachers/{teacher_uid}/student-assignments`
**描述**: 根据老师UID聚合其名下学生及作业明细，包含学生手机号
**认证**: Bearer Token (老师角色)

#### 路径参数
- `{teacher_uid}`: 老师在 `users.uid` 中的唯一标识

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "teacher_uid": "teacher_001",
    "students": [
      {
        "student": {
          "uid": "stu_1001",
          "name": "张三",
          "phone": "18800000000",
          "role_id": 3
        },
        "assignments": [
          {
            "student_assignment_id": "cf9e5b4d-6e3f-4fe9-8f1d-3a2b9c1d4f01",
            "assignment_id": "9d0b4b61-4c43-4b54-b7d4-9e5a9e7f1234",
            "assignment_title": "数学思维练习",
            "status": "completed",
            "dialog_rounds": 5,
            "avg_thinking_time_ms": 1200,
            "knowledge_mastery_score": "95.0",
            "thinking_depth_score": "88.0",
            "evaluation_metrics": {
              "three_student_rate": 0.92,
              "three_proposition_quality": 0.87,
              "two_student_chain": 0.81,
              "two_cover_rate": 0.78
            },
            "started_at": "2025-09-13T08:00:00Z",
            "completed_at": "2025-09-13T09:00:00Z"
          }
        ]
      }
    ]
  },
  "message": "老师学生作业查询成功"
}
```

#### 业务说明
- 返回结果按学生分组，学生可能无作业记录，此时 `assignments` 为空数组。
- 查询依赖 `teacher_students` 关系表，请保证目标老师已绑定学生。
- `assignment_title` 来源于 `assignments.title`，若记录缺失将返回 `null`。
- `evaluation_metrics` 为 JSON 对象，固定包含四个指标：`three_student_rate`、`three_proposition_quality`、`two_student_chain`、`two_cover_rate`。若尚未计算，字段值为 `null`。

---

## 📘 学生作业模块

> 面向学生作业记录的统一 CRUD 接口，要求 Bearer Token 认证。`assignment_id` 与 `student_id` 组合必须唯一。

### 新增学生作业记录
**端点**: `POST /api/student-assignments`
**认证**: Bearer Token（老师或系统服务可调用）

#### 请求体
```json
{
  "assignment_id": "9d0b4b61-4c43-4b54-b7d4-9e5a9e7f1234",
  "student_id": "stu_001",
  "status": "in_progress",
  "dialog_rounds": 2,
  "avg_thinking_time_ms": 1500,
  "knowledge_mastery_score": 88.5,
  "thinking_depth_score": 90.0,
  "evaluation_metrics": {
    "three_student_rate": 0.85,
    "three_proposition_quality": 0.9,
    "two_student_chain": 0.78,
    "two_cover_rate": 0.82
  },
  "conversation_id": "conv_001",
  "started_at": "2025-09-13T08:00:00Z",
  "completed_at": null
}
```

> `status` 取值：`not_started` / `in_progress` / `completed` / `reviewed`。未提供时默认为 `not_started`。`evaluation_metrics` 可选，省略时系统将使用四个指标初始化为 `null`。

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "3dfd2e73-4e05-4e39-8a55-08af2d0c8f4d",
    "assignment_id": "9d0b4b61-4c43-4b54-b7d4-9e5a9e7f1234",
    "student_id": "stu_001",
    "status": "in_progress",
    "dialog_rounds": 2,
    "avg_thinking_time_ms": 1500,
    "knowledge_mastery_score": "88.5",
    "thinking_depth_score": "90.0",
    "evaluation_metrics": {
      "three_student_rate": 0.85,
      "three_proposition_quality": 0.9,
      "two_student_chain": 0.78,
      "two_cover_rate": 0.82
    },
    "conversation_id": "conv_001",
    "started_at": null,
    "completed_at": null
  },
  "message": "学生作业创建成功"
}
```

#### 重复创建响应 (409)
```json
{
  "success": false,
  "errorcode": 200,
  "message": "学生作业记录已存在"
}
```

### 查询学生作业列表
**端点**: `GET /api/student-assignments`
**认证**: Bearer Token

#### 查询参数
```
?student_id=stu_001            // 可选，按学生筛选
?assignment_id=9d0b4b61-...    // 可选，按作业筛选
?status=completed              // 可选，状态过滤
```

> 至少提供 `student_id` 或 `assignment_id` 之一；同时提供时返回两者匹配的唯一记录。

#### 成功响应 (200)
```json
{
  "success": true,
  "data": [
    {
      "id": "3dfd2e73-4e05-4e39-8a55-08af2d0c8f4d",
      "assignment_id": "9d0b4b61-4c43-4b54-b7d4-9e5a9e7f1234",
      "student_id": "stu_001",
      "status": "completed",
      "dialog_rounds": 3,
      "avg_thinking_time_ms": 1800,
      "knowledge_mastery_score": "92.0",
      "thinking_depth_score": "93.0",
      "evaluation_metrics": {
        "three_student_rate": 0.9,
        "three_proposition_quality": 0.88,
        "two_student_chain": 0.84,
        "two_cover_rate": 0.8
      },
      "conversation_id": null,
      "started_at": "2025-09-13T08:00:00Z",
      "completed_at": "2025-09-13T10:30:00Z"
    }
  ],
  "message": "学生作业列表获取成功"
}
```

### 获取学生作业详情
**端点**: `GET /api/student-assignments/{id}`
**认证**: Bearer Token

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "3dfd2e73-4e05-4e39-8a55-08af2d0c8f4d",
    "assignment_id": "9d0b4b61-4c43-4b54-b7d4-9e5a9e7f1234",
    "student_id": "stu_001",
    "status": "completed",
    "dialog_rounds": 3,
    "avg_thinking_time_ms": 1800,
    "knowledge_mastery_score": "92.0",
    "thinking_depth_score": "93.0",
    "evaluation_metrics": {
      "three_student_rate": 0.9,
      "three_proposition_quality": 0.88,
      "two_student_chain": 0.84,
      "two_cover_rate": 0.8
    },
    "conversation_id": null,
    "started_at": "2025-09-13T08:00:00Z",
    "completed_at": "2025-09-13T10:30:00Z"
  },
  "message": "学生作业详情获取成功"
}
```

### 更新学生作业记录
**端点**: `PUT /api/student-assignments/{id}`
**认证**: Bearer Token

#### 请求体
```json
{
  "status": "completed",
  "dialog_rounds": 3,
  "avg_thinking_time_ms": 1800,
  "knowledge_mastery_score": 92.0,
  "thinking_depth_score": 93.0,
  "evaluation_metrics": {
    "three_student_rate": 0.9,
    "three_proposition_quality": 0.88,
    "two_student_chain": 0.84,
    "two_cover_rate": 0.8
  },
  "conversation_id": null,
  "started_at": "2025-09-13T08:00:00Z",
  "completed_at": "2025-09-13T10:30:00Z"
}
```

> 字段全部可选；显式传 `null` 表示清空对应值。`evaluation_metrics` 可整体覆盖，系统会自动补齐缺失的四个指标键。

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "3dfd2e73-4e05-4e39-8a55-08af2d0c8f4d",
    "status": "completed",
    "dialog_rounds": 3,
    "avg_thinking_time_ms": 1800,
    "knowledge_mastery_score": "92.0",
    "thinking_depth_score": "93.0",
    "evaluation_metrics": {
      "three_student_rate": 0.9,
      "three_proposition_quality": 0.88,
      "two_student_chain": 0.84,
      "two_cover_rate": 0.8
    },
    "conversation_id": null,
    "started_at": "2025-09-13T08:00:00Z",
    "completed_at": "2025-09-13T10:30:00Z"
  },
  "message": "学生作业更新成功"
}
```

### 删除学生作业记录
**端点**: `DELETE /api/student-assignments/{id}`
**认证**: Bearer Token

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "id": "3dfd2e73-4e05-4e39-8a55-08af2d0c8f4d",
    "message": "学生作业删除成功"
  },
  "message": "学生作业删除成功"
}
```

---

## 👨‍🎓 学生功能模块

> ℹ️ 师生绑定、查询等关系类接口已统一迁移至 [师生关系模块](#师生关系模块)。本节保留仅与学生自身作业相关的接口。

### 获取老师列表
> 功能已迁移至 [师生关系模块](#查询师生关系)，请使用 `GET /api/teacher-student?student_uid=...` 查询。

### 设置默认老师
> 功能已迁移至 [新增师生关系](#新增师生关系) 与 [更新师生关系](#更新师生关系) 接口，使用 `set_default` 字段控制默认老师。

### 获取默认老师
> 功能已迁移至 [查询师生关系](#查询师生关系)，结果中的 `is_default` 字段用于标识默认老师。

### 获取老师的作业列表
**端点**: `GET /api/student/teacher/{teacher_id}/assignments`
**描述**: 学生查看指定老师布置的作业
**认证**: Bearer Token (学生角色)

#### 路径参数
- `{teacher_id}`: 老师UUID

#### 请求参数
```
?status=published  // 可选查询参数
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "teacher_id": "teacher_uid_123",
    "teacher_name": "张老师",
    "assignments": [
      {
        "id": "assignment_uuid_123",
        "title": "数学作业1",
        "description": "完成第一章练习题",
        "knowledge_points": "加法运算,减法运算",
        "status": "published",
        "created_at": "2025-09-13T10:30:00Z"
      }
    ],
    "total": 1
  },
  "message": "获取老师作业列表成功"
}
```

### 更新会话ID
**端点**: `PUT /api/student/conversation`
**描述**: 学生更新与老师的会话标识
**认证**: Bearer Token (学生角色)

#### 请求参数
```json
{
  "assignment_id": "assignment_uuid_123",
  "conversation_id": "conv_uuid_456"
}
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "student_id": "student_uid_123",
    "assignment_id": "assignment_uuid_123",
    "conversation_id": "conv_uuid_456",
    "updated": true
  },
  "message": "会话ID更新成功"
}
```

---

## 🤝 师生关系模块

### 查询师生关系
**端点**: `GET /api/teacher-student`
**描述**: 按老师UID、学生UID或两者组合查询当前绑定关系
**认证**: Bearer Token

#### 查询参数
```
?teacher_uid=teacher_1694567890    // 可选，老师UID
?student_uid=student_1694567999    // 可选，学生UID
```

> 至少提供一个查询条件；同时提供时可用于校验指定师生是否绑定。

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "total": 2,
    "relationships": [
      {
        "teacher_id": "f1bc3c2a-9f13-4f5e-8a37-2f5e5f3b1c9e",
        "teacher_uid": "teacher_1694567890",
        "teacher_name": "李老师",
        "teacher_email": "teacher@example.com",
        "teacher_phone": "13800138000",
        "student_id": "0ad2b96d-62a8-4f0a-a932-82d8bfa2306a",
        "student_uid": "student_1694567999",
        "student_name": "张同学",
        "student_email": "student@example.com",
        "student_phone": "13900139000",
        "is_default": true
      }
    ]
  },
  "message": "师生关系查询成功"
}
```

#### 错误响应 - 条件缺失 (400)
```json
{
  "success": false,
  "errorcode": 103,
  "message": "查询条件至少需要提供teacher_uid或student_uid"
}
```

### 新增师生关系
**端点**: `POST /api/teacher-student`
**描述**: 为学生绑定指定老师，可选是否设为默认老师
**认证**: Bearer Token

#### 请求体
```json
{
  "teacher_uid": "teacher_1694567890",  // 必填，可使用teacher_id字段
  "student_uid": "student_1694567999",  // 必填，可使用student_id字段
  "set_default": true                    // 可选，默认false
}
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "message": "老师绑定成功",
    "teacher_id": "teacher_1694567890",
    "student_id": "student_1694567999",
    "is_default": true
  },
  "message": "师生关系绑定成功"
}
```

#### 错误响应 - 重复绑定 (409)
```json
{
  "success": false,
  "errorcode": 200,
  "message": "师生关系已存在"
}
```

### 更新师生关系
**端点**: `PUT /api/teacher-student`
**描述**: 将学生从原老师迁移到新老师，可选保持/指定默认老师
**认证**: Bearer Token

#### 请求体
```json
{
  "student_uid": "student_1694567999",          // 必填，可使用student_id
  "current_teacher_uid": "teacher_old",         // 必填，可使用current_teacher_id
  "new_teacher_uid": "teacher_new",             // 必填，可使用new_teacher_id
  "set_default": false                           // 可选；若原老师为默认且未显式指定，将自动转移给新老师
}
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "message": "师生关系更新成功",
    "student_id": "student_1694567999",
    "previous_teacher_id": "teacher_old",
    "new_teacher_id": "teacher_new",
    "is_default": true
  },
  "message": "师生关系更新成功"
}
```

#### 错误响应 - 原关系不存在 (404)
```json
{
  "success": false,
  "errorcode": 201,
  "message": "原师生关系不存在"
}
```

### 删除师生关系
**端点**: `DELETE /api/teacher-student`
**描述**: 解绑指定师生关系
**认证**: Bearer Token

#### 查询参数
```
?teacher_uid=teacher_1694567890    // 必填
&student_uid=student_1694567999    // 必填
```

#### 成功响应 (200)
```json
{
  "success": true,
  "data": {
    "message": "师生关系解绑成功",
    "student_id": "student_1694567999",
    "teacher_id": "teacher_1694567890",
    "was_default": false
  },
  "message": "师生关系解绑成功"
}
```

#### 错误响应 - 关系不存在 (404)
```json
{
  "success": false,
  "errorcode": 201,
  "message": "师生关系不存在"
}
```

---

## 📋 通用响应格式

### 成功响应结构
```json
{
  "success": true,                    // 操作是否成功
  "data": {                           // 业务数据（成功时存在）
    // 具体的业务数据内容
  },
  "message": "操作成功"                // 操作结果消息
}
```

### 错误响应结构
```json
{
  "success": false,                   // 操作是否成功
  "errorcode": 101,                   // 错误码（失败时存在）
  "message": "请求参数错误"            // 错误描述
}
```

---

## ⚠️ 错误码说明

### HTTP状态码对照表
| 状态码 | 说明 | 常见场景 |
|--------|------|----------|
| 200 | 成功 | 请求处理成功 |
| 201 | 创建成功 | 资源创建成功 |
| 400 | 请求错误 | 参数验证失败 |
| 401 | 未授权 | 登录失败、token无效 |
| 404 | 资源不存在 | 请求的资源未找到 |
| 500 | 服务器错误 | 系统内部错误 |

### 业务错误码对照表
| 错误码 | 说明 | HTTP状态码 |
|--------|------|------------|
| 100 | 请求错误 | 400 |
| 101 | 缺少参数 | 400 |
| 102 | 参数无效 | 400 |
| 103 | 验证失败 | 400 |
| 200 | 用户已存在 | 409 |
| 201 | 用户不存在 | 404 |
| 202 | 凭据无效 | 401 |
| 203 | 密码过短 | 400 |
| 204 | 邮箱格式错误 | 400 |
| 205 | 用户名已被占用 | 409 |
| 206 | 邮箱已被占用 | 409 |
| 300 | 业务规则违反 | 400 |
| 301 | 权限不足 | 403 |
| 500 | 服务器内部错误 | 500 |
| 501 | 数据库错误 | 500 |
| 502 | 外部服务错误 | 500 |

---

## 🔐 认证说明

### JWT Token格式
- **Header**: `Authorization: Bearer {token}`
- **有效期**: 24小时
- **包含信息**: 用户ID、用户名、邮箱、角色等

### 角色权限
- **学生 (role_id: 1)**: 只能访问学生相关接口
- **老师 (role_id: 2)**: 只能访问老师相关接口

### 请求示例
```bash
# 获取用户信息
curl -X GET \
  'http://localhost:8080/api/user?uid=123456' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json'

# 用户登录
curl -X POST \
  'http://localhost:8080/api/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

---

## 📝 开发说明

### 环境地址
- **开发环境**: `http://localhost:8080`
- **测试环境**: `https://test-api.qiqimanyou.com`
- **生产环境**: `https://api.qiqimanyou.com`

### 请求头要求
```
Content-Type: application/json
Authorization: Bearer {token}  // 需要认证的接口
```

### 响应编码
- 所有响应均为 UTF-8 编码
- 时间格式统一使用 ISO 8601 标准

---

## 🏥 健康检查

### 健康检查接口
**端点**: `GET /health`
**描述**: 系统健康状态检查
**认证**: 无需认证

#### 成功响应 (200)
```json
{
  "status": "OK",
  "timestamp": "2025-09-15T10:30:00Z",
  "version": "0.1.0",
  "service": "qiqimanyou_server"
}
```

---

**文档维护**: 如有接口变更，请及时更新此文档
**技术支持**: 详见项目 README.md 文件
