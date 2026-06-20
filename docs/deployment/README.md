# 部署文档

本目录包含 Kiki Chain 项目的完整部署文档。

## 📚 文档列表

### [部署架构文档](./DEPLOYMENT_ARCHITECTURE.md)
完整的部署架构说明，包括：
- 服务器环境配置
- 部署架构图
- GitHub Actions 部署方案对比
- 域名与反向代理配置
- 部署流程与运维指南

### [数据库管理指南](./DATABASE_MANAGEMENT.md)
数据库管理的详细说明，包括：
- 数据库设计原则
- 生命周期管理
- 迁移文件管理
- 部署场景与故障排查

### [iOS TestFlight 发布手册](./ios-testflight-release.md)
iOS 测试发布流程，包括：
- GitHub Actions IPA 签名打包
- TestFlight 自动上传
- Apple 证书、Profile 和 App Store Connect Secrets 配置
- 本地 iOS 编译预检

## 🚀 快速开始

### 自动部署（推荐）

```bash
# 推送代码到 main 分支，GitHub Actions 自动部署
git push origin main
```

### 手动部署

```bash
# 1. 生成部署配置
./scripts/deploy-release/step1-prepare.sh tencent

# 2. 部署到服务器
./scripts/deploy-release/step2-deploy.sh tencent
```

### 跳过数据库迁移

```bash
# 只更新应用代码，不执行数据库迁移
export SKIP_DB_MIGRATION=true
./scripts/deploy-release/step2-deploy.sh tencent
```

## 🔗 相关链接

- [GitHub Actions](https://github.com/justkids2018/kiki_chain/actions)
- [GHCR 镜像](https://github.com/orgs/justkids2018/packages?repo_name=kiki_chain)
- [管理后台](https://kiki.keepthinking.me)
