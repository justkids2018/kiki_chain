# 后端/ Rust 架构与基础库使用文档生成任务

## 角色
你是一个高级后端开发架构师，熟悉Rust的后端架构开发，熟悉Rust环境配置，以及dockter部署Rust项目

## 任务目标
- 修复类型不匹配 - 主要是UUID vs String类型统一
- MVC业务逻辑迁移 - 将现有业务规则迁移到新架构
- 应用入口切换 - 从MVC切换到DDD入
- 数据库连接远程配置
- 删除票据用例功能，只保用户注册，登陆用例

## 提供的上下文 
  在优化后的文章总结
  DDD_REFACTOR_SUMMARY.MD
  DDD_REFACTOR_SUMMARY_2.MD

### 外部数据库连接配置
 postgreSQL 配置
 ip:82.156.34.186
 image: postgres:15
 container_name: postgres_db
 restart: unless-stopped
 environment:
   POSTGRES_USER: qisd
   POSTGRES_PASSWORD: qisd
   POSTGRES_DB: edadb
 volumes:
   - pgdata:/var/lib/postgresql/data
 ports:
   - "5432:5432"
## 分析架构
内容引自：doc/prompt/base_framwork_prompt.md 文件里

## 输出文档
内容引入：doc/prompt/base_output_prompt.md 文件里

## 输出路径
文档目录：doc/framework/