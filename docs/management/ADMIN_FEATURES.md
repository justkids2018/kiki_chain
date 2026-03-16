# Hi Kiki 后台管理平台功能需求文档

> KKWebManager + KKServer Admin API 完整功能规划

**版本**: v1.0
**更新时间**: 2026-03-14

---

## 一、系统架构

```
KKWebManager (Flutter Web)
        ↓ HTTP API (Admin Token)
KKServer /api/v1/admin/*
        ↓ SQL
PostgreSQL (hikiki_db)
        ↑ 数据同步
KKWeb (移动端用户消费数据)
```

**权限分层**:
- `role_type = 1` → 普通用户（KKWeb）
- `role_type = 2` → 管理员（KKWebManager）

---

## 二、功能模块总览

| 模块 | KKServer 现状 | KKWebManager 现状 | 需要新增 |
|------|-------------|-----------------|---------|
| 登录/认证 | ✅ 已有 | ✅ 已有 | — |
| 场景分类管理 | ✅ CRUD | ❌ 无管理页面 | Manager 页面 |
| 场景管理 | ✅ CRUD | ❌ 无管理页面 | Manager 页面 |
| 场景物品管理 | ❌ 无 API | ❌ 无 | Server API + Manager 页面 |
| 用户管理 | ✅ 列表/详情 | ❌ 无管理页面 | Manager 页面 |
| 用户学习记录 | ❌ 无 API | ❌ 无 | Server API + Manager 页面 |
| 数据统计 | ❌ 无 | ❌ 无 | Server API + Manager 页面 |

---

## 三、场景分类管理

### 数据模型（对应 `scene_categories` 表）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | 分类 ID（如 `cat_001`）|
| name | String | 中文名称（如 "春节场景"）|
| icon | String | Emoji 图标（如 "🎉"）|
| cover_image | String | 封面图 URL |
| description | String | 描述 |
| display_order | Int | 排序（越小越靠前）|
| is_new | Bool | 是否标记为新 |
| scene_count | Int | 场景数量（只读，统计值）|
| total_item_count | Int | 物品总数（只读，统计值）|
| created_at | DateTime | 创建时间 |

### KKServer API（已有）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/admin/scene/categories` | 分类列表 |
| POST | `/api/v1/admin/scene/categories` | 创建分类 |
| PUT | `/api/v1/admin/scene/categories/:id` | 更新分类 |
| DELETE | `/api/v1/admin/scene/categories/:id` | 删除分类 |

### KKWebManager 页面（待开发）

**场景分类列表页**
- 表格展示所有分类
- 支持拖拽排序（更新 display_order）
- 操作：新建、编辑、删除

**场景分类编辑表单**
- 字段：名称、图标（Emoji 选择器）、封面图上传、描述、排序、是否新
- 实时预览卡片效果

---

## 四、场景管理

### 数据模型（对应 `scenes` 表）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | 场景 ID（如 `scn_001`）|
| category_id | String | 所属分类 ID |
| name | String | 中文名称 |
| name_en | String | 英文名称 |
| cover_image | String | 封面图 URL |
| interactive_image | String | 互动大图 URL |
| data_file | String | 互动数据 JSON 文件路径 |
| description | String | 描述 |
| context | String | 场景背景/情境说明 |
| display_order | Int | 排序 |
| is_new | Bool | 是否标记为新 |
| item_count | Int | 物品数量（只读）|
| created_at | DateTime | 创建时间 |

### KKServer API（已有）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/admin/scene/scenes` | 场景列表（支持按分类筛选）|
| POST | `/api/v1/admin/scene/scenes` | 创建场景 |
| GET | `/api/v1/admin/scene/scenes/:id` | 场景详情 |
| PUT | `/api/v1/admin/scene/scenes/:id` | 更新场景 |
| DELETE | `/api/v1/admin/scene/scenes/:id` | 删除场景 |

### KKWebManager 页面（待开发）

**场景列表页**
- 按分类筛选
- 卡片/表格切换视图
- 操作：新建、编辑、删除、预览

**场景编辑表单**
- 字段：所属分类、中文名、英文名、封面图、互动大图、描述、情境、排序、是否新
- 图片上传预览
- 关联物品列表（跳转到物品管理）

---

## 五、场景物品管理（Scene Items）⭐ 核心新增

> 这是 KKWeb 互动功能的核心数据，目前 KKServer 完全缺失此模块

### 数据模型（对应 `scene_items` 表）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | 物品 ID（如 `item_001`）|
| scene_id | String | 所属场景 ID |
| name_cn | String | 中文名称（如 "灯笼"）|
| name_en | String | 英文名称（如 "Lantern"）|
| pinyin | String | 拼音（如 "dēng lóng"）|
| pronunciation | String | 发音描述 |
| image_url | String | 物品图片 URL |
| audio_url | String | 发音音频 URL |
| data_file | String | 互动数据 JSON 路径（笔画/字母数据）|
| display_order | Int | 在场景中的排序 |
| hotspot | JSON | 热区坐标 `{x, y, width, height}`（在互动大图上的位置）|
| created_at | DateTime | 创建时间 |

