# Hi Kiki - 项目文档

> 📖 **快速导航**：[文档索引与查找规则](./DOCS_INDEX.md)

## 📋 文档目录说明

**本目录（`docs/`）用于存放项目级共享文档，尤其是前后端契约。**

```
docs/
├── DOCS_INDEX.md              # 📖 文档索引与查找指南（推荐阅读）
│
├── api/                       # ⭐ API 接口文档（前后端共享契约）
│   ├── README.md             # API 文档编写规范
│   ├── endpoints/            # 接口定义（前后端都看这里）
│   │   ├── auth.md          # 认证相关接口
│   │   ├── scenes.md        # 场景相关接口
│   │   ├── learning.md      # 学习记录接口
│   │   └── ...
│   └── schemas/              # 数据模型定义
│
├── architecture/             # 整体架构设计
├── engineering/              # 工程体系规则（结构、数据库、部署、CI、Agent）
├── deployment/               # 部署相关文档
├── tts/                      # TTS 与 sherpa_onnx 文档
└── project-ops.md           # 项目运维说明
```

## 🎯 文档分层原则

| 文档类型 | 存放位置 | 说明 |
|---------|---------|------|
| **API 接口定义** | `docs/api/` | ⭐ 前后端共享契约，最重要 |
| 后端实现文档 | `kiki_server/docs/` | 后端代码实现细节 |
| 前端实现文档 | `kiki_web/docs/` | 前端代码实现细节 |
| 整体架构 | `docs/architecture/` | 系统级架构设计 |
| 工程体系 | `docs/engineering/` | 目录归属、数据库、部署、CI、Agent 协作规则 |
| 部署运维 | `docs/deployment/` | 部署流程、配置 |
| 数据库事实源 | `kiki_server/database/` | 数据库初始化、迁移、schema 快照归属 |

**详细说明请查看：[文档索引指南](./DOCS_INDEX.md)**

## TTS 文档

- **[TTS 文档索引](./tts/README.md)** — 统一查看 sherpa_onnx 与 TTS 相关文档

## 部署相关

当前部署文档和脚本统一在 `scripts/deploy-release/` 与 `docs/deployment/`：

- **[发布流程手册](../scripts/deploy-release/README.md)** — 当前权威部署流程（镜像发布 + 两步部署）
- **[运行手册（执行版）](./deployment/deploy-release-runbook.md)** — 运维执行最短路径
- **[正式部署流程](./deployment/kiki_chain_正式部署流程.md)** — 团队执行版流程说明
- **[统一配置方案](./deployment/docker_统一配置部署方案.md)** — 方案设计与演进记录

常用脚本：

- `step1-prepare.sh` — 生成部署产物（deploy.env / deploy-manifest.txt）
- `step2-deploy.sh` — 同步最小部署资产并执行发布
- `update-image-version.sh` — 更新本次发布镜像 tag 记录
- `db-release.sh` — 数据库备份 + 增量迁移
- `status.sh` — 运行状态检查
- `check-remote-layout.sh` — 远端目录整洁度检查

## 工程体系

当前项目已经跑通 GitHub Actions + GHCR + deploy-release 发布链路。结构优化必须先保活、再迁移、最后删除旧路径。

- **[工程体系入口](./engineering/README.md)** — 总入口
- **[项目结构与事实源](./engineering/project-structure.md)** — 文件归属和禁止重复事实源
- **[数据库体系](./engineering/database-system.md)** — 数据库目标事实源和迁移规则
- **[部署体系](./engineering/deployment-system.md)** — 云厂商 profile 与发布职责边界
- **[CI 与质量门禁](./engineering/ci-quality-gates.md)** — 防止旧路径复活和迁移遗漏
- **[多 Agent 协作规则](./engineering/agent-collaboration.md)** — Claude/Codex/Copilot 入口规则

## 各端项目

| 项目 | 路径 | 技术栈 |
|------|------|--------|
| 移动端 | `kiki_web/` | Flutter (Clean Architecture + GetX) |
| 后端 | `kiki_server/` | Rust (Axum + sqlx + PostgreSQL) |
| 管理后台 | `kiki_admin/` | Vue 3 + Vite |
