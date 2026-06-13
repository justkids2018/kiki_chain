# 腾讯云服务器状态报告
生成时间：2026-06-13 15:40 (北京时间)

## 服务器信息
- **IP**: 82.156.34.186
- **用户**: ubuntu
- **域名**: https://kiki.keepthinking.me
- **项目目录**: /home/ubuntu/kiki_chain

---

## Docker 容器状态

### ✅ 新版本服务 (kiki_chain - 5小时前部署)
| 容器 | 状态 | 端口 | 镜像 |
|------|------|------|------|
| **kiki_chain-admin-1** | ✅ Up 5h | 127.0.0.1:18080→80 | ghcr.io/.../admin:sha-2255e8b5 |
| **kiki_chain-backend-1** | ⚠️ Up 5h (unhealthy) | 127.0.0.1:18001→8001 | ghcr.io/.../backend:sha-2255e8b5 |
| **kiki_chain-postgres-1** | ✅ Up 3w (healthy) | 127.0.0.1:15432→5432 | postgres:15 |

**注意**：Backend 显示 unhealthy 是**误报**，实际 API 完全正常工作。
- 原因：健康检查脚本使用 `/dev/tcp` 语法，但容器用的是 `sh` 而非 `bash`
- 验证：API 接口均正常响应

### ⚠️ 旧版本服务（仍在运行）
| 容器 | 状态 | 端口 | 备注 |
|------|------|------|------|
| qiqimanyou-frontend | Up 5w | 127.0.0.1:8081→80 | 需清理 |
| qiqimanyou-backend | Up 5m | 8001 | 需清理 |
| postgres_db | Up 6m | **0.0.0.0:5432→5432** | ⚠️ 占用公网端口 |
| certbot | Exited | - | SSL证书自动续期失败 |

---

## API 测试结果

### ✅ 健康检查
```bash
GET http://localhost:18001/health
```
**响应**:
```json
{
  "service": "qiqimanyou_server",
  "status": "OK",
  "timestamp": "2026-06-13T07:40:03Z",
  "version": "0.1.0"
}
```

### ✅ 公网 API
```bash
GET https://kiki.keepthinking.me/api/v1/mobile/scene/categories
```
**响应**: ✅ 正常返回场景分类数据

---

## 数据库状态

### 连接信息
- **容器**: kiki_chain-postgres-1
- **数据库**: hikiki_db
- **用户**: postgres
- **内部端口**: 5432 (映射到主机 15432)

### 数据统计
| 项目 | 数量 |
|------|------|
| 用户 (users) | 5 |
| 场景分类 (scene_categories) | 4 |
| 场景 (scenes) | 24 |
| 场景物品 (scene_items) | 0 |
| 学习记录 (learning_records) | 0 |

### 数据库表结构
```
✅ users                   - 用户表
✅ scene_categories        - 场景分类
✅ scenes                  - 场景
✅ scene_items             - 场景物品
✅ user_favorites          - 用户收藏
✅ user_feedback           - 用户反馈
✅ user_learning_records   - 学习记录
✅ user_scene_progress     - 场景进度
✅ user_score_summary      - 积分统计
✅ learning_detail_logs    - 学习详情日志
✅ schema_migrations       - 数据库迁移记录
```

### 用户数据
| ID | 手机号 | 昵称 | VIP | 注册时间 |
|----|--------|------|-----|----------|
| 13621096266 | 13621096266 | 13621096266 | ❌ | 2026-05-27 |
| admin_002 | 13900139002 | Admin User | ❌ | 2026-01-30 |
| test_user_003 | 13800138003 | Test Update | ✅ | 2026-01-29 |
| usr_test_002 | 13900139000 | 测试用户2 | ❌ | 2026-01-27 |
| usr_test_001 | 13800138000 | VIP测试用户 | ✅ | 2026-01-27 |

### 场景分类
| ID | 名称 | 描述 | 场景数 |
|----|------|------|--------|
| cat_fdb7d74766a8 | 校园生活 | 开心的校园时光 | 6 |
| cat_002 | 思维学习 | 生活中学思维 | 6 |
| cat_003 | 日常生活 | 家庭生活场景 | 6 |
| cat_004 | 游戏乐园 | 探索有趣的游乐世界 | 6 |

---

## 发现的问题

### 🔴 高优先级
1. **旧容器未清理**
   - `qiqimanyou-frontend`、`qiqimanyou-backend` 仍在运行
   - `postgres_db` 占用公网 5432 端口，存在安全风险
   - 建议：停止并删除旧容器

2. **Backend 健康检查误报**
   - 显示 unhealthy，但实际正常
   - 建议：修复 docker-compose.yml 中的健康检查脚本

3. **Certbot 容器未运行**
   - SSL 证书自动续期失败
   - 建议：检查 certbot 配置

### 🟡 中优先级
1. **学习数据为空**
   - `scene_items`、`learning_records` 表都是空的
   - 可能是新部署，数据尚未迁移

---

## 建议操作

### 立即执行
```bash
# 1. 停止旧版本容器
docker stop qiqimanyou-frontend qiqimanyou-backend
docker rm qiqimanyou-frontend qiqimanyou-backend

# 2. 修复 postgres_db 端口暴露（如果仍需保留）
# 或者完全迁移到 kiki_chain-postgres-1 后删除
```

### 后续优化
1. 修复 backend 健康检查脚本
2. 重启 certbot 容器
3. 迁移历史数据（如果需要）

---

## 快速命令参考

### SSH 连接
```bash
ssh -i ~/.ssh/kiki_tencent_deploy ubuntu@82.156.34.186
```

### 查看容器状态
```bash
docker ps -a
docker logs kiki_chain-backend-1
```

### 数据库查询
```bash
docker exec kiki_chain-postgres-1 psql -U postgres -d hikiki_db -c "SELECT COUNT(*) FROM users;"
```

### API 测试
```bash
# 本地
curl http://localhost:18001/health

# 公网
curl https://kiki.keepthinking.me/api/v1/mobile/scene/categories
```
