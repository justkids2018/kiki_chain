# 通用代码实现规范 (Common Implementation Standards)

> **适用范围**: 所有编程语言和项目
> **版本**: v1.0
> **最后更新**: 2026-01-19

---

## 📚 概述

本文档定义了**跨语言通用**的代码实现规范和最佳实践。无论使用什么编程语言（Rust、Python、Java、Go），都应遵循这些原则。

**项目特定规范**: 请查看 [`PROJECT.md`](./PROJECT.md)

---

## 🏗️ 架构模式

### Clean Architecture（整洁架构）

#### 核心原则

1. **依赖倒置（Dependency Inversion）**
   - 内层不依赖外层
   - 高层模块不依赖低层模块，两者都依赖抽象

2. **分层清晰**
   - 每一层只与相邻层通信
   - 外层实现内层定义的接口

#### 典型分层

```
┌─────────────────────────────────────┐
│   Framework Layer (框架层)          │  ← 启动、配置、路由
│   - Web Framework                   │
│   - DI Container                    │
└─────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────┐
│   Adapter Layer (适配器层)          │  ← 技术实现
│   - HTTP Handlers                   │
│   - Database Repository             │
│   - External API Clients            │
└─────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────┐
│   Core Layer (核心层)                │  ← 业务逻辑
│   - Entities (实体)                  │
│   - Use Cases (用例)                 │
│   - Ports (接口定义)                 │
└─────────────────────────────────────┘
```

**依赖方向**: Framework → Adapter → Core（外层依赖内层）

---

### Use Case 模式

#### 定义
Use Case（用例）是**业务流程的编排者**，负责协调多个实体和服务完成特定业务目标。

#### 典型结构

```
┌────────────────────────────────────┐
│   Use Case（用例）                  │
│                                    │
│   Input:  Command/Request DTO      │
│   Output: Response DTO             │
│                                    │
│   Steps:                           │
│   1. 验证输入                       │
│   2. 调用 Repository 获取数据       │
│   3. 执行业务逻辑                   │
│   4. 调用 Repository 保存数据       │
│   5. 返回结果                       │
└────────────────────────────────────┘
```

#### 示例（伪代码）

```
class LoginUserUseCase {
    constructor(userRepository) {
        this.userRepository = userRepository;
    }

    async execute(command) {
        // 1. 验证输入
        this.validateCommand(command);

        // 2. 查找用户
        user = await this.userRepository.findByPhone(command.identifier);
        if (!user) throw AuthenticationError("用户不存在");

        // 3. 验证密码
        if (!user.verifyPassword(command.password)) {
            throw AuthenticationError("密码错误");
        }

        // 4. 更新时间戳
        user.updateTimestamp();
        await this.userRepository.save(user);

        // 5. 生成 Token
        token = generateToken(user);

        return { user, token };
    }
}
```

---

### Repository 模式

#### 定义
Repository 是**数据访问的抽象层**，隐藏数据存储的具体实现。

#### 核心价值

1. **抽象数据源**：业务逻辑不关心数据来自 SQL、NoSQL 还是内存
2. **易于测试**：可以用 Mock Repository 替换真实数据库
3. **单一职责**：Repository 只负责数据访问，不包含业务逻辑

#### 典型接口

```
interface UserRepository {
    async save(user);
    async findById(id);
    async findByEmail(email);
    async delete(id);
}
```

---

## 🔤 命名规范（通用原则）

### 1. 模块/文件命名

**原则**:
- 使用小写字母
- 多个单词用分隔符连接（`_` 或 `-`，取决于语言习惯）
- 名词为主

**示例**:
```
✅ user_repository    (推荐: snake_case)
✅ user-repository    (可选: kebab-case)
❌ UserRepository     (错误: 用于类型名，不用于文件名)
```

---

### 2. 类型/类命名

**原则**:
- 使用 PascalCase（首字母大写驼峰）
- 名词为主
- 清晰表达用途

**示例**:
```
✅ UserRepository
✅ LoginUserUseCase
✅ AuthenticationError
❌ userrepository    (错误: 全小写)
❌ userRepository    (错误: camelCase 用于变量)
```

---

### 3. 函数/方法命名

**原则**:
- 使用 camelCase（首字母小写驼峰） 或 snake_case（取决于语言）
- 动词开头
- 表达行为

**示例**:
```
✅ findUserById      (camelCase)
✅ find_user_by_id   (snake_case)
✅ verifyPassword
✅ validate_command
❌ user              (错误: 没有动词)
❌ FindUser          (错误: 首字母大写用于类型)
```

