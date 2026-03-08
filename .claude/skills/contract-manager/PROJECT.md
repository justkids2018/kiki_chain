# Contract Manager - Hi Kiki 契约规范

> **适用项目**: Hi Kiki
> **版本**: v1.0

---

## 🎯 Hi Kiki 契约规范

### 标准字段

所有实体必须包含:
```yaml
id:
  type: integer
  required: true
  rust: i64
  dart: int
  db: BIGSERIAL PRIMARY KEY

created_at:
  type: datetime
  required: true
  rust: DateTime<Utc>
  dart: DateTime
  db: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

updated_at:
  type: datetime
  required: true
  rust: DateTime<Utc>
  dart: DateTime
  db: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

deleted_at:
  type: datetime
  required: false
  rust: Option<DateTime<Utc>>
  dart: DateTime?
  db: TIMESTAMP NULL
```

### API 路径规范

- 移动端: `/api/v1/mobile/*`
- 管理后台: `/api/v1/admin/*`
- 共享: `/api/v1/auth/*` 或 `/api/v1/common/*`

### 权限规范

- `User`: 移动端用户权限
- `Admin`: 管理后台管理员权限
- `Public`: 无需认证

---

**版本**: v1.0
**维护者**: Development Team
