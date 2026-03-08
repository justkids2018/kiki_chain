# Orchestrator - Hi Kiki 三端架构规范

> **适用项目**: Hi Kiki (kiki_web + kiki_server + kiki_web_manager)
> **版本**: v1.0
> **最后更新**: 2026-03-04

---

## 🏗️ Hi Kiki 项目架构

### 三端架构概览

```
┌─────────────────────────────────────────────────────────┐
│                     Hi Kiki 项目                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  📱 kiki_web              🔧 kiki_server                │
│  (移动端 Flutter)          (后端 Rust + Axum)            │
│                                                          │
│  - 用户端功能              - RESTful API                 │
│  - 场景学习                - Clean Architecture          │
│  - TTS 语音                - PostgreSQL                  │
│  - 互动学习                - JWT 认证                    │
│  - 学习进度                - 权限控制                    │
│                                                          │
│  💼 kiki_web_manager                                    │
│  (管理后台 Flutter Web)                                  │
│                                                          │
│  - 内容管理                                              │
│  - 用户管理                                              │
│  - 数据统计                                              │
│  - 批量操作                                              │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 项目结构

```
kiki_chain/
├── .claude/                    # 根级配置（全局 Skills）
│   ├── skills/
│   │   ├── orchestrator/      # 本 Skill
│   │   ├── contract-manager/
│   │   ├── code-generator/
│   │   └── task-executor/
│   ├── contracts/             # 契约定义
│   └── templates/             # 代码模板
│
├── kiki_server/               # 后端项目
│   ├── src/
│   │   ├── core/             # 核心业务逻辑
│   │   ├── adapters/         # 适配器层
│   │   ├── framework/        # 框架层
│   │   └── shared/           # 共享模块
│   ├── .claude/skills/       # 后端专属 Skills
│   └── Cargo.toml
│
├── kiki_web/                  # 移动端项目
│   ├── lib/
│   │   ├── core/             # 核心配置
│   │   ├── domain/           # 领域层
│   │   ├── data/             # 数据层
│   │   └── presentation/     # 表现层
│   ├── .claude/skills/       # 移动端专属 Skills
│   └── pubspec.yaml
│
├── kiki_web_manager/          # 管理后台项目
│   ├── lib/
│   │   ├── core/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── .claude/skills/       # 管理后台专属 Skills
│   └── pubspec.yaml
│
└── docs/                      # 文档
    ├── tasks/                # 任务管理
    │   ├── backend/
    │   ├── app/
    │   └── admin/
    └── database/             # 数据库文档
