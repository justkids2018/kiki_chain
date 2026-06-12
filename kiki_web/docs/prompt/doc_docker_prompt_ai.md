你是一名[领域]的专家（如：Flutter 全栈工程师 + Docker 部署专家），请帮我生成[目标]。

## 1. 上下文（Context）
- 项目类型： [Flutter Web ]
- 当前进度： [已有部分配置 / 从零开始 ...]
- 运行环境：
  - 系统： [Debian 12 / Ubuntu 22.04]
  - 架构： [linux/amd64 ]
  - 云服务商： [腾讯云 ]
- 依赖关系：
  - 是否有数据库？[PostgreSQL]
  - 是否已有后端服务？[是]
  - 是否已有 docker-compose？[是]

## 2. 目标（Goal）
- 需要生成的内容：
  1. [Dockerfile]
  2. [nginx.conf]
  3. [docker-compose.yml]
  4. [部署命令]
  5. [使用说明文档]

- 最终效果：
  - 可以通过[域名或 IP]访问 域名：http:keepthing.me
  - 容器可在生产环境稳定运行
## 提供的赏析下文
  - [frontend/ 目录]下生成来相关文件，可以先读区，然后在根据要求进行修改

## 3. 约束条件（Constraints）
- Docker 基础镜像用：[如 FROM debian:bookworm-slim  或 nginx:alpine] ，同时也要是Linux AMD64 架构
- 所有文件必须放在：[frontend/ 目录]
- docker-compose.yml 不覆盖已有的后端配置，只新增前端服务
- 代码、配置文件必须带详细中文注释
- 生成的镜像的命令必须兼容 Linux AMD64 架构，镜像文件也要支持Linux AMD64 
- Flutter SDK环境和版本都在本地已经有，直接引用本地，不需要下载
## 4. 输出结构（Output Structure）
请分步骤输出：
1. Dockerfile（带中文注释）
2. nginx.conf（带中文注释）
3. docker-compose.yml（合并后端配置）
4. 本地构建镜像命令：包含构建，和保存镜像生成tar文件，压缩文件
5. 使用说明文档（markdown，文件名：`部署文档_{时间戳}.md`）【docker-创建-保存-压缩-上传云服务器】

## 5. 规则（Rules）
- 每个步骤单独代码块输出，方便复制
- 每个命令行都写解释
- 可能的坑和解决方案提前说明
- 重要环境变量用占位符标明
- 最终结果必须可在生产环境直接运行

## 检查
- 执行一步要确定没有错误，再执行下一步