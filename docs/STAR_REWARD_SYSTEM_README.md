# 🌟 星星奖励系统 - 完整实施方案

## 📋 概述

这是一个完整的学习激励系统，通过星星奖励机制鼓励儿童学习。系统包含前端、后端、数据库三层完整实现。

### 核心功能
- ✅ 星星奖励系统（1/3、2/3、3/3进度）
- ✅ 学习进度追踪和持久化
- ✅ 本地缓存 + 服务器同步
- ✅ 飞入动画和音效反馈
- ✅ 防刷机制（时间门槛 + 去重）
- ✅ 积分规则：1星 = 1积分

---

## 🏗️ 技术架构

```
┌─────────────────────────────────────────────────────┐
│                   Flutter前端                        │
│  - GetX状态管理                                      │
│  - SharedPreferences本地存储                         │
│  - Dio HTTP客户端                                    │
└─────────────────┬───────────────────────────────────┘
                  │ REST API
┌─────────────────▼───────────────────────────────────┐
│                Rust后端 (Axum)                       │
│  - Clean Architecture                               │
│  - SQLx数据库操作                                    │
│  - JWT认证                                          │
└─────────────────┬────────��──────────────────────────┘
                  │ PostgreSQL
┌─────────────────▼───────────────────────────────────┐
│              PostgreSQL数据库                        │
│  - user_scene_progress (场景进度)                   │
│  - learning_detail_logs (学习日志)                  │
│  - user_score_summary (用户汇总)                    │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 快速开始

### 1. 数据库部署

```bash
cd kiki_server

# 方式A: 自动部署脚本
./scripts/deploy_learning_system.sh

# 方式B: 手动执行SQL
psql -U postgres -d your_database -f migrations/001_create_learning_tables.sql
```

### 2. 后端启动

```bash
cd kiki_server

# 安装依赖并编译
cargo build --release

# 启动服务器
cargo run --release

# 服务器将在 http://localhost:8080 启动
```

### 3. 前端启动

```bash
cd kiki_web

# 安装依赖（首次）
flutter pub get

# 如果需要dio (已添加)
flutter pub add dio

# 运行应用
flutter run

# 或指定设备
flutter run -d chrome  # Web
flutter run -d macos   # macOS
```

### 4. 测试API

```bash
cd kiki_server

# 运行API测试脚本
./scripts/test_learning_api.sh
```

---

## 📡 API接口

### 1. 获取学习进度
```bash
GET /api/v1/learning/progress/{user_id}/{scene_id}
```

### 2. 批量提交进度
```bash
POST /api/v1/learning/progress/batch
Content-Type: application/json

{
  "user_id": "user_123",
  "scene_id": "kiki_zhiwuyuan",
  "learned_regions": [...],
  "stars_earned": 2,
  "is_completed": false,
  "study_time": 125
}
```

### 3. 获取用户汇总
```bash
GET /api/v1/learning/user/{user_id}/summary
```

详细API文档：[API文档](./star_reward_system_implementation.md#-api接口文档)

---

## 🎯 核心规则

### 星星奖励规则
| 进度 | 星星数 | 时间要求 |
|------|--------|----------|
| 33%  | 🌟     | 无       |
| 67%  | 🌟🌟   | 无       |
| 100% | 🌟🌟🌟 | ≥30秒    |

### 积分规则
- **1颗星 = 1积分**
- 总积分 = 所有场景获得的星星总数
- 重复学习不增加积分

### 防刷机制
1. 已学过的区域不重复计入
2. 必须听完发音才记录进度
3. 第3颗星需要停留≥30秒

---

## 📁 项目结构

```
kiki_chain/
├── kiki_server/                    # 后端服务
│   ├── migrations/
│   │   └── 001_create_learning_tables.sql  # 数据库迁移
│   ├── src/
│   │   ├── core/
│   │   │   ├── domain/learning/    # 领域模型
│   │   │   ├── repositories/learning/  # 仓储接口
│   │   │   └── use_cases/learning/ # 用例
│   │   └── adapters/
│   │       ├── persistence/learning_repository.rs  # 仓储实现
│   │       └── http/learning/      # HTTP handlers
│   └── scripts/
│       ├── deploy_learning_system.sh  # 部署脚本
│       └── test_learning_api.sh       # API测试脚本
│
├── kiki_web/                       # 前端应用
│   ├── lib/
│   │   ├── data/
│   │   │   ├── models/learning/    # 数据模型
│   │   │   └── services/learning/  # 服务层
│   │   └── presentation/
│   │       └── pages/interactive_image/  # 学习页面
│   └── assets/
│       └── audio/                  # 音效素材
│           ├── star_1.mp3
│           ├── star_2.mp3
│           ├── star_3_complete.mp3
│           └── blank_area_hint.mp3
│
└── docs/
    └── star_reward_system_implementation.md  # 完整文档
