---
name: bug-analysis
description: |
  **AUTO-ACTIVATE when analyzing crashes/bugs**.

  Comprehensive bug analysis and root cause diagnosis for Android projects. Analyzes stack traces,
  NPE, lifecycle issues, memory leaks, crashes. Provides detailed root cause analysis,
  reproduction steps, and fix recommendations.

  Triggers: crash logs, exception traces, "bug", "崩溃", "空指针", "ANR", "OOM"
---

# Bug Analysis & Problem Diagnosis Skill

## When to Use

自动激活条件：
- **检测到崩溃日志** - Stack trace、crash report
- **用户报告Bug** - "有个bug"、"崩溃了"、"不工作"
- **异常追踪** - NullPointerException、IllegalStateException 等
- **性能问题** - ANR、内存泄漏、卡顿

## Core Patterns

### 1. Bug 分析流程

```
1. 收集信息（Stack Trace + 复现步骤）
2. 定位问题（分析错误类型和位置）
3. 根因分析（找出深层次原因）
4. 制定方案（提供修复建议）
5. 验证方案（确保不引入新问题）
```

### 2. 常见 Android Bug 类型

#### 类型 1: NullPointerException (NPE)

**识别特征：**
```
java.lang.NullPointerException: null cannot be cast to non-null type X
    at com.package.Class.method(File.kt:line)
```

**分析步骤：**
1. **定位空指针位置** - 查看 Stack Trace 中的行号
2. **追溯变量来源** - 变量从哪里传入？
3. **分析时序问题** - 是否异步操作导致？
4. **检查生命周期** - 是否 View/Activity 已销毁？

**常见原因：**
- ✗ 异步回调时 Activity/Fragment 已销毁
- ✗ 协程中访问已释放的资源
- ✗ 未初始化就使用（初始化顺序问题）
- ✗ 网络请求返回空数据未检查
- ✗ lateinit 变量未赋值就访问

**修复模式：**
```kotlin
// ❌ 错误：不检查 null
val view = findViewById<View>(R.id.view)
view.visibility = View.GONE  // NPE if view is null

// ✅ 修复方案1：安全调用
findViewById<View>(R.id.view)?.visibility = View.GONE

// ✅ 修复方案2：Elvis 操作符
val view = findViewById<View>(R.id.view) ?: return
view.visibility = View.GONE

// ✅ 修复方案3：使用 let
findViewById<View>(R.id.view)?.let { view ->
    view.visibility = View.GONE
}

// ✅ 修复方案4：检查生命周期
if (!isDestroyed && !isFinishing) {
    findViewById<View>(R.id.view)?.visibility = View.GONE
}
```

---

#### 类型 2: JSONException

**识别特征：**
```
org.json.JSONException: End of input at character 0 of
org.json.JSONException: Value null of type org.json.JSONObject$1 cannot be converted to JSONObject
```

**根本原因：**
- 尝试解析**空字符串** `""` 为 JSON
- 空字符串不是有效的 JSON（最小有效 JSON 是 `{}`）

**分析步骤：**
1. **追溯数据源** - JSON 字符串从哪里来？
2. **检查 API 响应** - 服务器是否返回空响应？
3. **检查默认值** - 是否使用了 `?: ""` 作为默认值？
4. **检查缓存** - 缓存数据是否为空？

**修复模式：**
```kotlin
// ❌ 错误：直接解析可能为空的字符串
val json = JSONObject(responseString)  // 如果 responseString = "" 则崩溃

// ✅ 修复方案1：检查空字符串
if (responseString.isNullOrBlank()) {
    // 处理空响应
    return defaultValue
}
val json = JSONObject(responseString)

// ✅ 修复方案2：try-catch 捕获
try {
    val json = JSONObject(responseString)
    // 处理 JSON
} catch (e: JSONException) {
    Log.e(TAG, "JSON 解析失败: ${e.message}")
    // 返回默认值或错误状态
}

// ✅ 修复方案3：使用安全解析工具
fun parseJsonSafely(jsonString: String?): JSONObject? {
    if (jsonString.isNullOrBlank()) return null
    return try {
        JSONObject(jsonString)
    } catch (e: JSONException) {
        Log.e(TAG, "JSON parse error: ${e.message}")
        null
    }
}
```

