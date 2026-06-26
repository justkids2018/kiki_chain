# 自动部署与数据库迁移审计

> 更新日期：2026-06-24

## 目的

本文用于回答一个关键问题：当代码提交到 GitHub 后自动部署到腾讯云时，数据库结构变更是否会自动执行。

结论先行：

- 提交到 `main` 会触发 `.github/workflows/docker-release.yml`，构建后端与管理端镜像，并自动执行腾讯云部署。
- 部署过程中会执行数据库发布流程，除非手动设置 `skip_db_migration=true`。
- 当前自动部署脚本已切换为同步并执行 `kiki_server/database/`。
- 旧目录 `scripts/deploy-release/db/`、`kiki_server/migrations/`、`docs/database/` 暂时保留为历史兼容。
- 如果新功能把 SQL 加到旧目录，CI 会阻止；新迁移必须进入 `kiki_server/database/migrations/`。

## 当前自动部署链路

### 触发条件

主工作流是 `.github/workflows/docker-release.yml`。

- `push` 到 `main`：自动构建并部署。
- `workflow_dispatch`：手动触发，可传入 `image_tag`，也可选择 `skip_db_migration`。

### 执行流程

1. Checkout 代码。
2. 生成镜像标签。
   - 默认：`sha-${GITHUB_SHA::8}`。
   - 手动触发时可覆盖 `image_tag`。
3. 构建并推送镜像到 GHCR。
   - 后端：`ghcr.io/justkids2018/kiki-chain-backend:<tag>`。
   - 管理端：`ghcr.io/justkids2018/kiki-chain-admin:<tag>`。
4. 准备 SSH。
5. 执行 `scripts/deploy-release/step1-prepare.sh tencent`。
   - GitHub Actions 会通过环境变量注入 `DEPLOY_IMAGE_TAG`。
   - 生成 `deploy.env` 和 `deploy-manifest.txt`。
6. 执行 `scripts/deploy-release/step2-deploy.sh tencent`。
   - 同步最小部署资产到腾讯云。
   - 调用 `db-release.sh` 做数据库备份与迁移。
   - 拉取新镜像。
   - 启动 `postgres/backend/admin`。

## 服务器同步范围

`scripts/deploy-release/bin/common.sh` 中的 `sync_deploy_assets` 只同步以下内容：

```bash
rsync -az \
  --include 'scripts/' \
  --include 'scripts/deploy-release/***' \
  --exclude '*' \
  "$ROOT_DIR/" "$SERVER:$REMOTE_DIR/"
```

这意味着远端部署目录会拿到部署脚本和数据库事实源。

不会同步完整源码：

- `kiki_server/src/`
- `kiki_admin/`
- 其他本地源码目录

业务代码通过镜像更新，数据库迁移通过 `kiki_server/database/migrations/` 更新。

## 数据库迁移真实执行逻辑

`step2-deploy.sh` 会调用：

```bash
"$SCRIPT_DIR/db-release.sh" "$PROFILE_NAME"
```

`db-release.sh` 的关键行为：

1. 如果 `SKIP_DB_MIGRATION=true`，直接跳过迁移。
2. 启动 PostgreSQL 容器。
3. 尝试备份线上数据库到远端 `backups/`。
4. 创建 `schema_migrations` 表。
5. 如果 `users` 表不存在，执行 `kiki_server/database/init.sql`。
6. 遍历 `kiki_server/database/migrations/*.sql`。
7. 从文件名提取版本号：`001_xxx.sql` 的版本号是 `001`。
8. 如果 `schema_migrations` 已存在该版本，则跳过。
9. 如果未执行过，则执行 SQL，并写入 `schema_migrations(version)`。

### 重要限制

版本号只取文件名前缀：

```bash
version="${filename%%_*}"
```

所以 `005_create_learning_tables.sql` 和 `005_fix_user_roles.sql` 都是版本 `005`。如果线上已经记录了 `005`，另一个 `005` 文件即使内容不同也会被跳过。

## 当前迁移目录漂移

截至 2026-06-24，两个迁移目录并不一致。

| 状态 | 文件 |
|---|---|
| 相同 | `001_add_role_support.sql` |
| 相同 | `002_scene_tables.sql` |
| 相同 | `003_scenes_add_columns.sql` |
| 内容不同 | `004_feedback_tables.sql` |
| 仅在部署目录 | `scripts/deploy-release/db/migrations/005_create_learning_tables.sql` |
| 仅在后端目录 | `kiki_server/migrations/001_create_learning_tables.sql` |
| 原仅在后端目录，已承接到新事实源 | `kiki_server/migrations/005_fix_user_roles.sql` -> `kiki_server/database/migrations/006_fix_user_roles.sql` |
| 原仅在后端目录，已承接到新事实源 | `kiki_server/migrations/006_subscription_commercialization.sql` -> `kiki_server/database/migrations/007_subscription_commercialization.sql` |

