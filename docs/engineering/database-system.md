# 数据库体系

## 目标

数据库结构属于后端服务。初始化脚本、增量迁移、schema 快照和数据库说明必须收敛到一个后端事实源，避免本地、线上、文档各维护一份。

## 事实源

```text
kiki_server/database/
├── README.md
├── init.sql
├── migrations/
├── seeds/
└── snapshots/
```

| 路径 | 用途 |
|---|---|
| `init.sql` | 全新环境首次建库基线 |
| `migrations/` | 每次数据库结构变更的唯一增量迁移目录 |
| `seeds/` | 可选，开发或初始化数据 |
| `snapshots/` | 可选，schema 导出快照 |
| `README.md` | 表结构索引、迁移规则、排障说明 |

## 部署执行逻辑

每次发布都进入数据库发布流程，但不会每次重建库：

```text
每次部署
  启动/检查 PostgreSQL
  备份线上数据库
  确保 schema_migrations 表存在
  如果基础表不存在：执行 kiki_server/database/init.sql
  遍历 kiki_server/database/migrations/*.sql
  只执行 schema_migrations 中未记录的版本
  记录执行成功的版本
```

## 迁移文件规则

迁移文件命名：

```text
NNN_short_description.sql
```

示例：

```text
007_subscription_commercialization.sql
008_add_scene_visibility_flags.sql
```

强制规则：

- 版本号必须唯一，且递增。
- 已上线迁移不得修改，只能新增更高版本迁移。
- SQL 必须兼容 PostgreSQL。
- 迁移必须尽量幂等。
- 不能只改 `init.sql` 而不提供老库增量迁移。

## PostgreSQL 语法要求

禁止 MySQL 方言：

- `AUTO_INCREMENT`
- `TINYINT(1)`
- `DATETIME`
- `ON DUPLICATE KEY UPDATE`
- `ENGINE=InnoDB`
- 表定义中的 `CHARSET` 或 `COLLATE`

推荐写法：

- `BIGSERIAL` 或 `SERIAL`
- `BOOLEAN`
- `TIMESTAMP` 或 `TIMESTAMPTZ`
- `INSERT ... ON CONFLICT (...) DO UPDATE`
- `CREATE TABLE IF NOT EXISTS`
- `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
- `CREATE INDEX IF NOT EXISTS`

## 现状与迁移约束

当前项目已将本地迁移脚本和 deploy-release 数据库发布脚本切换到：

```text
kiki_server/database/
```

以下历史路径暂时保留，不能继续新增执行 SQL：

- `docs/database/`
- `kiki_server/migrations/`
- `scripts/deploy-release/db/`

删除旧路径前必须确认所有引用已迁移，并保留回滚方案。

已完成：

- 创建 `kiki_server/database/` 目标结构。
- 迁移当前部署基线 SQL。
- 为旧目录中冲突版本新增安全生产版本 `006` 和 `007`。
- 改本地脚本读取新目录。
- 改部署脚本同步并读取新目录。
- 加 CI 门禁阻止旧路径新增数据库执行文件。

待完成：

- 清理旧文档引用。
- 确认生产发布验证通过后删除旧路径。

## CI 门禁要求

CI 必须检查：

- 只允许在 `kiki_server/database/migrations/` 新增迁移。
- 禁止新增 `docs/database/`、`kiki_server/migrations/`、`scripts/deploy-release/db/migrations/` 下的执行 SQL。
- 迁移版本号不能重复。
- 迁移文件名必须符合 `^[0-9]{3}_[a-z0-9_]+\.sql$`。
- 明显 MySQL 方言必须失败。

## 回滚原则

数据库回滚不能依赖删除迁移文件。发布前必须备份，失败时优先恢复备份或新增修复迁移。

涉及删表、删字段、数据清洗、重建 volume 的操作必须单独评审并给出回滚方案。