---

#### 类型 3: IllegalStateException

**识别特征：**
```
java.lang.IllegalStateException: Can not perform this action after onSaveInstanceState
java.lang.IllegalStateException: Fragment not attached to Activity
```

**常见原因：**
- ✗ Fragment Transaction 在 Activity 销毁后执行
- ✗ 异步回调时 Fragment 已 detach
- ✗ 在 onSaveInstanceState 后修改 Fragment

**修复模式：**
```kotlin
// ❌ 错误：直接提交 Fragment Transaction
supportFragmentManager.beginTransaction()
    .replace(R.id.container, fragment)
    .commit()

// ✅ 修复：使用 commitAllowingStateLoss
supportFragmentManager.beginTransaction()
    .replace(R.id.container, fragment)
    .commitAllowingStateLoss()

// ✅ 更好：检查生命周期
if (!isDestroyed && !isFinishing) {
    supportFragmentManager.beginTransaction()
        .replace(R.id.container, fragment)
        .commit()
}

// ✅ Fragment 中：检查是否 attached
if (isAdded && !isDetached) {
    // 安全执行操作
}
```

---

#### 类型 4: Memory Leak (内存泄漏)

**识别特征：**
```
android.app.Application has leaked:
- Window
- Activity
- Bitmap
```

**常见原因：**
- ✗ 静态变量持有 Activity/Context 引用
- ✗ Handler 未清理
- ✗ 观察者未取消订阅
- ✗ Bitmap 未回收
- ✗ 协程未取消

**修复模式：**
```kotlin
class MyActivity : AppCompatActivity() {
    private var job: Job? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ 使用 lifecycleScope
        lifecycleScope.launch {
            // 自动在 Activity 销毁时取消
        }

        // ❌ 错误：全局 Job 未取消
        job = GlobalScope.launch {
            // 泄漏
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // ✅ 清理资源
        job?.cancel()
        handler.removeCallbacksAndMessages(null)
    }
}
```

---

#### 类型 5: ANR (Application Not Responding)

**识别特征：**
```
ANR in com.package.name
Reason: Input dispatching timed out
```

**常见原因：**
- ✗ 主线程执行耗时操作（网络请求、数据库操作、文件 I/O）
- ✗ 主线程死锁
- ✗ BroadcastReceiver.onReceive 执行时间过长

**分析方法：**
```kotlin
// 查看 ANR trace
adb pull /data/anr/traces.txt

// 检查是否主线程阻塞
"main" prio=5 tid=1 TIMED_WAITING
  at java.lang.Thread.sleep(Native Method)
  at com.package.Class.method(File.kt:123)
```

**修复模式：**
```kotlin
// ❌ 错误：主线程网络请求
fun loadData() {
    val response = api.getData()  // 阻塞主线程
    updateUI(response)
}

// ✅ 修复：使用协程
fun loadData() {
    lifecycleScope.launch {
        val response = withContext(Dispatchers.IO) {
            api.getData()  // 在 IO 线程执行
        }
        updateUI(response)  // 回到主线程
    }
}

// ✅ 修复：BroadcastReceiver 中使用 goAsync
override fun onReceive(context: Context, intent: Intent) {
    val pendingResult = goAsync()
    scope.launch {
        // 异步处理
        pendingResult.finish()
    }
}
```

---

### 3. Bug 分析报告格式

```markdown
## Bug 分析报告

### 📋 问题概述
- **错误类型**：NullPointerException / JSONException / etc.
- **影响范围**：哪些用户受影响？
- **严重程度**：Critical / High / Medium / Low

### 🔍 错误详情
```
[粘贴完整 Stack Trace]
```

### 📍 问题定位
- **崩溃位置**：`com.package.Class.method(File.kt:行号)`
- **相关代码**：
  ```kotlin
  [粘贴相关代码]
  ```

### 💡 根因分析
1. **直接原因**：变量为 null / 字符串为空 / etc.
2. **深层原因**：
   - 异步回调时序问题
   - 生命周期管理不当
   - 缺少空值检查
3. **触发条件**：
   - 特定操作流程
   - 特定设备/系统版本
   - 网络状态

### 🛠️ 修复方案
#### 方案 1（推荐）
```kotlin
[修复代码]
```
- **优点**：...
- **缺点**：...

#### 方案 2（备选）
```kotlin
[备选方案代码]
```

### ✅ 验证方案
- [ ] 修复后编译通过
- [ ] 单元测试通过
- [ ] 手动测试复现场景
- [ ] 回归测试（确保不引入新bug）
- [ ] 检查是否有类似问题

### 📝 预防措施
- 添加防御性编程（null 检查）
- 添加日志便于调试
- 添加单元测试覆盖边界情况
```

