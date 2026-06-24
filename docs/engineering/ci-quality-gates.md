# CI 与质量门禁

## 目标

把“靠人记住”的规则变成 GitHub Actions 可执行检查，防止目录漂移、迁移遗漏和旧路径复活。

## 当前 CI

当前工作流：

- `.github/workflows/ci-validate.yml`
- `.github/workflows/docker-release.yml`
- `.github/workflows/android-release.yml`
- `.github/workflows/ios-release.yml`
- `.github/workflows/product-static-sites-release.yml`

## 必须逐步补齐的门禁

### 数据库门禁

目标：

- 只允许新增 `kiki_server/database/migrations/NNN_xxx.sql`。
- 禁止新增旧执行路径：
  - `docs/database/`
  - `kiki_server/migrations/`
  - `scripts/deploy-release/db/migrations/`
- 迁移版本号不得重复。
- 迁移文件名必须符合 `^[0-9]{3}_[a-z0-9_]+\.sql$`。
- SQL 不得包含明显 MySQL 方言。

### API 门禁

目标：

- 后端路由或 DTO 变更时，提醒检查 `docs/api/`。
- `docs/api/` 仍是唯一 API 契约。
- API 文档变更应触发 Server/Web/Admin 对齐检查。

### 部署门禁

目标：

- Step1 产物字段完整：
  - `DEPLOY_IMAGE_TAG`
  - `DEPLOY_BACKEND_IMAGE`
  - `DEPLOY_ADMIN_IMAGE`
- profile 必填字段完整。
- 禁止生产部署脚本出现 `down -v`。
- 禁止生产脚本默认删除远端目录或数据库 volume。

### Agent 规则门禁

目标：

- `AGENTS.md`、`CLAUDE.md`、`.github/copilot-instructions.md` 保持委托关系清晰。
- 关键规则不只存在于某个 Agent 的私有提示里。
- 新增工程规则必须能从 `docs/engineering/README.md` 找到。

## 分阶段接入

已接入：

- `scripts/check-db-migrations.sh`
- `.github/workflows/ci-validate.yml`

当前行为：

- 检查 `kiki_server/database/migrations/` 命名、版本重复和 MySQL 方言。
- 阻止后续向旧数据库 SQL 路径提交执行 SQL。
- 不因为旧目录历史存在而失败。

后续可增强：

1. 检查 API 契约与后端路由漂移。
2. 检查 deploy profile 必填字段。
3. 增加发布 dry-run 预检。

这样不会在迁移中途阻断已经跑通的发布链路。
