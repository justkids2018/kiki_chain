# Hi Kiki 自动化 Skills 入手教程

**版本**: v1.0
**更新时间**: 2026-03-04
**预计学习时间**: 30 分钟

---

## 🎯 教程目标

学完本教程，您将能够：
1. 理解 skills 体系的基本概念
2. 使用 skills 完成一个完整功能的开发
3. 掌握从需求到代码的自动化流程

---

## 📚 前置知识

您需要了解：
- ✅ 基本的 Rust 和 Dart/Flutter 知识
- ✅ Hi Kiki 项目的三端架构（kiki_web + kiki_server + kiki_web_manager）
- ✅ Clean Architecture 基本概念

---

## 🚀 快速开始（5分钟）

### Step 1: 查看现有 Skills


```bash
# 查看根级 skills（全局协调）
ls .claude/skills/

# 输出：
# orchestrator/        - 项目总指挥
# contract-manager/    - 契约管理器
# code-generator/      - 代码生成器
# task-executor/       - 任务执行器
```

**这4个 skills 是干什么的？**
- `orchestrator`: 分析需求，决定要开发什么
- `contract-manager`: 定义数据模型和 API（写契约）
- `code-generator`: 从契约自动生成代码
- `task-executor`: 批量执行多个任务

---

### Step 2: 查看契约示例

```bash
# 查看已有的契约
cat .claude/contracts/scene.contract.yaml
```

**契约是什么？**
契约是一个 YAML 文件，定义了：
- 数据模型（字段、类型）
- API 接口（移动端、管理后台）
- 数据库结构（表名、索引）

**为什么需要契约？**
- 保证三端（后端、移动端、管理后台）数据模型一致
- 避免类型不匹配错误
- 作为代码生成的蓝图

---

### Step 3: 查看任务示例

```bash
# 查看任务模板
cat docs/tasks/TASK_TEMPLATE.md

# 查看任务示例
cat docs/tasks/TASK_EXAMPLE.md
```

**任务文件是什么？**
任务文件记录了：
- 需求描述
- 技术方案
- 依赖关系
- 是否允许自动执行

---

## 💡 核心概念（10分钟）

### 1. 契约优先开发（Contract-First Development）

**传统方式**（容易出错）：
```
后端开发者：写 Rust 代码
前端开发者：写 Dart 代码
结果：类型不匹配，前后端对接困难
```

**契约优先方式**（推荐）：
```
Step 1: 团队一起定义契约（单一真相来源）
Step 2: 从契约自动生成三端代码（保证一致）
Step 3: 开发者补充业务逻辑（专注核心）
```

---

### 2. 80/20 原则

**自动生成 80%**：
- 数据结构定义（Entity）
- CRUD 基础操作（Repository）
- API 端点框架（Handler）
- 数据库迁移脚本（SQL）

**人工补充 20%**：
- 复杂的业务逻辑
- 特殊的验证规则
- 权限控制细节
- 性能优化策略

---

### 3. Skills 协作流程

```
用户需求
    ↓
orchestrator（理解需求，分解任务）
    ↓
contract-manager（创建契约）
    ↓
code-generator（生成代码）
    ↓
code-implementation（补充逻辑）
    ↓
code-review（审查代码）
    ↓
完成！
```

---

## 🎬 实战教程：开发"用户收藏场景"功能（15分钟）

让我们通过一个真实例子，学习如何使用这套 skills 体系。

### 场景描述

**需求**：用户可以收藏喜欢的场景，方便后续快速访问。

**涉及**：
- 后端：API 接口（添加收藏、取消收藏、查看收藏列表）
- 移动端：收藏按钮 + 我的收藏页面
- 数据库：user_favorites 表

---

### 方式 1：完全手动（传统方式）

如果完全手动开发，需要：

1. **设计数据库**（30分钟）
   - 创建 user_favorites 表
   - 设计字段、索引、外键

2. **后端实现**（3-4小时）
   - 定义 Rust Entity
   - 实现 Repository（CRUD）
   - 实现 Use Case（业务逻辑）
   - 实现 Handler（API 端点）
   - 配置路由
   - 编写测试

3. **前端实现**（2-3小时）
   - 定义 Dart Entity
   - 实现 Repository 接口
   - 实现 API Service
   - 实现 Controller
   - 实现 UI（收藏按钮、收藏页面）

