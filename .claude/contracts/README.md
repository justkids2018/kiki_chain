# Hi Kiki 契约索引

**更新时间**: 2026-03-04

---

## 📋 已定义契约

| 实体 | 契约文件 | 版本 | 创建时间 | 状态 | 说明 |
|------|----------|------|----------|------|------|
| Scene | [scene.contract.yaml](./scene.contract.yaml) | v1.0 | 2026-03-04 | 📝 待实现 | 学习场景 |

---

## 📚 契约规范

### 契约文件结构

每个契约文件必须包含以下部分：

1. **基本信息**: name, description, version, created_at
2. **数据模型**: schema.fields（字段定义）
3. **API 定义**: apis.mobile 和 apis.admin
4. **数据库配置**: database（表名、索引、关联）
5. **业务规则**: business_rules（可选）
6. **权限控制**: permissions
7. **测试数据**: test_data（可选）

### 类型映射表

| 概念类型 | Rust | Dart | PostgreSQL |
|----------|------|------|------------|
| 整数 ID | `i64` | `int` | `BIGSERIAL` |
| 整数 | `i32` | `int` | `INTEGER` |
| 字符串 | `String` | `String` | `VARCHAR` / `TEXT` |
| 可选字符串 | `Option<String>` | `String?` | `TEXT NULL` |
| 布尔值 | `bool` | `bool` | `BOOLEAN` |
| 时间戳 | `DateTime<Utc>` | `DateTime` | `TIMESTAMP` |
| JSON | `serde_json::Value` | `Map<String, dynamic>` | `JSONB` |
| 数组 | `Vec<T>` | `List<T>` | `ARRAY` |

### API 路径规范

- **移动端**: `/api/v1/mobile/*` - 用户端功能，只读或有限写入
- **管理后台**: `/api/v1/admin/*` - 管理员功能，完整 CRUD
- **共享**: `/api/v1/auth/*` 或 `/api/v1/common/*` - 认证和公共资源

### 权限级别

- **User**: 普通用户权限（移动端）
- **Admin**: 管理员权限（管理后台）
- **Public**: 无需认证（公开接口）

---

## 🚀 使用契约

### 1. 创建新契约

```bash
# 使用 /contract-manager skill
"创建 Favorite 契约"
```

### 2. 从契约生成代码

```bash
# 使用 /code-generator skill
"从 scene.contract.yaml 生成代码"
```

### 3. 验证契约

```bash
# 检查契约格式和完整性
"验证 scene.contract.yaml"
```

---

## 📝 待创建契约

以下是项目需要的契约列表：

### 核心实体
- [ ] `scene_category.contract.yaml` - 场景分类
- [ ] `scene_item.contract.yaml` - 场景互动项
- [ ] `user.contract.yaml` - 用户
- [ ] `user_profile.contract.yaml` - 用户资料

### 学习相关
- [ ] `user_learning_record.contract.yaml` - 学习记录
- [ ] `user_favorite.contract.yaml` - 用户收藏
- [ ] `user_achievement.contract.yaml` - 用户成就

### 内容管理
- [ ] `content_tag.contract.yaml` - 内容标签
- [ ] `content_resource.contract.yaml` - 内容资源（图片、音频等）

---

## 🔗 相关文档

- [契约规范详细说明](./CONTRACT_SPEC.md)
- [代码生成指南](../skills/code-generator/README.md)
- [数据库 Schema](../docs/database/schema.md)
- [API 文档](../docs/api/)

---

## 📊 统计信息

- 已定义契约: 1
- 待定义契约: 8
- 总计: 9
- 完成度: 11%

---

**维护者**: Development Team
**最后更新**: 2026-03-04