---

### 4. 变量命名

**原则**:
- 使用 camelCase 或 snake_case
- 名词为主
- 有意义的名称

**示例**:
```
✅ userName
✅ user_name
✅ isValid
✅ maxRetryCount
❌ x, y, z           (错误: 无意义)
❌ UserName          (错误: 首字母大写用于类型)
```

---

### 5. 常量命名

**原则**:
- 使用 SCREAMING_SNAKE_CASE（全大写 + 下划线）
- 表达不可变值

**示例**:
```
✅ MAX_RETRY_COUNT
✅ DEFAULT_TIMEOUT
✅ API_BASE_URL
❌ maxRetryCount     (错误: 用于变量)
```

---

## ⚠️ 错误处理规范

### 原则

1. **不要忽略错误**
   - 所有可能失败的操作都要处理错误
   - 不要使用空的 catch 块

2. **向上传播错误**
   - 底层函数抛出错误
   - 中间层传播错误
   - 顶层统一处理

3. **提供上下文信息**
   - 错误消息要有意义
   - 包含必要的上下文（如用户 ID、操作类型）

---

### 错误分类

#### 1. 验证错误（Validation Error）
**定义**: 输入数据不符合要求

**示例**:
- 必填字段为空
- 数据格式错误（邮箱格式、手机号格式）
- 数值超出范围

**HTTP 状态码**: `400 Bad Request`

---

#### 2. 认证/授权错误（Authentication/Authorization Error）
**定义**: 用户身份验证失败或权限不足

**示例**:
- 用户名或密码错误
- Token 过期
- 没有权限访问资源

**HTTP 状态码**: `401 Unauthorized` (认证失败), `403 Forbidden` (权限不足)

---

#### 3. 资源未找到错误（Not Found Error）
**定义**: 请求的资源不存在

**示例**:
- 用户 ID 不存在
- 文章不存在

**HTTP 状态码**: `404 Not Found`

---

#### 4. 业务逻辑错误（Business Logic Error）
**定义**: 违反业务规则

**示例**:
- 余额不足
- 重复注册
- 订单状态不允许退款

**HTTP 状态码**: `422 Unprocessable Entity` 或 `409 Conflict`

---

#### 5. 基础设施错误（Infrastructure Error）
**定义**: 外部系统或基础设施故障

**示例**:
- 数据库连接失败
- 第三方 API 调用超时
- 文件系统错误

**HTTP 状态码**: `500 Internal Server Error` 或 `503 Service Unavailable`

---

### 错误处理模式（伪代码）

```
// ✅ 好的错误处理
async function getUserById(id) {
    try {
        const user = await repository.findById(id);
        if (!user) {
            throw new NotFoundError(`用户不存在: id=${id}`);
        }
        return user;
    } catch (error) {
        if (error instanceof DatabaseError) {
            throw new InfrastructureError(`数据库查询失败: ${error.message}`);
        }
        throw error;  // 重新抛出未知错误
    }
}

// ❌ 不好的错误处理
async function getUserById(id) {
    try {
        return await repository.findById(id);
    } catch (error) {
        console.log(error);  // ❌ 只打印日志，不处理
        return null;         // ❌ 吞掉错误，返回 null
    }
}
```

---

## 🔐 安全规范

### 1. SQL 注入防护

**原则**: 永远不要拼接 SQL 字符串

```
❌ 错误：字符串拼接
query = "SELECT * FROM users WHERE phone = '" + phone + "'";

✅ 正确：参数化查询
query = "SELECT * FROM users WHERE phone = ?";
execute(query, [phone]);
```

---

### 2. 密码安全

**原则**:
1. 永远不要明文存储密码
2. 使用强加密算法（bcrypt、argon2）
3. 加盐（salt）

```
❌ 错误：明文存储
user.password = "123456";

✅ 正确：加密存储
user.password = bcrypt.hash("123456", saltRounds);
```

---

### 3. 认证 Token

**原则**:
1. 使用行业标准（JWT、OAuth2）
2. 设置合理的过期时间
3. 不在 Token 中存储敏感信息

---

### 4. XSS 防护

**原则**: 对所有用户输入进行转义

```
❌ 错误：直接输出
html = "<div>" + userInput + "</div>";

✅ 正确：转义输出
html = "<div>" + escape(userInput) + "</div>";
```

---

## 📝 日志记录规范

### 日志级别

