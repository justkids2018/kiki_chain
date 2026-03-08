# 代码模板说明

**创建时间**: 2026-03-06
**状态**: ✅ 完整可用

---

## 📦 模板列表

### Rust 模板（后端）

| 模板文件 | 用途 | 生成位置 |
|---------|------|----------|
| `rust/entity.rs.hbs` | 实体类 | `kiki_server/src/core/entities/` |
| `rust/repository_port.rs.hbs` | Repository 接口 | `kiki_server/src/core/ports/` |
| `rust/repository_impl.rs.hbs` | Repository 实现（PostgreSQL） | `kiki_server/src/adapters/persistence/postgres/` |
| `rust/handler.rs.hbs` | HTTP 处理器（Axum） | `kiki_server/src/adapters/http/` |

### Dart 模板（前端）

| 模板文件 | 用途 | 生成位置 |
|---------|------|----------|
| `dart/entity.dart.hbs` | 实体类 | `kiki_web/lib/domain/entities/` |
| `dart/repository_interface.dart.hbs` | Repository 接口 | `kiki_web/lib/domain/repositories/` |
| `dart/api_service.dart.hbs` | API Service（Dio） | `kiki_web/lib/data/services/` |
| `dart/controller.dart.hbs` | Controller（GetX） | `kiki_web/lib/presentation/controllers/` |

### SQL 模板（数据库）

| 模板文件 | 用途 | 生成位置 |
|---------|------|----------|
| `sql/migration.sql.hbs` | 数据库迁移脚本 | `kiki_server/migrations/` |

---

## 🎯 使用方法

### 1. 定义契约

创建契约文件 `.claude/contracts/your_entity.contract.yaml`：

```yaml
name: UserFavorite
description: 用户收藏

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

apis:
  mobile:
    - method: POST
      path: /api/v1/mobile/favorites

    - method: GET
      path: /api/v1/mobile/favorites
```

### 2. 生成代码

使用 `/code-generator` skill：

```
你："从 user_favorite.contract.yaml 生成代码"
```

或手动调用模板引擎（如 Handlebars）。

### 3. 生成的文件

**后端**（约 8 个文件）：
- ✅ Entity 定义
- ✅ Repository 接口
- ✅ Repository 实现（PostgreSQL）
- ✅ HTTP Handler（CRUD 端点）
- ✅ 数据库迁移脚本
- ✅ 测试骨架

**前端**（约 4 个文件）：
- ✅ Entity 定义
- ✅ Repository 接口
- ✅ API Service（HTTP 客户端）
- ✅ Controller（状态管理）

---

## 🔧 模板变量

### 通用变量

| 变量名 | 说明 | 示例 |
|-------|------|------|
| `{{entity_name}}` | 实体名（PascalCase） | `UserFavorite` |
| `{{snake_case_name}}` | 蛇形命名 | `user_favorite` |
| `{{description}}` | 实体描述 | `用户收藏` |
| `{{contract_file}}` | 契约文件名 | `user_favorite.contract.yaml` |

### 字段变量

| 变量名 | 说明 | 示例 |
|-------|------|------|
| `{{name}}` | 字段名（snake_case） | `user_id` |
| `{{rust_type}}` | Rust 类型 | `i64` |
| `{{dart_type}}` | Dart 类型 | `int` |
| `{{db_type}}` | 数据库类型 | `BIGINT` |
| `{{comment}}` | 字段注释 | `用户ID` |

### API 变量

| 变量名 | 说明 | 示例 |
|-------|------|------|
| `{{has_create_api}}` | 是否有创建 API | `true/false` |
| `{{has_get_api}}` | 是否有查询 API | `true/false` |
| `{{has_list_api}}` | 是否有列表 API | `true/false` |
| `{{has_update_api}}` | 是否有更新 API | `true/false` |
| `{{has_delete_api}}` | 是否有删除 API | `true/false` |
| `{{create_api_path}}` | 创建 API 路径 | `/api/v1/mobile/favorites` |

---

## 📝 模板语法

使用 Handlebars 模板引擎语法：

### 条件判断

```handlebars
{{#if has_create_api}}
  // 创建相关代码
{{/if}}
```

### 循环

```handlebars
{{#each fields}}
  pub {{name}}: {{rust_type}},
{{/each}}
```

### 辅助函数

```handlebars
{{camelCase name}}        // userFavorite
{{snake_case name}}       // user_favorite
{{pascal_case name}}      // UserFavorite
{{kebab_case name}}       // user-favorite
```

---

## ✅ 生成的代码特点

### 1. 完整的 CRUD 操作

- ✅ Create（创建）
- ✅ Read（查询）
- ✅ Update（更新）
- ✅ Delete（删除）
- ✅ List（列表 + 分页）

### 2. 错误处理

- ✅ Rust：统一的 `Result<T, DomainError>`
- ✅ Dart：try-catch + 友好的错误提示
- ✅ API：标准的错误响应格式

### 3. 日志记录

- ✅ Rust：使用 tracing/log
- ✅ Dart：使用 AppLogger
- ✅ 关键操作都有日志

### 4. 测试骨架

- ✅ Rust：`#[cfg(test)]` 模块
- ✅ Dart：TODO 注释提示
- ✅ 预留测试方法

---

## 🎨 自定义模板

### 修改现有模板

1. 编辑 `.claude/templates/` 下的 `.hbs` 文件
2. 使用 Handlebars 语法
3. 测试生成效果
4. 提交更改

### 添加新模板

1. 在对应目录创建新的 `.hbs` 文件
2. 定义模板变量
3. 更新本 README
4. 更新 `/code-generator` 的 SKILL.md

---

## 🔍 注意事项

### 1. 生成的代码是框架

- 提供 80% 的样板代码
- 需要补充 20% 的业务逻辑
- 在 `TODO` 标记处补充代码

### 2. 类型映射要准确

```yaml
# 契约中的类型映射必须一致
id:
  type: integer
  rust: i64        # ← 必须对应
  dart: int        # ← 必须对应
  db: BIGSERIAL    # ← 必须对应
```

### 3. 生成后需要调整

- 添加业务验证逻辑
- 添加权限控制
- 完善错误处理
- 编写测试用例

---

## 📊 模板覆盖情况

| 层级 | Rust | Dart | SQL |
|------|------|------|-----|
| Entity | ✅ | ✅ | ✅ |
| Repository | ✅ | ✅ | - |
| Handler/Controller | ✅ | ✅ | - |
| Use Case | ⚠️ | - | - |
| Tests | ⚠️ | ⚠️ | - |

**说明**：
- ✅ 完整可用
- ⚠️ 有骨架，需补充
- - 不需要

---

## 🚀 后续计划

### 高优先级
- [ ] 添加 Use Case 模板
- [ ] 完善测试模板
- [ ] 添加路由配置模板

### 中优先级
- [ ] 添加管理后台模板
- [ ] 支持关联查询模板
- [ ] 添加缓存层模板

### 低优先级
- [ ] 支持其他数据库（MySQL、MongoDB）
- [ ] 支持其他框架（Actix-web、Rocket）
- [ ] 可视化模板编辑器

---

**创建者**: Claude (Code Generator)
**版本**: v1.0
**最后更新**: 2026-03-06
