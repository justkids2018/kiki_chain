# 场景相关接口

## 获取场景详情

**接口描述**：获取指定场景的详细信息，包括场景元数据和交互区域数据

**请求方式**：GET

**接口路径**：`/api/v1/scenes/:sceneId`

**路径参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| sceneId | string | 是 | 场景ID | "scene_01_bedroom" |

**请求示例**：

```
GET /api/v1/scenes/scene_01_bedroom
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.scene | object | 场景对象（包装结构） |
| data.scene.id | string | 场景ID |
| data.scene.name | string | 场景名称 |
| data.scene.nameEn | string | 场景英文名称 |
| data.scene.categoryId | string | 分类ID |
| data.scene.coverImage | string | 封面图片URL |
| data.scene.dataFile | string | 数据文件路径 |

**响应示例**：

```json
{
  "success": true,
  "message": "success",
  "data": {
    "scene": {
      "id": "scene_01_bedroom",
      "name": "卧室",
      "nameEn": "Bedroom",
      "categoryId": "daily_life",
      "coverImage": "https://example.com/images/bedroom.png",
      "dataFile": "/data/scenes/scene_01_bedroom.json"
    }
  }
}
```

**错误响应示例**：

```json
{
  "success": false,
  "errorcode": 404,
  "message": "场景不存在"
}
```

**错误码说明**：

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 401 | 未授权 | 需要重新登录获取 token |
| 404 | 场景不存在 | 检查 sceneId 是否正确 |
| 500 | 服务器错误 | 稍后重试或联系技术支持 |

**前端使用说明**：

1. API 返回的是 `{scene: {...}}` 包装结构，前端需要提取 `data.scene` 对象
2. `scene` 对象可以直接用于 `Scene.fromJson()` 解析
3. 确保处理 `id` 和 `name` 字段的空值情况（使用空字符串作为默认值）

---

## 获取场景列表

**接口描述**：获取可用场景列表

**请求方式**：GET

**接口路径**：`/api/v1/scenes`

**请求参数**：

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| categoryId | string | 否 | 分类ID，用于过滤 | "daily_life" |
| page | int | 否 | 页码，从1开始 | 1 |
| pageSize | int | 否 | 每页数量，默认20 | 20 |

**请求示例**：

```
GET /api/v1/scenes?categoryId=daily_life&page=1&pageSize=20
```

**响应参数**：

| 参数名 | 类型 | 说明 |
|--------|------|------|
| success | boolean | 操作是否成功 |
| message | string | 响应消息 |
| data.scenes | array | 场景列表 |
| data.total | int | 总数量 |
| data.page | int | 当前页码 |
| data.pageSize | int | 每页数量 |

**响应示例**：

```json
{
  "success": true,
  "message": "success",
  "data": {
    "scenes": [
      {
        "id": "scene_01_bedroom",
        "name": "卧室",
        "nameEn": "Bedroom",
        "categoryId": "daily_life",
        "coverImage": "https://example.com/images/bedroom.png"
      }
    ],
    "total": 50,
    "page": 1,
    "pageSize": 20
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
| 401 | 未授权 | 需要重新登录 |
| 400 | 参数错误 | 检查请求参数格式 |
