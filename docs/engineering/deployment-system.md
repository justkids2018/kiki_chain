# 部署体系与云厂商可移植性

## 目标

保留当前已经跑通的 GitHub Actions + GHCR + 腾讯云部署链路，同时把云厂商差异、部署编排和业务事实源拆开，为后续迁移到 AWS、GCP 或其他云厂商降低成本。

## 当前发布模型

当前生产发布采用两步法：

```text
Step1: 本地或 GitHub Actions 生成部署产物
Step2: 远端拉镜像、执行数据库发布、启动服务
```

当前主入口：

- `.github/workflows/docker-release.yml`
- `scripts/deploy-release/step1-prepare.sh`
- `scripts/deploy-release/step2-deploy.sh`
- `scripts/deploy-release/db-release.sh`
- `scripts/deploy-release/profiles/tencent.env`

## 目录职责

| 路径 | 职责 |
|---|---|
| `.github/workflows/` | CI/CD 触发、镜像构建、发布任务编排 |
| `scripts/deploy-release/` | 发布脚本、compose、profile、nginx 模板 |
| `scripts/deploy-release/profiles/` | 云厂商和环境差异 |
| `scripts/deploy-release/deploy_files/` | 发布产物和快照 |
| `docs/deployment/` | 当前项目部署运行手册 |
| `kiki_server/database/` | 数据库事实源，部署脚本执行它 |

部署脚本不拥有业务 schema，不定义 API 契约，不包含业务实现。

## 云厂商扩展规则

新增云厂商时，优先新增 profile，而不是复制整套脚本：

```text
scripts/deploy-release/profiles/
├── tencent.env
├── aliyun.env
├── aws.env
└── gcp.env
```

profile 负责差异：

- SSH 用户和主机
- 远端目录
- 域名
- 端口
- 镜像 tag
- 证书域名
- 云厂商特有的运行参数

通用发布步骤继续留在 `step1-prepare.sh`、`step2-deploy.sh` 和 `db-release.sh`。

## GitHub Actions 职责

GitHub Actions 负责：

- 校验
- 构建镜像
- 推送 GHCR
- 生成发布产物
- 调用部署脚本
- 输出发布摘要

GitHub Actions 不应直接散写远端部署逻辑。远端部署逻辑应收敛到 `scripts/deploy-release/`，确保本地也能复现。

## 发布安全边界

禁止默认执行：

- `docker compose down -v`
- 删除数据库 volume
- 未备份的数据迁移
- 未确认的生产目录删除
- force push 触发生产发布

高风险操作必须单独确认影响范围和回滚方案。

## 验证要求

部署脚本变更后至少验证：

- Step1 能生成 `deploy.env` 和 `deploy-manifest.txt`。
- Step2 的 SSH、同步、compose 命令路径仍正确。
- 数据库发布逻辑仍会先备份再迁移。
- 后端健康检查可执行。
- Admin/API/Main URL 在发布摘要中可定位。

本轮工程文档收口不改脚本。脚本迁移必须作为后续独立阶段执行。
当前 deploy-release 数据库发布脚本已切换为同步并执行 `kiki_server/database/`。旧 `scripts/deploy-release/db/` 暂时保留，待发布验证和引用清理完成后删除。
