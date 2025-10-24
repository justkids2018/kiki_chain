根据您的 docker-compose.yml 配置，我帮您梳理出所有的Docker日志查看命令：

## 📋 **Docker日志查看命令清单**

### **1. 查看所有容器状态**
```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 使用docker compose查看服务状态
docker compose ps
```

### **2. 查看各个服务的日志**

#### **前端服务 (Nginx + Flutter Web)**
```bash
# 查看前端容器日志
docker logs qiqimanyou-frontend

# 实时跟踪前端日志
docker logs -f qiqimanyou-frontend

# 查看最近50行日志
docker logs --tail 50 qiqimanyou-frontend

# 查看带时间戳的日志
docker logs -t qiqimanyou-frontend
```

#### **后端服务 (Rust API)**
```bash
# 查看后端容器日志
docker logs qiqimanyou-backend

# 实时跟踪后端日志
docker logs -f qiqimanyou-backend

# 查看最近50行日志
docker logs --tail 50 qiqimanyou-backend

# 查看带时间戳的日志
docker logs -t qiqimanyou-backend
```

#### **数据库服务 (PostgreSQL)**
```bash
# 查看数据库容器日志
docker logs postgres_db

# 实时跟踪数据库日志
docker logs -f postgres_db

# 查看最近50行日志
docker logs --tail 50 postgres_db
```

#### **证书服务 (Certbot)**
```bash
# 查看证书服务日志
docker logs certbot

# 实时跟踪证书服务日志
docker logs -f certbot
```

### **3. 使用docker-compose查看日志**
```bash
# 查看所有服务日志
docker compose logs

# 实时跟踪所有服务日志
docker compose logs -f

# 查看特定服务日志
docker compose logs frontend
docker compose logs backend
docker compose logs postgres
docker compose logs certbot

# 查看最近50行日志
docker compose logs --tail 50

# 查看特定服务的最近日志
docker compose logs --tail 50 backend
```

### **4. 进入容器内部检查**
```bash
# 进入前端容器
docker exec -it qiqimanyou-frontend sh

# 进入后端容器
docker exec -it qiqimanyou-backend sh

# 进入数据库容器
docker exec -it postgres_db psql -U qisd -d edadb

# 在容器内查看Nginx配置
docker exec qiqimanyou-frontend cat /etc/nginx/nginx.conf

# 在容器内查看Nginx错误日志
docker exec qiqimanyou-frontend cat /var/log/nginx/error.log
```

### **5. 网络和连接测试**
```bash
# 测试前端到后端的连接
docker exec qiqimanyou-frontend ping backend

# 测试前端到后端的端口连接
docker exec qiqimanyou-frontend telnet backend 8001

# 查看容器网络信息
docker network ls
docker network inspect frontend_qiqimanyou-network
```

### **6. 资源使用情况**
```bash
# 查看容器资源使用
docker stats

# 查看特定容器资源使用
docker stats qiqimanyou-backend qiqimanyou-frontend postgres_db
```

## 🎯 **针对502错误的重点检查顺序**

1. **首先检查后端服务状态和日志**：
   ```bash
   docker logs qiqimanyou-backend --tail 100
   ```

2. **检查前端Nginx日志**：
   ```bash
   docker logs qiqimanyou-frontend --tail 50
   ```

3. **检查容器间网络连通性**：
   ```bash
   docker exec qiqimanyou-frontend ping backend
   ```

4. **检查数据库连接状态**：
   ```bash
   docker logs postgres_db --tail 50
   ```

