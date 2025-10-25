你是一名 **Rust 后端 + Docker 部署专家**，请帮我生成 **Rust + Tokio 后端服务的生产环境部署配置**。

### 1. 上下文（Context）
- 项目类型：Rust + Tokio（Axum）
- 当前进度：已有代码 + 已在 docker-compose 中配置前端
- 运行环境：
  - 系统：Ubuntu 22.04 / Debian 12
  - 架构：linux/amd64
  - 云服务商：腾讯云 / 阿里云
- 依赖关系：
  - 数据库：PostgreSQL
  - Redis：可选
  - 前端：Flutter Web，已用 nginx 做反向代理
- 现有架构：
  - 一个统一的 docker-compose.yml
  - Nginx 只在前端使用（反向代理 /api → 后端）
  - 后端和数据库在同一 docker 网络

---

### 2. 目标（Goal）
- 生成以下内容：
  1. **多阶段构建的 Dockerfile**（编译 + 精简运行时）
  2. **docker-compose.yml 后端服务配置部分**（兼容现有网络，不影响前端）
  3. **本地构建镜像脚本→ 创建 → 生成镜像 → 保存镜像-压缩镜像**
  4. **上传服务器脚本 → 镜像配置文件 → 上传云服务器 → 解压 →执行 docker compose**
  5. **部署注意事项**（常见问题 + 解决方案）
- 最终效果：
  - 后端可在生产环境稳定运行
  
  - 镜像尽量小（使用 debian:bookworm-slim,优先判断本地，如果本地没有，下拉起在执行构建脚本）

---

### 3. 约束条件（Constraints）
- 所有文件必须放在：[backtend/ 目录]
- Dockerfile 必须：
  - 使用多阶段构建（builder + runtime）
  - 固定 `--platform=linux/amd64`
  - 安装必要的系统依赖（如 `libssl-dev`、`pkg-config`）
- 镜像体积尽量小
- docker-compose.yml：
  - 后端只 `expose` 端口，不直接映射到宿主机
  - 必须加入现有网络（例如 `qiqimanyou-network`）
- 构建命令需包含：
  - 本地构建
  - 导出 tar
  - 压缩（可选）
  - scp 上传
  - 云服务器 docker load
  - docker compose up -d 重启
- 所有命令行要加中文解释
- 可以借鉴已经存在的文件，可进行优化和修改
---

### 4. 输出结构（Output Structure）
1. **Dockerfile**（带中文注释）
2. **docker-compose.yml**（仅后端部分，优化也是在当前文件，不要创建其他文件）
3. **部署命令脚本**（包含构建，和保存镜像生成tar文件，压缩文件，上传云服务器）
4. **使用说明文档**（markdown，文件名：`部署文档_{时间戳}.md`，`云上传文档_{时间戳}.md`）
5. **每次优化都是在上面对于文件优化，不创建新的文件**

---

### 提供已知内容：
#### 云服务器配置
```
1、ssh ubuntu@82.156.34.186
目录：
qisd_eda_college/backend 后端

```
#### 借鉴配置：docker-compose.yml
整合配置后的docker-composebackend目录下的docker-compose-all.yml，可以作为参考


### 5. 规则（Rules）
- 每个代码块独立输出
- 重要变量（如数据库连接、JWT_SECRET）用占位符
- 部署过程中的坑要提前说明
- 最终结果必须可直接运行

---

## 执行逻辑
1. 根据 Rust 项目名自动替换 Dockerfile 中的可执行文件名
2. 根据已知 docker 网络名称替换 docker-compose.yml 的 `networks`
3. 构建时强制指定 `--platform=linux/amd64`
4. 部署命令必须全流程可执行