```

---

## 🎯 端识别规则

### 关键词映射

| 关键词 | 涉及端 | 示例 |
|--------|--------|------|
| "用户可以..." | 移动端 + 后端 | "用户可以收藏场景" |
| "管理员可以..." | 管理后台 + 后端 | "管理员可以批量导入场景" |
| "场景"、"学习"、"进度" | 可能三端 | "实现场景管理功能" |
| "统计"、"报表"、"批量" | 管理后台 + 后端 | "生成用户学习报表" |
| "API"、"接口" | 后端 | "添加场景查询 API" |
| "界面"、"UI"、"页面" | 前端 | "优化场景列表界面" |
| "数据库"、"表"、"迁移" | 后端 | "添加收藏表" |
| "TTS"、"语音"、"发音" | 移动端 | "优化 TTS 发音" |
| "导入"、"导出"、"Excel" | 管理后台 + 后端 | "支持场景批量导入" |

### 功能类型映射

| 功能类型 | 涉及端 |
|----------|--------|
| 用户端功能 | 移动端 + 后端 |
| 管理功能 | 管理后台 + 后端 |
| 数据统计 | 管理后台 + 后端 |
| 学习功能 | 移动端 + 后端 |
| 内容管理 | 管理后台 + 后端 |
| 权限控制 | 后端 |
| UI 优化 | 移动端 或 管理后台 |

---

## 🔗 API 端点规范

### 移动端 API

**路径前缀**: `/api/v1/mobile/`

**特点**:
- 面向普通用户
- 只读或有限写入
- 无需管理员权限
- 响应数据精简

**示例**:
```
GET  /api/v1/mobile/scenes              # 获取场景列表
GET  /api/v1/mobile/scenes/{id}         # 获取场景详情
POST /api/v1/mobile/favorites           # 添加收藏
GET  /api/v1/mobile/users/{id}/progress # 获取学习进度
```

### 管理后台 API

**路径前缀**: `/api/v1/admin/`

**特点**:
- 面向管理员
- 完整的 CRUD 操作
- 需要管理员权限（AdminGuard）
- 支持批量操作
- 响应数据详细

**示例**:
```
GET    /api/v1/admin/scenes              # 获取场景列表（带分页）
POST   /api/v1/admin/scenes              # 创建场景
PUT    /api/v1/admin/scenes/{id}         # 更新场景
DELETE /api/v1/admin/scenes/{id}         # 删除场景
POST   /api/v1/admin/scenes/batch        # 批量导入场景
GET    /api/v1/admin/users               # 获取用户列表
GET    /api/v1/admin/statistics          # 获取统计数据
```

### 共享 API

**路径前缀**: `/api/v1/auth/` 或 `/api/v1/common/`

**特点**:
- 移动端和管理后台共享
- 认证相关
- 公共���源

**示例**:
```
POST /api/v1/auth/login                  # 登录（移动端和管理后台共用）
POST /api/v1/auth/register               # 注册
POST /api/v1/auth/refresh                # 刷新 Token
GET  /api/v1/common/categories           # 获取分类（共享）
```

---

## 📊 数据模型规范

### 类型映射

| 概念类型 | Rust | Dart | PostgreSQL |
|----------|------|------|------------|
| 整数 ID | `i64` | `int` | `BIGSERIAL` |
| 字符串 | `String` | `String` | `VARCHAR` / `TEXT` |
| 可选字符串 | `Option<String>` | `String?` | `TEXT NULL` |
| 布尔值 | `bool` | `bool` | `BOOLEAN` |
| 时间戳 | `DateTime<Utc>` | `DateTime` | `TIMESTAMP` |
| JSON | `serde_json::Value` | `Map<String, dynamic>` | `JSONB` |

### 命名规范

**Rust (后端)**:
- Struct: `PascalCase` (如 `Scene`, `UserProfile`)
- Field: `snake_case` (如 `created_at`, `category_id`)
- Function: `snake_case` (如 `get_scenes_by_category`)

**Dart (前端)**:
- Class: `PascalCase` (如 `Scene`, `UserProfile`)
- Field: `camelCase` (如 `createdAt`, `categoryId`)
- Function: `camelCase` (如 `getScenesByCategory`)

**PostgreSQL (数据库)**:
- Table: `snake_case` (如 `scenes`, `user_profiles`)
- Column: `snake_case` (如 `created_at`, `category_id`)

### 标准字段

**所有表必须包含**:
```sql
id BIGSERIAL PRIMARY KEY,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
deleted_at TIMESTAMP NULL  -- 软删除
```

---

## 🔄 开发流程

### 标准流程（新功能）

```
Step 1: 需求分析
  → /orchestrator 分析需求
  → 识别涉及的端
  → 评估复杂度

Step 2: 契约定义
  → /contract-manager 创建契约
  → 定义数据模型
  → 定义 API 规范

Step 3: 代码生成
  → /code-generator 生成三端代码
  → 后端: Entity + Repository + Handler
  → 移动端: Entity + Repository + API Service
  → 管理后台: Entity + Repository + API Service

Step 4: 后端实现（优先）
  → kiki_server/code-implementation
  → 补充业务逻辑
  → 添加权限控制
  → 编写单元测试
  → kiki_server/code-review

Step 5: 前端实现（并行）
  → kiki_web/code-implementation (移动端)
  → kiki_web_manager/code-implementation (管理后台)
  → 实现 UI
  → 集成 API
  → 测试

Step 6: 集成测试
  → 端到端测试
  → 验收测试
```

### 快速流程（小修改）

```
Step 1: 直接修改代码
  → 使用项目级 Skills

