# Kiki Chain 部署架构文档

## 📋 目录

- [服务器环境](#服务器环境)
- [部署架构](#部署架构)
- [GitHub Actions 部署方案](#github-actions-部署方案)
- [数据库管理策略](#数据库管理策略)
- [域名与反向代理](#域名与反向代理)
- [部署流程](#部署流程)
- [运维指南](#运维指南)

---

## 🖥️ 服务器环境

### 基本信息
- **服务器地址**: 82.156.34.186 (腾讯云)
- **操作系统**: Ubuntu 24.04 LTS
- **Docker**: 28.3.2
- **Docker Compose**: v2.38.2
- **SSH 用户**: ubuntu

### 运行中的服务

```
┌─────────────────────────────────────────────────────────┐
│ 旧项目 (qiqimanyou)                                      │
│ - Frontend: 8081 → keepthinking.me                      │
│ - Backend: 8001                                         │
│ - PostgreSQL: 5432                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 新项目 (kiki_chain) ⭐                                   │
│ - Admin: 18080 → kiki.keepthinking.me                   │
│           → admin.keepthinking.me                       │
│ - Backend: 18001 → kiki.keepthinking.me/api/            │
│ - PostgreSQL: 15432 (独立数据库)                        │
└─────────────────────────────────────────────────────────┘
```

---

## 🏗️ 部署架构

### 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Actions                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ 1. 构建 Docker 镜像                                   │   │
│  │ 2. 推送到 GHCR (ghcr.io/justkids2018/kiki-chain-*)  │   │
│  │ 3. 打标签: sha-{commit} + latest                     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ SSH 连接
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  腾讯云服务器 (82.156.34.186)                │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 主机 Nginx (80/443)                                 │    │
│  │ - SSL/TLS 终止                                      │    │
│  │ - 反向代理                                          │    │
│  └────────────────────────────────────────────────────┘    │
│                            │                                │
│         ┌──────────────────┼──────────────────┐            │
│         ↓                  ↓                  ↓            │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐         │
│  │ Admin    │      │ Backend  │      │ Postgres │         │
│  │ :18080   │      │ :18001   │      │ :15432   │         │
│  │ (容器)   │      │ (容器)   │      │ (容器)   │         │
│  └──────────┘      └──────────┘      └──────────┘         │
│       │                  │                  │              │
│       └──────────────────┴──────────────────┘              │
│              Docker Compose Network                        │
└─────────────────────────────────────────────────────────────┘
```

### 容器配置

| 服务 | 镜像 | 端口映射 | 健康检查 | 数据持久化 |
|------|------|----------|----------|-----------|
| **Admin** | ghcr.io/justkids2018/kiki-chain-admin | 127.0.0.1:18080→80 | - | - |
| **Backend** | ghcr.io/justkids2018/kiki-chain-backend | 127.0.0.1:18001→8001 | TCP :8001 | - |
| **PostgreSQL** | postgres:15 | 127.0.0.1:15432→5432 | pg_isready | volume: postgres_data |

**安全设计**：
- ✅ 所有端口仅绑定到 `127.0.0.1`，不对外暴露
- ✅ 通过主机 Nginx 反向代理访问
- ✅ SSL/TLS 由主机 Nginx 处理

---

## 🚀 GitHub Actions 部署方案

### 方案对比

我们评估了三种部署方案：

#### ✅ 方案 A：SSH + 脚本部署（当前方案）

**工作流程**：
```
GitHub Actions
  ↓ 1. 构建镜像推送到 GHCR
  ↓ 2. SSH 连接服务器
  ↓ 3. 登录 GHCR
  ↓ 4. 执行 step1-prepare.sh (生成配置)
  ↓ 5. 执行 step2-deploy.sh (数据库迁移 + 拉取镜像 + 重启服务)
  ↓ 6. 健康检查
```

**优点**：
- ✅ **完全控制**：可以执行数据库迁移、备份等复杂操作
- ✅ **灵活性高**：支持多环境配置（tencent/aliyun）
- ✅ **已经成熟**：脚本完善，易于维护
- ✅ **易于调试**：可以手动执行脚本排查问题
- ✅ **支持回滚**：有数据库备份机制

**缺点**：
- ⚠️ 需要管理 SSH 密钥
- ⚠️ 依赖服务器环境

**适用场景**：✅ **有状态应用，需要数据库迁移（我们的项目）**

---

#### 方案 B：Watchtower 自动更新

**工作流程**：
```
GitHub Actions → 推送镜像到 GHCR (latest 标签)
服务器 Watchtower → 定期检查更新 → 自动拉取 → 重启容器
```

**优点**：
- ✅ 简单：无需 SSH，只需推送镜像
- ✅ 自动化：定时检查更新

**缺点**：
- ❌ **无法执行数据库迁移**
- ❌ **无法控制更新时机**（可能在业务高峰期更新）
- ❌ **无回滚机制**
- ❌ **无健康检查**（更新失败也不知道）

**适用场景**：简单的无状态应用

---

#### 方案 C：Docker Swarm / Kubernetes

**优点**：
- ✅ 原生编排
- ✅ 滚动更新
- ✅ 服务发现

**缺点**：
- ❌ **过度设计**：单服务器不需要
- ❌ **学习成本高**
- ❌ **需要重构现有架构**

**适用场景**：多服务器集群

---

### 🏆 最终选择：方案 A（SSH + 脚本部署）

**理由**：
1. **数据库迁移是刚需**：我们的应用有数据库，需要执行 schema 迁移
2. **备份机制重要**：每次部署前自动备份数据库，安全可靠
3. **灵活性高**：可以根据需要调整部署流程
4. **已经成熟**：脚本已经过验证，稳定可靠

---

## 🗄️ 数据库管理策略

### 设计原则

1. **数据库独立性**：PostgreSQL 容器独立运行，数据持久化
2. **只初始化一次**：首次部署时执行 `init.sql`，后续不再重复
3. **增量迁移**：通过 `schema_migrations` 表跟踪已执行的迁移
4. **自动备份**：每次部署前自动备份数据库

### 数据库生命周期

```
首次部署:
  ┌─────────────────────────────────────────────────┐
  │ 1. 启动 PostgreSQL 容器                          │
  │ 2. 创建数据库 (如果不存在)                       │
  │ 3. 创建 schema_migrations 表                    │
  │ 4. 检查 users 表 → 不存在 → 执行 init.sql       │
  │ 5. 执行增量迁移 (migrations/*.sql)              │
  └─────────────────────────────────────────────────┘

后续部署:
  ┌─────────────────────────────────────────────────┐
  │ 1. 启动 PostgreSQL 容器 (使用已有数据)           │
  │ 2. 备份数据库                                    │
  │ 3. 检查 users 表 → 存在 → 跳过 init.sql         │
  │ 4. 执行增量迁移 (只执行未应用的)                 │
  └─────────────────────────────────────────────────┘
```

### 迁移文件管理

**目录结构**：
```
kiki_server/database/
├── init.sql                    # 初始化脚本（只执行一次）
└── migrations/
    ├── 001_add_user_profile.sql
    ├── 002_add_card_table.sql
    └── ...
```

**命名规范**：
- 格式：`{version}_{description}.sql`
- 版本号：3位数字，递增
- 描述：简短的英文描述

**执行规则**：
- ✅ 已执行的迁移会记录在 `schema_migrations` 表中
- ✅ 每次部署只执行未应用的迁移
- ✅ 迁移失败会中止部署

---

## 🌐 域名与反向代理

### 域名配置

| 域名 | 目标服务 | 用途 |
|------|---------|------|
| **kiki.keepthinking.me** | Admin (18080) + Backend (18001) | 主域名 |
| **admin.keepthinking.me** | Admin (18080) | 管理后台 |
| **keepthinking.me** | 旧项目 (8081) | 旧项目（保留） |

### Nginx 配置

**配置文件**：`/etc/nginx/conf.d/kiki-unified.conf`

```nginx
server {
    listen 443 ssl http2;
    server_name kiki.keepthinking.me admin.keepthinking.me;

    ssl_certificate /etc/letsencrypt/live/keepthinking.me/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/keepthinking.me/privkey.pem;

    # 后端 API
    location /api/ {
        proxy_pass http://127.0.0.1:18001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 管理后台
    location / {
        proxy_pass http://127.0.0.1:18080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 📦 部署流程

### 自动部署（推荐）

**触发条件**：推送代码到 `main` 分支

```bash
git push origin main
```

**GitHub Actions 自动执行**：
1. 构建 Docker 镜像
2. 推送到 GHCR
3. SSH 连接服务器
4. 执行部署脚本
5. 健康检查

**查看部署状态**：
- GitHub Actions: https://github.com/justkids2018/kiki_chain/actions
- 服务器日志: `ssh ubuntu@82.156.34.186 "cd ~/kiki_chain && docker compose logs -f"`

---

### 手动部署

**1. 本地准备**

```bash
cd /path/to/kiki_chain

# 生成部署配置
./scripts/deploy-release/step1-prepare.sh tencent
```

**2. 部署到服务器**

```bash
# 同步并部署
./scripts/deploy-release/step2-deploy.sh tencent
```

**3. 验证部署**

```bash
# 检查容器状态
ssh ubuntu@82.156.34.186 "cd ~/kiki_chain && docker compose ps"

# 检查后端健康
curl https://kiki.keepthinking.me/api/health

# 检查管理后台
curl -I https://kiki.keepthinking.me
```

---

## 🛠️ 运维指南

### 查看服务状态

```bash
# SSH 连接服务器
ssh ubuntu@82.156.34.186

# 查看容器状态
cd ~/kiki_chain
docker compose ps

# 查看日志
docker compose logs -f backend
docker compose logs -f admin
docker compose logs -f postgres
```

### 数据库操作

```bash
# 连接数据库
docker compose exec postgres psql -U kiki_user -d kiki_db

# 查看迁移历史
docker compose exec postgres psql -U kiki_user -d kiki_db -c "SELECT * FROM schema_migrations ORDER BY applied_at DESC;"

# 手动备份
docker compose exec postgres pg_dump -U kiki_user kiki_db | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### 回滚部署

```bash
# 1. 查看备份文件
ls -lh ~/kiki_chain/backups/

# 2. 恢复数据库
cd ~/kiki_chain
gunzip -c backups/kiki_db_20260115_120000.sql.gz | \
  docker compose exec -T postgres psql -U kiki_user -d kiki_db

# 3. 回滚到指定版本
docker compose pull backend:sha-{old_commit}
docker compose up -d backend
```

### 重启服务

```bash
# 重启所有服务
docker compose restart

# 重启单个服务
docker compose restart backend
docker compose restart admin
```

### 查看资源使用

```bash
# 容器资源使用
docker stats

# 磁盘使用
df -h
du -sh ~/kiki_chain/*

# 清理旧镜像
docker image prune -a
```

---

## 🔐 安全配置

### GitHub Secrets

以下敏感信息存储在 GitHub Secrets 中：

| Secret 名称 | 用途 |
|------------|------|
| `GHCR_USERNAME` | GitHub Container Registry 用户名 |
| `GHCR_READ_TOKEN` | GHCR 读取令牌 (read:packages) |
| `TENCENT_SSH_PRIVATE_KEY` | 服务器 SSH 私钥 |
| `DEPLOY_SERVER_IP` | 服务器 IP 地址 |
| `DEPLOY_SSH_USER` | SSH 用户名 |
| `DEPLOY_REMOTE_DIR` | 远程部署目录 |

### 服务器安全

- ✅ 所有容器端口仅绑定到 `127.0.0.1`
- ✅ 通过 Nginx 反向代理访问
- ✅ SSL/TLS 证书由 Let's Encrypt 提供
- ✅ SSH 密钥认证，禁用密码登录
- ✅ 数据库不对外暴露

---

## 📊 监控与告警

### 健康检查

**Backend 健康检查**：
- 端点：`http://127.0.0.1:18001/health`
- 方法：TCP 端口检查
- 间隔：30秒
- 超时：5秒
- 重试：3次

**PostgreSQL 健康检查**：
- 命令：`pg_isready -h 127.0.0.1 -U kiki_user`
- 间隔：10秒
- 超时：5秒
- 重试：5次

### 日志管理

**日志位置**：
- 容器日志：`docker compose logs`
- Nginx 日志：`/var/log/nginx/`
- 部署日志：GitHub Actions

**日志保留**：
- 容器日志：Docker 默认保留
- 数据库备份：手动清理旧备份

---

## 📝 变更记录

| 日期 | 版本 | 变更内容 |
|------|------|---------|
| 2026-01-15 | 1.0.0 | 初始版本，记录当前部署架构 |

---

## 🔗 相关链接

- **GitHub 仓库**: https://github.com/justkids2018/kiki_chain
- **GitHub Actions**: https://github.com/justkids2018/kiki_chain/actions
- **GHCR 镜像**: https://github.com/orgs/justkids2018/packages?repo_name=kiki_chain
- **管理后台**: https://kiki.keepthinking.me
- **API 文档**: https://kiki.keepthinking.me/api/docs

---

## 📞 联系方式

如有问题，请联系：
- **GitHub Issues**: https://github.com/justkids2018/kiki_chain/issues
- **维护者**: qisd
