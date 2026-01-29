# Hi Kiki 项目代码审查规范 (Rust + Axum)

> **适用范围**: Hi Kiki 后端服务（Rust + Axum + SQLx + PostgreSQL）
> **架构**: Clean Architecture (4 Layers)
> **版本**: v2.0
> **最后更新**: 2026-01-19

---

## 🦀 Rust 特定检查项

### 1. 编译检查（强制）⭐

```bash
# 必须通过的检查
cargo check       # 编译检查
cargo clippy      # Lint 检查
cargo fmt --check # 格式检查
cargo test        # 测试检查
```

**如果任一检查失败，立即打回！**

---

### 2. 类型系统检查

#### 借用检查（Borrow Checker）
- [ ] 没有多个可变借用冲突
- [ ] 生命周期正确
- [ ] 没有悬垂引用

**常见错误**:
```rust
// ❌ 错误：多个可变借用
let mut x = vec![1, 2, 3];
let r1 = &mut x;
let r2 = &mut x;  // ❌ 编译错误

// ✅ 正确：使用作用域分离
let mut x = vec![1, 2, 3];
{
    let r1 = &mut x;
    // use r1
}
let r2 = &mut x;  // ✅ r1 已失效
```

---

#### 类型转换安全
- [ ] 使用 `From/Into` trait 进行类型转换
- [ ] 避免使用 `as` 进行不安全转换
- [ ] Option/Result 转换正确

**检查示例**:
```rust
// ❌ 不好：直接 unwrap
let user = repository.find_by_id(&id).await.unwrap();

// ✅ 好：使用 ? 传播错误
let user = repository.find_by_id(&id).await?
    .ok_or_else(|| DomainError::NotFound("用户不存在".to_string()))?;
```

---

### 3. 错误处理检查（Critical）

#### 必须检查
- [ ] 没有使用 `unwrap()`（除非在测试中）
- [ ] 没有使用 `expect()`（除非有充分理由）
- [ ] 所有 Result 都使用 `?` 传播或 `match` 处理
- [ ] 所有 Option 都正确处理

**常见错误**:
```rust
// ❌ Critical：可能 panic
let config = std::env::var("DATABASE_URL").unwrap();

// ✅ 正确：处理错误
let config = std::env::var("DATABASE_URL")
    .map_err(|_| DomainError::Infrastructure("DATABASE_URL 未设置".to_string()))?;
```

---

### 4. 异步编程检查

#### 必须检查
- [ ] 使用 `async/await` 正确
- [ ] 没有阻塞异步运行时（不在 async 中调用阻塞函数）
- [ ] Arc 用于共享所有权
- [ ] 没有在 async 块中持有锁太久

**常见错误**:
```rust
// ❌ 错误：在 async 中使用阻塞操作
pub async fn process() -> Result<()> {
    let data = std::fs::read("file.txt")?;  // ❌ 阻塞 I/O
    Ok(())
}

// ✅ 正确：使用异步 I/O
pub async fn process() -> Result<()> {
    let data = tokio::fs::read("file.txt").await?;  // ✅ 异步 I/O
    Ok(())
}
```

---

### 5. SQL 安全检查（Critical）

#### 必须检查
- [ ] 所有 SQL 查询使用参数绑定
- [ ] 没有字符串拼接 SQL
- [ ] 没有 SQL 注入风险

**示例**:
```rust
// ❌ Critical：SQL 注入风险
let sql = format!("SELECT * FROM users WHERE phone = '{}'", phone);
sqlx::query(&sql).fetch_one(&pool).await?;

// ✅ 正确：参数绑定
sqlx::query("SELECT * FROM users WHERE phone = $1")
    .bind(phone)
    .fetch_one(&pool)
    .await?;
```

---

### 6. Clean Architecture 检查

#### 依赖方向检查
- [ ] core 层不依赖 adapters 层
- [ ] core 层不依赖 framework 层
- [ ] 依赖方向：framework → adapters → core

**示例**:
```rust
// ❌ 错误：core 层依赖 adapters
// core/use_cases/login_user.rs
use crate::adapters::persistence::postgres::PostgresUserRepository;  // ❌

// ✅ 正确：core 层只依赖 port
use crate::core::ports::UserRepository;  // ✅
```

---

#### 分层检查
- [ ] Entity 在 `core/entities/`
- [ ] Use Case 在 `core/use_cases/`
- [ ] Port 在 `core/ports/`
- [ ] Repository 实现在 `adapters/persistence/`
- [ ] HTTP Handler 在 `adapters/http/`

---

### 7. 性能检查

#### 必须检查
- [ ] 没有不必要的 `clone()`
- [ ] 使用 `&str` 而非 `String` 作为参数
- [ ] 循环中没有重复的数据库查询
- [ ] 没有内存泄漏（Arc 循环引用）

