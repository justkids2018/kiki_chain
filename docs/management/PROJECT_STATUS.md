# Hi Kiki 项目进度与计划

> 记录项目当前状态、已完成工作、待办事项和下一步计划

**最后更新**: 2026-03-12

---

## 📊 当前状态总览

### 架构模式

```
kiki_web (Flutter 移动端)
    ↓ HTTP API
kiki_server (Rust 后端)
    ↓ SQL
PostgreSQL (Docker 数据库)
```

### 数据流向

- **开发阶段**: kiki_web → Mock 数据（本地 JSON）
- **目标模式**: kiki_web → 真实 API → kiki_server → PostgreSQL

---

## ✅ 已完成

### 1. 数据库（PostgreSQL）

- [x] Docker 容器配置（`docker-compose.local.yml`）
- [x] 完整建表 SQL（`docs/database/init.sql`）
- [x] 测试数据初始化
  - 4 个场景分类
  - 8 个场景
  - 测试用户（13900139000 / test123）
- [x] 端口映射：5433 → 5432

### 2. 后端（kiki_server）

- [x] Clean Architecture 架构搭建
- [x] 数据库连接配置（sqlx + PostgreSQL）
- [x] JWT 认证系统
- [x] API 路径规范（`/api/v1/` 前缀）
- [x] 已实现的 API：
  - [x] `/health` - 健康检查
  - [x] `/api/v1/auth/login` - 登录
  - [x] `/api/v1/auth/register` - 注册
  - [x] `/api/v1/mobile/scene/categories` - 场景分类列表
  - [x] `/api/v1/mobile/scene/categories/:id/scenes` - 分类下的场景
  - [x] `/api/v1/mobile/scene/:id` - 场景详情
  - [x] `/api/v1/mobile/scene/search` - 场景搜索
  - [x] `/api/v1/mobile/user/profile` - 用户资料
- [x] 本地编译运行（9.8MB 二进制）
- [x] API 响应格式统一：`{success: bool, data: any, message: string}`

### 3. 移动端（kiki_web）

- [x] Clean Architecture + GetX 架构
- [x] Mock 数据模式（当前使用）
- [x] 真实 API 模式（已配置，可切换）
- [x] API 端点配置（`api_endpoints.dart`）
- [x] 环境配置（`env_config.dart`）
- [x] 场景分类页面
- [x] 场景列表页面
- [x] 场景详情页面

### 4. 开发工具

- [x] 环境状态检查脚本（`scripts/dev-start.sh`）
- [x] 服务停止脚本（`scripts/dev-stop.sh`）
- [x] 开发环境文档（`docs/DEV_SETUP.md`）

---

## 🚧 进行中

### API 对齐工作

**目标**: 确保 kiki_web 和 kiki_server 的 API 完全一致

**当前问题**:
- kiki_web 部分接口仍使用 Mock 数据
- 部分 API 字段名不匹配（已修复部分）
- 部分 API 响应格式需要调整

**已修复**:
- ✅ 场景分类 API 字段对齐（`display_order` → `order`）
- ✅ API 响应格式统一（`{success, data, message}`）
- ✅ 数据库端口配置（5433）

**待修复**:
- [ ] 场景详情 API 字段完整性验证
- [ ] 场景搜索 API 参数对齐
- [ ] 用户资料 API 字段对齐

---

## 📋 待办事项

### 优先级 P0（必须完成）

#### 1. API 完全对齐

**目标**: kiki_web 完全切换到真实 API，不再使用 Mock

**任务**:
- [ ] 逐个验证所有 API 端点
- [ ] 修复字段不匹配问题
- [ ] 修复响应格式不一致问题
- [ ] 更新 kiki_web 的 Repository 实现
- [ ] 设置 `env_config.dart` 中 `_useMock = false`

**验证清单**:
```bash
# 场景分类
curl -H "Authorization: Bearer <token>" http://127.0.0.1:8081/api/v1/mobile/scene/categories

# 场景列表
curl -H "Authorization: Bearer <token>" http://127.0.0.1:8081/api/v1/mobile/scene/categories/cat_001/scenes

# 场景详情
curl -H "Authorization: Bearer <token>" http://127.0.0.1:8081/api/v1/mobile/scene/scn_001

# 场景搜索
curl -H "Authorization: Bearer <token>" "http://127.0.0.1:8081/api/v1/mobile/scene/search?keyword=春节"

# 用户资料
curl -H "Authorization: Bearer <token>" http://127.0.0.1:8081/api/v1/mobile/user/profile
```

#### 2. 自动化启动流程

**目标**: 一键启动完整开发环境

**已完成**:
- [x] 状态检查脚本
- [x] 按需启动逻辑

**待完成**:
- [ ] 集成到 IDE（VS Code tasks）
- [ ] 添加日志查看命令
- [ ] 添加快速重启命令

#### 3. 数据库数据完善

**目标**: 补充更多测试数据