```

---

## 🧪 测试清单

### 功能测试
- [ ] 学习2个词获得1颗星
- [ ] 学习5个词获得2颗星
- [ ] 学习8个词 + 停留30秒获得3颗星
- [ ] 快速点击不刷星星（时间<30秒）
- [ ] 星星飞入动画正常播放
- [ ] 音效播放正确
- [ ] 退出保存进度
- [ ] 重新进入恢复进度
- [ ] 已完成场景显示金色星星

### API测试
```bash
# 运行自动化测试
./kiki_server/scripts/test_learning_api.sh
```

### 数据库测试
```sql
-- 查看进度数据
SELECT * FROM user_scene_progress;

-- 查看学习日志
SELECT * FROM learning_detail_logs ORDER BY learned_at DESC LIMIT 10;

-- 查看用户汇总
SELECT * FROM user_score_summary;
```

---

## 🔧 配置说明

### 后端配置 (.env)
```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=qiqimanyou
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password
```

### 前端配置
在 `lib/core/network/dio_client.dart` 中配置API地址：
```dart
baseUrl: 'https://your-api-domain.com',  // 修改为实际API地址
```

---

## 📊 数据库表结构

### user_scene_progress (场景进度表)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| user_id | VARCHAR(64) | 用户ID |
| scene_id | VARCHAR(128) | 场景ID |
| learned_regions | JSON | 已学习区域列表 |
| stars_earned | INT | 获得星星数(0-3) |
| total_score | INT | 总积分(=stars_earned) |
| is_completed | BOOLEAN | 是否完成 |

### learning_detail_logs (学习日志表)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| user_id | VARCHAR(64) | 用户ID |
| scene_id | VARCHAR(128) | 场景ID |
| region_id | VARCHAR(128) | 区域ID |
| learned_at | DATETIME | 学习时间 |

### user_score_summary (用户汇总表)
| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | VARCHAR(64) | 用户ID (主键) |
| total_stars | INT | 总星星数 |
| total_score | INT | 总积分 |
| completed_scenes | INT | 完成场景数 |

---

## 🐛 故障排查

### 问题1: 数据库连接失败
```bash
# 检查PostgreSQL是否运行
pg_isready -h localhost -p 5432

# 检查.env配置
cat kiki_server/.env
```

### 问题2: 后端编译错误
```bash
# 清理并重新编译
cd kiki_server
cargo clean
cargo build
```

### 问题3: 前端无法连接API
- 检查 `dio_client.dart` 中的 `baseUrl` 配置
- 确认后端服务器已启动
- 检查网络权限配置

### 问题4: 星星不亮
- 检查 `assets/audio/` 目录是否有音频文件
- 确认 `pubspec.yaml` 中已添加 `assets/audio/`
- 运行 `flutter pub get` 重新加载资源

---

## 📈 性能优化建议

1. **数据库优化**
   - 添加Redis缓存用户总积分
   - learned_regions字段使用GIN索引
   - 定期归档历史日志

2. **API优化**
   - 实现批量查询接口
   - 添加CDN加速音频文件
   - 使用连接池优化数据库连接

3. **前端优化**
   - 音频预加载
   - 动画性能优化
   - 本地缓存过期策略

---

## 📚 相关文档

- [完整实施文档](./star_reward_system_implementation.md)
- [API接口文档](./star_reward_system_implementation.md#-api接口文档)
- [数据库设计](../kiki_server/database/migrations/005_create_learning_tables.sql)

---

## ✅ 完成状态

- ✅ 数据库设计与迁移
- ✅ 后端API实现 (Rust + Axum)
- ✅ 前端UI和逻辑 (Flutter + GetX)
- ✅ 数据持久化 (本地 + 服务器)
- ✅ 音效素材生成
- ✅ 部署脚本
- ✅ 测试脚本
- ✅ 完整文档

**所有功能已实现！准备部署测试！** 🎉

---

## 📞 支持

如有问题，请查看：
1. [故障排查](#-故障排查)
2. [完整实施文档](./star_reward_system_implementation.md)
3. 运行测试脚本诊断问题
