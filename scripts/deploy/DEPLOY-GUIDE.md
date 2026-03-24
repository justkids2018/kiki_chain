# Hi Kiki 部署手册

## 服务器信息

| 项目 | 值 |
|------|-----|
| 服务器 | 39.102.74.171 (阿里云) |
| 域名 | mtrain.xyz |
| 项目目录 | /root/kiki_chain |
| 数据库 | PostgreSQL 15, 用户 `postgres`, 密码 `postgres`, 库名 `hikiki_db` |
| SSL | Let's Encrypt, 自动续期 |

## 架构

```
                    ┌─────────────┐
  用户 ──HTTPS──▶   │   Nginx     │
                    │  (443/80)   │
                    └──┬──┬──┬────┘
                       │  │  │
            ┌──────────┘  │  └──────────┐
            ▼             ▼             ▼
     ┌────────────┐ ┌──────────┐ ┌────────────┐
     │  Admin Vue │ │ Backend  │ │ CDN Proxy  │
     │   (Nginx)  │ │ (Rust)   │ │ /cdn/ ──▶  │
     │   :80      │ │  :8001   │ │img.mtrain  │
     └────────────┘ └────┬─────┘ └────────────┘
                         │
                    ┌────▼─���───┐
                    │PostgreSQL│
                    │  :5432   │
                    └──────────┘
```

## 快速部署

### 全量部署（推荐首次或大更新时使用）
```bash
./scripts/deploy/deploy-all.sh
```

### 只更新后端（改了 Rust 代码）
```bash
./scripts/deploy/deploy-backend.sh
```

### 只更新管理后台（改了 Vue 代码）
```bash
./scripts/deploy/deploy-admin.sh
```

### 只执行数据库迁移
```bash
./scripts/deploy/deploy-db.sh
```

## 脚本说明

### 1. deploy-sync.sh — 代码同步

将本地代码 rsync 到服务器，自动排除 `target/`、`node_modules/`、`.git/`、`kiki_web/`。

```bash
./scripts/deploy/deploy-sync.sh
```

### 2. deploy-backend.sh — 后端部署

同步代码 → 备份数据库 → 重新构建 Rust 镜像 → 重启后端 → 验证 API。

```bash
# 完整流程（含代码同步）
./scripts/deploy/deploy-backend.sh

# 跳过同步（已手动同步过）
./scripts/deploy/deploy-backend.sh --no-sync
```

> Rust 编译需要 3-5 分钟，请耐心等待。

### 3. deploy-admin.sh — 管理后台部署

同步代码 → 构建 Vue 项目 → 重启 Admin + Nginx。

```bash
./scripts/deploy/deploy-admin.sh
./scripts/deploy/deploy-admin.sh --no-sync
```

### 4. deploy-db.sh — 数据库管理

```bash
# 执行所有迁移文件 (kiki_server/migrations/*.sql)
./scripts/deploy/deploy-db.sh

# 执行指定 SQL 文件
./scripts/deploy/deploy-db.sh --file path/to/migration.sql

# 直接执行 SQL
./scripts/deploy/deploy-db.sh --sql "SELECT count(*) FROM users"

# 查看数据库状态
./scripts/deploy/deploy-db.sh --status

# 仅备份
./scripts/deploy/deploy-db.sh --backup

# 恢复最新备份
./scripts/deploy/deploy-db.sh --restore latest
```

### 5. deploy-all.sh — 一键全量部署

按顺序执行：同步 → 数据库迁移 → 后端 → 管理后台。

## 常用运维命令

```bash
# SSH 连接服务器
ssh root@39.102.74.171

# 查看所有容器状态
ssh root@39.102.74.171 "cd /root/kiki_chain && docker compose -f docker-compose.prod.yml ps"

# 查看后端日志
ssh root@39.102.74.171 "docker logs hikiki_backend --tail 50"

# 查看实时日志
ssh root@39.102.74.171 "docker logs hikiki_backend -f"

# 重启单个服务
ssh root@39.102.74.171 "cd /root/kiki_chain && docker compose -f docker-compose.prod.yml restart backend"

# 重启所有服务
ssh root@39.102.74.171 "cd /root/kiki_chain && docker compose -f docker-compose.prod.yml restart"

# 停止所有服务
ssh root@39.102.74.171 "cd /root/kiki_chain && docker compose -f docker-compose.prod.yml down"

# 启动所有服务
ssh root@39.102.74.171 "cd /root/kiki_chain && docker compose -f docker-compose.prod.yml up -d"
```

## 数据库管理

```bash
# 进入数据库交互模式
ssh root@39.102.74.171 "docker exec -it hikiki_postgres psql -U postgres -d hikiki_db"

# pgAdmin 连接信息
#   Host:     39.102.74.171
#   Port:     5432
#   Username: postgres
#   Password: postgres
#   Database: hikiki_db
#   (需要阿里云安全组放行 5432 端口)
```

## 自动备份

数据库每天凌晨 3:00 自动备份，保留 7 天。

备份位置：`/root/kiki_chain/backups/`

## SSL 证书

Let's Encrypt 证书通过 Certbot 容器自动续期（每 12 小时检查一次）。
证书有效期 90 天，过期前会自动更新。

## Docker 容器

| 容器名 | 服务 | 端口 |
|--------|------|------|
| hikiki_postgres | PostgreSQL 15 | 5432 |
| hikiki_backend | Rust 后端 | 8001 (内部) |
| hikiki_admin | Vue 管理后台 | 80 (内部) |
| hikiki_nginx | Nginx 反向代理 | 80, 443 |
| hikiki_certbot | SSL 证书续期 | - |

## 故障排查

### 后端启动失败
```bash
# 查看错误日志
ssh root@39.102.74.171 "docker logs hikiki_backend --tail 50"
# 常见原因：数据库连接失败、端口冲突
```

### 管理后台白屏
```bash
# 检查 Nginx 配置
ssh root@39.102.74.171 "docker exec hikiki_nginx nginx -t"
# 检查管理后台构建产物
ssh root@39.102.74.171 "docker exec hikiki_admin ls /usr/share/nginx/html/"
```

### 图片不显示
图片通过 Nginx `/cdn/` 代理访问七牛云。如果图片不显示：
```bash
# 测试代理
ssh root@39.102.74.171 "curl -sI https://localhost/cdn/kiki/scenes/test.png -k | head -3"
```

### 数据库连接失败
```bash
ssh root@39.102.74.171 "docker exec hikiki_postgres pg_isready -U postgres"
```
