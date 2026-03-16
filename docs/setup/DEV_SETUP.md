# Hi Kiki 开发环境快速启动

> 每次开发前对照此文档检查，确保环境正常。

---

## 1. 数据库

### 连接信息

| 项目 | 值 |
|------|-----|
| 类型 | PostgreSQL 15 |
| Host | localhost |
| Port | **5432** (Docker 映射) |
| Database | hikiki_db |
| User | postgres |
| Password | postgres |
| 连接字符串 | `postgresql://postgres:postgres@localhost:5432/hikiki_db` |

### 启动数据库

```bash
cd kiki_server
docker compose -f docker-compose.local.yml up -d postgres
```

### 验证数据库

```bash
docker exec hikiki_postgres_local psql -U postgres -d hikiki_db -c "\dt"
```

### 初始化 SQL

- 完整建表 + 示例数据：`docs/database/init.sql`
- 自动挂载路径：`docker-entrypoint-initdb.d/01_init.sql`

### 测试账号

| 字段 | 值 |
|------|-----|
| 手机号 | 13900139000 |
| 密码 | test123 |
| 密码存储 | 明文（开发环境） |

---

## 2. kiki_server（Rust 后端）

### 配置文件

- 环境变量：`kiki_server/.env`
- 服务配置：`kiki_server/config/development.toml`

### 关键配置

```env
# kiki_server/.env
ENVIRONMENT=development
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/hikiki_db
JWT_SECRET=d9F8jK2LmQwPzX7VcTaRgHs1NfYb0UJ3DeLoZiCvBkWpEqRsTxYuNmGhIjOlPqRw
```

```toml
# kiki_server/config/development.toml
[server]
host = "0.0.0.0"
port = 8081
```

### 启动服务器

```bash
cd kiki_server
RUST_ENV=development ./target/release/qiqimanyou_server &
```

### 重新编译

```bash
cd kiki_server
cargo build --release
```

### 验证服务器

```bash
curl http://127.0.0.1:8081/health
# 期望: {"status":"OK",...}
```

### 测试登录

```bash
curl -X POST http://127.0.0.1:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"13900139000","password":"test123"}'
```

---

## 3. kiki_web（Flutter 移动端）

### API 地址配置

| 运行平台 | API 地址 |
|----------|----------|
| iOS 模拟器 / macOS | `http://127.0.0.1:8081` |
| Android 模拟器 | `http://10.0.2.2:8081` |
| 真机（局域网） | `http://192.168.3.101:8081` |

### 配置文件

- `kiki_web/lib/config/env_config.dart` — Mock 模式开关
- `kiki_web/config/dev.env` — API Base URL

### 切换真实 API

```dart
// kiki_web/lib/config/env_config.dart
static bool _useMock = false;  // false = 真实 API
```

### 启动 App

```bash
cd kiki_web
flutter run
```

---

## 4. 启动检查清单

每次开发前按顺序检查：

- [ ] Docker Desktop 已运行
- [ ] PostgreSQL 容器运行中：`docker ps | grep hikiki_postgres`
- [ ] kiki_server 进程运行中：`curl http://127.0.0.1:8081/health`
- [ ] kiki_web `_useMock` 设置正确（true=Mock / false=真实API）
- [ ] kiki_web API 地址与运行平台匹配

---

## 5. API 路径速查

| 功能 | 方法 | 路径 |
|------|------|------|
| 健康检查 | GET | `/health` |
| 登录 | POST | `/api/v1/auth/login` |
| 注册 | POST | `/api/v1/auth/register` |
| 场景分类 | GET | `/api/v1/mobile/scene/categories` |
| 场景列表 | GET | `/api/v1/mobile/scene/categories/:id/scenes` |
| 场景详情 | GET | `/api/v1/mobile/scene/:id` |
| 场景搜索 | GET | `/api/v1/mobile/scene/search` |
| 用户资料 | GET | `/api/v1/mobile/user/profile` |

---

## 6. 常见问题

**服务器启动失败（数据库连接错误）**
→ 检查 `.env` 中 `DATABASE_URL` 端口是否为 `5432`

**Docker 镜像构建失败（DNS 错误）**
→ 使用本地编译：`cargo build --release`，不使用 Docker 运行 app

**API 返回 401**
→ 请求需要携带 `Authorization: Bearer <token>`

**kiki_web 无法连接服务器**
→ 检查 `env_config.dart` 中 `_useMock = false`，以及 API 地址是否匹配运行平台