**待完成**:
- [ ] 补充更多场景（每个分类至少 5 个）
- [ ] 补充场景物品（scene_items）
- [ ] 补充用户学习记录示例
- [ ] 补充用户收藏示例

---

### 优先级 P1（重要）

#### 1. 新功能开发

- [ ] 用户收藏功能
  - [ ] 后端 API
  - [ ] 移动端 UI
- [ ] 学习进度记录
  - [ ] 后端 API
  - [ ] 移动端进度展示
- [ ] 用户成就系统
  - [ ] 后端 API
  - [ ] 移动端成就页面

#### 2. 性能优化

- [ ] API 响应缓存
- [ ] 图片懒加载
- [ ] 列表分页加载

#### 3. 测试

- [ ] 后端单元测试
- [ ] 后端集成测试
- [ ] 移动端 Widget 测试
- [ ] 端到端测试

---

### 优先级 P2（可选）

- [ ] 管理后台（kiki_web_manager）
- [ ] 数据统计面板
- [ ] 日志监控
- [ ] 错误追踪

---

## 🎯 下一步计划

### 本周目标（2026-03-12 ~ 2026-03-18）

**主要目标**: 完成 API 对齐，kiki_web 完全切换到真实 API

**具体任务**:

1. **Day 1-2: API 验证和修复**
   - 逐个测试所有 API 端点
   - 记录字段不匹配问题
   - 修复后端 DTO 定义
   - 修复前端 Entity 定义

2. **Day 3-4: 前端适配**
   - 更新 Repository 实现
   - 处理错误情况
   - 添加加载状态
   - 测试所有页面

3. **Day 5: 集成测试**
   - 端到端测试所有功能
   - 修复发现的问题
   - 性能测试

4. **Day 6-7: 数据完善**
   - 补充测试数据
   - 优化 SQL 脚本
   - 文档更新

---

## 📝 每次开发前检查清单

使用自动化脚本检查：

```bash
./scripts/dev-start.sh
```

手动检查项：

- [ ] Docker Desktop 运行中
- [ ] PostgreSQL 容器运行中（`docker ps | grep hikiki_postgres`）
- [ ] kiki_server 运行中（`curl http://127.0.0.1:8081/health`）
- [ ] kiki_web 配置正确（`_useMock` 设置）
- [ ] API 地址匹配运行平台（iOS/Android/真机）

---

## 🔄 开发工作流

### 标准流程

1. **启动环境**
   ```bash
   ./scripts/dev-start.sh --start
   ```

2. **开发代码**
   - 后端：修改 Rust 代码 → `cargo build --release` → 重启服务
   - 前端：修改 Dart 代码 → Hot Reload

3. **测试验证**
   - API 测试：`curl` 或 Postman
   - 前端测试：`flutter run`

4. **停止环境**
   ```bash
   ./scripts/dev-stop.sh
   ```

### 快速命令

```bash
# 查看状态
./scripts/dev-start.sh

# 启动服务
./scripts/dev-start.sh --start

# 停止服务
./scripts/dev-stop.sh

# 查看后端日志
tail -f /tmp/kiki_server.log

# 查看数据库
docker exec hikiki_postgres_local psql -U postgres -d hikiki_db

# 重启后端
pkill qiqimanyou_server && cd kiki_server && RUST_ENV=development ./target/release/qiqimanyou_server &
```

---

## 📈 进度追踪

### 完成度

- **数据库**: 90% ✅
- **后端 API**: 70% 🚧
- **移动端**: 60% 🚧
- **API 对齐**: 40% 🚧
- **测试**: 10% ⏳

### 里程碑

- [x] **M1**: 基础架构搭建（2026-02）
- [x] **M2**: 数据库设计完成（2026-02）
- [x] **M3**: 核心 API 实现（2026-03）
- [ ] **M4**: API 完全对齐（2026-03-18 目标）
- [ ] **M5**: 移动端完整功能（2026-03-31 目标）
- [ ] **M6**: 测试覆盖 80%（2026-04-15 目标）

---

## 🐛 已知问题

### 高优先级

1. **API 字段不匹配**
   - 部分字段名不一致
   - 部分字段缺失
   - 需要逐个验证修复

2. **Docker 构建问题**
   - DNS 解析失败（mirror.ccs.tencentyun.com）
   - 临时方案：本地编译，不使用 Docker 运行 app

### 中优先级

1. **密码存储**
   - 当前使用明文（开发环境）
   - 生产环境需要 bcrypt

2. **错误处理**
   - 部分 API 错误信息不够详细
   - 需要统一错误码

---

## 📚 相关文档

- [开发环境配置](./DEV_SETUP.md)
- [数据库文档](./database/README.md)
- [API 文档](./api/)
- [架构文档](./architecture/)
- [Skills 使用指南](../.claude/GETTING_STARTED.md)

---

**维护者**: Development Team
**更新频率**: 每周更新