Step 2: 代码审查
  → 自动触发 code-review

Step 3: 测试
```

---

## 📝 任务文件规范

### 文件路径

```
docs/tasks/backend/features/[功能名]-[日期].md
docs/tasks/app/features/[功能名]-[日期].md
docs/tasks/admin/features/[功能名]-[日期].md
```

### 任务模板

```markdown
# [功能名称]

**优先级**: P0/P1/P2/P3
**状态**: 📝 待办
**涉及端**: 后端 / 移动端 / 管理后台
**预计时间**: X 小时
**创建时间**: 2026-03-04

## 需求描述

[详细描述]

## 技术方案

### 后端
- [ ] API: POST /api/v1/mobile/xxx
- [ ] 数据表: xxx
- [ ] 业务逻辑: xxx

### 移动端
- [ ] UI: xxx 页面
- [ ] 功能: xxx

### 管理后台
- [ ] UI: xxx 页面
- [ ] 功能: xxx

## 依赖关系

- 依赖: [其他任务]

## 自动化执行

是否允许自动执行？ [x] 是 [ ] 否

## 验收标准

- [ ] 标准 1
- [ ] 标准 2
```

---

## 🎯 常见场景处理

### 场景 1: 用户端新功能

**示例**: "用户可以收藏场景"

**涉及端**: 移动端 + 后端

**任务分解**:
1. 后端:
   - 创建 `user_favorites` 表
   - API: `POST /api/v1/mobile/favorites`
   - API: `DELETE /api/v1/mobile/favorites/{id}`
   - API: `GET /api/v1/mobile/users/{id}/favorites`
2. 移动端:
   - 场景详情页添加收藏按钮
   - 新增"我的收藏"页面

---

### 场景 2: 管理功能

**示例**: "管理员可以批量导入场景"

**涉及端**: 管理后台 + 后端

**任务分解**:
1. 后端:
   - API: `POST /api/v1/admin/scenes/batch`
   - 解析 Excel/CSV 文件
   - 批量插入数据库
   - 添加 AdminGuard 权限
2. 管理后台:
   - 文件上传组件
   - 导入进度显示
   - 错误处理和提示

---

### 场景 3: 三端功能

**示例**: "实现场景管理功能"

**涉及端**: 后端 + 移动端 + 管理后台

**任务分解**:
1. 后端:
   - 移动端 API (只读)
   - 管理后台 API (CRUD)
2. 移动端:
   - 场景浏览界面
3. 管理后台:
   - 场景管理界面（创建/编辑/删除）

---

### 场景 4: 仅后端

**示例**: "添加 API 限流"

**涉及端**: 仅后端

**任务分解**:
1. 后端:
   - 实现限流中间件
   - 配置限流规则
   - 添加限流日志

---

### 场景 5: 仅前端

**示例**: "优化场景列表 UI"

**涉及端**: 移动端 或 管理后台

**任务分解**:
1. 移动端:
   - 优化列表布局
   - 添加加载动画
   - 优化滚动性能

---

## 🚨 注意事项

### 1. 权限控制

- 移动端 API: 用户权限（UserGuard）
- 管理后台 API: 管理员权限（AdminGuard）
- 共享 API: 根据具体情况

### 2. 数据一致性

- 三端使用相同的数据模型
- 类型映射必须正确
- 时间戳统一使用 UTC

### 3. API 版本控制

- 使用 `/api/v1/` 前缀
- 破坏性变更时升级版本号
- 保持向后兼容

### 4. 错误处理

- 统一的错误码
- 友好的错误提示
- 详细的错误日志

---

## 📚 相关文档

- [数据库 Schema](../../../docs/database/schema.md)
- [API 文档](../../../docs/api/)
- [任务管理](../../../docs/tasks/TASK_BOARD.md)
- [开发工作流](../../../docs/workflow/AI_DRIVEN_DEVELOPMENT.md)

---

**版本**: v1.0
**最后更新**: 2026-03-04
**适用项目**: Hi Kiki
**维护者**: Development Team
