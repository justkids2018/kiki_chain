---
name: contract-manager
description: |
  契约管理器 - 管理三端数据模型和 API 契约定义

  负责创建、编辑、验证契约文件（.contract.yaml），确保三端（kiki_web + kiki_server +
  kiki_web_manager）使用统一的数据模型和 API 规范。

  Triggers:
  - "创建契约"、"定义契约"
  - "生成数据模型"
  - 需要统一三端类型时
---

# Contract Manager Skill - 契约管理器

> **本 Skill 遵循**:
> - [`../COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) - 全局开发规范 ⭐
> - [`COMMON.md`](./COMMON.md) - 通用契约管理规范
> - [`PROJECT.md`](./PROJECT.md) - Hi Kiki 契约规范

---

## 🎯 When to Use

**自动激活条件**:
- 需要定义新的数据模型时
- 需要设计 API 接口时
- 三端类型不一致需要统一时
- /orchestrator 调用时

**触发关键词**:
- "创建契约"
- "定义数据模型"
- "设计 API"
- "统一类型"

---

## 📋 Workflow / Process

### Step 1: 需求分析

**目标**: 理解数据模型和 API 需求

**检查清单**:
- [ ] 确认实体名称（如 Scene, User, Favorite）
- [ ] 确认字段列表和类型
- [ ] 确认必填/可选字段
- [ ] 确认关联关系（外键）
- [ ] 确认 API 端点需求（移动端/管理后台）

### Step 2: 创建契约文件

**目标**: 生成标准的 .contract.yaml 文件

**文件路径**: `.claude/contracts/[entity_name].contract.yaml`

**契约文件结构**:
```yaml
# 基本信息
name: EntityName
description: 实体描述
version: v1.0
created_at: 2026-03-04

# 数据模型定义
schema:
  fields:
    id:
      type: integer
      required: true
      rust: i64
      dart: int
      db: BIGSERIAL PRIMARY KEY
      description: 主键 ID

    name:
      type: string
      required: true
      rust: String
      dart: String
      db: VARCHAR(255) NOT NULL
      description: 名称

    description:
      type: string
      required: false
      rust: Option<String>
      dart: String?
      db: TEXT
      description: 描述（可选）

    created_at:
      type: datetime
      required: true
      rust: DateTime<Utc>
      dart: DateTime
      db: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      description: 创建时间

# API 定义
apis:
  # 移动端 API（用户端）
  mobile:
    - method: GET
      path: /api/v1/mobile/entities
      description: 获取实体列表
      query_params:
        - name: page
          type: integer
          required: false
        - name: size
          type: integer
          required: false
      response: Entity[]
      auth: User

    - method: GET
      path: /api/v1/mobile/entities/{id}
      description: 获取实体详情
      path_params:
        - name: id
          type: integer
      response: Entity
      auth: User

  # 管理后台 API（管理员）
  admin:
    - method: GET
      path: /api/v1/admin/entities
      description: 获取实体列表（管理后台）
      query_params:
        - name: page
          type: integer
        - name: size
          type: integer
        - name: keyword
          type: string
          required: false
      response: Paginated<Entity>
      auth: Admin

    - method: POST
      path: /api/v1/admin/entities
      description: 创建实体
      body: CreateEntityRequest
      response: Entity
      auth: Admin

    - method: PUT
      path: /api/v1/admin/entities/{id}
      description: 更新实体
      path_params:
        - name: id
          type: integer
      body: UpdateEntityRequest
      response: Entity
      auth: Admin

    - method: DELETE
      path: /api/v1/admin/entities/{id}
      description: 删除实体（软删除）
      path_params:
        - name: id
          type: integer
      response: Success
      auth: Admin

# 数据库配置
database:
  table: entities
  indexes:
    - columns: [name]
      unique: false
    - columns: [created_at]
      unique: false
  relations:
    - table: categories
      type: belongs_to
      foreign_key: category_id
  soft_delete: true

# 验证规则
validation:
  name:
    - rule: min_length
      value: 2
    - rule: max_length
      value: 255
  description:
    - rule: max_length
      value: 1000
```

### Step 3: 验证契约

**目标**: 确保契约文件格式正确，内容完整

**验证清单**:
- [ ] YAML 格式正确
- [ ] 必填字段完整（name, schema, apis, database）
- [ ] 类型映射正确（rust, dart, db）
- [ ] API 路径符合规范（/api/v1/mobile/* 或 /api/v1/admin/*）
- [ ] 权限设置正确（User 或 Admin）
- [ ] 数据库表名符合命名规范（snake_case）

**常见错误检查**:
```yaml
# ❌ 错误：类型不匹配
id:
  rust: String      # 错误！ID 应该是 i64
  dart: String      # 错误！ID 应该是 int
  db: VARCHAR       # 错误！ID 应该是 BIGSERIAL

# ✅ 正确
id:
  rust: i64
  dart: int
  db: BIGSERIAL PRIMARY KEY
```

### Step 4: 生成契约文档

**目标**: 生成人类可读的契约文档

**文档格式**: Markdown

**输出路径**: `.claude/contracts/[entity_name].md`

**文档内容**:
```markdown
# Entity 契约文档

**版本**: v1.0
**创建时间**: 2026-03-04

## 数据模型

| 字段 | 类型 | 必填 | 描述 |
|------|------|------|------|
| id | integer | 是 | 主键 ID |
| name | string | 是 | 名称 |
| description | string | 否 | 描述 |
| created_at | datetime | 是 | 创建时间 |

## API 端点

### 移动端 API

#### GET /api/v1/mobile/entities
获取实体列表

**权限**: User

**查询参数**:
- page (integer, 可选): 页码
- size (integer, 可选): 每页数量

**响应**: Entity[]

---

### 管理后台 API

#### POST /api/v1/admin/entities
创建实体

**权限**: Admin

**请求体**: CreateEntityRequest

**响应**: Entity

---

## 数据库

**表名**: entities

**索引**:
- name
- created_at

**关联**:
- belongs_to: categories (category_id)

**软删除**: 是
```

### Step 5: 更新契约索引

**目标**: 维护契约文件的索引，方便查找

**索引文件**: `.claude/contracts/README.md`

**索引内容**:
```markdown
# 契约索引

## 已定义契约

| 实体 | 契约文件 | 版本 | 创建时间 | 状态 |
|------|----------|------|----------|------|
| Scene | scene.contract.yaml | v1.0 | 2026-03-04 | ✅ 已实现 |
| User | user.contract.yaml | v1.0 | 2026-03-04 | ✅ 已实现 |
| Favorite | favorite.contract.yaml | v1.0 | 2026-03-04 | 📝 待实现 |

## 契约规范

详见 [CONTRACT_SPEC.md](./CONTRACT_SPEC.md)
```

---

## 🔗 Integration with Other Skills

### 输入（依赖）
- **← /orchestrator**: 接收任务分解后的数据模型需求

### 输出（链接）
- **→ /code-generator**: 提供契约文件用于代码生成
- **→ /schema-sync**: 契约变更时触发同步

---

## 📝 Output Format

### 契约创建输出

```markdown
## ✅ 契约创建完成

### 契约文件
- 路径: .claude/contracts/favorite.contract.yaml
- 版本: v1.0
- 实体: Favorite

### 数据模型
- 字段数: 6
- 必填字段: 4
- 可选字段: 2

### API 端点
- 移动端: 3 个
- 管理后台: 5 个

### 数据库
- 表名: user_favorites
- 索引: 2 个
- 关联: 2 个

### 下一步
契约已创建，可以调用 /code-generator 生成代码
```

---

## 🚨 Important Notes

### 类型映射规则

| 概念类型 | Rust | Dart | PostgreSQL |
|----------|------|------|------------|
| 整数 ID | `i64` | `int` | `BIGSERIAL` |
| 字符串 | `String` | `String` | `VARCHAR` / `TEXT` |
| 可选字符串 | `Option<String>` | `String?` | `TEXT NULL` |
| 布尔值 | `bool` | `bool` | `BOOLEAN` |
| 时间戳 | `DateTime<Utc>` | `DateTime` | `TIMESTAMP` |
| JSON | `serde_json::Value` | `Map<String, dynamic>` | `JSONB` |
| 数组 | `Vec<T>` | `List<T>` | `ARRAY` / 关联表 |

### 命名规范

- 契约文件: `snake_case.contract.yaml` (如 `user_favorite.contract.yaml`)
- 实体名: `PascalCase` (如 `UserFavorite`)
- 表名: `snake_case` (如 `user_favorites`)
- API 路径: `kebab-case` (如 `/user-favorites`)

### 权限级别

- `User`: 普通用户权限（移动端）
- `Admin`: 管理员权限（管理后台）
- `Public`: 无需认证（公开接口）

---

## 📚 相关文档

- [`COMMON.md`](./COMMON.md) - 通用契约管理规范
- [`PROJECT.md`](./PROJECT.md) - Hi Kiki 契约规范
- [`../code-generator/SKILL.md`](../code-generator/SKILL.md) - 代码生成
- [契约规范](../../contracts/CONTRACT_SPEC.md)

---

**版本**: v1.0
**最后更新**: 2026-03-04
**适用项目**: Hi Kiki
**维护者**: Development Team
