# 工程体系入口

本文档目录定义 Kiki Chain 的工程事实源、自动化边界和多 Agent 协作规则。目标是在不破坏已跑通发布链路的前提下，把当前项目沉淀为可复制、可迁移、可自动化维护的工程模板。

## 阅读顺序

所有 Agent 和开发者先读本文件，再按任务场景读取对应文档。

| 场景 | 必读文档 |
|---|---|
| 判断文件应该放哪里 | [project-structure.md](./project-structure.md) |
| 数据库初始化、迁移、schema 归属 | [database-system.md](./database-system.md) |
| API 契约、Server/Web/Admin 协作 | [api-contracts.md](./api-contracts.md) |
| 发布部署、云厂商迁移、GitHub Actions | [deployment-system.md](./deployment-system.md) |
| 本地启动、迁移、日志、验证 | [local-development.md](./local-development.md) |
| CI 门禁、禁止路径、质量检查 | [ci-quality-gates.md](./ci-quality-gates.md) |
| Claude/Codex/Copilot 协作规则 | [agent-collaboration.md](./agent-collaboration.md) |

## 核心原则

1. 已跑通的发布链路优先保活，任何结构优化必须分阶段、可验证、可回滚。
2. 每类工程资产只能有一个事实源，脚本和文档可以引用事实源，但不能复制出第二份事实源。
3. 跨端共享契约放根 `docs/`，子项目实现细节放各自项目目录。
4. 部署脚本只做编排和执行，不拥有业务 schema、API 契约或业务实现。
5. GitHub Actions 和本地脚本必须尽量读取同一套事实源，避免本地能跑、线上漏执行。
6. Agent 入口保持短，详细规则放本目录，避免不同 Agent 读到不同结论。

## 当前目标结构

```text
kiki_chain/
├── AGENTS.md                         # 多 Agent 入口，只引用规则，不堆细节
├── docs/
│   ├── engineering/                  # 工程体系规则，可迁移到新项目
│   ├── api/                          # 前后端共享 API 契约
│   ├── deployment/                   # 部署运维文档
│   ├── architecture/                 # 系统级架构
│   └── project-ops.md                # 项目级运维约定
├── kiki_server/
│   ├── database/                     # 数据库事实源
│   ├── docs/                         # 后端实现文档
│   └── src/                          # 后端实现
├── kiki_web/                         # Flutter 用户端
├── kiki_admin/                       # 管理后台
├── scripts/
│   ├── deploy-release/               # 发布部署编排
│   └── local_dev/                    # 本地开发环境脚本
└── .github/workflows/                # CI/CD 自动化
```

## 迁移策略

工程收口必须遵循四步：

1. **先写规则**：先更新工程文档和 Agent 入口，明确目标结构。
2. **再迁事实源**：迁移文件时保留当前可运行链路，避免一次性删除导致部署失效。
3. **再改脚本**：脚本切换后必须跑本地验证和发布预检。
4. **最后删旧路径**：确认没有引用、CI 已能阻止回退后，再删除旧目录。

任何高风险删除、生产部署、数据库变更都必须有影响范围、验证命令和回滚方案。
