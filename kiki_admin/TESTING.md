# Hi Kiki 管理后台测试指南

**更新时间**: 2026-03-16

---

## 🚀 服务状态

### 前端服务
- **地址**: http://localhost:5173
- **状态**: ✅ 运行中
- **启动命令**: `npm run dev`

### 后端服务
- **地址**: http://127.0.0.1:8081
- **状态**: ✅ 运行中
- **启动命令**: `cargo run`

---

## 🔐 测试账号

### 管理员账号 1
- **手机号**: `13900139002`
- **密码**: `admin123`
- **角色**: Admin (role_type=2)
- **用户ID**: admin_002

### 管理员账号 2
- **手机号**: `13900139000`
- **密码**: `test123`
- **角色**: Admin (role_type=2)
- **用户ID**: usr_test_002

---

## 🧪 API 测试

### 1. 登录获取 Token

```bash
curl -X POST http://127.0.0.1:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier": "13900139002", "password": "admin123"}'
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "uid": "admin_002",
    "name": "Admin User",
    "token": "eyJ0eXAiOiJKV1Q...",
    "role_type": 2
  }
}
```

### 2. 获取用户列表

```bash
TOKEN="your_token_here"
curl -X GET http://127.0.0.1:8081/api/v1/admin/users \
  -H "Authorization: Bearer $TOKEN"
```

### 3. 获取场景分类

```bash
curl -X GET http://127.0.0.1:8081/api/v1/admin/scene/categories \
  -H "Authorization: Bearer $TOKEN"
```

### 4. 获取场景列表

```bash
curl -X GET http://127.0.0.1:8081/api/v1/admin/scene/scenes \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🐛 问题修复记录

### 问题 1: admin_get_users_handler 类型不匹配 ✅ 已修复

**错误信息**:
```
error[E0308]: mismatched types
expected `AppState`, found `Arc<dyn UserRepository>`
```

**原因**:
路由配置中 `admin_get_users_handler` 使用了错误的状态类型。

**修复**:
```rust
// 修复前
.with_state(app_state.user_repository.clone())

// 修复后
.with_state(app_state.clone())
```

**文件**: `kiki_server/src/framework/bootstrap/routes/admin.rs:35`

---

## 📝 前端测试步骤

1. 打开浏览器访问 http://localhost:5173
2. 使用管理员账号登录：
   - 手机号：`13900139002`
   - 密码：`admin123`
3. 测试各个功能模块：
   - ✅ 数据总览 (Dashboard)
   - ✅ 用户管理 (Users)
   - ✅ 场景分类 (Categories)
   - ✅ 场景管理 (Scenes)
   - ✅ 场景物品 (Scene Items)

---

## 🔧 开发环境配置

### 环境变量
`.env.development`:
```
VITE_API_BASE_URL=http://127.0.0.1:8081
```

### 数据库
- **容器**: PostgreSQL 15
- **端口**: 5433:5432
- **数据库**: hikiki_db
- **用户**: postgres/postgres

---

## ✅ 验证清单

- [x] 后端服务正常启动
- [x] 前端服务正常启动
- [x] 登录功能正常
- [x] Token 认证正常
- [x] Admin API 权限验证正常
- [x] 用户列表 API 正常返回数据
