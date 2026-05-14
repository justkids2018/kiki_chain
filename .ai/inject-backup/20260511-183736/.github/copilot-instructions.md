# Copilot Instructions

## Runtime Contract

- AGENTS.md is the canonical rule source for this repository.
- CLAUDE.md is the only soft reference adapter.
- Use skills under `.github/skills/` as the authoritative skill assets in each target project.

## Skill-First Routing

When user intent matches an available specialized skill, invoke that skill workflow first.
Avoid ad-hoc direct answers when a dedicated skill exists.

Default behavior:

- Prefer automatic routing from natural-language intent.
- Do not require users to type slash commands.
- Use skill workflows as default when intent is clear, but do not force execution if the user is clearly asking to discuss/analyze first.
- If confidence is low, ask a short confirmation question before entering a workflow.

Routing map:

- End-to-end feature delivery -> just-dev-pipeline
- Generate requirement/logic/api docs from code -> just-feature-doc-generator
- Design review before coding -> just-plan-eng-review
- QA and verification -> just-qa
- Pre-commit review -> just-review
- Root cause analysis -> just-investigate
- Commit/PR/release handoff -> just-ship and just-document-release
- High-risk operations safety -> just-careful

## Keyword Trigger Hints

Use these phrases as strong routing signals in addition to semantic intent.

- `just-dev-pipeline`
	- Trigger words: 新增功能, 增加功能, 开发功能, 实现需求, 做一个功能, 功能迭代, 从需求到上线
- `just-feature-doc-generator`
	- Trigger words: 根据代码出文档, 反向生成功能文档, 梳理功能逻辑, 生成接口文档, 需求文档整理
- `just-plan-eng-review`
	- Trigger words: 先评审方案, 技术方案评审, 架构评审, 开发前评审, 风险评审
- `just-qa`
	- Trigger words: 跑测试, 做 QA, 回归验证, 验证修复, 验收测试
- `just-review`
	- Trigger words: 代码审查, 提交前检查, review 一下, 找风险点
- `just-investigate`
	- Trigger words: 排查问题, 根因分析, 为什么报错, 为什么没生效, 异常定位
- `just-ship` + `just-document-release`
	- Trigger words: 提交代码, 生成 PR, 发布版本, 发版收口, 发布文档同步
- `just-careful`
	- Trigger words: 删除, 覆盖, 回滚, 重置, force, down -v, 高风险操作

## Routing Priority

When multiple intents appear in one request, use this order:

1. High-risk safety (`just-careful`)
2. Failure diagnosis (`just-investigate`)
3. End-to-end feature workflow (`just-dev-pipeline`)
4. QA / Review / Ship / Docs worker skills

## Post-Change Auto QA

After any request that results in code changes (new feature, bug fix, interaction adjustment), run QA by default:

- Prefer `just-qa` automatically after implementation.
- For Flutter/Android/iOS UI-related changes, include page-level UI verification (navigation to changed page, screenshots, interaction and layout checks).
- Do not auto-run QA only when user explicitly requests analysis-only/no-execution, or explicitly defers QA.
- If QA cannot run due to missing environment/devices, report `BLOCKED` with required setup and next action.

Fallback behavior:

- If the user's request is exploratory (e.g., "先分析", "先讨论方案", "先别写代码"), keep to analysis mode and do not auto-enter execution workflows.
- If request contains multiple intents, choose one primary workflow and explicitly list the next-step workflows.

## Documentation Discipline

- Keep feature artifacts under `doc/features/<feature>/`.
- Keep reverse docs under `doc/feature-docs/<feature>/`.
- Keep docs aligned with delivered behavior.
