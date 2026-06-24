# 多 Agent 协作规则

## 目标

Claude、Codex、Copilot 和其他 Agent 必须读到同一套项目规则，避免不同工具按不同目录、不同发布流程工作。

## 入口层级

```text
AGENTS.md                         # 项目总入口
CLAUDE.md                         # Claude 适配入口，委托 AGENTS.md
.github/copilot-instructions.md   # Copilot/GitHub 适配入口，委托 AGENTS.md
docs/engineering/README.md        # 工程体系规则入口
```

## AGENTS.md 职责

`AGENTS.md` 只做入口和硬边界：

- 必读规则入口
- 工程事实源入口
- 高风险操作边界
- 验证要求
- 场景到文档的路由

不要把所有细节都写进 `AGENTS.md`。详细规则放 `docs/engineering/` 和项目专门文档。

## Agent 场景路由

| 场景 | 读取 |
|---|---|
| 数据库变更 | `docs/engineering/database-system.md` |
| API 变更 | `docs/engineering/api-contracts.md` 和 `docs/api/` |
| 部署变更 | `docs/engineering/deployment-system.md` 和 `docs/deployment/` |
| 本地开发脚本 | `docs/engineering/local-development.md` |
| CI 门禁 | `docs/engineering/ci-quality-gates.md` |
| 目录归属判断 | `docs/engineering/project-structure.md` |

## 高风险操作

以下操作不得自动执行，必须先说明影响范围、验证方式和回滚方案：

- 删除目录
- 删除数据库 volume
- 执行破坏性 SQL
- 修改生产部署脚本并立即发布
- force push
- 回滚线上数据

## 本项目当前迁移阶段

当前项目已经跑通 GitHub Actions 发布链路。工程体系收口必须先保证旧链路可用，再逐步切换事实源。

Agent 在执行目录迁移时必须遵循：

1. 先更新文档和规则。
2. 再迁移文件。
3. 再改脚本。
4. 再加 CI。
5. 最后删除旧路径。

每一步都要检查 `git diff`，确认没有误改用户正在处理的文件。
