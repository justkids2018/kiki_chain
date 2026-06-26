# Agent Entry

## Source Of Truth

Project-level agent behavior must follow shared platform governance.
Read these files first:

1. `.ai/system-platform/README.md`
2. `.ai/common-prompt/baseline/README.md`
3. `.github/copilot-instructions.md`

If a referenced shared governance file is missing in the current checkout, report the gap
and continue with the tracked project rules below.

## Project-Specific Notes

Keep project-specific operational details in project docs (for example `docs/project-ops.md`),
not in this entry file.

Project engineering system rules live under `docs/engineering/`.
Read `docs/engineering/README.md` before changing project structure, database files,
API contracts, deployment scripts, local development scripts, CI gates, or Agent rules.

For `kiki_web` architecture generation, use project-owned docs in `docs/architecture/` as the baseline.
For `kiki_web` implementation rules, follow `docs/architecture/kiki_web_flutter_simplified_ddd_architecture.md` and `docs/architecture/kiki_web_flutter_simplified_ddd_implementation_guide.md`.

## Development Standards

**所有开发规范参考 `.ai/dev-prompts/` 目录**

### 必读规范

在开始开发前，请先阅读以下规范文档：

1. **[API 开发规范](.ai/dev-prompts/api-development-standards.md)** - API 接口设计、文档编写、前后端协作流程
2. **[文档管理规范](.ai/dev-prompts/documentation-standards.md)** - 文档目录结构、命名规范、更新规则

### 快速参考

| 场景 | 查阅规范 |
|------|----------|
| 判断文件归属/工程体系 | [工程体系入口](docs/engineering/README.md) |
| 数据库初始化/迁移/事实源 | [数据库体系](docs/engineering/database-system.md) |
| 发布部署/云厂商迁移 | [部署体系](docs/engineering/deployment-system.md) |
| CI 门禁/禁止路径 | [CI 与质量门禁](docs/engineering/ci-quality-gates.md) |
| 开发新的 API 接口 | [API 开发规范](.ai/dev-prompts/api-development-standards.md) |
| 创建或更新文档 | [文档管理规范](.ai/dev-prompts/documentation-standards.md) |
| 查找文档位置 | [文档索引](docs/DOCS_INDEX.md) |

### 核心原则概要

**文档分层**：
- 共享文档（API 契约）→ `docs/`
- 专属文档（实现细节）→ `{project}/docs/`
- 工程体系规则 → `docs/engineering/`
- 数据库事实源 → `kiki_server/database/`

**API 开发**：
- 文档驱动开发：先写 API 文档，再写代码
- 前后端以 `docs/api/` 为唯一标准
- 接口变更必须同步更新文档

**工程体系收口**：
- 当前项目发布链路已经跑通，结构优化必须分阶段、可验证、可回滚
- 不得在验证发布链路前删除旧数据库/部署路径
- 涉及数据库、部署、CI、Agent 规则时，先查 `docs/engineering/`

**详细规范请查阅对应的规范文档。**

## Execution Rule

- Prefer skill-first routing.
- Respect baseline boundaries and quality gates.
- For high-risk changes, require explicit review and rollback plan.
- **Documentation-driven development**: API 文档先行，代码跟随文档实现
- **Documentation consistency**: 每次代码变更必须检查并更新相关文档
- **Keep the working release path alive**: 不要在单步改动中破坏当前 GitHub Actions + deploy-release 发布链路
