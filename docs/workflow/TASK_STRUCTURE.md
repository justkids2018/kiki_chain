# 📋 Kiki 漫游 - 任务结构定义

> **三端任务分类与管理规范**

**最后更新**: 2026-02-11

---

## 📊 项目概览

### 三端架构

```
kiki_chain/
├── kiki_web/              # 📱 Flutter App (移动端/Web端)
├── kiki_server/           # 🔧 Rust 后端服务
├── kiki_web_manager/      # 💼 管理后台
└── docs/                  # 📚 共享文档
    └── tasks/             # 任务管理中心
        ├── app/           # App 任务
        ├── backend/       # 后端任务
        └── admin/         # 管理后台任务
```

---

## 🎯 任务分类体系

### 按端分类

| 端 | 目录 | 负责范围 | 技术栈 |
|---|------|---------|--------|
| **📱 App** | `tasks/app/` | 用户端功能、UI/UX | Flutter, GetX, Dio |
| **🔧 Backend** | `tasks/backend/` | API、数据库、业务逻辑 | Rust, Actix-web, PostgreSQL |
| **💼 Admin** | `tasks/admin/` | 管理功能、数据管理 | Flutter Web, GetX |

### 按类型分类

每个端下都有以下子分类：

```
tasks/{端}/
├── features/          # 新功能开发
├── bugs/              # Bug 修复
├── optimizations/     # 性能优化
├── refactoring/       # 代码重构
└── documentation/     # 文档更新
```

---

## 📱 App 任务定义

### 任务类型

#### 1. 功能开发 (Features)

**路径**: `tasks/app/features/`

**常见任务**:

- **场景功能**
  - 场景列表展示
  - 场景详情页
  - 互动学习功能
  - 场景搜索与筛选

- **用户系统**
  - 登录注册
  - 用户信息管理
  - 学习进度记录
  - 成就系统

- **学习功能**
  - TTS 语音播放
  - 互动点击学习
  - 单词收藏
  - 学习统计

- **UI/UX**
  - 主题切换
  - 国际化 (i18n)
  - 动画效果
  - 响应式布局

**任务模板**:

```markdown
### APP-FEAT-XXX: 功能标题

**优先级**: 🔴 P0 / 🟡 P1 / 🟢 P2
**预计时间**: X 小时/天
**依赖**: 无 / BACKEND-XXX

**功能描述**:
[详细描述功能需求]

**技术方案**:
- 使用的组件/库
- 状态管理方案
- 数据流设计

**子任务**:
- [ ] UI 设计实现
- [ ] 状态管理
- [ ] API 集成
- [ ] 测试验证

**验收标准**:
1. UI 符合设计规范
2. 功能正常运行
3. 无性能问题
```

#### 2. Bug 修复 (Bugs)

**路径**: `tasks/app/bugs/`

**常见问题**:
- GetX 状态管理错误
- 路由导航问题
- UI 渲染异常
- 网络请求失败
- 内存泄漏

**任务模板**:

```markdown
### APP-BUG-XXX: Bug 标题

**优先级**: 🔴 P0 (阻塞) / 🟡 P1 (严重) / 🟢 P2 (一般)
**发现时间**: YYYY-MM-DD
**影响范围**: 功能模块名称

**Bug 描述**:
[详细描述 Bug 现象]

**复现步骤**:
1. 步骤1
2. 步骤2
3. 步骤3

**预期行为**:
[应该如何表现]

**实际行为**:
[实际如何表现]

**错误信息**:
```
[错误日志]
```

**修复方案**:
[如何修复]

**验证步骤**:
1. 验证步骤1
2. 验证步骤2
```

#### 3. 性能优化 (Optimizations)

**路径**: `tasks/app/optimizations/`

**优化方向**:
- 启动速度优化
- 页面渲染优化
- 内存使用优化
- 网络请求优化
- 包体积优化

**任务模板**:

