# kiki_chain 正式部署流程（两步制）

本文档用于团队执行统一发布流程。

## 1. 目标

- 先在本地生成固定部署文件（可审阅）
- 再将该文件同步到服务器并发布
- 保证发布过程可追溯、可复核

## 2. 本地部署文件目录（固定）

所有发布产物统一放在：

- `scripts/deploy-release/deploy_files/latest/`：当前待发布版本
- `scripts/deploy-release/deploy_files/releases/<artifact_id>/`：历史快照

每次 Step1 会生成：

1. `deploy.env`（发布环境变量）
2. `deploy-manifest.txt`（发布清单：服务器、域名、端口、stack 等）

## 3. 标准发布步骤

### Step 1：生成部署产物（本地）

```bash
./scripts/deploy-release/step1-prepare.sh tencent
```

执行后检查：

1. `scripts/deploy-release/deploy_files/latest/deploy.env`
2. `scripts/deploy-release/deploy_files/latest/deploy-manifest.txt`

重点检查项：

- server / remote_dir 是否正确
- 域名（mobile/admin/api）是否正确
- host 端口是否与现网冲突
- stack name 是否为 `kiki*`

### Step 2：同步并发布（远端）

```bash
./scripts/deploy-release/step2-deploy.sh tencent
```

Step2 内置：

1. SSH 与冲突预检查
2. 同步最小部署资产到远端（仅 `scripts/deploy-release`）
3. 数据库备份
4. 数据库增量迁移
5. 拉取镜像并启动 postgres/backend/admin
6. 健康检查

## 4. 首次域名接入

```bash
./scripts/deploy-release/install-host-nginx.sh tencent
```

该命令会生成并下发宿主机 Nginx 配置，将域名反代到本机端口。

## 5. 回滚建议

1. 先定位上一次可用的 `artifact_id`
2. 使用对应快照中的 `deploy.env` 重新执行 Step2
3. 如涉及数据库变更，按备份文件恢复

## 6. 约束与规范

- 线上禁止 `docker compose down -v`
- 生产数据库必须先备份再迁移
- 发布前必须审阅 `latest/deploy-manifest.txt`
- `DEPLOY_REMOTE_DIR` 固定使用独立项目目录（如 `~/kiki_chain`）
