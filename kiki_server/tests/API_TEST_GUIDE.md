# 🧪 API测试验证指南

根据你的开发需求和文档要求，这里是完整的API功能测试指南。

## 📋 测试前准备

### 1. 环境变量设置
```bash
# 设置数据库连接
export DATABASE_URL="postgresql://username:password@localhost/qiqimanyou_dev"

# 设置环境
export ENVIRONMENT=development

# 设置日志级别
export RUST_LOG=info
```

### 2. 数据库准备
```bash
# 创建数据库 (如果不存在)
createdb qiqimanyou_dev

# 初始化表结构
psql $DATABASE_URL -f doc/sql/00-create-all-tables.sql

# 插入测试数据 (可选)
psql $DATABASE_URL -f tests/test_data.sql
```

## 🚀 快速测试步骤

### 方法一：老师作业API专项测试
```bash
# 1. 启动服务器 (新终端)
cargo run

# 2. 运行老师作业API测试 (另一个新终端)
chmod +x tests/teacher_assignment_api_test.sh
./tests/teacher_assignment_api_test.sh

# 3. 快速验证 (可选)
chmod +x tests/quick_teacher_api_check.sh
./tests/quick_teacher_api_check.sh
```

### 方法二：完整功能测试
```bash
# 1. 设置测试环境
chmod +x tests/test_setup.sh
./tests/test_setup.sh

# 2. 启动服务器 (新终端)
cargo run

# 3. 运行完整API测试 (另一个新终端)
chmod +x tests/new_api_test.sh
./tests/new_api_test.sh
```

### 方法二：手动步骤测试
```bash
# 1. 编译项目
cargo build

# 2. 启动服务器
cargo run

# 3. 在另一个终端运行测试
./tests/new_api_test.sh
```

## 📝 API测试覆盖范围

### 老师功能测试
- ✅ 创建作业 `POST /api/teacher/assignments`
- ✅ 获取作业列表 `GET /api/teacher/assignments`
- ✅ 获取作业详情 `GET /api/teacher/assignments/:id`
- ✅ 更新作业 `PUT /api/teacher/assignments/:id`
- ✅ 删除作业 `DELETE /api/teacher/assignments/:id`

### 学生功能测试
- ✅ 查看老师列表 `GET /api/student/teachers`
- ✅ 设置默认老师 `POST /api/student/default-teacher`
- ✅ 获取默认老师 `GET /api/student/default-teacher`
- ✅ 查看老师作业 `GET /api/student/teacher/:teacher_id/assignments`
- ✅ 更新会话ID `PUT /api/student/conversation`

### 基础功能测试
- ✅ 用户注册 `POST /api/auth/register`
- ✅ 用户登录 `POST /api/auth/login`
- ✅ JWT令牌验证
- ✅ ApiResponse格式验证

## 🔍 测试结果验证

### 成功指标
- 所有API返回正确的HTTP状态码
- 响应格式符合ApiResponse结构
- 数据库正确存储和检索数据
- JWT认证正常工作
- 业务逻辑符合需求规范

### 常见问题排查
1. **数据库连接失败**
   - 检查DATABASE_URL是否正确
   - 确认PostgreSQL服务运行中
   - 验证数据库用户权限

2. **编译错误**
   - 运行 `cargo check` 检查语法
   - 确认所有依赖正确安装

3. **API测试失败**
   - 检查服务器是否启动 (http://127.0.0.1:8081/health)
   - 查看服务器日志输出
   - 验证测试数据是否正确插入

## 📊 测试报告

测试脚本会输出详细的执行过程：
- ✅ 绿色：测试通过
- ❌ 红色：测试失败
- ℹ️ 蓝色：信息提示
- 📝 黄色：测试进行中

## 🛠️ 手动API测试

如果需要手动测试单个API，可以使用curl命令：

```bash
# 登录获取token
TOKEN=$(curl -s -X POST "http://127.0.0.1:8081/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"identifier":"teacher@test.com","password":"teacher123"}' \
  | jq -r '.data.token')

# 创建作业
curl -X POST "http://127.0.0.1:8081/api/teacher/assignments" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "teacher_id": "teacher_test_uid",
    "title": "手动测试作业",
    "description": "这是手动创建的测试作业",
    "knowledge_points": "测试知识点"
  }' | jq .
```

## 📚 测试验证清单

按照你的文档要求，请确认以下各项：

- [ ] 登录注册逻辑保持不变 ✅
- [ ] 使用ApiResponse统一返回格式 ✅
- [ ] 按照现有代码结构开发 ✅
- [ ] 每个业务模块结构分明 ✅
- [ ] 严格按照数据库结构实现 ✅
- [ ] 所有API功能正常工作
- [ ] 错误处理和日志记录正确
- [ ] JWT认证机制正常

测试完成后，你将验证所有新开发的API功能是否符合需求规范！