```markdown
### APP-OPT-XXX: 优化标题

**优先级**: 🟡 P1 / 🟢 P2
**当前性能**: [具体指标]
**目标性能**: [目标指标]

**问题分析**:
[性能瓶颈分析]

**优化方案**:
1. 方案1
2. 方案2

**预期收益**:
- 性能提升 X%
- 内存减少 X MB
- 包体积减少 X KB

**验证方法**:
[如何验证优化效果]
```

---

## 🔧 Backend 任务定义

### 任务类型

#### 1. API 开发 (Features)

**路径**: `tasks/backend/features/`

**常见任务**:

- **认证系统**
  - 用户注册/登录
  - Token 管理
  - 权限验证
  - 密码找回

- **场景管理**
  - 场景 CRUD
  - 分类管理
  - 场景搜索
  - 数据导入

- **用户系统**
  - 用户信息管理
  - 学习记录
  - 进度统计
  - 成就系统

- **数据管理**
  - 数据库设计
  - 数据迁移
  - 数据备份
  - 数据清理

**任务模板**:

```markdown
### BACKEND-FEAT-XXX: 功能标题

**优先级**: 🔴 P0 / 🟡 P1 / 🟢 P2
**预计时间**: X 小时/天
**依赖**: 无 / 其他任务

**API 设计**:
```
POST /api/v1/endpoint
Request: {...}
Response: {...}
```

**数据库设计**:
- 表结构
- 索引设计
- 关联关系

**技术方案**:
- 使用的 crate
- 架构层次 (Domain/Application/Infrastructure)
- 错误处理

**子任务**:
- [ ] 数据库 migration
- [ ] Domain 层实现
- [ ] Repository 实现
- [ ] API Handler 实现
- [ ] 单元测试
- [ ] 集成测试

**验收标准**:
1. API 符合规范
2. 测试覆盖率 > 80%
3. 性能满足要求
```

#### 2. Bug 修复 (Bugs)

**路径**: `tasks/backend/bugs/`

**常见问题**:
- SQL 查询错误
- 并发问题
- 内存泄漏
- API 响应错误
- 数据一致性问题

**任务模板**:

```markdown
### BACKEND-BUG-XXX: Bug 标题

**优先级**: 🔴 P0 / 🟡 P1 / 🟢 P2
**发现时间**: YYYY-MM-DD
**影响范围**: API 端点 / 功能模块

**Bug 描述**:
[详细描述]

**错误日志**:
```
[日志内容]
```

**根因分析**:
[问题根本原因]

**修复方案**:
[如何修复]

**测试计划**:
1. 单元测试
2. 集成测试
3. 性能测试
```

#### 3. 性能优化 (Optimizations)

**路径**: `tasks/backend/optimizations/`

**优化方向**:
- SQL 查询优化
- 缓存策略
- 并发处理
- 连接池优化
- 内存使用优化

---

## 💼 Admin 任务定义

### 任务类型

#### 1. 管理功能 (Features)

**路径**: `tasks/admin/features/`

**常见任务**:

- **内容管理**
  - 场景管理 (CRUD)
  - 分类管理
  - 批量导入
  - 数据审核

- **用户管理**
  - 用户列表
  - 用户详情
  - 权限管理
  - 数据统计

- **系统管理**
  - 系统配置
  - 日志查看
  - 数据备份
  - 监控面板

**任务模板**:

```markdown
### ADMIN-FEAT-XXX: 功能标题

**优先级**: 🔴 P0 / 🟡 P1 / 🟢 P2
**预计时间**: X 小时/天
**依赖**: BACKEND-XXX

**功能描述**:
[详细描述]

**页面设计**:
- 列表页
- 详情页
- 编辑页

**技术方案**:
- 使用的组件
- 数据表格方案
- 表单验证

**子任务**:
- [ ] 页面布局
- [ ] 数据表格
- [ ] 表单实现
- [ ] API 集成
- [ ] 权限控制

**验收标准**:
1. 功能完整
2. 操作流畅
3. 权限正确
```