4. **测试和调试**（1-2小时）
   - 前后端联调
   - 修复类型不匹配
   - 修复 API 对接问题

**总耗时**：7-10 小时

---

### 方式 2：使用 Skills（推荐方式）

#### Phase 1: 需求分析和任务分解（5分钟）

**操作**：向 Claude 发送需求

```
您："实现用户收藏场景功能"
```

**Claude 的响应**（orchestrator skill 自动触发）：

```markdown
## 需求理解

功能：用户收藏场景
涉及端：后端 + 移动端
复杂度：中等

## 任务分解

### 后端任务
1. 数据库设计：user_favorites 表
2. API 实现：
   - POST /api/v1/mobile/favorites
   - DELETE /api/v1/mobile/favorites/{id}
   - GET /api/v1/mobile/users/{id}/favorites

### 移动端任务
1. UI 实现：场景详情页收藏按钮
2. 页面实现：我的收藏页面

## 下一步
是否生成任务文件？[是/否]
```

**您的回复**：
```
是
```

**结果**：
- 生成任务文件到 `docs/tasks/backend/features/用户收藏-20260304.md`
- 生成任务文件到 `docs/tasks/app/features/收藏功能-20260304.md`

---

#### Phase 2: 创建契约（5分钟）

**操作**：请求创建契约

```
您："创建 UserFavorite 契约"
```

**Claude 的响应**（contract-manager skill 自动触发）：

```yaml
# .claude/contracts/user_favorite.contract.yaml

name: UserFavorite
description: 用户收藏场景

schema:
  fields:
    id:
      type: integer
      rust: i64
      dart: int
      db: BIGSERIAL PRIMARY KEY

    user_id:
      type: integer
      rust: i64
      dart: int
      db: BIGINT NOT NULL

    scene_id:
      type: integer
      rust: i64
      dart: int
      db: BIGINT NOT NULL

    created_at:
      type: datetime
      rust: DateTime<Utc>
      dart: DateTime
      db: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

apis:
  mobile:
    - method: POST
      path: /api/v1/mobile/favorites
      body: { scene_id: integer }

    - method: DELETE
      path: /api/v1/mobile/favorites/{id}

    - method: GET
      path: /api/v1/mobile/users/{user_id}/favorites
      response: Scene[]

database:
  table: user_favorites
  indexes:
    - [user_id, scene_id]
  unique:
    - [user_id, scene_id]
```

**审查确认**：
```
您："契约正确，继续"
```

---

#### Phase 3: 生成代码（1分钟）

**操作**：请求生成代码

```
您："从 user_favorite.contract.yaml 生成代码"
```

**Claude 的响应**（code-generator skill 自动触发）：

```markdown
## 代码生成完成 ✅

### 后端（Rust）
生成文件：
✅ kiki_server/src/core/entities/user_favorite.rs
✅ kiki_server/src/core/ports/user_favorite_repository.rs
✅ kiki_server/src/adapters/persistence/postgres/user_favorite_repository.rs
✅ kiki_server/src/core/use_cases/favorites/create_favorite.rs
✅ kiki_server/src/adapters/http/favorites/handlers.rs
✅ kiki_server/src/framework/bootstrap/routes/favorites.rs

### 移动端（Dart）
生成文件：
✅ kiki_web/lib/domain/entities/user_favorite.dart
✅ kiki_web/lib/domain/repositories/i_user_favorite_repository.dart
✅ kiki_web/lib/data/services/user_favorite_api_service.dart

### 数据库（SQL）
生成文件：
✅ kiki_server/migrations/20260304_create_user_favorites_table.sql

### 统计
- 总文件：10 个
- 总代码：~800 行
- 生成时间：10 秒

### 下一步
1. 运行数据库迁移
2. 补充业务逻辑（20%的工作）
3. 实现移动端 UI
```

---

#### Phase 4: 补充业务逻辑（30-60分钟）

**后端**：打开生成的文件，补充业务逻辑

