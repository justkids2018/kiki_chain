---
name: code-generator
description: |
  代码生成器 - 从契约自动生成三端代码

  从 .contract.yaml 契约文件自动生成 Rust 后端代码、Dart 前端代码（移动端和管理后台）、
  PostgreSQL 迁移脚本和测试骨架，确保三端代码完全一致。

  Triggers:
  - "生成代码"、"从契约生成"
  - /orchestrator 或 /contract-manager 调用
  - 契约文件创建或更新后
---

# Code Generator Skill - 代码生成器

> **本 Skill 遵循**:
> - [`../COMMON_GUIDELINES.md`](../COMMON_GUIDELINES.md) - 全局开发规范 ⭐
> - [`COMMON.md`](./COMMON.md) - 通用代码生成规范
> - [`PROJECT.md`](./PROJECT.md) - Hi Kiki 代码生成规范

---

## 🎯 When to Use

**自动激活条件**:
- 契约文件创建或更新后
- /orchestrator 调用时
- /contract-manager 创建契约后
- 用户明确要求生成代码

**触发关键词**:
- "生成代码"
- "从契约生成"
- "根据 [契约名] 生成代码"
- "实现 [契约名]"

---

## 📋 Workflow / Process

### Step 1: 读取和解析契约

**目标**: 读取 .contract.yaml 文件并解析内容

**输入**: 契约文件路径（如 `.claude/contracts/scene.contract.yaml`）

**解析内容**:
- [ ] 基本信息（name, description, version）
- [ ] 数据模型（schema.fields）
- [ ] API 定义（apis.mobile, apis.admin）
- [ ] 数据库配置（database）
- [ ] 业务规则（business_rules）
- [ ] 权限控制（permissions）

**验证**:
- [ ] YAML 格式正确
- [ ] 必填字段完整
- [ ] 类型映射有效（rust, dart, db）

### Step 2: 生成后端代码（Rust）

**目标**: 生成 kiki_server 的 Rust 代码

#### 2.1 生成 Entity（实体）

**文件路径**: `kiki_server/src/core/entities/[entity_name].rs`

**生成内容**:
```rust
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// [Entity Description]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct [EntityName] {
    pub id: i64,
    pub name: String,
    pub description: Option<String>,
    // ... 其他字段
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub deleted_at: Option<DateTime<Utc>>,
}

impl [EntityName] {
    /// 创建新实例
    pub fn new(/* 参数 */) -> Self {
        Self {
            // 初始化字段
        }
    }
}
```

**模板**: `.claude/templates/rust/entity.rs.hbs`

#### 2.2 生成 Repository Trait（仓储接口）

**文件路径**: `kiki_server/src/core/ports/[entity_name]_repository.rs`

**生成内容**:
```rust
use async_trait::async_trait;
use crate::core::entities::[entity_name]::[EntityName];
use crate::core::errors::DomainError;

/// [EntityName] Repository Trait
#[async_trait]
pub trait [EntityName]Repository: Send + Sync {
    /// 根据 ID 查找
    async fn find_by_id(&self, id: i64) -> Result<Option<[EntityName]>, DomainError>;

    /// 创建
    async fn create(&self, entity: &[EntityName]) -> Result<[EntityName], DomainError>;

    /// 更新
    async fn update(&self, entity: &[EntityName]) -> Result<[EntityName], DomainError>;

    /// 删除（软删除）
    async fn delete(&self, id: i64) -> Result<(), DomainError>;

    // 根据契约生成的自定义查询方法
    // ...
}
```

**模板**: `.claude/templates/rust/repository_trait.rs.hbs`

#### 2.3 生成 Repository Implementation（仓储实现）

**文件路径**: `kiki_server/src/adapters/persistence/postgres/[entity_name]_repository.rs`

**生成内容**:
```rust
use async_trait::async_trait;
use sqlx::PgPool;
use crate::core::entities::[entity_name]::[EntityName];
use crate::core::ports::[entity_name]_repository::[EntityName]Repository;
use crate::core::errors::DomainError;

pub struct Postgres[EntityName]Repository {
    pool: PgPool,
}

impl Postgres[EntityName]Repository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl [EntityName]Repository for Postgres[EntityName]Repository {
    async fn find_by_id(&self, id: i64) -> Result<Option<[EntityName]>, DomainError> {
        let result = sqlx::query_as!(
            [EntityName],
            r#"
            SELECT * FROM [table_name]
            WHERE id = $1 AND deleted_at IS NULL
            "#,
            id
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::DatabaseError(e.to_string()))?;

        Ok(result)
    }

    // 其他方法实现...
}
```

