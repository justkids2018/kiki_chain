# Hi Kiki Docker 统一配置部署方案

本文档目标：把部署基础信息集中到配置文件，做到“换云厂商/换 IP/换域名时，改一处即可跑通部署流程”。

## 1. 现有部署基线（已整理）

当前项目已经具备以下部署能力：

- Docker Compose 生产编排：docker-compose.prod.yml
- 腾讯云部署脚本：scripts/deploy-tencent/
- 历史部署文档：DEPLOY.md、scripts/deploy/DEPLOY-GUIDE.md、frontend/腾讯云部署指南_AMD64.md
- 服务组成：
  - PostgreSQL
  - Rust 后端（kiki_server）
  - Admin 管理台（kiki_admin）
  - Nginx 网关
  - Certbot（证书续期）

## 2. 统一配置设计

新增统一配置目录：

- scripts/deploy/config/deploy.env.example
- scripts/deploy-tencent/config/tencent.env
- scripts/deploy/config/aliyun.env

关键配置字段：

- 服务器连接：DEPLOY_SSH_USER、DEPLOY_SERVER_IP、DEPLOY_REMOTE_DIR
- 编排文件：DEPLOY_COMPOSE_FILE
- 域名：DEPLOY_PRIMARY_DOMAIN、DEPLOY_ADMIN_DOMAIN、DEPLOY_API_DOMAIN、DEPLOY_MOBILE_DOMAIN
- 协议策略：DEPLOY_ENABLE_HTTPS
- 健康检查路径：DEPLOY_API_HEALTH_PATH
- 数据库：DEPLOY_DB_CONTAINER、DEPLOY_DB_NAME、DEPLOY_DB_USER

这样后续切换腾讯云/阿里云，只需要切换配置文件，不需要到多个脚本里找 IP 和域名。

## 3. 统一执行入口

新增入口脚本：

- scripts/deploy/run.sh

支持 action：

- all
- sync
- backend
- admin
- db
- setup

支持 provider：

- tencent
- aliyun

示例：

```bash
# 腾讯云全量部署
./scripts/deploy/run.sh all --provider tencent

# 阿里云全量部署
./scripts/deploy/run.sh all --provider aliyun

# 腾讯云仅部署后端
./scripts/deploy/run.sh backend --provider tencent

# 腾讯云数据库状态检查
./scripts/deploy/run.sh db --provider tencent -- --status
```

说明：db 后面的参数通过 -- 透传给 deploy-db.sh。

## 4. 推荐域名规划（含客户端）

建议统一用二级域名，职责清晰：

- 主站（Web）：kiki.<你的主域名>
- Admin：admin.kiki.<你的主域名>
- API：api.kiki.<你的主域名>
- 客户端入口（H5/落地页）：mobile.kiki.<你的主域名>

若你希望继续沿用“同域名 + 路径”模式（例如 /admin、/api），也可以保留，二级域名配置先作为预留。

## 5. DNS 与网络检查清单

部署前请先确认：

1. A 记录
   - DEPLOY_PRIMARY_DOMAIN -> DEPLOY_SERVER_IP
   - DEPLOY_ADMIN_DOMAIN -> DEPLOY_SERVER_IP（如果启用独立 Admin 域名）
   - DEPLOY_API_DOMAIN -> DEPLOY_SERVER_IP（如果启用独立 API 域名）
   - DEPLOY_MOBILE_DOMAIN -> DEPLOY_SERVER_IP（如果启用）
2. 安全组/防火墙
   - 22（SSH）
   - 80（HTTP）
   - 443（HTTPS）
3. 服务器已安装 Docker 与 Docker Compose

## 6. HTTPS 与证书策略

- 默认建议：DEPLOY_ENABLE_HTTPS=true
- 证书建议统一使用 Let's Encrypt
- setup 流程里已经考虑了 webroot 模式续期

注意：setup-server.sh 仍是“现网双站共存场景”脚本（会调整 companion 项目端口并写宿主机 Nginx 规则），执行前建议先在低峰时段验证。

## 7. 一次完整部署（建议流程）

```bash
# 1) 检查并填写配置
vim scripts/deploy-tencent/config/tencent.env

# 2) 首次部署（会做更多初始化）
./scripts/deploy/run.sh setup --provider tencent

# 3) 日常迭代部署
./scripts/deploy/run.sh all --provider tencent

# 4) 查看数据库状态
./scripts/deploy/run.sh db --provider tencent -- --status
```

## 8. 后续可继续增强（下一步）

当前已完成“部署脚本配置集中化”。若你要做到“Nginx 和 Compose 完全不含硬编码域名”，下一步建议：

1. 增加 nginx 模板化（envsubst 生成 conf）
2. 增加 server/.env 生成步骤，统一注入 VITE_API_BASE_URL 等变量
3. 增加 deploy doctor 检测脚本（DNS、端口、证书、容器健康）并在 all 前自动执行

这样就可以实现真正的“一键部署 + 一键体检 + 一键切云”。
