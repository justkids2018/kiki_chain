# Hi Kiki - 认证接口API文档

> 版本：v1.0 | 日期：2026-01-18 | Base URL: `http://127.0.0.1:8080/api`

---

## 1. 用户注册

### 接口信息
- **URL**: `POST /auth/register`
- **说明**: 注册新用户，注册成功后自动返回Token
- **需要Token**: 否

### 请求参数
```json
{
  "phone": "13800138000",          // 必填，11位手机号
  "password": "abc123456",         // 必填，6-20位，需包含字母和数字（前端SHA256加密后传输）
  "nickname": "小明"               // 可选，2-20字符，默认"用户{手机号后4位}"
}
```

### 响应示例（成功）
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "user": {
      "id": "usr_1a2b3c4d",
      "phone": "13800138000",
      "nickname": "小明",
      "avatar": null,
      "createdAt": "2026-01-18T10:30:00Z",
      "lastLoginAt": "2026-01-18T10:30:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresAt": "2026-01-25T10:30:00Z"  // Token过期时间（7天后）
  }
}
```

### 响应示例（失败）
```json
{
  "code": 400,
  "message": "该手机号已注册",
  "data": null
}
```

### 错误码
| code | message | 说明 |
|------|---------|------|
| 400 | 该手机号已注册 | 手机号已存在 |
| 400 | 手机号格式不正确 | 手机号不是11位数字 |
| 400 | 密码格式不正确 | 密码不符合规则 |

---

## 2. 用户登录

### 接口信息
- **URL**: `POST /auth/login`
- **说明**: 用户登录
- **需要Token**: 否

### 请求参数
```json
{
  "phone": "13800138000",
  "password": "abc123456"  // SHA256加密后传输
}
```

### 响应示例（成功）
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "user": {
      "id": "usr_1a2b3c4d",
      "phone": "13800138000",
      "nickname": "小明",
      "avatar": null,
      "createdAt": "2026-01-18T10:30:00Z",
      "lastLoginAt": "2026-01-18T12:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresAt": "2026-01-25T12:00:00Z"
  }
}
```

### 响应示例（失败）
```json
{
  "code": 401,
  "message": "手机号或密码错误",
  "data": null
}
```

### 错误码
| code | message | 说明 |
|------|---------|------|
| 401 | 手机号或密码错误 | 认证失败 |
| 429 | 密码错误次数过多，请15分钟后重试 | 连续5次密码错误，账号被锁定 |

---

## 3. 刷新Token

### 接口信息
- **URL**: `POST /auth/refresh-token`
- **说明**: 在Token即将过期时刷新Token（过期前1天自动刷新）
- **需要Token**: 是

### 请求头
```
Authorization: Bearer {token}
```

### 请求参数
无（从Token中解析用户ID）

### 响应示例（成功）
```json
{
  "code": 200,
  "message": "Token刷新成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresAt": "2026-02-01T12:00:00Z"
  }
}
```

### 响应示例（失败）
```json
{
  "code": 401,
  "message": "Token已过期，请重新登录",
  "data": null
}
```

---

## 4. 验证Token

### 接口信息
- **URL**: `GET /auth/verify`
- **说明**: 验证Token是否有效（用于App启动时的自动登录）
- **需要Token**: 是

### 请求头
```
Authorization: Bearer {token}
```

### 响应示例（成功）
```json
{
  "code": 200,
  "message": "Token有效",
  "data": {
    "valid": true,
    "userId": "usr_1a2b3c4d",
    "expiresAt": "2026-01-25T12:00:00Z"
  }
}
```

### 响应示例（失败）
```json
{
  "code": 401,
  "message": "Token无效或已过期",
  "data": {
    "valid": false
  }
}
```

---

## 通用错误码

| code | message | 说明 |
|------|---------|------|
| 200 | 成功 | 请求成功 |
| 400 | 参数错误 | 请求参数格式错误 |
| 401 | 未授权 | Token无效或过期 |
| 429 | 请求过于频繁 | 触发限流 |
| 500 | 服务器错误 | 内部错误 |

---

## 前端集成建议

### Token存储
```dart
// 使用 flutter_secure_storage 安全存储Token
final storage = FlutterSecureStorage();

// 保存Token
await storage.write(key: 'access_token', value: token);
await storage.write(key: 'token_expires_at', value: expiresAt);

// 读取Token
String? token = await storage.read(key: 'access_token');
```

### 自动刷新Token
```dart
// 在Token过期前1天自动刷新
final expiresAt = DateTime.parse(await storage.read(key: 'token_expires_at'));
final now = DateTime.now();

if (expiresAt.difference(now).inHours < 24) {
  // 刷新Token
  await refreshToken();
}
```

### 请求拦截器（Dio）
```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    // 自动添加Token到请求头
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) async {
    // Token过期时自动跳转登录页
    if (error.response?.statusCode == 401) {
      Get.offAllNamed('/login');
    }
    return handler.next(error);
  },
));
```

---

**后端实现要点**：
- JWT生成与验证（使用`jsonwebtoken`库）
- 密码使用bcrypt加盐哈希存储
- 登录失败次数限制（使用Redis计数器，15分钟过期）
- Token黑名单机制（退出登录时加入黑名单）