**模板**: `.claude/templates/rust/repository_impl.rs.hbs`

#### 2.4 生成 Use Case（用例）

**文件路径**: `kiki_server/src/core/use_cases/[entity_name]/[action]_[entity_name].rs`

**生成内容**:
```rust
use std::sync::Arc;
use crate::core::entities::[entity_name]::[EntityName];
use crate::core::ports::[entity_name]_repository::[EntityName]Repository;
use crate::core::errors::DomainError;

pub struct Get[EntityName]ByIdUseCase {
    repository: Arc<dyn [EntityName]Repository>,
}

impl Get[EntityName]ByIdUseCase {
    pub fn new(repository: Arc<dyn [EntityName]Repository>) -> Self {
        Self { repository }
    }

    pub async fn execute(&self, id: i64) -> Result<[EntityName], DomainError> {
        let entity = self.repository
            .find_by_id(id)
            .await?
            .ok_or_else(|| DomainError::NotFound(format!("[EntityName] with id {} not found", id)))?;

        Ok(entity)
    }
}
```

**模板**: `.claude/templates/rust/use_case.rs.hbs`

#### 2.5 生成 HTTP Handler（处理器）

**文件路径**: `kiki_server/src/adapters/http/[entity_name]s/handlers.rs`

**生成内容**:
```rust
use axum::{
    extract::{Path, Query, State},
    Json,
};
use std::sync::Arc;
use crate::shared::api_response::ApiResponse;
use crate::core::entities::[entity_name]::[EntityName];
use crate::core::errors::DomainError;
use crate::framework::bootstrap::container::AppState;

/// GET /api/v1/mobile/[entity_name]s/{id}
pub async fn get_[entity_name]_by_id(
    Path(id): Path<i64>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<ApiResponse<[EntityName]>>, DomainError> {
    let entity = state.[entity_name]_repository
        .find_by_id(id)
        .await?
        .ok_or_else(|| DomainError::NotFound(format!("[EntityName] not found")))?;

    Ok(Json(ApiResponse::success(entity)))
}

// 其他 handler 方法...
```

**模板**: `.claude/templates/rust/handler.rs.hbs`

#### 2.6 生成 Routes（路由配置）

**文件路径**: `kiki_server/src/framework/bootstrap/routes/[entity_name]s.rs`

**生成内容**:
```rust
use axum::{
    routing::{get, post, put, delete},
    Router,
};
use crate::framework::bootstrap::container::AppState;
use crate::adapters::http::[entity_name]s::handlers;

pub fn mobile_[entity_name]_routes() -> Router<AppState> {
    Router::new()
        .route("/[entity_name]s", get(handlers::get_[entity_name]s))
        .route("/[entity_name]s/:id", get(handlers::get_[entity_name]_by_id))
}

pub fn admin_[entity_name]_routes() -> Router<AppState> {
    Router::new()
        .route("/[entity_name]s", get(handlers::admin_get_[entity_name]s))
        .route("/[entity_name]s", post(handlers::create_[entity_name]))
        .route("/[entity_name]s/:id", put(handlers::update_[entity_name]))
        .route("/[entity_name]s/:id", delete(handlers::delete_[entity_name]))
}
```

**模板**: `.claude/templates/rust/routes.rs.hbs`

### Step 3: 生成前端代码（Dart）

**目标**: 生成 kiki_web 和 kiki_web_manager 的 Dart 代码

#### 3.1 生成 Entity（实体）

**文件路径**:
- `kiki_web/lib/domain/entities/[entity_name].dart`
- `kiki_web_manager/lib/domain/entities/[entity_name].dart`

**生成内容**:
```dart
/// [Entity Description]
class [EntityName] {
  final int id;
  final String name;
  final String? description;
  // ... 其他字段
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const [EntityName]({
    required this.id,
    required this.name,
    this.description,
    // ... 其他字段
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// 从 JSON 创建
  factory [EntityName].fromJson(Map<String, dynamic> json) {
    return [EntityName](
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      // ... 其他字段
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      // ... 其他字段
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// 复制并修改
  [EntityName] copyWith({
    int? id,
    String? name,
    String? description,
    // ... 其他字段
  }) {
    return [EntityName](
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      // ... 其他字段
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
```

**模板**: `.claude/templates/dart/entity.dart.hbs`

#### 3.2 生成 Repository Interface（仓储接口）

