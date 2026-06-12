# Agent Entry

## Source Of Truth

Project-level agent behavior must follow shared platform governance.
Read these files first:

1. `.ai/system-platform/README.md`
2. `.ai/common-prompt/baseline/README.md`
3. `.github/copilot-instructions.md`

## Project-Specific Notes

Keep project-specific operational details in project docs (for example `docs/project-ops.md`),
not in this entry file.

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
| 开发新的 API 接口 | [API 开发规范](.ai/dev-prompts/api-development-standards.md) |
| 创建或更新文档 | [文档管理规范](.ai/dev-prompts/documentation-standards.md) |
| 查找文档位置 | [文档索引](docs/DOCS_INDEX.md) |

### 核心原则概要

**文档分层**：
- 共享文档（API 契约）→ `docs/`
- 专属文档（实现细节）→ `{project}/docs/`

**API 开发**：
- 文档驱动开发：先写 API 文档，再写代码
- 前后端以 `docs/api/` 为唯一标准
- 接口变更必须同步更新文档

**详细规范请查阅对应的规范文档。**

## Execution Rule

- Prefer skill-first routing.
- Respect baseline boundaries and quality gates.
- For high-risk changes, require explicit review and rollback plan.
- **Documentation-driven development**: API 文档先行，代码跟随文档实现
- **Documentation consistency**: 每次代码变更必须检查并更新相关文档
