# Hi Kiki 部署手册

## 服务器信息

| 项目 | 值 |
|------|----|
| 服务器 | `root@39.102.74.171` |
| 项目目录 | `/root/kiki_chain` |
| 域名 | `https://mtrain.xyz` |
| 数据库 | PostgreSQL 15，`hikiki_db`，用户 `postgres`，密码 `postgres` |

---

## 错误日志（2026-03-24）

以下是本次部署出现的所有问题，记录供以后排查参考。

### 问题 1：`hikiki_db` 数据库不存在

**现象：** 后端持续报错 `database "hikiki_db" does not exist`。

**根本原因：** Docker volume（`kiki_chain_hikiki_pgdata`）是从其他项目复用过来的旧 volume，内部数据不是空的，所以 PostgreSQL 容器启动时跳过了初始化脚本（Docker 规定：只有 volume 为空时才执行 `docker-entrypoint-initdb.d/` 里的 SQL）。

**修复方法：** 手动在容器里创建数据库并执行初始化 SQL：
```bash
docker exec hikiki_postgres psql -U postgres -c 'CREATE DATABASE hikiki_db;'
docker exec hikiki_postgres psql -U postgres -d hikiki_db -f /docker-entrypoint-initdb.d/01_init.sql
docker exec hikiki_postgres psql -U postgres -d hikiki_db -f /docker-entrypoint-initdb.d/02_scene_tables.sql
```

### 问题 2：rsync `--delete` 删除了服务器上的重要文件

**现象：** 代码同步后，服务器上的以下内容被删除：
- `certbot/conf/`（SSL 证书）
- `backups/`（数据库备份）
- `scripts/backup.sh`

**根本原因：** `deploy-sync.sh` 使用了 `rsync --delete`，它会把服务器上存在但本地没有的文件全部删掉。SSL 证书和数据库备份只存在于服务器上，本地没有，所以被删掉了。

**修复方法：** 在 `deploy-sync.sh` 的 rsync 命令中加入以下排除项（已修复，见下文）。

### 问题 3：`hikiki_backend` 容器状态显示 `unhealthy`

**现象：** `docker compose ps` 显示 backend 是 `unhealthy`，但 API 实际正常响应。

**根本原因：** `docker-compose.prod.yml` 的健康检查命令是：
```
curl -f http://localhost:8001/health || exit 1
```
Rust 二进制镜像里没有 `curl`，所以健康检查永远失败。这是误报，不影响实际服务。

**修复方法：** 把健康检查改成用 `/bin/sh` + `wget` 或者直接去掉 curl（见下文修复说明）。

### 问题 4：`production.toml` CORS 域名过时

**现象：** 生产配置里的 CORS 域名全是旧的（`keepthinking.me`、`82.156.34.186` 等），不包含 `mtrain.xyz`。

**修复方法：** 已更新为只保留 `https://mtrain.xyz` 和 `https://www.mtrain.xyz`。

### 问题 5：`hikiki_certbot` 容器未运行

**现象：** `docker compose ps` 里看不到 certbot 容器。SSL 证书续期可能失效。

**处理方式：** certbot 容器在 `docker-compose.prod.yml` 里没有加 `networks`，所以它无法访问内部服务。目前证书尚未到期，暂时不影响 HTTPS。

---

## 当前服务状态（2026-03-24 验证）

```
hikiki_postgres   healthy    ✅ 正常
hikiki_backend    unhealthy  ⚠️ 误报，API 实际可用（见问题 3）
hikiki_admin      running    ✅ 正常
hikiki_nginx      running    ✅ 正常
hikiki_certbot    -          ❌ 未运行
```

API 验证：
```bash
curl -s https://mtrain.xyz/api/v1/mobile/scene/categories
# 返回 {"success":true,"data":[...]} ✅
```

---

## 如何同步代码到服务器

**规则：永远不要让 rsync 删除服务器上的 `certbot/`、`backups/`、`nginx/` 目录。**

同步命令（手动执行，确认安全）：

```bash
rsync -avz \
  --exclude 'target/' \
  --exclude 'node_modules/' \
  --exclude '.git/' \
  --exclude 'kiki_web/' \
  --exclude '.DS_Store' \
  --exclude '*.swp' \
  --exclude 'kiki_server/target/' \
  --exclude 'kiki_admin/node_modules/' \
  --exclude 'kiki_admin/dist/' \
  --exclude 'certbot/' \
  --exclude 'backups/' \
  ./ root@39.102.74.171:/root/kiki_chain/
```