---

## 🔄 任务流转规则

### 任务状态

```
📝 待办 (TODO)
    ↓
🚀 进行中 (IN_PROGRESS)
    ↓
👀 代码审查 (REVIEW)
    ↓
🧪 测试中 (TESTING)
    ↓
✅ 已完成 (DONE)
    ↓
📦 已归档 (ARCHIVED)
```

### 跨端任务协调

**场景**: 新增一个完整功能

**流程**:

1. **产品经理提需求**
   ```
   需求: 添加学习进度功能
   ```

2. **AI 分解任务**
   ```
   BACKEND-FEAT-001: 实现学习进度 API
   APP-FEAT-001: 实现学习进度页面
   ADMIN-FEAT-001: 实现学习进度管理
   ```

3. **确定依赖关系**
   ```
   BACKEND-FEAT-001 (先做)
       ↓
   APP-FEAT-001 (依赖后端)
       ↓
   ADMIN-FEAT-001 (依赖后端)
   ```

4. **按顺序实现**
   ```
   Day 1: 完成 BACKEND-FEAT-001
   Day 2: 完成 APP-FEAT-001
   Day 3: 完成 ADMIN-FEAT-001
   ```

---

## 📊 任务优先级定义

| 级别 | 标识 | 说明 | 响应时间 | 适用场景 |
|------|------|------|----------|----------|
| P0 | 🔴 | 紧急且重要 | 立即处理 | 阻塞功能、严重 Bug |
| P1 | 🟡 | 重要不紧急 | 1-2天内 | 核心功能、用户体验 |
| P2 | 🟢 | 一般优化 | 1周内 | 优化改进、文档 |
| P3 | ⚪ | 可选功能 | 待定 | 未来规划 |

---

## 📝 任务命名规范

### 命名格式

```
{端}-{类型}-{编号}: {简短标题}
```

### 示例

```
APP-FEAT-001: 实现场景列表页
BACKEND-BUG-005: 修复登录接口 500 错误
ADMIN-OPT-003: 优化数据表格加载速度
```

### 编号规则

- **APP**: 001-999
- **BACKEND**: 001-999
- **ADMIN**: 001-999

每个端独立编号，按创建顺序递增。

---

## 🗂️ 任务文件组织

### 目录结构

```
docs/tasks/
├── TASK_BOARD.md              # 总任务看板
├── app/                       # App 任务
│   ├── features/
│   │   ├── APP-FEAT-001.md
│   │   └── APP-FEAT-002.md
│   ├── bugs/
│   │   └── APP-BUG-001.md
│   ├── optimizations/
│   └── backlog.md             # App 待办池
│
├── backend/                   # 后端任务
│   ├── features/
│   │   ├── BACKEND-FEAT-001.md
│   │   └── BACKEND-FEAT-002.md
│   ├── bugs/
│   ├── optimizations/
│   └── backlog.md             # 后端待办池
│
└── admin/                     # 管理后台任务
    ├── features/
    ├── bugs/
    ├── optimizations/
    └── backlog.md             # 管理后台待办池
```

---

## 🎯 任务看板格式

**TASK_BOARD.md** - 总看板