**文件路径**:
- `kiki_web/lib/domain/repositories/i_[entity_name]_repository.dart`
- `kiki_web_manager/lib/domain/repositories/i_[entity_name]_repository.dart`

**生成内容**:
```dart
import '../entities/[entity_name].dart';

/// [EntityName] Repository Interface
abstract class I[EntityName]Repository {
  /// 根据 ID 获取
  Future<[EntityName]> getById(int id);

  /// 获取列表
  Future<List<[EntityName]>> getList({
    int page = 1,
    int size = 20,
  });

  // 根据契约生成的其他方法...
}
```

**模板**: `.claude/templates/dart/repository_interface.dart.hbs`

#### 3.3 生成 API Service（API 服务）

**文件路径**:
- `kiki_web/lib/data/services/[entity_name]_api_service.dart`
- `kiki_web_manager/lib/data/services/[entity_name]_api_service.dart`

**生成内容**:
```dart
import 'package:dio/dio.dart';
import '../../domain/entities/[entity_name].dart';
import '../../domain/repositories/i_[entity_name]_repository.dart';

class [EntityName]ApiService implements I[EntityName]Repository {
  final Dio _dio;
  final String _baseUrl;

  [EntityName]ApiService(this._dio, {String baseUrl = '/api/v1/mobile'})
      : _baseUrl = baseUrl;

  @override
  Future<[EntityName]> getById(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/[entity_name]s/$id');
      return [EntityName].fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get [entity_name]: $e');
    }
  }

  @override
  Future<List<[EntityName]>> getList({
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/[entity_name]s',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => [EntityName].fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get [entity_name] list: $e');
    }
  }

  // 其他方法实现...
}
```

**模板**: `.claude/templates/dart/api_service.dart.hbs`

### Step 4: 生成数据库迁移脚本

**目标**: 生成 PostgreSQL 迁移脚本

**文件路径**: `kiki_server/migrations/[timestamp]_create_[table_name]_table.sql`

**生成内容**:
```sql
-- 创建 [table_name] 表
CREATE TABLE IF NOT EXISTS [table_name] (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    -- ... 其他字段
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- 创建索引
CREATE INDEX idx_[table_name]_created_at ON [table_name](created_at);
CREATE INDEX idx_[table_name]_deleted_at ON [table_name](deleted_at);
-- ... 其他索引

-- 添加外键约束
ALTER TABLE [table_name]
    ADD CONSTRAINT fk_[table_name]_[foreign_table]
    FOREIGN KEY ([foreign_key]) REFERENCES [foreign_table](id)
    ON DELETE RESTRICT;

-- 添加唯一约束
ALTER TABLE [table_name]
    ADD CONSTRAINT uq_[table_name]_[field]
    UNIQUE ([field]) WHERE deleted_at IS NULL;

-- 添加注释
COMMENT ON TABLE [table_name] IS '[Entity Description]';
COMMENT ON COLUMN [table_name].id IS '主键 ID';
COMMENT ON COLUMN [table_name].name IS '名称';
-- ... 其他注释
```

**模板**: `.claude/templates/sql/migration.sql.hbs`

### Step 5: 生成测试骨架

**目标**: 生成单元测试和集成测试的骨架

#### 5.1 后端测试

**文件路径**: `kiki_server/tests/[entity_name]_test.rs`

**生成内容**:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_create_[entity_name]() {
        // TODO: 实现测试
    }

    #[tokio::test]
    async fn test_get_[entity_name]_by_id() {
        // TODO: 实现测试
    }

    #[tokio::test]
    async fn test_update_[entity_name]() {
        // TODO: 实现测试
    }

    #[tokio::test]
    async fn test_delete_[entity_name]() {
        // TODO: 实现测试
    }
}
```

#### 5.2 前端测试

**文件路径**: `kiki_web/test/domain/entities/[entity_name]_test.dart`

**生成内容**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kiki_web/domain/entities/[entity_name].dart';

void main() {
  group('[EntityName]', () {
    test('fromJson creates valid entity', () {
      // TODO: 实现测试
    });

    test('toJson creates valid JSON', () {
      // TODO: 实现测试
    });

    test('copyWith creates modified copy', () {
      // TODO: 实现测试
    });
  });
}
```

### Step 6: 生成代码报告

**目标**: 生成详细的代码生成报告

