# AI 驱动开发工作流 - Kiki 漫游项目

> **角色定义**
> 🤖 **AI (Claude)**: 主要工程师 - 负责代码实现、架构设计、技术决策
> 👨‍💼 **你**: 产品经理 - 负责需求定义、功能规划、验收测试

---

## 📋 目录

1. [工作流概览](#工作流概览)
2. [任务管理系统](#任务管理系统)
3. [三端同步开发策略](#三端同步开发策略)
4. [开发流程](#开发流程)
5. [文档管理](#文档管理)
6. [自动化工具](#自动化工具)

---

## 工作流概览

### 核心理念

```
产品经理 (你)          主要工程师 (AI)
     ↓                      ↓
  需求文档  ────────→   任务分解
     ↓                      ↓
  功能验收  ←────────   代码实现
     ↓                      ↓
  反馈优化  ────────→   迭代改进
```

### 项目结构

```
kiki_chain/
├── kiki_web/              # 📱 Flutter App (当前目录)
├── kiki_server/           # 🔧 Rust 后端
├── kiki_admin/            # 💼 管理后台
└── docs/                  # 📚 共享文档
    ├── api/               # API 接口文档
    ├── product/           # 产品需求文档
    └── tasks/             # 任务管理
```

---

## 任务管理系统

### 任务文件结构

```
doc/task/
├── TASK_BOARD.md          # 📊 任务看板 (主文件)
├── backlog/               # 待办任务池
│   ├── features/          # 功能需求
│   ├── bugs/              # Bug 修复
│   └── optimizations/     # 优化任务
├── in_progress/           # 进行中
├── completed/             # 已完成
└── archived/              # 已归档
```

### 任务看板格式

**TASK_BOARD.md** - 主看板文件

```markdown
# Kiki 漫游 - 任务看板

**更新时间**: 2026-02-10 18:00
**当前迭代**: Sprint 1 (第1-2周)

---

## 🎯 当前迭代目标

- [ ] 完成日常生活场景 (6个)
- [ ] 实现场景互动学习功能
- [ ] 优化 UI/UX 体验

---

## 📊 任务统计

| 状态 | 数量 | 占比 |
|------|------|------|
| 待办 | 15 | 50% |
| 进行中 | 3 | 10% |
| 已完成 | 12 | 40% |
| **总计** | **30** | **100%** |

---

## 🔥 进行中 (In Progress)

### TASK-001: 架构优化 - 合并 SceneDetailPage
**优先级**: 🔴 P0
**负责人**: AI
**预计时间**: 4小时
**开始时间**: 2026-02-10 17:00

**描述**:
删除 SceneDetailPage，直接使用 InteractiveImagePage

**子任务**:
- [x] 分析现有架构
- [x] 创建优化方案文档
- [ ] 删除 SceneDetailPage
- [ ] 修改导航逻辑
- [ ] 更新 Mock 数据
- [ ] 测试验证

**相关文档**:
- `doc/ARCHITECTURE_OPTIMIZATION.md`
- `doc/COMPLETE_FLOW_ANALYSIS.md`

**进度**: 40% (2/6)

---

### TASK-002: Mock 数据完善
**优先级**: 🟡 P1
**负责人**: AI
**预计时间**: 2小时

**描述**:
为所有 Scene 和 SceneItem 添加 dataFile 字段

**子任务**:
- [ ] 更新 Scene 实体
- [ ] 更新 SceneItem 实体
- [ ] 创建互动数据 JSON 文件
- [ ] 更新 Mock 数据

---

## 📝 待办 (Backlog)

### 高优先级 (P0)

#### TASK-003: 日常生活场景开发
**预计时间**: 2周
**场景列表**:
1. [ ] 早餐时间 (Breakfast Time)
2. [ ] 准备上学 (Getting Ready for School)
3. [ ] 帮妈妈做饭 (Helping Mom Cook)
4. [ ] 看电视时间 (TV Time)
5. [ ] 睡前准备 (Bedtime Routine)
6. [ ] 周末打扫房间 (Weekend Room Cleaning)

#### TASK-004: TTS 功能完善
**预计时间**: 1天
**内容**:
- [ ] 支持中文发音
- [ ] 支持英文发音
- [ ] 支持拼音发音
- [ ] 音频缓存优化

### 中优先级 (P1)

#### TASK-005: 用户系统优化
**预计时间**: 3天
**内容**:
- [ ] 登录流程优化
- [ ] 用户信息管理
- [ ] 学习进度记录

---

## ✅ 已完成 (Completed)

### TASK-000: 项目初始化
**完成时间**: 2026-02-04
**内容**:
- [x] Flutter 项目搭建
- [x] GetX 状态管理集成
- [x] 基础路由配置
- [x] 登录注册功能

---

## 🗄️ 已归档 (Archived)

查看 `doc/task/archived/` 目录

---

## 📌 任务模板

### 新建任务

```markdown
### TASK-XXX: 任务标题
**优先级**: 🔴 P0 / 🟡 P1 / 🟢 P2
**负责人**: AI / 产品经理
**预计时间**: X小时/天
**开始时间**: YYYY-MM-DD HH:MM
**完成时间**: YYYY-MM-DD HH:MM (完成后填写)

**描述**:
任务的详细描述

**子任务**:
- [ ] 子任务1
- [ ] 子任务2
- [ ] 子任务3

**相关文档**:
- `doc/xxx.md`

**依赖任务**:
- TASK-XXX

**验收标准**:
1. 标准1
2. 标准2

**进度**: 0% (0/3)
```

---

## 🔄 任务状态流转

```
待办 (Backlog)
    ↓
进行中 (In Progress)
    ↓
代码审查 (Code Review)
    ↓
测试验证 (Testing)
    ↓
已完成 (Completed)
    ↓
已归档 (Archived)
```

---

## 📊 任务优先级定义

| 级别 | 标识 | 说明 | 响应时间 |
|------|------|------|----------|
| P0 | 🔴 | 紧急且重要，阻塞其他任务 | 立即处理 |
| P1 | 🟡 | 重要但不紧急，影响用户体验 | 1-2天内 |
| P2 | 🟢 | 优化改进，不影响核心功能 | 1周内 |
| P3 | ⚪ | 可选功能，未来考虑 | 待定 |

---

**文档版本**: v1.0
**创建时间**: 2026-02-10
**维护者**: AI + 产品经理
```

---

## 三端同步开发策略

### 方案 1: 单窗口 + 智能切换 (推荐)

**工作方式**:
```
一个 Claude Code 窗口
  ↓
通过命令切换项目
  ↓
cd ../kiki_server    # 切换到后端
cd ../kiki_admin     # 切换到管理后台
cd kiki_web          # 切换回 App
```

**优势**:
- ✅ 上下文连贯，AI 记住所有项目信息
- ✅ 统一的任务管理
- ✅ 减少窗口切换

**劣势**:
- ❌ 需要频繁切换目录

---

### 方案 2: 三窗口并行 (适合独立开发)

**工作方式**:
```
窗口1: kiki_web (App)
窗口2: kiki_server (后端)
窗口3: kiki_admin (管理后台)
```

**优势**:
- ✅ 可以同时查看三端代码
- ✅ 独立开发互不干扰

**劣势**:
- ❌ 上下文分散
- ❌ 需要在三个窗口间同步信息

---

### 方案 3: 主从模式 (最佳实践) ⭐

**工作方式**:
```
主窗口 (kiki_web)
  ↓
负责任务管理、文档维护
  ↓
需要时切换到其他项目
  ↓
完成后切回主窗口更新任务
```

**开发流程**:
1. **在主窗口 (kiki_web) 查看任务**
   ```bash
   # 查看当前任务
   cat doc/task/TASK_BOARD.md
   ```

2. **如果需要修改后端**
   ```bash
   cd ../kiki_server
   # 进行后端开发
   # 完成后
   cd ../kiki_web
   # 更新任务状态
   ```

3. **如果需要修改管理后台**
   ```bash
   cd ../kiki_admin
   # 进行管理后台开发
   # 完成后
   cd ../kiki_web
   # 更新任务状态
   ```

**优势**:
- ✅ 统一的任务管理中心
- ✅ 上下文连贯
- ✅ 灵活切换

---

### API 同步策略

**共享 API 文档**:
```
kiki_chain/docs/api/
├── api_spec.md           # API 规范总览
├── endpoints/            # 接口详细文档
│   ├── auth.md          # 认证接口
│   ├── scenes.md        # 场景接口
│   └── users.md         # 用户接口
└── changelog.md          # API 变更日志
```

**同步流程**:
1. **产品经理定义 API 需求**
   ```markdown
   # 新增场景列表接口
   GET /api/v1/scenes?categoryId={id}
   ```

2. **AI 更新 API 文档**
   ```bash
   # 在 kiki_chain/docs/api/ 更新文档
   ```

3. **AI 实现后端接口**
   ```bash
   cd ../kiki_server
   # 实现接口
   ```

4. **AI 实现前端调用**
   ```bash
   cd kiki_web
   # 实现 Repository
   ```

5. **AI 更新管理后台**
   ```bash
   cd ../kiki_admin
   # 实现管理功能
   ```

---

## 开发流程

### 标准开发流程

```
1. 产品经理提出需求
   ↓
2. AI 分析需求，创建任务
   ↓
3. AI 设计技术方案
   ↓
4. 产品经理审核方案
   ↓
5. AI 实现代码
   ↓
6. AI 自我审查 (Code Review)
   ↓
7. 产品经理功能验收
   ↓
8. AI 根据反馈优化
   ↓
9. 任务完成，更新文档
```

### 每日工作流

**产品经理 (你)**:
```
09:00 - 查看任务看板，确定今日目标
10:00 - 提出新需求或反馈
11:00 - 审核 AI 的技术方案
14:00 - 验收完成的功能
16:00 - 提供优化建议
17:00 - 更新产品文档
```

**主要工程师 (AI)**:
```
收到需求 → 分析需求 → 创建任务
         ↓
      设计方案 → 等待审核 → 实现代码
         ↓
      自我审查 → 提交验收 → 根据反馈优化
         ↓
      更新文档 → 标记完成
```

---

## 文档管理

### 文档分类

```
doc/
├── product/              # 产品文档 (产品经理维护)
│   ├── requirements/     # 需求文档
│   ├── features/         # 功能说明
│   └── roadmap.md        # 产品路线图
│
├── technical/            # 技术文档 (AI 维护)
│   ├── architecture/     # 架构设计
│   ├── api/              # API 文档
│   └── implementation/   # 实现细节
│
├── task/                 # 任务管理 (共同维护)
│   ├── TASK_BOARD.md     # 任务看板
│   ├── backlog/          # 待办任务
│   ├── in_progress/      # 进行中
│   └── completed/        # 已完成
│
└── workflow/             # 工作流文档 (本文档)
    ├── AI_DRIVEN_DEVELOPMENT.md
    └── COLLABORATION_GUIDE.md
```

### 文档更新规则

| 文档类型 | 维护者 | 更新时机 |
|---------|--------|----------|
| 产品需求 | 产品经理 | 需求变更时 |
| 技术方案 | AI | 开发前 |
| API 文档 | AI | 接口变更时 |
| 任务看板 | 共同 | 任务状态变更时 |
| 代码注释 | AI | 代码提交时 |

---

## 自动化工具

### 任务管理脚本

**创建新任务**:
```bash
# scripts/task_create.sh
#!/bin/bash
TASK_ID=$1
TITLE=$2
PRIORITY=$3

cat > doc/task/backlog/TASK-${TASK_ID}.md <<EOF
# TASK-${TASK_ID}: ${TITLE}

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

echo "✅ 任务 TASK-${TASK_ID} 已创建"
```

**使用**:
```bash
./scripts/task_create.sh 006 "实现用户登录" "P0"
```

---

### 任务状态更新

**移动任务到进行中**:
```bash
# scripts/task_start.sh
#!/bin/bash
TASK_ID=$1
mv doc/task/backlog/TASK-${TASK_ID}.md doc/task/in_progress/
echo "🚀 任务 TASK-${TASK_ID} 已开始"
```

**标记任务完成**:
```bash
# scripts/task_complete.sh
#!/bin/bash
TASK_ID=$1
COMPLETE_TIME=$(date +"%Y-%m-%d %H:%M")

# 添加完成时间
echo "**完成时间**: ${COMPLETE_TIME}" >> doc/task/in_progress/TASK-${TASK_ID}.md

# 移动到已完成
mv doc/task/in_progress/TASK-${TASK_ID}.md doc/task/completed/

echo "✅ 任务 TASK-${TASK_ID} 已完成"
```

---

### 任务统计

```bash
# scripts/task_stats.sh
#!/bin/bash

BACKLOG=$(ls doc/task/backlog/ | wc -l)
IN_PROGRESS=$(ls doc/task/in_progress/ | wc -l)
COMPLETED=$(ls doc/task/completed/ | wc -l)
TOTAL=$((BACKLOG + IN_PROGRESS + COMPLETED))

echo "📊 任务统计"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "待办: ${BACKLOG}"
echo "进行中: ${IN_PROGRESS}"
echo "已完成: ${COMPLETED}"
echo "总计: ${TOTAL}"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "完成率: $((COMPLETED * 100 / TOTAL))%"
```

---

## 协作示例

### 示例 1: 新功能开发

**产品经理**:
```
我需要添加一个"学习进度"功能，用户可以看到自己学习了多少个场景。
```

**AI**:
```
收到需求！让我分析一下：

1. 创建任务 TASK-007
2. 需要的功能：
   - 记录用户学习过的场景
   - 显示学习进度百分比
   - 展示已学习的场景列表

3. 技术方案：
   - 后端：添加学习记录表
   - API：GET /api/v1/users/{id}/progress
   - 前端：创建进度页面

是否开始实现？
```

**产品经理**:
```
方案看起来不错，开始实现吧！
```

**AI**:
```
好的！开始实现...

[4小时后]

✅ 功能已完成！
- 后端接口已实现
- 前端页面已完成
- 测试通过

请验收功能。
```

---

### 示例 2: Bug 修复

**产品经理**:
```
发现一个 Bug：场景详情页打开时报错 GetX 错误。
```

**AI**:
```
收到 Bug 报告！

1. 创建任务 TASK-BUG-001
2. 优先级：P0 (阻塞功能)
3. 开始调查...

[分析后]

问题原因：SceneDetailPage 中混用了 GetBuilder 和响应式变量

修复方案：将响应式变量访问包装在 Obx() 中

是否立即修复？
```

**产品经理**:
```
立即修复！
```

**AI**:
```
✅ Bug 已修复！
- 修改了 SceneDetailPage
- 测试通过
- 应用已重启

请验证功能是否正常。
```

---

## 最佳实践

### 产品经理 (你)

1. **清晰的需求描述**
   - ✅ "我需要一个学习进度页面，显示用户学习了多少场景"
   - ❌ "做个进度功能"

2. **及时的反馈**
   - 功能完成后尽快验收
   - 发现问题立即反馈

3. **优先级管理**
   - 明确哪些是 P0 必须做的
   - 哪些是 P1 可以延后的

### 主要工程师 (AI)

1. **主动沟通**
   - 实现前确认技术方案
   - 遇到问题及时反馈

2. **文档先行**
   - 代码实现前先写文档
   - 保持文档与代码同步

3. **自我审查**
   - 代码完成后自我 Review
   - 确保质量后再提交验收

---

## 工具推荐

### 任务管理
- ✅ Markdown 文件 (当前方案)
- 📊 GitHub Projects (可选)
- 📋 Notion (可选)

### 文档协作
- ✅ Markdown + Git (当前方案)
- 📝 Notion (可选)
- 📄 Google Docs (可选)

### 代码同步
- ✅ Git (必须)
- 🔄 GitHub Actions (自动化)

---

## 总结

### 推荐工作方式

1. **使用单窗口主从模式**
   - 主窗口在 kiki_web
   - 需要时切换到其他项目

2. **任务看板作为中心**
   - 所有任务在 TASK_BOARD.md 管理
   - 每天更新任务状态

3. **文档驱动开发**
   - 需求 → 文档 → 代码
   - 保持文档最新

4. **自动化脚本辅助**
   - 使用脚本管理任务
   - 减少手动操作

### 下一步行动

1. ✅ 创建任务看板
2. ✅ 设置自动化脚本
3. ✅ 开始第一个任务
4. ✅ 建立协作节奏

---

**文档版本**: v1.0
**创建时间**: 2026-02-10
**最后更新**: 2026-02-10
