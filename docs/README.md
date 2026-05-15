# Hi Kiki - 项目文档

## 目录结构

```
docs/
├── tts/               # TTS 与 sherpa_onnx 文档
│   ├── README.md      # TTS 文档索引
│   ├── flutter_sherpa_onnx_integration.md
│   ├── tts_local_model_usage.md
│   ├── tts_implementation_report.md
│   └── tts_sherpa_onnx_optimization_plan.md
└── database/          # 数据库设计与迁移
    ├── init.sql       # 完整数据库初始化脚本
    ├── schema.md      # 表结构设计文档
    └── migrations/    # SQL 迁移文件
```

## TTS 文档

- **[TTS 文档索引](./tts/README.md)** — 统一查看 sherpa_onnx 与 TTS 相关文档

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