### 当前高风险点

1. 历史上 `kiki_server/migrations/006_subscription_commercialization.sql` 不在部署迁移目录。
   - 后端代码已经使用 `is_vip`、`vip_expire_at`、`subscription_products`、`subscription_orders`、`subscription_events` 等结构。
   - 新库的 `init.sql` 已包含部分字段，但老库只靠迁移补齐。
   - 现已在新事实源中承接为 `007_subscription_commercialization.sql`。

2. `001_add_role_support.sql` 使用 `role_id`，但当前后端代码主要使用 `role_type`。
   - `init.sql` 创建的是 `role_type`。
   - 后端查询、JWT、权限判断也使用 `role_type`。
   - 这说明早期迁移和当前模型存在历史漂移。

3. `005` 版本号已发生冲突风险。
   - 部署目录的 `005` 是 `005_create_learning_tables.sql`。
   - 后端目录的 `005` 是 `005_fix_user_roles.sql`。
   - 自动迁移以版本号为唯一键，不以文件名或 checksum 判断。

## 对“提交代码后数据库会不会重新执行”的回答

分情况：

### 会执行的情况

满足以下条件时，会自动执行：

- 代码 push 到 `main` 或手动触发 `docker-release.yml`。
- 没有设置 `skip_db_migration=true`。
- 新 SQL 文件位于 `kiki_server/database/migrations/`。
- 文件名前缀版本号没有出现在远端 `schema_migrations` 表中。

### 不会执行的情况

以下情况不会自动执行：

- SQL 只放在历史旧目录。
- SQL 文件进入新事实源，但版本号已经执行过。
- 手动触发工作流时设置了 `skip_db_migration=true`。
- 只修改了 `init.sql`，而线上 `users` 表已存在。

### 会失败并中断部署的情况

以下情况大概率会使部署失败：

- 迁移 SQL 非幂等，例如重复创建已存在对象且没有 `IF NOT EXISTS`。
- 迁移依赖的旧表或旧字段不存在。
- SQL 方言错误，例如 MySQL 语法被放进 PostgreSQL 迁移。
- 迁移执行成功但记录 `schema_migrations` 失败，导致下次重复执行。

## 推荐的收口方案（已切换事实源）

### 当前规则：统一到后端数据库事实源

数据库属于后端服务，事实源为：

```text
kiki_server/database/
├── init.sql
└── migrations/
```

目标完成后，开发新功能如果涉及数据库：

1. 新增一个未使用过的版本号，例如 `kiki_server/database/migrations/008_next_change.sql`。
2. 确保 SQL 是 PostgreSQL 语法。
3. 确保 SQL 幂等，优先使用：
   - `CREATE TABLE IF NOT EXISTS`
   - `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
   - `CREATE INDEX IF NOT EXISTS`
   - `INSERT ... ON CONFLICT`
4. 不修改已经上线执行过的旧迁移。
5. 不再向 `docs/database/`、`kiki_server/migrations/`、`scripts/deploy-release/db/migrations/` 新增执行 SQL。

### 过渡期规则：先保活，再迁移

当前脚本已经读取 `kiki_server/database/`，但旧目录仍暂时保留。删除旧路径前仍需分阶段：

1. 验证本地迁移脚本。
2. 验证 deploy-release Step1/Step2 预检路径。
3. 清理旧文档引用。
4. 确认无引用后删除旧路径。

### 中期改进：增加 CI 门禁

建议在 GitHub Actions 里增加一个迁移一致性检查：

- 禁止向旧执行路径新增 SQL。
- 检查 `kiki_server/database/migrations/` 中版本号不得重复。
- 检查迁移文件名必须匹配：`^[0-9]{3}_[a-z0-9_]+\.sql$`。

这样可以防止“后端数据库变更没有进入自动部署链路”的情况。

## 发布前检查清单

每次有数据库变更时，提交前检查：

- [ ] 是否只新增 `kiki_server/database/migrations/NNN_xxx.sql`。
- [ ] `NNN` 是否大于线上已执行版本，且没有重复。
- [ ] 是否没有只改 `init.sql` 而忘记增量迁移。
- [ ] SQL 是否是 PostgreSQL 语法。
- [ ] SQL 是否幂等。
- [ ] 是否避免删除字段、删表、清空数据等高风险操作。
- [ ] 相关后端代码是否只依赖迁移后一定存在的字段或表。
- [ ] API 变更是否同步更新 `docs/api/`。

## 当前建议的下一步

1. 梳理线上 `schema_migrations` 表，确认已执行到哪个版本。
2. 用本地和部署预检验证新事实源路径。
3. 清理旧文档引用。
4. 发布验证通过后删除旧数据库路径。
5. 评估是否需要把 `db-release.sh` 改为记录 `version + filename + checksum`，避免同版本不同文件被静默跳过。