```rust
// kiki_server/src/core/use_cases/favorites/create_favorite.rs

impl CreateFavoriteUseCase {
    pub async fn execute(&self, user_id: i64, scene_id: i64)
        -> Result<UserFavorite, DomainError>
    {
        // TODO: 补充以下业务逻辑

        // 1. 验证用户权限
        // 检查用户是否已登录
        if user_id <= 0 {
            return Err(DomainError::Unauthorized("User not logged in".to_string()));
        }

        // 2. 检查场景是否存在
        let scene = self.scene_repository
            .find_by_id(scene_id)
            .await?
            .ok_or(DomainError::NotFound("Scene not found".to_string()))?;

        // 3. 检查是否已收藏（防止重复）
        if let Some(_) = self.repository.find_by_user_and_scene(user_id, scene_id).await? {
            return Err(DomainError::AlreadyExists("Already favorited".to_string()));
        }

        // 4. 检查收藏数量限制（最多100个）
        let count = self.repository.count_by_user(user_id).await?;
        if count >= 100 {
            return Err(DomainError::LimitExceeded("Favorite limit reached".to_string()));
        }

        // 5. 创建收藏记录（框架已生成）
        let favorite = UserFavorite::new(user_id, scene_id);
        let result = self.repository.create(&favorite).await?;

        Ok(result)
    }
}
```

**前端**：实现 UI

```dart
// kiki_web/lib/presentation/widgets/favorite_button.dart

class FavoriteButton extends StatelessWidget {
  final Scene scene;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<FavoriteController>();
      final isFavorited = controller.isFavorited(scene.id);

      return IconButton(
        icon: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: isFavorited ? Colors.red : Colors.grey,
        ),
        onPressed: () async {
          if (isFavorited) {
            await controller.removeFavorite(scene.id);
          } else {
            await controller.addFavorite(scene.id);
          }
        },
      );
    });
  }
}
```

---

#### Phase 5: 代码审查（自动）

**操作**：代码审查会自动触发（code-review skill）

```markdown
## 代码审查报告 ✅

### 编译检查
✅ Rust 代码编译通过
✅ Dart 代码分析通过

### 代码质量
✅ 命名规范符合项目标准
✅ 错误处理完善
✅ 注释清晰
⚠️ 建议添加单元测试

### 安全检查
✅ SQL 注入防护（使用参数化查询）
✅ 权限验证完善
✅ 输入验证充分

### 建议
1. 添加单元测试（覆盖率目标 80%）
2. 添加集成测试（前后端对接）
```

---

#### Phase 6: 测试（10-20分钟）

**后端测试**：

```bash
# 运行数据库迁移
cd kiki_server
sqlx migrate run

# 运行测试
cargo test favorites

# 运行服务
cargo run
```

**前端测试**：

```bash
# 运行 Flutter
cd kiki_web
flutter run

# 测试功能
# 1. 打开场景详情页
# 2. 点击收藏按钮
# 3. 查看"我的收藏"页面
```

---

#### 结果对比

**使用 Skills**：
- ⏱️ 总耗时：1-2 小时
- ⚡ 自动生成：~800 行代码
- ✅ 零类型错误
- 📝 完整文档

**手动开发**：
- ⏱️ 总耗时：7-10 小时
- ⚡ 手写：~800 行代码
- ⚠️ 可能有 5-10 个类型错误
- 📝 文档不完整

**效率提升**：5-7 倍！

---

## 🎯 进阶用法：批量执行任务

当您有多个任务要做时，可以使用 `task-executor` 批量执行。

### Step 1: 准备任务文件

```bash
# 创建多个任务文件
docs/tasks/backend/features/
├── 用户收藏-20260304.md
├── 学习进度-20260304.md
├── 用户成就-20260304.md
└── 数据统计-20260304.md
```

### Step 2: 批量执行

```
您："自动执行所有 P0 任务"
```

**Claude 的响应**（task-executor skill 自动触发）：

```markdown
## 扫描任务池

发现任务：
- [P0] 用户收藏功能
- [P0] 学习进度记录
- [P1] 用户成就系统
- [P2] 数据统计面板

## 执行计划

Phase 1: 后端实现（串行）
  [1/2] 用户收藏功能 (2h)
  [2/2] 学习进度记录 (2.5h)

Phase 2: 前端实现（并行）
  [3/4] 移动端：收藏功能 (1h) ║
  [4/4] 移动端：进度展示 (1h) ║

预计总耗时：5.5h（考虑并行）

是否立即执行？[是/否]
```

