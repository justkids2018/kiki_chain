# Contract Manager - 通用契约管理规范

> **适用范围**: 所有多端架构项目
> **版本**: v1.0

---

## 📋 核心原则

### 1. 单一真相来源（Single Source of Truth）

契约文件是数据模型和 API 的唯一定义来源，所有代码从契约生成。

### 2. 类型安全（Type Safety）

确保 Rust、Dart、PostgreSQL 的类型严格对应，避免类型不匹配。

### 3. 版本控制（Versioning）

契约文件必须包含版本号，破坏性变更时升级版本。

---

## ✅ 最佳实践

### 契约文件命名
- 使用 `snake_case.contract.yaml`
- 示例: `user_favorite.contract.yaml`, `scene_category.contract.yaml`

### 字段定义
- 必须包含: type, required, rust, dart, db, description
- 可选字段使用 `Option<T>` (Rust) 和 `T?` (Dart)

---

**版本**: v1.0
**维护者**: Development Team
