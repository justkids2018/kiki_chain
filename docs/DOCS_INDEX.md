# 文档索引与导航指南

## 🎯 快速查找

### 我需要查找...

| 需求 | 位置 | 说明 |
|------|------|------|
| **API 接口定义** | `docs/api/endpoints/` | ⭐ 前后端共享契约 |
| 后端实现细节 | `kiki_server/docs/` | 后端代码实现说明 |
| 前端实现细节 | `kiki_web/docs/` | 前端代码实现说明 |
| 整体架构设计 | `docs/architecture/` | 系统级架构文档 |
| 工程体系规则 | `docs/engineering/` | 目录归属、数据库、部署、CI、Agent 协作 |
| 数据库事实源 | `kiki_server/database/` | 数据库初始化、迁移、schema 快照 |
| 部署运维 | `docs/deployment/` | 部署流程、配置 |
| API 文档规范 | `docs/api/README.md` | 如何编写 API 文档 |

## 📁 目录结构

```
kiki_chain/                         # 项目根目录
│
├── docs/                           # 项目级共享文档
│   ├── api/                       # ⭐ API 接口文档（前后端契约）
│   │   ├── README.md             # API 文档编写规范
│   │   ├── endpoints/            # 接口定义
│   │   │   ├── auth.md          # 认证相关接口
│   │   │   ├── scenes.md        # 场景相关接口
│   │   │   ├── learning.md      # 学习记录接口
│   │   │   └── ...
│   │   └── schemas/              # 数据模型定义
│   │
│   ├── architecture/             # 整体架构设计
│   │   ├── system-overview.md
│   │   └── ...
│   │
│   ├── engineering/              # 工程体系规则
│   │   ├── README.md
│   │   ├── project-structure.md
│   │   ├── database-system.md
│   │   ├── api-contracts.md
│   │   ├── deployment-system.md
│   │   ├── local-development.md
│   │   ├── ci-quality-gates.md
│   │   └── agent-collaboration.md
│   │
│   ├── deployment/               # 部署文档
│   └── project-ops.md           # 项目运维说明
│
├── kiki_server/                   # 后端项目
│   ├── database/                 # 数据库事实源
│   │   ├── init.sql
│   │   ├── migrations/
│   │   ├── seeds/
│   │   └── snapshots/
│   │
│   ├── docs/                     # 后端专属文档
│   │   ├── implementation/      # 实现细节
│   │   └── api/                 # 后端 API 实现说明（非契约）
│   └── ...
│
├── kiki_web/                     # 前端项目
│   ├── docs/                     # 前端专属文档
│   │   ├── components/          # 组件文档
│   │   ├── state-management/    # 状态管理
│   │   ├── architecture/        # 前端架构（DDD）
│   │   └── ...
│   └── ...
│
└── kiki_admin/                   # 管理后台（如果有）
    └── docs/                     # 管理后台专属文档
```

## 🔍 文档查找规则（AI Agent）

### 规则 1：API 接口 → 根目录 docs/api/

**所有前后端接口定义必须且只能在这里查找和更新**

- ✅ 正确：`docs/api/endpoints/scenes.md`
- ❌ 错误：`kiki_server/docs/api/`（这里只能放实现说明）
- ❌ 错误：`kiki_web/docs/api/`（前端不应该定义接口）

### 规则 2：实现细节 → 对应子项目的 docs/

- 后端如何实现某个接口 → `kiki_server/docs/implementation/`
- 前端如何调用接口 → `kiki_web/docs/`
- 数据库初始化、迁移、schema 快照 → 目标事实源 `kiki_server/database/`

### 规则 3：架构设计 → 看范围

- **系统级架构**（前后端如何协作）→ `docs/architecture/`
- **前端架构**（DDD、状态管理）→ `kiki_web/docs/architecture/`
- **后端架构**（分层、模块）→ `kiki_server/docs/architecture/`

### 规则 4：工程体系 → docs/engineering/

- 目录归属 → `docs/engineering/project-structure.md`
- 数据库事实源 → `docs/engineering/database-system.md`
- 部署体系 → `docs/engineering/deployment-system.md`
- CI 门禁 → `docs/engineering/ci-quality-gates.md`
- 多 Agent 协作 → `docs/engineering/agent-collaboration.md`

## 📝 常见场景示例

### 场景 1：开发新的 API 接口

1. **先写接口文档** → `docs/api/endpoints/new-feature.md`
2. **后端实现** → 代码在 `kiki_server/`，实现说明在 `kiki_server/docs/implementation/`
3. **前端调用** → 代码在 `kiki_web/`，使用说明在 `kiki_web/docs/`

### 场景 2：修改现有接口

1. **更新接口文档** → `docs/api/endpoints/{module}.md`
2. **通知前后端** → API 文档变更即代表契约变更
3. **同步更新实现** → 前后端各自更新代码和内部文档

### 场景 3：查找某个接口的定义

```bash
# 步骤 1：先查 API 文档（契约）
cat docs/api/endpoints/{module}.md

# 步骤 2：如果需要实现细节
cat kiki_server/docs/implementation/{feature}.md  # 后端实现
cat kiki_web/docs/{feature}.md                    # 前端使用
```

## ⚠️ 重要约定

### 禁止行为

- ❌ 在子项目中定义 API 接口（接口定义必须在根目录 `docs/api/`）
- ❌ 使用 `doc` 目录（单数），必须使用 `docs`（复数）
- ❌ 前后端接口不一致（以 `docs/api/` 为唯一标准）

### 强制要求

- ✅ 新增/修改接口时，必须先更新 `docs/api/`
- ✅ PR 中涉及接口变更，必须包含 API 文档更新
- ✅ 前后端联调时，以 `docs/api/` 为仲裁标准

## 🤖 AI Agent 提示

当你（AI Agent）被要求：

- "查找 XXX 接口定义" → 去 `docs/api/endpoints/`
- "查看后端如何实现" → 去 `kiki_server/docs/`
- "查看前端如何使用" → 去 `kiki_web/docs/`
- "查看整体架构" → 去 `docs/architecture/`
- "更新 API 文档" → 更新 `docs/api/endpoints/`
- "判断文件放哪里/迁移数据库目录/改部署脚本/加 CI 门禁" → 先读 `docs/engineering/README.md`
- "查看或新增数据库初始化/迁移/schema 快照" → 目标事实源是 `kiki_server/database/`

**记住：API 文档是唯一真理来源，实现必须遵循文档！**