**您的回复**：
```
是
```

**自动执行过程**：
```
[1/4] ✅ 用户收藏功能（2h）
      - 契约创建 ✅
      - 代码生成 ✅
      - 业务逻辑 ✅
      - 代码审查 ✅

[2/4] ✅ 学习进度记录（2.5h）
      - 契约创建 ✅
      - 代码生成 ✅
      - 业务逻辑 ✅
      - 代码审查 ✅

[3/4] ✅ 移动端：收藏功能（1h）║
[4/4] ✅ 移动端：进度展示（1h）║

完成！总耗时：5.5h
```

---

## 📝 常用命令速查

### 需求分析和任务分解
```
"实现 [功能名] 功能"
"帮我规划 [功能名] 的开发"
```

### 创建契约
```
"创建 [实体名] 契约"
"定义 [实体名] 的数据模型"
```

### 生成代码
```
"从 [契约名].contract.yaml 生成代码"
"生成 [实体名] 的代码"
```

### 批量执行任务
```
"自动执行所有 P0 任务"
"执行后端任务池中的任务"
"运行所有高优先级任务"
```

### 查看状态
```
"查看任务进度"
"显示项目状态"
```

---

## 🐛 常见问题

### Q1: 生成的代码编译错误怎么办？

**A**:
1. 检查契约文件是否正确（类型映射）
2. 检查生成的代码（可能模板有问题）
3. 手动修复编译错误
4. 反馈问题，优化模板

### Q2: 如何只生成后端代码？

**A**:
```
"只生成 [实体名] 的后端代码"
"从契约生成 Rust 代码"
```

### Q3: 生成的代码可以修改吗？

**A**:
可以！生成的代码只是框架（80%），您需要补充业务逻辑（20%）。
建议在 TODO 标记的地方补充代码。

### Q4: 如何更新契约？

**A**:
1. 修改 `.claude/contracts/xxx.contract.yaml`
2. 重新生成代码
3. 手动合并变更（注意不要覆盖业务逻辑）

### Q5: 任务执行失败怎么办？

**A**:
1. 查看错误信息
2. 修复问题
3. 重新执行任务
4. 或者切换为手动模式完成

---

## 🎓 学习路径

### 初级（第1天）
- [x] 理解契约优先开发概念
- [x] 使用 orchestrator 分析需求
- [x] 使用 contract-manager 创建契约
- [x] 查看生成的代码

### 中级（第2-3天）
- [ ] 使用 code-generator 生成完整代码
- [ ] 补充业务逻辑
- [ ] 实现完整功能（包括前后端）
- [ ] 理解 Skills 协作流程

### 高级（第4-7天）
- [ ] 使用 task-executor 批量执行任务
- [ ] 创建自定义契约
- [ ] 优化代码模板
- [ ] 完成 3-5 个功能开发

### 专家级（第2周+）
- [ ] 独立使用 Skills 体系开发
- [ ] 优化工作流
- [ ] 扩展 Skills 功能
- [ ] 帮助团队成员使用

---

## 🚀 下一步

现在您已经学会了基础用法，建议：

1. **立即实践**（最重要！）
   ```
   "实现用户收藏场景功能"
   ```
   完整走一遍流程，体会自动化的魅力。

2. **查看详细文档**
   - `.claude/FINAL_REPORT.md` - 完整报告
   - `.claude/skills/*/SKILL.md` - 各 skill 详细说明
   - `.claude/contracts/scene.contract.yaml` - 契约示例

3. **参考示例**
   - `docs/tasks/TASK_EXAMPLE.md` - 任务文件示例
   - `.claude/templates/` - 代码模板

4. **持续优化**
   - 根据使用体验优化工作流
   - 完善代码模板
   - 扩展新功能

---

## 💬 获取帮助

遇到问题时：
1. 查看文档：`.claude/FINAL_REPORT.md`
2. 查看示例：`docs/tasks/TASK_EXAMPLE.md`
3. 询问 Claude："[具体问题描述]"

---

**祝您使用愉快！开始享受高效的自动化开发吧！** 🎉

---

**教程版本**: v1.0
**创建时间**: 2026-03-04
**适用项目**: Hi Kiki
**维护者**: Development Team
