# 学习记录相关接口

## 获取学习记录列表

**接口描述**：获取用户的学习记录列表

**请求方式**：GET

**接口路径**：`/api/v1/learning/records`

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| page | int | 否 | 页码，从1开始 | 1 |
| pageSize | int | 否 | 每页数量，默认20 | 20 |

**请求头**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| Authorization | string | 是 | 用户 token | "Bearer xxx" |

**请求示例**：

```
GET /api/v1/learning/records?page=1&pageSize=20
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.records | array | 学习记录列表 |
| data.records[].sceneId | string | 场景ID |
| data.records[].sceneName | string | 场景名称 |
| data.records[].progress | int | 学习进度（0-100） |
| data.records[].stars | int | 获得星星数（0-3） |
| data.records[].lastStudyAt | string | 最后学习时间 |
| data.total | int | 总记录数 |

**响应示例**：

```json
{
  "success": true,
  "message": "success",
  "data": {
    "records": [
      {
        "sceneId": "scene_01_bedroom",
        "sceneName": "卧室",
        "progress": 75,
        "stars": 2,
        "lastStudyAt": "2026-06-12T10:30:00Z"
      }
    ],
    "total": 10
  }
}
```

**错误响应示例**：

```json
{
  "success": false,
  "errorcode": 401,
  "message": "未授权"
}
```

**错误码说明**：

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 401 | 未授权 | token 过期或无效，需要重新登录 |
| 403 | 无权限 | 该用户无权访问学习记录 |

---

## 更新学习进度

**接口描述**：更新用户在指定场景的学习进度和星星数

**请求方式**：POST

**接口路径**：`/api/v1/learning/progress`

**请求头**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Authorization | string | 是 | 用户 token |

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| sceneId | string | 是 | 场景ID | "scene_01_bedroom" |
| progress | int | 是 | 学习进度（0-100） | 75 |
| stars | int | 是 | 星星数（0-3） | 2 |

**请求示例**：

```json
POST /api/v1/learning/progress
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "sceneId": "scene_01_bedroom",
  "progress": 75,
  "stars": 2
}
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.updated | boolean | 是否更新成功 |

**响应示例**：

```json
{
  "success": true,
  "message": "success",
  "data": {
    "updated": true
  }
}
```

**错误响应示例**：

```json
{
  "success": false,
  "errorcode": 400,
  "message": "参数错误"
}
```

**错误码说明**：

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 401 | 未授权 | token 过期或无效 |
| 400 | 参数错误 | 检查 progress 和 stars 的取值范围 |
| 404 | 场景不存在 | 检查 sceneId 是否正确 |
