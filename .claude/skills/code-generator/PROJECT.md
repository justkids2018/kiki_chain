# Code Generator - Hi Kiki 代码生成规范

> **适用项目**: Hi Kiki
> **版本**: v1.0

---

## 🎯 Hi Kiki 代码生成规范

### 后端代码结构

```
kiki_server/src/
├── core/
│   ├── entities/[entity_name].rs
│   ├── ports/[entity_name]_repository.rs
│   └── use_cases/[entity_name]s/
├── adapters/
│   ├── persistence/postgres/[entity_name]_repository.rs
│   └── http/[entity_name]s/handlers.rs
└── framework/
    └── bootstrap/routes/[entity_name]s.rs
```

### 前端代码结构

```
kiki_web/lib/
├── domain/
│   ├── entities/[entity_name].dart
│   └── repositories/i_[entity_name]_repository.dart
└── data/
    └── services/[entity_name]_api_service.dart
```

### 命名规范

- Entity: `PascalCase` (Scene, UserProfile)
- File: `snake_case.rs` / `snake_case.dart`
- Table: `snake_case` (scenes, user_profiles)
- API: `kebab-case` (/user-profiles)

---

**版本**: v1.0
**维护者**: Development Team
