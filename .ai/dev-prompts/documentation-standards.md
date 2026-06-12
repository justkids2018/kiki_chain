# 文档管理规范

## 1. 文档目录分层规范

**核心原则：共享的放根目录，专属的放子项目**

### 1.1 根目录 `docs/` - 项目级共享文档

用于存放**跨子项目的共享文档**，尤其是前后端契约：

```
docs/
├── api/                        # ⭐ API 接口文档（前后端共享契约，最重要）
│   ├── README.md              # API 文档规范
│   ├── endpoints/             # 接口定义（前后端都看这里）
│   └── schemas/               # 数据模型定义
├── architecture/              # 整体架构设计文档
├── deployment/                # 部署相关文档
└── project-ops.md            # 项目运维文档
```

**重要**：`docs/api/` 是前后端的接口契约，任何接口变更必须在这里更新！

### 1.2 子项目 `{project}/docs/` - 专属实现文档

用于存放**各子项目内部的实现细节**：

```
kiki_server/docs/              # 后端专属文档
├── implementation/            # 后端实现细节
├── database/                  # 数据库设计（物理层）
└── ...

kiki_web/docs/                # 前端专属文档  
├── components/               # 组件文档
├── state-management/         # 状态管理
└── architecture/             # 前端架构（如 DDD 实现）

kiki_admin/docs/              # 管理后台专属文档（如果有）
```

### 1.3 文档查找规则（AI Agent 必读）

**当你需要查找文档时，按以下优先级：**

1. **API 接口文档** → `docs/api/endpoints/{module}.md`
2. **后端实现细节** → `kiki_server/docs/`
3. **前端实现细节** → `kiki_web/docs/`
4. **整体架构设计** → `docs/architecture/`
5. **部署运维相关** → `docs/deployment/` 或 `docs/project-ops.md`

**禁止使用 `doc` 目录（单数形式），统一使用 `docs`（复数形式）**

## 2. 文档命名规范

### 2.1 文件命名

- 使用小写字母和连字符：`api-development-standards.md`
- 避免使用空格和特殊字符
- 文件名应清晰表达内容：`learning-api.md` 而不是 `api1.md`

### 2.2 目录命名

- 使用小写字母和连字符：`dev-prompts`
- 按功能分类：`endpoints`、`implementation`、`components`

## 3. 文档更新规范

### 3.1 何时更新文档

**强制更新场景**：
- 新增功能：添加功能设计文档和 API 文档（如涉及接口）
- 修改接口：必须同步更新 API 文档
- 架构变更：更新架构文档
- 部署流程变更：更新部署文档

**建议更新场景**：
- 重要 bug 修复：记录问题原因和解决方案
- 性能优化：记录优化思路和效果
- 技术选型：记录选型理由和对比

### 3.2 文档质量标准

每个文档应包含：
- **标题**：清晰的文档标题
- **目的**：为什么需要这个文档
- **内容**：详细的说明、示例、图表
- **更新记录**：最后更新时间和版本（可选）

## 4. 文档引用规范

### 4.1 内部引用

使用相对路径引用项目内文档：

```markdown
详见 [API 开发规范](.ai/dev-prompts/api-development-standards.md)
```

### 4.2 跨目录引用

从 AGENTS.md 引用 dev-prompts：

```markdown
开发规范参考：`.ai/dev-prompts/` 目录
```

## 5. AI Agent 使用指南

### 5.1 查找文档

**场景 1：查找 API 接口定义**
```bash
cat docs/api/endpoints/{module}.md
```

**场景 2：查找后端实现**
```bash
cat kiki_server/docs/implementation/{feature}.md
```

**场景 3：查找开发规范**
```bash
cat .ai/dev-prompts/{standard}.md
```

### 5.2 创建文档

**场景 1：新增 API 接口**
```bash
# 1. 创建接口文档
docs/api/endpoints/new-feature.md

# 2. 后端实现文档
kiki_server/docs/implementation/new-feature.md

# 3. 前端使用文档
kiki_web/docs/new-feature.md
```

**场景 2：新增开发规范**
```bash
.ai/dev-prompts/new-standard.md
```

### 5.3 更新文档

- PR 中涉及文档的文件必须同时更新对应文档
- 使用 git diff 检查文档是否同步更新
- Code Review 时检查文档完整性

## 6. 文档目录索引

完整的文档索引和查找规则，请参考：`docs/DOCS_INDEX.md`

## 7. 常见问题

### Q: 文档应该写在哪里？

A: 遵循分层原则：
- API 接口 → `docs/api/`（共享）
- 实现细节 → `{project}/docs/`（专属）
- 开发规范 → `.ai/dev-prompts/`（规范）

### Q: 如何保持文档同步？

A:
1. 开发前先写文档（文档驱动）
2. PR 中同时更新文档
3. Code Review 检查文档完整性
4. 定期审查文档准确性

### Q: 旧的 doc/ 目录怎么办？

A: 采用渐进式迁移：
1. 新文档全部放在 `docs/`
2. 更新旧文档时迁移到 `docs/`
3. 最后统一清理空的 `doc/` 目录
