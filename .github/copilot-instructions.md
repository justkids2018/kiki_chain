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
- Unified deployment + domain/TLS onboarding -> just-deploy-release
- Generate requirement/logic/api docs from code -> just-feature-doc-generator
- Generate hotspot JSON from image + MD -> just-hotspot-generator
- Card vocab + role design (selecting 8 words / dedup / character cast Mimi-Yuki-Kiki-Jack) -> just-card-vocab-design
- Card production full chain (Prompt to Admin) -> just-card-to-json-workflow
- Card JSON text to audio + Qiniu upload -> just-card-audio-qiniu-workflow
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

- `just-github-workflows`
	- Trigger words: 配GitHub Actions, 配CI/CD, workflow移到新项目, 复制workflow, 配安卓打包, 配iOS打包, 配Docker自动构建, APK自动打包, 签名secrets配置, 镜像自动构建部署, 新项目配workflow, CI workflow迁移

- `just-deploy-release`
	- Trigger words: 部署到服务器, 统一部署, 一键部署, 先step1再step2, 域名接入, HTTPS接入, nginx接入, admin+server+db部署, 腾讯云部署, 阿里云部署, 自动发布, release发布, tag发布, GitHub workflow部署
- `just-feature-doc-generator`
	- Trigger words: 根据代码出文档, 反向生成功能文档, 梳理功能逻辑, 生成接口文档, 需求文档整理
- `just-hotspot-generator`
	- Trigger words: 图片生成热区, 自动标注热区, 根据图片生成JSON, 生成items_data, 1024x1024坐标, card/object热区
- `just-card-vocab-design`
	- Trigger words: 卡片词条, 选词, 换词, 查重, 去重, 一样的词, 重复词, 生成新卡, 新场景卡片, 词表设计, vocab, 8个词, 八个词条, 角色搭配, 谁出场, 出场组合, Jack出不出, 男孩女孩搭配
- `just-card-to-json-workflow`
	- Trigger words: 卡片全流程, 从prompt到admin, 图片+md生成json, 图片转json再校验, 只给目录跑流程, 目录到json校验, 89分门槛, 学习卡片workflow, 学习卡片生产流程, 学习法卡片workflow, 卡片生成并上传, 一张卡从出图到提交
- `just-card-audio-qiniu-workflow`
	- Trigger words: 卡片JSON转语音, 中文英文转语音, JSON词条生成音频, 上传七牛audio, Edge TTS批量音频, 卡片音频上传
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

Fallback behavior:

- If the user's request is exploratory (e.g., "先分析", "先讨论方案", "先别写代码"), keep to analysis mode and do not auto-enter execution workflows.
- If request contains multiple intents, choose one primary workflow and explicitly list the next-step workflows.

## Documentation Discipline

- Engineering system rules live under `docs/engineering/`; use `docs/engineering/README.md` as the entry for project structure, database, deployment, local development, CI gates, and Agent collaboration.
- Keep feature artifacts under `doc/features/<feature>/`.
- Keep reverse docs under `doc/feature-docs/<feature>/`.
- Keep docs aligned with delivered behavior.

## Kiki Web Architecture Baseline (Mandatory)

For `kiki_web` feature design and code generation, always apply this project-owned baseline:

1. `docs/architecture/kiki_web_flutter_simplified_ddd_architecture.md`
2. `docs/architecture/kiki_web_flutter_simplified_ddd_implementation_guide.md`
3. New feature pages must follow the dedicated feature directory convention defined in implementation guide section `2.1 Feature Directory Convention` (co-locate `pages/controllers/widgets` under one feature directory).

Execution requirements:

- External architecture references are inspiration only; do not copy them verbatim.
- Every generated feature should be independently structured and regenerable.
- Keep one-way dependency flow: presentation -> domain -> data -> core/services.
- Avoid cross-feature direct coupling; share only through neutral contracts or shared infrastructure.