---

## Anti-Patterns

### ❌ 错误做法

1. **只看表面，不找根因**
   ```
   ❌ "空指针异常，加个 ?. 就行了"
   ✅ "为什么会是 null？是初始化问题还是生命周期问题？"
   ```

2. **修复了症状，没修复病因**
   ```
   ❌ try-catch 捕获所有异常，然后忽略
   ✅ 找出为什么会抛异常，从根源修复
   ```

3. **没有验证修复方案**
   ```
   ❌ 改完代码就提交
   ✅ 手动复现原问题 → 验证已修复 → 回归测试
   ```

4. **忽略类似问题**
   ```
   ❌ 只修复这一处崩溃
   ✅ 搜索代码库中是否有类似模式，一并修复
   ```

5. **没有记录分析过程**
   ```
   ❌ 改完就忘
   ✅ 写下分析过程，便于团队学习和未来参考
   ```

---

## Best Practices

### 1. 系统化分析

```
收集信息 → 重现问题 → 定位代码 → 根因分析 → 设计方案 → 验证修复
```

### 2. 使用工具辅助

**Android Studio**：
- Logcat 过滤关键词
- 断点调试
- Profiler 检测内存/CPU

**命令行工具**：
```bash
# 查看崩溃日志
adb logcat | grep -i "exception\|error\|crash"

# 查看 ANR trace
adb pull /data/anr/traces.txt

# 检查内存
adb shell dumpsys meminfo <package>
```

**第三方工具**：
- LeakCanary - 内存泄漏检测
- StrictMode - 主线程违规检测
- Firebase Crashlytics - 崩溃收集

### 3. 防御性编程

```kotlin
// ✅ 参数检查
fun updateUser(user: User?) {
    requireNotNull(user) { "User cannot be null" }
    require(user.id.isNotEmpty()) { "User id must not be empty" }
    // ...
}

// ✅ 生命周期检查
if (!isDestroyed && !isFinishing) {
    // 安全执行
}

// ✅ 协程取消检查
launch {
    while (isActive) {  // 检查是否已取消
        // 执行操作
    }
}

// ✅ 详细日志
Log.d(TAG, "updateUser: userId=${user.id}, timestamp=${System.currentTimeMillis()}")
```

### 4. 边界情况测试

```kotlin
@Test
fun `test null input`() {
    assertThrows<IllegalArgumentException> {
        updateUser(null)
    }
}

@Test
fun `test empty data`() {
    val result = parseData("")
    assertNull(result)
}

@Test
fun `test concurrent modification`() {
    // 测试并发场景
}
```

---

## Integration with Other Skills

1. **→ code-review**
   - 修复后进行代码审查
   - 确保修复质量

2. **→ code-implementation**
   - 按照修复方案实现代码
   - 遵循编码规范

3. **→ architecture-design**
   - 如果是架构问题，重新设计
   - 避免类似问题再次发生

---

## Quick Reference

### 常见崩溃速查表

| 错误类型 | 常见原因 | 快速检查点 |
|---------|---------|-----------|
| NPE | 变量未初始化、异步时序 | 检查变量来源、生命周期 |
| JSONException | 空字符串、格式错误 | 检查 API 响应、默认值 |
| IllegalStateException | Fragment 生命周期 | 检查 isAdded、isDetached |
| OOM | 内存泄漏、大图片 | 检查 Bitmap、列表缓存 |
| ANR | 主线程阻塞 | 检查网络、数据库、循环 |
| ConcurrentModificationException | 遍历时修改集合 | 使用迭代器、复制集合 |

### 分析优先级

1. **Critical** - 导致崩溃、数据丢失
2. **High** - 核心功能不可用
3. **Medium** - 次要功能异常
4. **Low** - UI 显示问题、性能轻微下降
