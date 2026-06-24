# Deploy Unified (New)

这是一套新的统一部署目录，目标是：

- 不影响旧目录：scripts/deploy、scripts/deploy-tencent
- 同机共存：默认只绑定 127.0.0.1 的高位端口，不抢占 80/443
- 一套脚本统一部署：PostgreSQL + backend + admin（Docker）

## 目录

- docker-compose.yml
- admin/
- server/
- db/                                  # 历史兼容目录，不再新增业务 SQL
- profiles/tencent.env
- profiles/aliyun.env
- profiles/example.env
- bin/common.sh
- deploy-all.sh
- status.sh
- check-remote-layout.sh
- step1-prepare.sh
- step2-deploy.sh
- db-release.sh
- install-host-nginx.sh
- nginx/site.conf.template
- deploy_files/latest/                # 固定“当前可发布”产物
- deploy_files/releases/<artifact_id>/ # 每次 Step1 的快照产物

## 本地部署文件目录

Step1 会把部署产物统一写入：

- `scripts/deploy-release/deploy_files/latest/`
	- `deploy.env`
	- `deploy-manifest.txt`
	- `host-nginx.conf`（执行 install-host-nginx.sh 后生成）
- `scripts/deploy-release/deploy_files/releases/<artifact_id>/`
	- 每次生成的一份不可变快照，方便回溯与审计

这样你们检查时只看 `latest`，追溯时看 `releases`。

## 快速开始

推荐按 2 步执行：

1. 第一步：生成部署产物（本地）
2. 第二步：同步并部署（远端）

```bash
./scripts/deploy-release/step1-prepare.sh tencent
./scripts/deploy-release/step2-deploy.sh tencent
```

首次接入域名（宿主机 Nginx 入口）：

```bash
./scripts/deploy-release/install-host-nginx.sh tencent

# 校验远端目录是否保持“仅部署资产”
./scripts/deploy-release/check-remote-layout.sh tencent
```

或显式文件路径：

```bash
./scripts/deploy-release/step1-prepare.sh ./scripts/deploy-release/profiles/tencent.env
./scripts/deploy-release/step2-deploy.sh ./scripts/deploy-release/profiles/tencent.env
```

也支持一键（兼容旧习惯）：

```bash
./scripts/deploy-release/deploy-all.sh tencent
```

## 运维辅助

```bash
# 查看状态
./scripts/deploy-release/status.sh tencent

# 单独执行数据库发布（会备份 + 增量迁移）
./scripts/deploy-release/db-release.sh tencent
```

## 同机共存设计

服务目录约定：

- `admin/`: 管理端相关部署资产（镜像由 compose 引用）
- `server/`: 后端相关部署资产（镜像由 compose 引用）
- `kiki_server/database/`: 数据库初始化与迁移事实源（Step2 会同步并执行）

compose 不暴露 80/443，只使用：

- backend: 127.0.0.1:${DEPLOY_BACKEND_HOST_PORT}
- admin: 127.0.0.1:${DEPLOY_ADMIN_HOST_PORT}
- postgres: ${DEPLOY_POSTGRES_HOST_BIND:-127.0.0.1}:${DEPLOY_POSTGRES_HOST_PORT}

你可以在宿主机现有 Nginx 上按域名反代到上述本地端口，实现“在已有项目上新增服务”。

如果需要用本地 pgAdmin 连接远程 PostgreSQL，可以在 profile 中设置：

```bash
DEPLOY_POSTGRES_HOST_BIND="0.0.0.0"
DEPLOY_POSTGRES_HOST_PORT="15432"
```

注意：开放 PostgreSQL 到公网前，必须在服务器安全组或防火墙中限制来源 IP，避免数据库端口对全网暴露。

## 服务器目录隔离（推荐）

- 统一使用独立目录部署 KiKi 项目，例如：`~/kiki_chain` 或 `/root/kiki_chain`。
- 不要与旧项目共用目录（如 `kiki_chain`、`qisd_eda_college`）。
- 好处：
	1. 运维边界清晰，回滚和排障更简单
	2. 避免 rsync/脚本误覆盖旧项目文件
	3. 后续把本流程做成 skill 时更容易标准化

## 命名防冲突建议

- `DEPLOY_STACK_NAME` 建议统一使用 `kiki_` 前缀（例如 `kiki_stack`）。
- 原因：同一台机器如果已有其他 compose 项目，使用独立且可识别前缀可以避免容器/网络/volume 命名混淆。
- `step2-deploy.sh` 已内置冲突预检查：
	1. 检查 stack 命名前缀
	2. 检查目标 localhost 端口是否被其他 Docker 容器占用
	3. 检查 `${DEPLOY_STACK_NAME}-postgres-1` 等同名容器是否仍由当前 Compose 项目管理

## 域名要不要写到后端

- 后端和前端在同一台服务器时，服务间调用通常不需要域名（容器内用服务名、宿主机用 127.0.0.1 端口）。
- 域名主要用于用户访问入口和 HTTPS（Nginx 层）。
- Admin 前端需要一个 API 基础地址，所以 profile 中保留 DEPLOY_ADMIN_API_BASE_URL。

## 数据库上线策略（重要）

- 线上数据库容器不会每次重建数据。只要 volume 在，数据会保留。
- 日常发布不需要把线上数据每次同步回本地。
- 只有在“需要改表结构”时才做 migration，且要先备份线上库再执行。
- 禁止在生产执行 down -v（会删除数据库卷）。
- 新增数据库迁移只允许放在 `kiki_server/database/migrations/`。
- `scripts/deploy-release/db/` 仅为历史兼容目录，不再新增业务 SQL。

在正式流程中，step2 已内置：

1. 备份线上数据库（输出到远端 backups/）
2. 执行增量迁移（基于 schema_migrations 记录）
3. 再构建并拉起 backend/admin

推荐流程：

1. 先备份线上数据库
2. 执行迁移脚本（仅增量变更）
3. 再发布后端与 admin

## 迁移建议

旧目录暂时保留，建议步骤：

1. 先用 deploy-release 完成一次灰度部署并验证
2. 通过域名切流验证稳定性
3. 确认无引用后再删除旧 deploy/database 目录