注意：**不加 `--delete`**。只同步本地有的文件，不删除服务器上多出来的文件。

---

## 如何启动远程服务器

### 正常启动（所有服务）

```bash
ssh root@39.102.74.171
cd /root/kiki_chain
docker compose -f docker-compose.prod.yml up -d
```

### 查看运行状态

```bash
docker compose -f docker-compose.prod.yml ps
```

### 查看日志

```bash
# 后端日志
docker logs hikiki_backend --tail 50

# 数据库日志
docker logs hikiki_postgres --tail 20

# Nginx 日志
docker logs hikiki_nginx --tail 20
```

---

## 启动项坏了怎么处理

### 场景 A：数据库连接失败（`database does not exist`）

```bash
# 1. 确认数据库是否存在
docker exec hikiki_postgres psql -U postgres -l

# 2. 如果 hikiki_db 不在列表里，手动创建
docker exec hikiki_postgres psql -U postgres -c 'CREATE DATABASE hikiki_db;'

# 3. 运行初始化 SQL（文件已挂载到容器里）
docker exec hikiki_postgres psql -U postgres -d hikiki_db \
  -f /docker-entrypoint-initdb.d/01_init.sql
docker exec hikiki_postgres psql -U postgres -d hikiki_db \
  -f /docker-entrypoint-initdb.d/02_scene_tables.sql

# 4. 重启后端
docker compose -f docker-compose.prod.yml restart backend
```

### 场景 B：后端容器启动失败

```bash
# 查看错误原因
docker logs hikiki_backend --tail 50

# 重新构建并启动
docker compose -f docker-compose.prod.yml up -d --build backend

# 如果端口冲突
docker compose -f docker-compose.prod.yml down backend
docker compose -f docker-compose.prod.yml up -d backend
```

### 场景 C：Nginx 报错 / HTTPS 无法访问

```bash
# 检查配置语法
docker exec hikiki_nginx nginx -t

# 重载配置（不中断服务）
docker exec hikiki_nginx nginx -s reload

# 重启 nginx
docker compose -f docker-compose.prod.yml restart nginx
```

### 场景 D：SSL 证书过期

```bash
# 手动续期
docker compose -f docker-compose.prod.yml run --rm certbot renew

# 续期后重载 nginx
docker exec hikiki_nginx nginx -s reload
```

### 场景 E：全部重启

```bash
cd /root/kiki_chain
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d
```

> **警告：不要轻易执行 `down -v`，加 `-v` 会删除数据库 volume，所有数据丢失。**

### 场景 F：数据库备份与恢复

```bash
# 手动备份
docker exec hikiki_postgres pg_dump -U postgres hikiki_db \
  | gzip > /root/kiki_chain/backups/hikiki_db_$(date +%Y%m%d_%H%M%S).sql.gz

# 恢复（先确认要恢复的文件）
ls /root/kiki_chain/backups/
gunzip -c /root/kiki_chain/backups/<文件名>.sql.gz \
  | docker exec -i hikiki_postgres psql -U postgres -d hikiki_db
```

---

## 更新部署流程

### 只更新后端代码

```bash
# 1. 本地同步代码（不加 --delete）
rsync -avz --exclude 'target/' --exclude '.git/' --exclude 'certbot/' --exclude 'backups/' \
  ./kiki_server/ root@39.102.74.171:/root/kiki_chain/kiki_server/

# 2. 在服务器重新构建后端
ssh root@39.102.74.171 "cd /root/kiki_chain && \
  docker compose -f docker-compose.prod.yml build backend --no-cache && \
  docker compose -f docker-compose.prod.yml up -d backend"
```

### 只更新管理后台

```bash
# 1. 同步 kiki_admin
rsync -avz --exclude 'node_modules/' --exclude 'dist/' \
  ./kiki_admin/ root@39.102.74.171:/root/kiki_chain/kiki_admin/

# 2. 在服务器重新构建 admin
ssh root@39.102.74.171 "cd /root/kiki_chain && \
  docker compose -f docker-compose.prod.yml build admin --no-cache && \
  docker compose -f docker-compose.prod.yml up -d admin nginx"
```

### 全量部署

```bash
bash scripts/deploy/deploy-all.sh
```

---

## 常用快捷命令

```bash
# SSH 进服务器
ssh root@39.102.74.171

# 进数据库交互
docker exec -it hikiki_postgres psql -U postgres -d hikiki_db

# 查所有表
\dt

# 查用户数量
SELECT count(*) FROM users;

# 退出 psql
\q
```