| 级别 | 用途 | 示例 |
|------|------|------|
| **DEBUG** | 调试信息 | 打印变量值、函数调用 |
| **INFO** | 关键操作 | 用户登录、订单创建 |
| **WARN** | 警告（可恢复） | 重试失败、降级策略 |
| **ERROR** | 错误（需关注） | 数据库连接失败、API 调用失败 |

---

### 日志内容

**必须包含**:
- 时间戳
- 日志级别
- 操作描述
- 关键上下文（用户 ID、订单 ID 等）

**示例**:
```
✅ 好的日志
INFO  [2026-01-19 10:30:45] 用户登录成功: uid=user123, ip=192.168.1.1
ERROR [2026-01-19 10:35:12] 数据库查询失败: table=users, query_id=abc123, error=connection timeout

❌ 不好的日志
INFO  登录成功           (缺少时间戳、用户信息)
ERROR 查询失败           (缺少上下文)
```

---

## 🧪 测试规范

### 测试金字塔

```
          ┌──────────┐
         │   E2E    │  ← 少量（端到端测试）
        │  Testing  │
       └────────────┘
      ┌──────────────┐
     │  Integration  │  ← 中等（集成测试）
    │    Testing     │
   └──────────────────┘
  ┌────────────────────┐
 │   Unit Testing      │  ← 大量（单元测试）
└──────────────────────┘
```

---

### 单元测试（Unit Test）

**目标**: 测试单个函数/方法的逻辑

**原则**:
- 快速（毫秒级）
- 隔离（不依赖外部系统）
- 可重复

**示例**:
```
test("验证空密码应该抛出错误", () => {
    const command = { identifier: "user@example.com", password: "" };
    expect(() => validateCommand(command)).toThrow("密码不能为空");
});
```

---

### 集成测试（Integration Test）

**目标**: 测试多个模块协作

**原则**:
- 测试真实依赖（如数据库）
- 验证数据流

**示例**:
```
test("用户注册流程", async () => {
    // 1. 调用注册接口
    const response = await registerUser({ name: "Alice", email: "alice@example.com" });

    // 2. 验证响应
    expect(response.success).toBe(true);

    // 3. 验证数据库
    const user = await db.findUserByEmail("alice@example.com");
    expect(user).toBeDefined();
    expect(user.name).toBe("Alice");
});
```

---

## 🚀 性能优化

### 1. 数据库优化

- ✅ 使用索引（特别是查询频繁的字段）
- ✅ 避免 N+1 查询
- ✅ 使用连接池
- ❌ 避免 SELECT *

---

### 2. 缓存策略

**适用场景**:
- 读多写少的数据（如配置、分类）
- 计算密集型数据（如统计报表）

**缓存类型**:
- 本地缓存（内存）：适合单机
- 分布式缓存（Redis）：适合集群

---

### 3. 异步处理

**适用场景**:
- 耗时操作（发送邮件、生成报表）
- 非关键路径操作

**实现方式**:
- 消息队列（RabbitMQ、Kafka）
- 后台任务（Celery、Sidekiq）

---

## ⛔ Anti-Patterns（反模式）

### ❌ 1. 上帝对象（God Object）
**问题**: 一个类/模块承担过多职责

```
❌ 错误：UserService 做了所有事情
class UserService {
    createUser()
    deleteUser()
    sendEmail()        // ❌ 应该分离到 EmailService
    generateReport()   // ❌ 应该分离到 ReportService
    processPayment()   // ❌ 应该分离到 PaymentService
}
```

---

### ❌ 2. 魔法数字（Magic Number）
**问题**: 硬编码的数字，没有说明含义

```
❌ 错误
if (user.age > 18) { ... }           // 18 是什么？
setTimeout(callback, 3000);          // 3000 是什么？

✅ 正确
const LEGAL_AGE = 18;
if (user.age > LEGAL_AGE) { ... }

const RETRY_DELAY_MS = 3000;
setTimeout(callback, RETRY_DELAY_MS);
```

---

### ❌ 3. 过早优化
**问题**: 在没有性能瓶颈时进行复杂优化

**原则**: "Premature optimization is the root of all evil" - Donald Knuth

```
❌ 错误：过早优化
// 在没有性能问题时，引入复杂的缓存机制
cache = new ComplexCache(sharding=true, compression=true);

✅ 正确：先实现功能，后优化
// 先用简单实现，发现性能问题再优化
data = await repository.findAll();
```

---

## 📚 参考资料

- Clean Architecture - Robert C. Martin
- Design Patterns - Gang of Four
- SOLID Principles
- Domain-Driven Design - Eric Evans

---

**版本**: v1.0
**最后更新**: 2026-01-19
**适用项目**: 所有项目
