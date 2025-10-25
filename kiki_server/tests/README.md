# 测试脚本说明

本目录包含了多个测试脚本，用于验证项目的各种功能和性能。

## 测试脚本列表

### 1. `api_test.sh` - API功能测试
完整的API端点功能测试，包括：
- 静态文件服务
- CORS跨域请求
- 用户认证（登录/失败）
- 票据CRUD操作
- 错误处理
- 请求日志记录

**使用方法：**
```bash
# 1. 先启动服务器
cargo run

# 2. 在另一个终端运行测试
./tests/api_test.sh
```

### 2. `log_test.sh` - 日志功能测试
测试不同日志级别的输出效果：
- `trace` - 最详细的日志
- `debug` - 调试级别日志
- `info` - 一般信息日志
- `warn` - 仅警告和错误
- `error` - 仅错误日志

**使用方法：**
```bash
# 运行日志测试（会自动启动/停止服务器）
./tests/log_test.sh

# 查看生成的日志文件
cat log_test_info.log
cat log_test_debug.log
cat log_test_warn.log
```

### 3. `performance_test.sh` - 性能压力测试
测试中间件在高并发情况下的表现：
- 并发登录测试
- 并发API请求测试
- 混合请求压力测试

**使用方法：**
```bash
# 1. 先启动服务器
cargo run

# 2. 安装依赖（macOS）
brew install bc

# 3. 运行性能测试
./tests/performance_test.sh
```

### 4. `test_logging.sh` - 日志配置测试
简单的日志级别配置测试。

**使用方法：**
```bash
./test_logging.sh
```

## 环境配置

### 数据库设置
确保PostgreSQL正在运行，并且数据库已初始化：
```bash
# 创建数据库
createdb qiqimanyou_dev

# 运行初始化脚本
psql -d qiqimanyou_dev -f sql/dev_initial/00-recreate-db.sql
psql -d qiqimanyou_dev -f sql/dev_initial/01-create-schema.sql
psql -d qiqimanyou_dev -f sql/dev_initial/02-dev-seed.sql
```

### 环境变量
创建 `.env` 文件：
```bash
DATABASE_URL=postgresql://app_user:dev_only_pwd@localhost/app_db
HOST=127.0.0.1
PORT=8080
SERVICE_WEB_FOLDER=./web-folder
DEV_MODE=true
```

## 日志配置

### 环境变量控制
使用 `RUST_LOG` 环境变量控制日志级别：
```bash
# 详细日志
RUST_LOG=debug cargo run

# 一般日志
RUST_LOG=info cargo run

# 仅错误日志
RUST_LOG=error cargo run

# 模块特定日志
RUST_LOG=qiqimanyou_server=debug cargo run
```

### 日志特性
- ✅ 彩色输出（开发环境）
- ✅ 结构化日志记录
- ✅ 请求追踪ID
- ✅ 响应时间记录
- ✅ 错误堆栈跟踪
- ✅ 性能监控指标

## 中间件功能验证

### 1. 日志中间件
- 记录每个HTTP请求的详细信息
- 包含请求ID、方法、路径、IP、User-Agent
- 记录响应状态码和处理时间
- 支持不同日志级别的过滤

### 2. 错误处理中间件
- 统一错误响应格式
- 错误日志记录
- 客户端友好的错误消息
- 开发/生产环境的不同处理

### 3. CORS中间件
- 处理跨域请求
- 支持预检请求
- 可配置的域名白名单
- 开发/生产环境的不同策略

### 4. 认证中间件
- JWT token验证
- 用户身份提取
- 受保护路由的访问控制

## 测试结果分析

### 成功指标
- API请求返回正确的HTTP状态码
- 认证流程正常工作
- 日志正确记录请求信息
- 错误处理返回适当的错误信息
- CORS头部正确设置

### 性能指标
- 并发请求处理能力
- 平均响应时间
- 错误率统计
- 系统资源使用情况

## 故障排除

### 常见问题
1. **服务器启动失败**
   - 检查数据库连接
   - 确认端口未被占用
   - 查看环境变量配置

2. **认证失败**
   - 检查数据库中的用户数据
   - 确认密码哈希算法
   - 查看JWT配置

3. **数据库连接问题**
   - 确认PostgreSQL服务运行
   - 检查数据库URL配置
   - 运行数据库初始化脚本

### 调试命令
```bash
# 检查服务器状态
curl -I http://127.0.0.1:8080/static/

# 测试API端点
curl -X POST -H "Content-Type: application/json" \
  -d '{"username": "demo1", "password": "welcome"}' \
  http://127.0.0.1:8080/api/v1/auth/login

# 查看详细日志
RUST_LOG=debug cargo run 2>&1 | tee debug.log
```

## 扩展测试

### 添加新的测试
1. 创建新的测试脚本
2. 添加到此README中
3. 确保脚本有可执行权限
4. 遵循现有的输出格式

### 自定义配置
可以通过修改脚本顶部的配置变量来调整测试参数：
- `BASE_URL` - 服务器地址
- `CONCURRENT_REQUESTS` - 并发请求数
- `TOTAL_REQUESTS` - 总请求数
- `TEST_DURATION` - 测试持续时间
