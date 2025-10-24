### 需求
在学生登陆后，显示老师姓名的卡片，卡片要简洁，美观，学生在选择自己老师的卡片时，卡片有轻微的动画效果
功能实现在 presentation/student/coose_teacher/目录下

### API 老师数据请求的接口

### 获取老师用户信息列表
**端点**: `GET /api/user`
**描述**: 根据uid或role_id查询用户信息
**认证**: Bearer Token

#### 请求参数
```
?role_id=3          // 根据角色ID查询用户列表
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
        "id": "550e8400-e29b-41d4-a716-446655440000"
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

### 开发中的架构规范
基础开发要求请动态读取以下目录中所有以 "base" 开头的文件：
- `doc/prompt/base_*.md` - 所有基础开发规范和要求

### 必须按照开发指南模版进行业务开发（重点）
模版：doc/framework/新功能开发指南标准_20250916.md

### UI设计规范
- 文档：doc/prompt/base_prompt_ui.md