**示例**:
```rust
// ❌ 不好：不必要的 clone
fn process_user(user: &User) -> String {
    let user_clone = user.clone();  // ❌ 不必要
    user_clone.name().to_string()
}

// ✅ 好：直接使用引用
fn process_user(user: &User) -> String {
    user.name().to_string()  // ✅
}
```

---

### 8. 日志记录检查

#### 必须使用 tracing
- [ ] 使用 `tracing` crate（不用 println!）
- [ ] 关键操作有日志
- [ ] 日志级别正确（info/warn/error/debug）
- [ ] 日志信息包含足够上下文

**示例**:
```rust
use tracing::{info, warn, error};

// ✅ 好的日志
info!("用户登录成功: uid={}, ip={}", user.uid(), ip);
warn!("密码验证失败: uid={}", user.uid());
error!("数据库连接失败: error={}", e);
```

---

### 9. 项目特定检查

#### Hi Kiki 项目规范
- [ ] HTTP Handler 直接调用 Use Case（不经过 Controller）
- [ ] 使用强类型 DTOs（不使用 `serde_json::Value`）
- [ ] 错误使用 `DomainError` 枚举
- [ ] Repository 返回 `Result<Option<T>>`

**检查示例**:
```rust
// ✅ 正确：强类型 DTO
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub identifier: String,
    pub password: String,
}

// ❌ 错误：弱类型
pub async fn login(Json(payload): Json<Value>) { }
```

---

## 🔍 审查流程

### 第一步：自动化检查
```bash
# 1. 编译检查
cargo check

# 2. Lint 检查
cargo clippy -- -D warnings

# 3. 格式检查
cargo fmt --check

# 4. 测试检查
cargo test
```

**如果任一失败 → 立即打回**

---

### 第二步：手动审查

#### 1. 架构检查（5 分钟）
- 检查依赖方向
- 检查分层是否正确
- 检查文件位置是否合理

#### 2. 安全检查（10 分钟）
- SQL 注入风险
- 错误处理（unwrap/panic）
- 权限控制

#### 3. 性能检查（5 分钟）
- 不必要的 clone
- 循环中的数据库查询
- 异步阻塞

#### 4. 代码质量检查（10 分钟）
- 命名规范
- 注释完整性
- 日志记录
- 测试覆盖

---

## 📋 审查报告模板（Rust）

```markdown
## 代码审查报告

**审查文件**: `src/core/use_cases/auth/login_user.rs`
**审查时间**: 2026-01-19

---

### 🚨 编译检查

```bash
$ cargo check
✅ 通过

$ cargo clippy
⚠️  Warning: 2 条 clippy 建议
```

**Clippy 建议**:
1. 使用 `&str` 替代 `&String` (line 45)
2. 简化 match 表达式 (line 78)

---

### 🚨 安全检查

#### SQL 注入检查
- [x] 所有查询使用参数绑定 ✅

#### 错误处理检查
- [ ] 发现 1 处 unwrap() ❌ (line 102)

**问题**:
```rust
// Line 102
let token = JwtUtils::generate_token(&user).unwrap();  // ❌

// 建议改为:
let token = JwtUtils::generate_token(&user)?;  // ✅
```

---

### ✅ 架构检查

- [x] 依赖方向正确 ✅
- [x] 分层清晰 ✅
- [x] 使用 Repository trait ✅

---

### 📊 总体评价

- **编译检查**: ✅ 通过
- **安全检查**: ⚠️  1 处 Critical（unwrap）
- **代码质量**: 85%（良好）

**结论**: ⚠️  修复 Critical 问题后可以合并

**修复清单**:
1. [Critical] 移除 line 102 的 unwrap()
2. [Warning] 优化 clippy 建议（2 处）
```

---

## 🚨 常见 Rust 错误速查

### 1. unwrap/expect
```rust
❌ let x = option.unwrap();
✅ let x = option.ok_or_else(|| Error)?;
```

### 2. SQL 注入
```rust
❌ format!("SELECT * FROM users WHERE id = {}", id)
✅ query("SELECT * FROM users WHERE id = $1").bind(id)
```

### 3. 跨层依赖
```rust
❌ use crate::adapters::...  // 在 core 层
✅ use crate::core::ports::...
```

### 4. 不必要的 clone
```rust
❌ fn f(s: &String) -> String { s.clone().to_uppercase() }
✅ fn f(s: &str) -> String { s.to_uppercase() }
```

---

**版本**: v2.0
**最后更新**: 2026-01-19
**技术栈**: Rust + Axum 0.8.4 + SQLx + PostgreSQL