**报告内容**:
```markdown
# 代码生成报告

## 契约信息
- 契约文件: scene.contract.yaml
- 实体名称: Scene
- 版本: v1.0

## 生成的文件

### 后端（Rust）
✅ kiki_server/src/core/entities/scene.rs (Entity)
✅ kiki_server/src/core/ports/scene_repository.rs (Repository Trait)
✅ kiki_server/src/adapters/persistence/postgres/scene_repository.rs (Repository Impl)
✅ kiki_server/src/core/use_cases/scenes/get_scene_by_id.rs (Use Case)
✅ kiki_server/src/adapters/http/scenes/handlers.rs (Handlers)
✅ kiki_server/src/framework/bootstrap/routes/scenes.rs (Routes)

### 前端（Dart - 移动端）
✅ kiki_web/lib/domain/entities/scene.dart (Entity)
✅ kiki_web/lib/domain/repositories/i_scene_repository.dart (Repository Interface)
✅ kiki_web/lib/data/services/scene_api_service.dart (API Service)

### 前端（Dart - 管理后台）
✅ kiki_web_manager/lib/domain/entities/scene.dart (Entity)
✅ kiki_web_manager/lib/domain/repositories/i_scene_repository.dart (Repository Interface)
✅ kiki_web_manager/lib/data/services/scene_api_service.dart (API Service)

### 数据库
✅ kiki_server/migrations/20260304_create_scenes_table.sql (Migration)

### 测试
✅ kiki_server/tests/scene_test.rs (Backend Tests)
✅ kiki_web/test/domain/entities/scene_test.dart (Frontend Tests)

## 统计
- 总文件数: 14
- 后端文件: 7
- 前端文件: 6
- 数据库文件: 1
- 测试文件: 2
- 总代码行数: ~1200 行

## 下一步
1. 补充业务逻辑（Use Cases 和 Handlers）
2. 运行数据库迁移
3. 实现测试用例
4. 运行代码审查（/code-review）
```

---

## 🔗 Integration with Other Skills

### 输入（依赖）
- **← /contract-manager**: 接收契约文件
- **← /orchestrator**: 接收代码生成任务

### 输出（链接）
- **→ kiki_server/code-implementation**: 补充后端业务逻辑
- **→ kiki_web/code-implementation**: 补充前端 UI
- **→ kiki_server/code-review**: 审查生成的代码

---

## 📝 Output Format

### 代码生成输出

```markdown
## ✅ 代码生成完成

### 契约
- 文件: scene.contract.yaml
- 实体: Scene
- 版本: v1.0

### 生成统计
- 后端文件: 7 个
- 前端文件: 6 个（移动端 3 + 管理后台 3）
- 数据库文件: 1 个
- 测试文件: 2 个
- 总代码行数: ~1200 行

### API 端点
- 移动端: 4 个
- 管理后台: 8 个

### 下一步
1. 运行数据库迁移: `cd kiki_server && sqlx migrate run`
2. 补充业务逻辑（20% 的工作）
3. 运行测试: `cargo test`
4. 代码审查: 调用 /code-review
```

---

## 🚨 Important Notes

### 代码生成策略

**80/20 原则**:
- 生成 80% 的框架代码（Entity, Repository, Handler 骨架）
- 留 20% 让开发者补充（业务逻辑、验证、错误处理）

**生成的代码包含**:
- ✅ 完整的数据结构定义
- ✅ CRUD 操作的骨架
- ✅ API 端点的基本实现
- ✅ 数据库查询的基本语句
- ⚠️ TODO 注释标记需要补充的部分

**不生成的内容**:
- ❌ 复杂的业务逻辑
- ❌ 特殊的验证规则
- ❌ 复杂的权限控制
- ❌ 缓存策略实现
- ❌ 完整的测试用例

### 模板变量

模板中可用的变量：
- `{{entity_name}}`: 实体名称（snake_case）
- `{{EntityName}}`: 实体名称（PascalCase）
- `{{table_name}}`: 表名（snake_case）
- `{{fields}}`: 字段列表
- `{{apis}}`: API 列表
- `{{indexes}}`: 索引列表
- `{{relations}}`: 关联列表

### 文件命名规范

- Rust: `snake_case.rs`
- Dart: `snake_case.dart`
- SQL: `timestamp_description.sql`

---

## 📚 相关文档

- [`COMMON.md`](./COMMON.md) - 通用代码生成规范
- [`PROJECT.md`](./PROJECT.md) - Hi Kiki 代码生成规范
- [`../contract-manager/SKILL.md`](../contract-manager/SKILL.md) - 契约管理
- [代码模板](../../templates/)

---

**版本**: v1.0
**最后更新**: 2026-03-04
**适用项目**: Hi Kiki
**维护者**: Development Team
