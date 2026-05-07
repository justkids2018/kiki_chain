# CLOUD.md

## 目标
记录当前云端部署现状（阿里云）与后续迁移到腾讯云的改造位点。当前以“可运行、可维护”为主，迁移优化后续再做。

## 当前云端现状（阿里云）

### 生产信息（现状）
1. 云厂商：阿里云
2. 服务器：`root@39.102.74.171`
3. 项目目录：`/root/kiki_chain`
4. 域名：`https://mtrain.xyz`
5. 编排文件：`docker-compose.prod.yml`

### 生产服务拓扑
1. `nginx`：入口，监听 80/443
2. `backend`：Rust API（容器内 8001）
3. `admin`：Vue 管理后台
4. `postgres`：PostgreSQL 15（5432）
5. `certbot`：证书续期

### 部署脚本入口
1. 全量部署：`bash scripts/deploy/deploy-all.sh`
2. 后端部署：`bash scripts/deploy/deploy-backend.sh`
3. 管理后台部署：`bash scripts/deploy/deploy-admin.sh`
4. 代码同步：`bash scripts/deploy/deploy-sync.sh`
5. 数据库运维：`bash scripts/deploy/deploy-db.sh`

## 服务器启动（当前标准）

### 启动全部服务
```bash
ssh root@39.102.74.171
cd /root/kiki_chain
docker compose -f docker-compose.prod.yml up -d
```

### 查看状态
```bash
docker compose -f docker-compose.prod.yml ps
```

### 查看关键日志
```bash
docker logs hikiki_backend --tail 50
docker logs hikiki_nginx --tail 20
docker logs hikiki_postgres --tail 20
```

## 现状风险与约束
1. `deploy-sync.sh` 明确不能使用 `rsync --delete`，避免删除 `certbot/`、`backups/`。
2. `docker-compose.prod.yml` 中后端健康检查使用 `curl`，若镜像无 curl 可能误报 unhealthy。
3. 生产 CORS 当前绑定 `mtrain.xyz` 域名。
4. `kiki_server/auto_deploy.sh` 目前为空，统一以 `scripts/deploy/` 为准。

## 腾讯云迁移预留（后续执行）

### 需要替换的核心变量
1. 服务器地址：`SERVER=root@39.102.74.171`
2. 域名：`mtrain.xyz`
3. 证书与 DNS 提供商
4. 安全组与端口策略（80/443/5432）

### 需要逐步改造的文件
1. `scripts/deploy/deploy-sync.sh`
2. `scripts/deploy/deploy-backend.sh`
3. `scripts/deploy/deploy-admin.sh`
4. `scripts/deploy/deploy-all.sh`
5. `DEPLOY.md`
6. `docker-compose.prod.yml`（如镜像仓库、网络、健康检查策略变化）
7. `kiki_server/config/production.toml`（域名/CORS）

### 建议迁移步骤（草案）
1. 先平移部署脚本变量（IP、域名、路径）到腾讯云测试机。
2. 验证容器编排可用，再切 DNS。
3. 切流后观察 API、Admin、证书续期与数据库备份。
4. 稳定后再做性能优化与脚本重构。

## 本地与云端关系
1. 本地开发以 `scripts/dev/dev-start.sh` 为统一入口。
2. 云端部署以 `scripts/deploy/*.sh` 为统一入口。
3. 业务代码尽量与云厂商解耦，云差异收敛到脚本与配置。

## 维护约定
1. 云资源变化先更新本文件，再更新脚本。
2. 地址变更必须同步更新：部署脚本 + Nginx 配置 + 后端 CORS。
3. 迁移到腾讯云后，本文件保留“阿里云历史段落”，新增“腾讯云现状段落”，避免丢失排障信息。
