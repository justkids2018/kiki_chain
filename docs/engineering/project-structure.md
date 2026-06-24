# 项目结构与事实源

## 目标

统一回答“文件应该放哪里”，避免数据库、API、部署、文档在多个目录重复存在。

## 事实源规则

| 资产类型 | 唯一事实源 | 说明 |
|---|---|---|
| API 契约 | `docs/api/` | Server/Web/Admin 共享契约，接口变更先改这里 |
| 后端数据库 | `kiki_server/database/` | 初始化、迁移、schema 快照和数据库说明 |
| 后端实现 | `kiki_server/src/` | Rust/Axum/sqlx 业务实现 |
| 后端实现文档 | `kiki_server/docs/` | 后端内部实现说明，不替代 API 契约 |
| Flutter 用户端 | `kiki_web/` | 用户端代码、资源、前端专属文档 |
| 管理后台 | `kiki_admin/` | Admin 代码、资源、前端专属文档 |
| 部署编排 | `scripts/deploy-release/` | 镜像发布、远端同步、compose、nginx、profile |
| 本地开发编排 | `scripts/local_dev/` | 本地启动、停止、迁移、日志、状态 |
| 工程体系规则 | `docs/engineering/` | 可迁移到新项目的工程规范 |
| 部署运维文档 | `docs/deployment/` | 当前项目发布说明、运行手册、云厂商接入 |

## 根 `docs/` 的边界

根 `docs/` 只放跨端共享信息和项目级规则：

- API 契约
- 系统架构
- 部署运维
- 工程体系规范
- 项目运维约定

不应在根 `docs/` 中继续新增后端专属数据库执行文件。数据库执行文件归属 `kiki_server/database/`。

## 子项目文档边界

子项目 `docs/` 只放内部实现细节：

- `kiki_server/docs/`：后端模块设计、实现细节、内部排障。
- `kiki_web/docs/`：Flutter 架构、组件、页面、资源生产流程。
- `kiki_admin/docs/`：Admin 内部说明。

子项目文档不能定义跨端 API 契约。

## 当前需要收口的历史路径

这些路径目前仍可能被引用，迁移前不能直接删除：

- `docs/database/`
- `kiki_server/migrations/`
- `scripts/deploy-release/db/`

目标是把数据库执行源统一到 `kiki_server/database/`，再更新脚本和引用，最后删除旧路径。

## 新项目移植规则

复制到新项目时，优先复制：

- `docs/engineering/`
- `AGENTS.md` 的入口结构
- `scripts/deploy-release/` 的两步部署模式
- `scripts/local_dev/` 的本地环境模式
- `.github/workflows/` 中的 CI/CD 模式

复制后必须替换项目名、镜像名、云厂商 profile、域名、数据库名和验证端点。
