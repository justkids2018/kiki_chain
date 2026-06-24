# 本地开发体系

## 目标

本地开发环境必须尽量复用线上事实源，避免本地能跑、线上漏迁移或线上脚本读另一套文件。

## 当前脚本入口

```text
scripts/local_dev/
├── start.sh
├── stop.sh
├── migrate.sh
├── status.sh
└── logs.sh
```

开发者和 Agent 应优先使用这些脚本，不要临时拼接命令。

## 职责

| 脚本 | 职责 |
|---|---|
| `start.sh` | 启动 PostgreSQL、后端、前端 |
| `stop.sh` | 停止本地服务 |
| `migrate.sh` | 补齐本地数据库结构并执行增量迁移 |
| `status.sh` | 查看服务状态 |
| `logs.sh` | 查看日志 |

## 数据库路径

本地迁移目标与线上一致：

```text
kiki_server/database/init.sql
kiki_server/database/migrations/
```

`scripts/local_dev/migrate.sh` 已读取 `kiki_server/database/`。它会先检查基础表，缺失时执行 `init.sql`，再执行 `migrations/*.sql` 中尚未记录的版本。旧迁移目录暂时保留为历史兼容，不再新增执行 SQL。

## 本地验证要求

涉及本地开发脚本、数据库路径或后端启动流程时，至少验证：

```bash
./scripts/local_dev/status.sh
./scripts/local_dev/migrate.sh
```

如涉及启动链路，再验证：

```bash
./scripts/local_dev/start.sh
./scripts/local_dev/logs.sh backend
```

如果本地已有运行服务，先确认状态，不要直接重置 volume。

## 迁移策略

本地脚本已切换到新数据库事实源。后续删除旧路径前，按阶段执行：

1. 跑本地迁移验证。
2. 检查 compose 初始化挂载。
3. 确认没有文档或脚本引用旧路径。
4. 最后删除旧路径。

这保证当前已跑通本地链路不会被一次性打断。
