# 腾讯云 Docker 部署指南 (Linux AMD64)

## 📋 部署概述
本文档指导如何在腾讯云 Linux AMD64 服务器上部署 qiqimanyou Flutter Web 应用

## 🏗️ 系统要求
- 腾讯云服务器：Linux AMD64 架构
- Docker Engine 20.10+
- Docker Compose 2.0+
- 域名：http://keepthinking.me
- 开放端口：80, 443

## 📦 文件清单
```
frontend/
├── qiqimanyou-flutter-web-amd64.tar.gz  # Docker 镜像文件 (24MB)
├── docker-compose.yml                   # 容器编排文件
├── nginx.conf                          # Nginx 配置文件
└── 腾讯云部署指南_AMD64.md              # 本文档
```

## 🚀 部署步骤

### 步骤 1: 上传文件到腾讯云服务器
```bash
# 使用 scp 上传文件到服务器
scp frontend/qiqimanyou-flutter-web-amd64.tar.gz  ubuntu@82.156.34.186:~/qisd_eda_college/frontend

scp frontend/docker-compose.yml  ubuntu@82.156.34.186:~/qisd_eda_college/

scp frontend/ssl/nginx.conf  ubuntu@82.156.34.186:~/qisd_eda_college/

scp frontend/nginx.conf  ubuntu@82.156.34.186:~/qisd_eda_college/

# 或者使用其他上传方式：宝塔面板、FTP 等
```

### 步骤 2: 在腾讯云服务器上操作
```bash
# 1. 连接服务器
ssh ubuntu@82.156.34.186

# 2. 部署目录
cd qisd_eda_college

# 3. 验证文件
ls -la
# 应该看到：qiqimanyou-flutter-web-amd64.tar.gz, docker-compose.yml, nginx.conf

# 4. 安装 Docker（如果还没安装）
curl -fsSL https://get.docker.com | bash
systemctl start docker
systemctl enable docker

# 5. 安装 Docker Compose（如果还没安装）
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 步骤 3: 导入 Docker 镜像
```bash
# 导入镜像
docker load < qiqimanyou-flutter-web-amd64.tar.gz

# 验证镜像
docker images | grep qiqimanyou-flutter-web
# 应该看到：qiqimanyou-flutter-web latest linux/amd64

# 验证架构
docker inspect qiqimanyou-flutter-web:latest | grep -A 2 "Architecture"
# 应该显示：Architecture: amd64, Os: linux
```

### 步骤 4: 启动应用
```bash
# 使用 Docker Compose 启动
docker compose up -d

docker compose down 

# 检查容器状态
docker-compose ps
# 应该显示：qiqimanyou-frontend running

# 查看日志
docker-compose logs -f frontend

# 查看image
sudo docker images

docker compose down
docker rm qiqimanyou-frontend
docker rmi qiqimanyou-flutter-web:latest
docker load < qiqimanyou-flutter-web-amd64.tar.gz
docker compose up -d

```

### 步骤 5: 配置域名解析
1. 在域名管理面板中，将 `keepthinking.me` 的 A 记录指向腾讯云服务器 IP
2. 等待 DNS 生效（通常 10-30 分钟）

### 步骤 6: 验证部署
```bash
# 1. 检查容器健康状态
docker ps
# STATUS 应该显示 healthy

# 2. 本地测试
curl -I http://localhost
# 应该返回 200 状态码

# 3. 外网测试
curl -I http://keepthinking.me
# 应该返回 200 状态码

# 4. 浏览器测试
# 访问 http://keepthinking.me 应该显示 Flutter Web 应用
```

## 🔧 维护命令

### 停止应用
```bash
cd /opt/qiqimanyou
docker-compose down
```

### 重启应用
```bash
cd /opt/qiqimanyou
docker-compose restart
```

### 更新应用
```bash
# 1. 上传新镜像
# 2. 导入新镜像
docker load < qiqimanyou-flutter-web-amd64.tar.gz
gunzip qiqimanyou-flutter-web-amd64.tar.gz

# 3. 重新启动
docker compose down
docker compose up -d
```

### 查看日志
```bash
# 实时日志
docker-compose logs -f frontend

# 历史日志
docker-compose logs frontend --tail 100

sudo docker compose logs frontend

```

## 🛠️ 故障排查

### 容器无法启动
```bash
# 检查容器状态
docker-compose ps

# 查看详细日志
docker-compose logs frontend

# 检查端口占用
netstat -tlnp | grep :80
```

### 域名无法访问
```bash
# 检查 DNS 解析
nslookup keepthinking.me

# 检查防火墙
ufw status
iptables -L

# 检查腾讯云安全组
# 确保开放 80 和 443 端口
```

### 性能优化
```bash
# 查看资源使用
docker stats

# 检查磁盘空间
df -h

# 清理无用镜像
docker system prune -a
```

## 📊 监控指标

### 应用状态检查
```bash
# HTTP 状态检查
curl -I http://keepthinking.me

# 健康检查
docker inspect qiqimanyou-frontend | grep Health

# 资源使用情况
docker stats qiqimanyou-frontend --no-stream
```

### 性能指标
- **容器启动时间**: ~30 秒
- **内存使用**: ~50MB
- **CPU 使用**: <5%
- **镜像大小**: 61MB (压缩后 24MB)

## 🔒 安全配置

### HTTPS 配置（可选）
```bash
# 安装 Certbot
apt install certbot

# 申请 SSL 证书
certbot certonly --standalone -d keepthinking.me

# 更新 nginx.conf 添加 SSL 配置
# 重启容器
docker-compose restart
```

### 防火墙配置
```bash
# UFW 配置
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw enable
```

## 📞 技术支持

### 联系信息
- 开发团队：Flutter 开发组
- 部署时间：2024年8月12日
- 架构版本：Linux AMD64
- Flutter 版本：3.7.12

### 常用资源
- Docker 官方文档：https://docs.docker.com/
- Nginx 配置指南：https://nginx.org/en/docs/
- 腾讯云文档：https://cloud.tencent.com/document

---

## 🎉 部署完成
恭喜！你已经成功在腾讯云上部署了 qiqimanyou Flutter Web 应用！
访问 http://keepthinking.me 开始使用吧！