### KKServer API（待新增）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/admin/scene/scenes/:id/items` | 获取场景下所有物品 |
| POST | `/api/v1/admin/scene/scenes/:id/items` | 创建物品 |
| GET | `/api/v1/admin/scene/items/:id` | 物品详情 |
| PUT | `/api/v1/admin/scene/items/:id` | 更新物品 |
| DELETE | `/api/v1/admin/scene/items/:id` | 删除物品 |
| PUT | `/api/v1/admin/scene/scenes/:id/items/reorder` | 批量更新排序 |

### KKWebManager 页面（待开发）

**物品列表页**（嵌入场景详情页）
- 在互动大图上可视化展示热区位置
- 拖拽调整热区位置
- 操作：新建、编辑、删除、排序

**物品编辑表单**
- 字段：中文名、英文名、拼音、发音、图片上传、音频上传、data_file 路径
- 热区编辑器：在互动大图上点击/拖拽设置热区坐标
- 预览：模拟 KKWeb 中的展示效果

---

## 六、用户管理

### KKServer API（已有）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/admin/users` | 用户列表 |
| GET | `/api/v1/admin/users/:id` | 用户详情 |

### KKServer API（待新增）

| 方法 | 路径 | 说明 |
|------|------|------|
| PUT | `/api/v1/admin/users/:id` | 更新用户信息（角色、VIP 等）|
| DELETE | `/api/v1/admin/users/:id` | 禁用/删除用户 |
| GET | `/api/v1/admin/users/:id/learning` | 用户学习记录 |

### KKWebManager 页面（待开发）

**用户列表页**
- 搜索（手机号、昵称）
- 筛选（角色、VIP 状态）
- 操作：查看详情、设置角色、设置 VIP

**用户详情页**
- 基本信息
- 学习记录统计
- 收藏列表

---

## 七、用户学习记录（待新增）

### 数据模型（对应 `user_learning_records` 表）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int | 记录 ID |
| user_id | String | 用户 ID |
| scene_id | String | 场景 ID |
| item_id | String | 物品 ID |
| action | String | 操作类型（view/click/complete）|
| duration_seconds | Int | 学习时长（秒）|
| created_at | DateTime | 记录时间 |

### KKServer API（待新增）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/admin/stats/learning` | 学习记录统计 |
| GET | `/api/v1/admin/stats/popular-scenes` | 热门场景排行 |
| GET | `/api/v1/admin/stats/active-users` | 活跃用户统计 |
| GET | `/api/v1/admin/stats/overview` | 数据总览 |

### KKWebManager 页面（待开发）

**数据统计仪表盘**
- 总用户数、今日活跃、总学习次数
- 热门场景 Top 10
- 用户增长趋势图
- 学习时长分布

---

## 八、开发优先级

### P0 - 立即开发（核心数据录入）

1. **场景物品 API**（KKServer）
   - `GET/POST /api/v1/admin/scene/scenes/:id/items`
   - `GET/PUT/DELETE /api/v1/admin/scene/items/:id`

2. **场景分类管理页**（KKWebManager）
   - 列表 + 编辑表单

3. **场景管理页**（KKWebManager）
   - 列表 + 编辑表单

4. **场景物品管理页**（KKWebManager）
   - 物品列表 + 热区编辑器

### P1 - 重要功能

5. **用户管理页**（KKWebManager）
6. **用户学习记录 API**（KKServer）
7. **数据统计仪表盘**（KKWebManager）

### P2 - 优化

8. 图片/音频文件上传（OSS 集成）
9. 批量导入数据（CSV/JSON）
10. 操作日志记录

---

## 九、KKServer 需要新增的 API 汇总

```
# 场景物品（P0）
GET    /api/v1/admin/scene/scenes/:id/items
POST   /api/v1/admin/scene/scenes/:id/items
GET    /api/v1/admin/scene/items/:id
PUT    /api/v1/admin/scene/items/:id
DELETE /api/v1/admin/scene/items/:id
PUT    /api/v1/admin/scene/scenes/:id/items/reorder

# 用户管理扩展（P1）
PUT    /api/v1/admin/users/:id
DELETE /api/v1/admin/users/:id
GET    /api/v1/admin/users/:id/learning

# 数据统计（P1）
GET    /api/v1/admin/stats/overview
GET    /api/v1/admin/stats/popular-scenes
GET    /api/v1/admin/stats/active-users
GET    /api/v1/admin/stats/learning
```

---

## 十、KKWebManager 需要新增的页面汇总

```
管理后台页面结构：

├── 登录页（已有）
├── 仪表盘（待开发）
│   └── 数据总览、趋势图
├── 内容管理
│   ├── 场景分类（待开发）
│   │   ├── 分类列表
│   │   └── 分类编辑
│   ├── 场景管理（待开发）
│   │   ├── 场景列表
│   │   ├── 场景编辑
│   │   └── 物品管理（热区编辑器）
│   └── 物品详情编辑（待开发）
├── 用户管理（待开发）
│   ├── 用户列表
│   └── 用户详情
└── 数据统计（待开发）
    ├── 学习记录
    └── 热门场景
```

---

**下一步**: 先实现 P0 — 场景物品 API（KKServer）+ 场景/分类/物品管理页（KKWebManager）