```markdown
# Kiki 漫游 - 任务看板

**更新时间**: 2026-02-11

---

## 📊 任务统计

| 端 | 待办 | 进行中 | 已完成 | 总计 |
|----|------|--------|--------|------|
| 📱 App | 5 | 2 | 10 | 17 |
| 🔧 Backend | 3 | 1 | 8 | 12 |
| 💼 Admin | 2 | 1 | 5 | 8 |
| **总计** | **10** | **4** | **23** | **37** |

---

## 🔥 进行中任务

### 📱 App

- [APP-FEAT-003](./app/features/APP-FEAT-003.md) - 实现学习进度页面 (P0, 60%)
- [APP-BUG-001](./app/bugs/APP-BUG-001.md) - 修复场景详情页错误 (P0, 80%)

### 🔧 Backend

- [BACKEND-FEAT-005](./backend/features/BACKEND-FEAT-005.md) - 实现学习进度 API (P0, 70%)

### 💼 Admin

- [ADMIN-FEAT-002](./admin/features/ADMIN-FEAT-002.md) - 场景管理页面 (P1, 50%)

---

## 📝 高优先级待办

### 📱 App (P0/P1)

1. [APP-FEAT-004](./app/features/APP-FEAT-004.md) - TTS 功能完善 (P0)
2. [APP-FEAT-005](./app/features/APP-FEAT-005.md) - 场景搜索功能 (P1)

### 🔧 Backend (P0/P1)

1. [BACKEND-FEAT-006](./backend/features/BACKEND-FEAT-006.md) - 场景搜索 API (P0)
2. [BACKEND-OPT-001](./backend/optimizations/BACKEND-OPT-001.md) - SQL 查询优化 (P1)

### 💼 Admin (P0/P1)

1. [ADMIN-FEAT-003](./admin/features/ADMIN-FEAT-003.md) - 用户管理功能 (P1)
```

---

## 🔧 任务管理工具

### 创建任务脚本

```bash
#!/bin/bash
# scripts/create_task.sh

COMPONENT=$1  # app/backend/admin
TYPE=$2       # features/bugs/optimizations
TITLE=$3
PRIORITY=$4

# 生成任务 ID
LAST_ID=$(ls docs/tasks/${COMPONENT}/${TYPE}/ | grep -o '[0-9]\+' | sort -n | tail -1)
NEW_ID=$(printf "%03d" $((LAST_ID + 1)))

TASK_ID="${COMPONENT^^}-${TYPE^^:0:4}-${NEW_ID}"
FILE_PATH="docs/tasks/${COMPONENT}/${TYPE}/${TASK_ID}.md"

# 创建任务文件
cat > ${FILE_PATH} <<EOF
# ${TASK_ID}: ${TITLE}

**优先级**: ${PRIORITY}
**状态**: 待办
**创建时间**: $(date +"%Y-%m-%d %H:%M")

## 描述

[填写任务描述]

## 子任务

- [ ] 子任务1

## 验收标准

1. 标准1

EOF

echo "✅ 任务已创建: ${TASK_ID}"
echo "📄 文件路径: ${FILE_PATH}"
```

**使用示例**:

```bash
# 创建 App 功能任务
./scripts/create_task.sh app features "实现场景列表" "P0"

# 创建后端 Bug 任务
./scripts/create_task.sh backend bugs "修复登录错误" "P0"

# 创建管理后台优化任务
./scripts/create_task.sh admin optimizations "优化表格性能" "P1"
```

---

## 📋 快速参考

### 常用命令

```bash
# 查看所有任务
find docs/tasks -name "*.md" -type f

# 查看 App 任务
ls docs/tasks/app/features/

# 查看进行中的任务
grep -r "状态.*进行中" docs/tasks/

# 统计任务数量
find docs/tasks -name "*.md" -type f | wc -l
```

### 任务模板位置

- App 任务: `docs/tasks/app/`
- Backend 任务: `docs/tasks/backend/`
- Admin 任务: `docs/tasks/admin/`

---

## 🎓 最佳实践

### 1. 任务粒度

- ✅ 一个任务 = 1-2 天工作量
- ❌ 避免过大任务 (> 1 周)
- ❌ 避免过小任务 (< 2 小时)

### 2. 依赖管理

- 明确标注任务依赖
- 优先完成被依赖的任务
- 避免循环依赖

### 3. 文档同步

- 任务完成后更新文档
- API 变更同步到 API 文档
- 架构变更同步到架构文档

### 4. 代码审查

- 每个任务完成后自我审查
- 检查代码质量
- 确保测试覆盖

---

**文档版本**: v1.0
**创建时间**: 2026-02-11
**维护者**: AI (Claude) + 产品经理
