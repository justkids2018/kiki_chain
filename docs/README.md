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

当前部署文档和脚本统一在 `scripts/deploy-release/` 与 `docs/deployment/`：

- **[发布流程手册](../scripts/deploy-release/README.md)** — 当前权威部署流程（镜像发布 + 两步部署）
- **[运行手册（执行版）](./deployment/deploy-release-runbook.md)** — 运维执行最短路径
- **[正式部署流程](./deployment/kiki_chain_正式部署流程.md)** — 团队执行版流程说明
- **[统一配置方案](./deployment/docker_统一配置部署方案.md)** — 方案设计与演进记录

常用脚本：

- `step1-prepare.sh` — 生成部署产物（deploy.env / deploy-manifest.txt）
- `step2-deploy.sh` — 同步最小部署资产并执行发布
- `update-image-version.sh` — 更新本次发布镜像 tag 记录
- `db-release.sh` — 数据库备份 + 增量迁移
- `status.sh` — 运行状态检查
- `check-remote-layout.sh` — 远端目录整洁度检查

## 各端项目

| 项目 | 路径 | 技术栈 |
|------|------|--------|
| 移动端 | `kiki_web/` | Flutter (Clean Architecture + GetX) |
| 后端 | `kiki_server/` | Rust (Axum + sqlx + PostgreSQL) |
| 管理后台 | `kiki_admin/` | Vue 3 + Vite |
