# deploy-release 运行手册（当前有效）

## 适用范围

本手册适用于当前生产发布流程：

- 本地 Step1 生成部署产物
- 远端 Step2 同步最小部署资产并发布
- 运行时仅使用镜像，不在服务器构建源码

## 前置条件

1. 已将目标镜像推送到 GHCR
2. 本地可 SSH 到服务器
3. profile 配置正确（默认 `tencent`）

## 标准发布流程

1. 更新镜像版本（必做）

```bash
./scripts/deploy-release/update-image-version.sh sha-<8位commit>
```

2. 生成部署产物（本地）

```bash
./scripts/deploy-release/step1-prepare.sh tencent
```

3. 执行发布（远端）

```bash
./scripts/deploy-release/step2-deploy.sh tencent
```

4. 发布后校验

```bash
./scripts/deploy-release/status.sh tencent
./scripts/deploy-release/check-remote-layout.sh tencent
```

## 首次域名接入

```bash
./scripts/deploy-release/install-host-nginx.sh tencent
```

## 数据库操作

单独执行数据库发布（备份 + 增量迁移）：

```bash
./scripts/deploy-release/db-release.sh tencent
```

## 发布产物位置

- 当前发布产物：`scripts/deploy-release/deploy_files/latest/`
- 历史快照：`scripts/deploy-release/deploy_files/releases/<artifact_id>/`

## 约束

1. 禁止在生产执行 `docker compose down -v`
2. 发布前必须确认 `deploy-manifest.txt`
3. 远端目录必须保持整洁，仅允许：
   - `./backups`
   - `./scripts`
   - `./scripts/deploy-release`
