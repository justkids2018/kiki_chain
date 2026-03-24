# Hi Kiki - 项目文档

## 目录结构

```
docs/
└── database/          # 数据库设计与迁移
    ├── init.sql       # 完整数据库初始化脚本
    ├── schema.md      # 表结构设计文档
    └── migrations/    # SQL 迁移文件
```

## 部署相关

部署文档和脚本统一在 `scripts/deploy/` 目录：

- **[部署手册](../scripts/deploy/DEPLOY-GUIDE.md)** — 完整部署流程、架构图、运维命令
- `deploy-all.sh` — 一键全量部署
- `deploy-backend.sh` — 后端部署
- `deploy-admin.sh` — 管理后台部署
- `deploy-db.sh` — 数据库迁移/备份/恢复

## 各端项目

| 项目 | 路径 | 技术栈 |
|------|------|--------|
| 移动端 | `kiki_web/` | Flutter (Clean Architecture + GetX) |
| 后端 | `kiki_server/` | Rust (Axum + sqlx + PostgreSQL) |
| 管理后台 | `kiki_admin/` | Vue 3 + Vite |
