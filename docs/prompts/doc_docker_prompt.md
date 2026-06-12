你是一名资深 Flutter 全栈工程师和 Docker 部署专家，请帮我生成一个适合生产环境的 Flutter Web 项目打包与 Docker 部署方案。

## 项目需求：
1、 生成本地的docker 文件,构建docker镜像 以及配置 docker-compose.yml, 和nginx
2、 通过外部通过 域名： http:keepthinking.me  来请求


## 支持的环境
1、环境使用debian 来处理
2、云服务器 是linux-amd64 环境，需要docker 支持

## 输出
1、docker和nginx 的文件都放在frontend/目录下
2、文档也有放到frontend/目录下
3、要总结输出使用文档：名称为： flutter_web_deploy_{时间戳}.md
## 上下文说明
<!-- 1、docker-compose.yml文件中已经存在后端的配置，flutter web的配置直接往里面添加就可以 -->
2、加上详细的功能注释说明

## 规则
请一步一步输出：
- Dockerfile 内容
- nginx.conf 内容
- docker-compose.yml 内容
- 生成镜像要支持linux amd64，保存镜像文件并压缩
- 给出上传服务器命令和操作完整流程文档