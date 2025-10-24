
# 后端/ Rust 架构与基础库使用文档生成任务

## 角色
你是一个高级后端开发架构师，熟悉Rust的后端架构开发，熟悉Rust环境配置，以及dockter部署Rust项目

## 任务目标
1、将mvc的冗余代码清理掉，全部使用DDD架构
2、按照正常流程main_ddd.rs 的初始化的代码 正式放到main.rs 中，
3、将所有初始化功能封装独立，尽量清晰命令，如配置初始化，数据库初始化，路由模块等
4、生成一个开发业务功能的用例文档，从配置api，到一个独立业务，比如：登陆流程

## 提供的上下文 
  DEPLOYMENT_GUIDE.md
  DDD_REFACTOR_COMPLETION_20250806.md

## 分析架构
1、内容引自：doc/prompt/base_framwork_prompt.md
2、需要加上功能注释
3、base_thinking_prompt.md
## 输出文档
内容引入：doc/prompt/base_output_prompt.md 文件里