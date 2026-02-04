# Claude Code Skills 深度使用指南

**项目**: android_17pen_jinshu (Android Kotlin Project)
**版本**: v1.0
**更新日期**: 2026-01-12
**适用**: Claude Code CLI

---

## 📖 目录

1. [什么是 Claude Code Skills](#什么是-claude-code-skills)
2. [完整能力体系](#完整能力体系)
3. [Skills 深度解析](#skills-深度解析)
4. [Agents 自主智能体](#agents-自主智能体)
5. [Commands 命令工作流](#commands-命令工作流)
6. [Hooks 自动化触发](#hooks-自动化触发)
7. [Scripts 脚本工具](#scripts-脚本工具)
8. [完整开发工作流](#完整开发工作流)
9. [实战案例](#实战案例)
10. [高级技巧](#高级技巧)
11. [常见问题](#常见问题)

---

## 什么是 Claude Code Skills

### 核心概念

Claude Code Skills 是一套**领域知识文档系统**，让 AI 助手能够：

1. **自动激活专业知识** - 根据上下文自动加载相关技能
2. **遵循项目规范** - 按照你的代码风格和架构模式工作
3. **执行标准流程** - 统一需求分析、代码审查、Bug 诊断等流程
4. **持续自我优化** - 从每次审查中学习，不断改进

### 与传统 AI 对话的区别

| 传统 AI 对话 | Claude Code Skills |
|------------|-------------------|
| 每次都要重新解释项目架构 | 一次配置，永久记忆 |
| 代码风格不统一 | 自动遵循项目规范 |
| 缺少系统性流程 | 标准化工作流（需求→设计→代码→审查） |
| 被动响应 | 主动检查和优化 |
| 无法积累经验 | 自我学习和改进 |

### 配置文件结构

```
.claude/
├── README.md              # 配置概览
├── USAGE_GUIDE.md         # 本文档（深度使用指南）
├── settings.local.json    # 个人设置（权限配置）
│
├── skills/                # 5个核心技能
│   ├── README.md         # Skills 能力清单
│   ├── requirement-clarification/   # 需求澄清
│   ├── ui-design-analysis/         # UI 设计分析
│   ├── code-implementation/        # 代码实现规范
│   ├── code-review/                # 代码审查
│   └── bug-analysis/               # Bug 分析
│
├── agents/                # 智能体（自主任务）
│   └── skill-learner.md  # 自我学习系统
│
├── commands/              # 工作流命令
│   └── dev.md            # /dev 完整开发工作流
│
├── hooks/                 # 自动触发脚本
│   └── post-edit.sh      # 代码编辑后自动格式化
│
└── scripts/               # 自动化脚本
    ├── create-activity.sh  # 生成 Activity 模板
    └── create-fragment.sh  # 生成 Fragment 模板
```

---

## 完整能力体系

### 1. Skills（领域技能）- 5个

| Skill | 作用 | 触发方式 | 自动化 |
|-------|------|---------|--------|
| **requirement-clarification** | 需求澄清和任务拆解 | 手动 / 关键词 | ❌ |
| **ui-design-analysis** | UI 设计图→代码生成 | 图片输入时 | ✅ |
| **code-implementation** | 代码实现规范 | 编写代码时 | ❌ |
| **code-review** | 15项代码审查 | Write/Edit后 | ✅ |
| **bug-analysis** | 崩溃/Bug 诊断 | 异常日志出现时 | ❌ |

### 2. Agents（智能体）- 1个

| Agent | 作用 | 运行方式 |
|-------|------|---------|
| **skill-learner** | 从审查中学习，自动优化 skills | 后台自动 / 手动调用 |

### 3. Commands（命令）- 1个

| Command | 作用 | 阶段数 |
|---------|------|--------|
| **/dev** | 完整开发工作流 | 6个阶段 |

### 4. Hooks（钩子）- 1个

| Hook | 触发时机 | 作用 |
|------|---------|------|
| **post-edit.sh** | 编辑 .kt 文件后 | 自动运行 ktlint 格式化 |

### 5. Scripts（脚本）- 2个

| Script | 作用 | 用法 |
|--------|------|------|
| **create-activity.sh** | 生成 Activity 模板 | `bash .claude/scripts/create-activity.sh LoginActivity` |
| **create-fragment.sh** | 生成 Fragment 模板 | `bash .claude/scripts/create-fragment.sh HomeFragment` |

---

## Skills 深度解析

### Skill 1: requirement-clarification（需求澄清）

#### 何时使用

- ✅ 收到新功能需求
- ✅ 需求描述模糊不清
- ✅ 需要拆解复杂任务
- ✅ 评估技术方案

#### 触发方式

**自动触发关键词**：
```
"帮我澄清需求：..."
"帮我设计：..."
"新需求：..."
"实现功能：..."
```

**手动调用**：
```bash
# 直接描述需求，AI 会自动使用该 skill
"我要添加一个多页笔迹同步功能"
```

#### 输出内容

1. **需求分析**
   - 核心功能点识别
   - 模糊点和缺失信息标记
   - 边界条件和限制

2. **任务拆解**
   - 分解为可执行的开发步骤
   - 标注优先级和依赖关系

3. **技术方案**
   - 基于项目架构（Mediator 模式）的实现建议
   - 涉及的文件和类
   - 潜在风险和注意事项

4. **实施计划**
   - 开发顺序建议
   - 测试验证清单

#### 实战示例

**输入**：
```
"添加一个笔迹撤销/重做功能"
```

**AI 输出**（使用 requirement-clarification skill）：

```markdown
## 需求分析

### 核心功能
1. **撤销（Undo）**：回退最后一次笔迹操作
2. **重做（Redo）**：恢复已撤销的操作

### 需要澄清的问题
1. 撤销/重做的粒度是什么？
   - [ ] 单笔画（一次按下到抬起）
   - [ ] 批量操作（如清除整页）
   - [ ] 时间间隔（如5秒内的连续笔画）

2. 历史记录保留多少步？
   - [ ] 无限制（可能占用大量内存）
   - [ ] 固定步数（如 50 步）
   - [ ] 基于内存限制动态调整

3. 是否需要持久化？
   - [ ] 仅在当前会话有效
   - [ ] 需要在 App 重启后恢复

4. UI 交互方式？
   - [ ] 按钮（工具栏）
   - [ ] 手势（双指滑动）
   - [ ] 快捷键（外接键盘）

### 技术方案建议

**推荐架构**：Command 模式 + 双栈结构

1. **Command 接口**：
   ```kotlin
   interface DrawCommand {
       fun execute()
       fun undo()
   }
   ```

2. **实现类**：
   ```kotlin
   class AddStrokeCommand(
       private val drawView: DrawView,
       private val stroke: Stroke
   ) : DrawCommand {
       override fun execute() { drawView.addStroke(stroke) }
       override fun undo() { drawView.removeStroke(stroke) }
   }
   ```

3. **历史管理器**：
   ```kotlin
   class DrawHistoryManager {
       private val undoStack = Stack<DrawCommand>()
       private val redoStack = Stack<DrawCommand>()

       fun executeCommand(command: DrawCommand) {
           command.execute()
           undoStack.push(command)
           redoStack.clear()  // 新操作清空重做栈
       }

       fun undo() {
           if (undoStack.isNotEmpty()) {
               val command = undoStack.pop()
               command.undo()
               redoStack.push(command)
           }
       }

       fun redo() {
           if (redoStack.isNotEmpty()) {
               val command = redoStack.pop()
               command.execute()
               undoStack.push(command)
           }
       }
   }
   ```

### 涉及文件

- `DrawView.kt` - 绘制视图，需要支持添加/移除笔画
- `PenJinshuManager.kt` - 中介者，协调撤销/重做操作
- `DrawCommand.kt` - 新建，命令接口和实现类
- `DrawHistoryManager.kt` - 新建，历史管理器

### 实施计划

1. **Phase 1**: 实现 Command 模式（2-3天）
   - [ ] 创建 DrawCommand 接口
   - [ ] 实现 AddStrokeCommand
   - [ ] 单元测试

2. **Phase 2**: 集成到 DrawView（1-2天）
   - [ ] 修改 DrawView.addPenMessages() 使用 Command
   - [ ] 测试绘制功能不受影响

3. **Phase 3**: UI 集成（1天）
   - [ ] 添加撤销/重做按钮
   - [ ] 更新按钮状态（是否可用）

4. **Phase 4**: 测试验证（1天）
   - [ ] 边界测试（空栈、满栈）
   - [ ] 性能测试（大量笔画）
   - [ ] 内存测试（长时间使用）

### 潜在风险

⚠️ **内存占用**：每个笔画对象包含大量点数据，无限历史会导致 OOM
📌 **解决方案**：限制历史步数 + 使用弱引用

⚠️ **多页笔迹**：当前是多页显示（ViewPager2），撤销/重做需要区分页面
📌 **解决方案**：每个页面独立的 DrawHistoryManager
```

---

### Skill 2: ui-design-analysis（UI 设计分析）

#### 何时使用

- ✅ 收到设计稿图片
- ✅ 需要将 UI 设计转换为代码
- ✅ 分析现有界面结构
- ✅ 生成 Android 布局文件

#### 触发方式

**自动触发**：
```bash
# 拖拽图片到对话框，然后说：
"这是登录页面设计，帮我实现"
"生成这个界面的布局"
"分析这个设计稿"
```

**支持的输入**：
- ✅ PNG/JPG 设计稿截图（推荐）
- ✅ Figma 链接（需要截图或 WebFetch）
- ✅ 手绘草图照片
- ✅ 现有 App 截图

#### 分析能力

1. **UI 元素识别**
   ```
   - TextView（标题、说明文字）
   - EditText（输入框）
   - Button / MaterialButton（按钮）
   - ImageView（图标、图片）
   - RecyclerView（列表）
   - CardView（卡片）
   - ConstraintLayout / LinearLayout（布局）
   ```

2. **尺寸估算**
   ```
   - 控件宽高（dp）
   - 间距（margin、padding）
   - 字体大小（sp）
   - 圆角半径（dp）
   ```

3. **颜色提取**
   ```
   - 主题色（Primary Color）
   - 强调色（Accent Color）
   - 文本颜色（Text Color）
   - 背景色（Background）
   - 格式：#RRGGBB
   ```

4. **布局结构分析**
   ```
   - 推荐布局类型（ConstraintLayout / LinearLayout）
   - 约束关系（Top-to-Top, Start-to-End）
   - 权重分配（layout_weight）
   ```

#### 输出内容

1. **分析报告**（Markdown 格式）
   ```markdown
   ## UI 分析报告

   ### 布局结构
   - 根布局：ConstraintLayout
   - 总高度：约 600dp

   ### UI 元素清单
   1. Logo (ImageView)
      - 尺寸：120x120dp
      - 位置：顶部居中，margin_top=80dp

   2. 标题 (TextView)
      - 文本："欢迎登录"
      - 字体：24sp, Bold
      - 颜色：#212121

   3. 用户名输入框 (EditText)
      - hint="请输入手机号"
      - 高度：48dp
      - 圆角：8dp

   ### 颜色方案
   - Primary: #1E88E5
   - Text: #212121
   - Hint: #9E9E9E
   - Background: #FFFFFF
   ```

2. **Android XML 布局文件**
   ```xml
   <!-- activity_login.xml -->
   <?xml version="1.0" encoding="utf-8"?>
   <androidx.constraintlayout.widget.ConstraintLayout
       xmlns:android="http://schemas.android.com/apk/res/android"
       xmlns:app="http://schemas.android.com/apk/res-auto"
       android:layout_width="match_parent"
       android:layout_height="match_parent"
       android:background="@color/white">

       <ImageView
           android:id="@+id/ivLogo"
           android:layout_width="120dp"
           android:layout_height="120dp"
           android:layout_marginTop="80dp"
           android:src="@drawable/ic_logo"
           app:layout_constraintTop_toTopOf="parent"
           app:layout_constraintStart_toStartOf="parent"
           app:layout_constraintEnd_toEndOf="parent"/>

       <!-- 更多控件... -->
   </androidx.constraintlayout.widget.ConstraintLayout>
   ```

3. **colors.xml 资源文件**
   ```xml
   <!-- res/values/colors.xml -->
   <resources>
       <color name="primary">#1E88E5</color>
       <color name="text_primary">#212121</color>
       <color name="text_hint">#9E9E9E</color>
   </resources>
   ```

4. **Kotlin 代码骨架**
   ```kotlin
   class LoginActivity : AppCompatActivity() {
       private lateinit var binding: ActivityLoginBinding

       override fun onCreate(savedInstanceState: Bundle?) {
           super.onCreate(savedInstanceState)
           binding = ActivityLoginBinding.inflate(layoutInflater)
           setContentView(binding.root)

           setupViews()
       }

       private fun setupViews() {
           binding.btnLogin.setOnClickListener {
               val phone = binding.etPhone.text.toString()
               val password = binding.etPassword.text.toString()
               handleLogin(phone, password)
           }
       }

       private fun handleLogin(phone: String, password: String) {
           // TODO: 实现登录逻辑
       }
   }
   ```

#### 实战示例

**场景**：产品给了一张登录页面设计稿

**步骤**：

1. **拖拽图片到 Claude Code 对话框**

2. **输入提示**：
   ```
   "这是登录页面设计，帮我生成 Android 布局和代码"
   ```

3. **AI 自动分析**（使用 ui-design-analysis skill）：
   - 识别所有 UI 元素
   - 估算尺寸和间距
   - 提取颜色值
   - 推荐布局类型

4. **AI 生成代码**：
   - `activity_login.xml` - 完整布局
   - `colors.xml` - 颜色资源
   - `dimens.xml` - 尺寸定义
   - `LoginActivity.kt` - Activity 代码

5. **AI 自动触发 code-review**：
   - 检查布局是否符合 Material Design
   - 检查是否使用了硬编码字符串
   - 检查是否缺少 contentDescription（无障碍）

---

### Skill 3: code-implementation（代码实现规范）

#### 何时使用

- ✅ 准备编写新代码
- ✅ 重构现有代码
- ✅ 需要遵循项目规范
- ✅ 不确定如何实现某功能

#### 项目专属规范

##### 1. 架构模式：Mediator（中介者）

**核心原则**：Activity/Fragment 不直接操作 UI，通过 Manager 中介

```kotlin
// ❌ 错误：Activity 直接操作 DrawView
class MyActivity : AppCompatActivity() {
    private val drawView = DrawView(this)

    fun handlePenData(msg: MsgPb.Msg) {
        drawView.addPenMessages(msg)  // 违反中介者模式
    }
}

// ✅ 正确：通过 PenJinshuManager 中介
class MyActivity : AppCompatActivity() {
    private val penManager = PenJinshuManager()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        penManager.init(this, containerLayout, NoteType.NOTE, listener)
    }

    fun handlePenData(msg: MsgPb.Msg) {
        // PenJinshuManager 内部会路由到正确的 DrawView
    }

    override fun onDestroy() {
        super.onDestroy()
        penManager.release()  // 清理资源
    }
}
```

**关键文件**：`PenJinshuManager.kt:712`

##### 2. Kotlin 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | PascalCase | `PenJinshuManager` |
| 接口 | I + PascalCase | `IPenJinshuManager` |
| 函数 | camelCase | `initView()`, `handleDataReceived()` |
| 变量 | camelCase | `middleView`, `noteType` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| 私有属性 | camelCase（不用下划线） | `private val context` |
| 伴生对象常量 | UPPER_SNAKE_CASE | `companion object { const val TAG = "..." }` |

##### 3. 空指针安全（重点）

**本项目常见 NPE 场景**：

```kotlin
// ❌ 危险：协程回调时 middleView 可能为 null
lifecycleScope.launch {
    delay(1000)
    middleView.updateBackground(url)  // NPE 风险
}

// ✅ 安全：使用局部变量 + 空检查
lifecycleScope.launch {
    delay(1000)
    val currentMiddleView = middleView
    if (currentMiddleView == null) {
        PenLog.e(TAG, "middleView is null")
        return@launch
    }
    currentMiddleView.updateBackground(url)
}

// ✅ 更安全：使用安全调用 + let
lifecycleScope.launch {
    delay(1000)
    middleView?.let { view ->
        view.updateBackground(url)
    } ?: PenLog.e(TAG, "middleView is null")
}

// ✅ 安全类型转换
val manager = middleView as? IMiddleViewManager
manager?.setBackgroundImage(url) ?: PenLog.e(TAG, "cast failed")
```

**禁止使用 `!!` 强制解包**（除非绝对安全）：
```kotlin
// ❌ 危险
val view = middleView!!  // 如果为 null 立即崩溃

// ✅ 使用 lateinit（仅适用于生命周期内一定初始化的情况）
private lateinit var binding: ActivityMainBinding
```

##### 4. 协程使用规范

**生命周期感知**：

```kotlin
// ❌ 错误：使用 GlobalScope（内存泄漏）
GlobalScope.launch {
    loadData()
}

// ✅ 正确：Activity 使用 lifecycleScope
class MyActivity : AppCompatActivity() {
    fun loadData() {
        lifecycleScope.launch {
            try {
                val data = repository.fetchData()  // 挂起函数
                updateUI(data)
            } catch (e: CancellationException) {
                // 协程取消，不做处理
                throw e
            } catch (e: Exception) {
                PenLog.e(TAG, "loadData error: ${e.message}")
                showError()
            }
        }
    }
}

// ✅ 正确：Fragment 使用 viewLifecycleOwner.lifecycleScope
class MyFragment : Fragment() {
    fun loadData() {
        viewLifecycleOwner.lifecycleScope.launch {
            // 同上
        }
    }
}

// ✅ 正确：ViewModel 使用 viewModelScope
class MyViewModel : ViewModel() {
    fun loadData() {
        viewModelScope.launch {
            // 同上
        }
    }
}
```

**线程切换**：

```kotlin
// IO 操作使用 Dispatchers.IO
lifecycleScope.launch {
    val data = withContext(Dispatchers.IO) {
        database.query()  // 耗时操作
    }
    // 自动切回主线程
    updateUI(data)
}
```

##### 5. 生命周期管理

**标准模式**：

```kotlin
class PenJinshuManager {
    private var middleView: JinshuMiddleView? = null

    // 初始化
    fun init(context: Context, container: ViewGroup, noteType: NoteType) {
        if (middleView != null) {
            PenLog.w(TAG, "already initialized")
            return
        }

        val view = JinshuMiddleView(context)
        container.addView(view)
        middleView = view
    }

    // 清理资源
    fun release() {
        middleView?.let { view ->
            (view.parent as? ViewGroup)?.removeView(view)
            view.resetViewState()
        }
        middleView = null
    }
}

// Activity 使用
class MyActivity : AppCompatActivity() {
    private val penManager = PenJinshuManager()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        penManager.init(this, containerLayout, NoteType.NOTE)
    }

    override fun onDestroy() {
        super.onDestroy()
        penManager.release()  // 关键：防止内存泄漏
    }
}
```

##### 6. 防御性编程

**参数检查**：

```kotlin
fun setBackgroundImage(url: String?) {
    if (url.isNullOrEmpty()) {
        PenLog.e(TAG, "url is null or empty")
        return
    }

    if (!url.startsWith("http")) {
        PenLog.e(TAG, "invalid url: $url")
        return
    }

    // 继续处理
}
```

**提供默认值**：

```kotlin
// ✅ 使用默认值避免 null
fun initView(noteType: NoteType = NoteType.NOTE) { ... }

// ✅ Elvis 操作符提供默认值
val data = intent.getStringExtra(EXTRA_DATA) ?: ""
```

**详细日志**：

```kotlin
// ✅ 关键操作记录日志
fun release() {
    PenLog.d(TAG, "release: middleView=$middleView")
    middleView?.resetViewState()
    middleView = null
    PenLog.d(TAG, "release: completed")
}
```

#### 自动触发 code-review

编写完代码后，**自动触发** code-review skill 进行 15 项检查。

---

### Skill 4: code-review（代码审查）

#### 自动触发

✅ **无需手动调用**，以下情况自动激活：

- 使用 Write 工具创建新文件后
- 使用 Edit 工具修改文件后
- code-implementation skill 完成后

#### 15 项检查清单

| # | 检查项 | 说明 | 示例 |
|---|--------|------|------|
| 1 | 功能完整性 | 所有需求已实现 | 是否遗漏边界情况 |
| 2 | 准确性 | 逻辑正确、命名规范 | 变量名是否语义化 |
| 3 | 可测试性 | 关键逻辑有测试 | 是否可以写单元测试 |
| 4 | 可复用性 | 避免重复代码 | 是否提取了公共函数 |
| 5 | 一致性 | 代码风格统一 | 是否遵循项目规范 |
| 6 | 设计合理性 | 无过度设计 | 是否符合 KISS 原则 |
| 7 | 错误处理 | 异常捕获完整 | try-catch 是否完整 |
| 8 | 数据安全 | 权限控制、加密 | 是否暴露敏感数据 |
| 9 | 注释文档 | 复杂逻辑有说明 | 是否有必要的注释 |
| 10 | 性能优化 | 无性能瓶颈 | 是否有内存泄漏 |
| 11 | 用户体验 | 加载/错误提示 | 是否有加载动画 |
| 12 | 数据迁移 | 旧数据兼容 | 是否需要数据库迁移 |
| 13 | 依赖管理 | 版本明确、无循环依赖 | 是否引入了新依赖 |
| 14 | Git 提交 | 提交信息清晰 | Commit message 是否规范 |
| 15 | 符合项目规范 | 遵循 CLAUDE.md | 是否使用 Mediator 模式 |

#### 评分标准

```
✅ 优秀（93%+）：14-15 项通过 → 可以合并
✅ 良好（73%-93%）：11-13 项通过 → 修复关键问题后合并
⚠️ 需改进（53%-73%）：8-10 项通过 → 需要重构
❌ 不合格（<53%）：<8 项通过 → 建议重写
```

#### 输出示例

```markdown
## 代码审查报告

**文件**: `yqPen/src/main/java/com/yiqizuoye/yqpen/feature/LoginActivity.kt`
**评分**: 12/15 (80%) - ✅ 良好
**建议**: 修复 2 个关键问题后可合并

---

### ✅ 通过项（12项）

1. ✅ **功能完整性** - 登录流程完整实现
2. ✅ **准确性** - 逻辑正确，命名规范
3. ✅ **可测试性** - 登录逻辑可单元测试
4. ✅ **可复用性** - 网络请求已提取为 Repository
5. ✅ **一致性** - 遵循 Kotlin 代码风格
6. ✅ **设计合理性** - 使用 MVVM，无过度设计
7. ✅ **错误处理** - 网络异常、登录失败已处理
8. ✅ **数据安全** - 密码使用 MD5 加密传输
9. ✅ **注释文档** - 关键函数有注释
10. ✅ **性能优化** - 使用协程，无阻塞主线程
11. ✅ **用户体验** - 有加载动画和错误提示
12. ✅ **符合项目规范** - 使用 lifecycleScope

---

### ❌ 未通过项（3项）

13. ❌ **数据迁移** - 无需数据库（N/A）
14. ❌ **依赖管理** - ⚠️ 新增依赖 `retrofit:2.9.0`，需在 `build.gradle` 中声明版本号
15. ❌ **Git 提交** - ⚠️ 提交信息过于简略："add login"，建议改为："feat: 添加用户登录功能（手机号+密码）"

---

### 🛠️ 修复建议

#### 问题 1: 依赖管理
**文件**: `yqPen/build.gradle`
**位置**: dependencies 块

**当前代码**:
```gradle
implementation 'com.squareup.retrofit2:retrofit:2.9.0'
```

**建议改为**:
```gradle
// 在根 build.gradle 中定义版本
ext {
    retrofitVersion = '2.9.0'
}

// 在模块 build.gradle 中引用
implementation "com.squareup.retrofit2:retrofit:$retrofitVersion"
```

#### 问题 2: Git 提交信息
**建议使用**:
```bash
git commit -m "feat: 添加用户登录功能

- 实现手机号+密码登录
- 使用 Retrofit 进行网络请求
- 密码 MD5 加密传输
- 错误提示和加载动画

Related: #123"
```

---

### 📊 详细分析

#### 优点
- ✅ 代码结构清晰，MVVM 分层合理
- ✅ 使用 ViewBinding，避免 findViewById
- ✅ 协程使用规范，使用 lifecycleScope
- ✅ 错误处理完整，用户体验好

#### 改进空间
- 密码加密使用 MD5 不够安全，建议使用 SHA-256 或 bcrypt（如果后端支持）
- 可以添加输入验证（手机号格式检查）
- 登录成功后建议使用 EventBus 或 LiveData 通知其他页面

---

### ✅ 结论

**总体评价**: 代码质量良好，结构清晰，功能完整。
**下一步**: 修复依赖管理和 Git 提交信息后可合并到主分支。
```

---

### Skill 5: bug-analysis（Bug 分析）

#### 何时使用

- ✅ App 崩溃
- ✅ 出现异常日志
- ✅ 功能不工作
- ✅ 性能问题

#### 触发方式

**自动触发关键词**：
```
"崩溃"、"crash"、"NPE"、"NullPointerException"
"ANR"、"内存泄漏"、"Memory Leak"
"Exception"、"Stack Trace"
```

**手动调用**：
```bash
"帮我分析这个崩溃：
java.lang.NullPointerException: Attempt to invoke virtual method ...
    at com.yiqizuoye.yqpen.PenJinshuManager.setBackgroundImage(PenJinshuManager.kt:330)
    ..."
```

#### 分析能力

1. **快速定位**
   - 解析 Stack Trace
   - 定位崩溃代码位置（文件:行号）
   - 追溯变量来源

2. **根因分析**
   - NullPointerException（空指针）
   - JSONException（JSON 解析）
   - IllegalStateException（生命周期）
   - Memory Leak（内存泄漏）
   - ANR（主线程阻塞）

3. **修复方案**
   - 提供多个方案（推荐 + 备选）
   - 包含完整代码示例
   - 说明优缺点和适用场景

4. **验证检查清单**
   - 编译验证
   - 测试验证
   - 回归测试
   - 类似问题排查

#### 输出示例

```markdown
## Bug 分析报告

---

### 📋 问题概述

**错误类型**: `NullPointerException`
**崩溃位置**: `PenJinshuManager.kt:330`
**触发场景**: 协程回调中调用 `middleView.setBackgroundImage(url)`
**严重程度**: 🔴 高（导致 App 崩溃）

---

### 🔍 Stack Trace 分析

```
java.lang.NullPointerException: Attempt to invoke virtual method
'void com.yiqizuoye.yqpen.jinshu.JinshuMiddleView.setBackgroundImage(String)'
on a null object reference

    at com.yiqizuoye.yqpen.jinshu.PenJinshuManager$fetchBackground$1.invokeSuspend(PenJinshuManager.kt:330)
    at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
    at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:106)
    at android.os.Handler.handleCallback(Handler.java:938)
```

**关键信息**:
- 崩溃发生在协程挂起函数恢复时（`invokeSuspend`）
- `middleView` 对象为 null
- 调用链：fetchBackground → 网络请求 → 回调更新 UI

---

### 🛠️ 根本原因

**代码位置**: `PenJinshuManager.kt:328-332`

```kotlin
// 当前代码（有问题）
fun fetchBackground() {
    lifecycleScope.launch {
        val url = repository.getBackgroundUrl()  // 挂起函数，耗时操作
        // ❌ 问题：等待期间 Activity 可能已 onDestroy，middleView 被置为 null
        middleView.setBackgroundImage(url)  // 330 行：NPE 崩溃
    }
}
```

**时间线**:
1. T0: 用户进入页面，调用 `fetchBackground()`
2. T1: 协程启动，开始网络请求（挂起）
3. T2: 用户按返回键，Activity `onDestroy()` 被调用
4. T3: `PenJinshuManager.release()` 执行，`middleView = null`
5. T4: 网络请求完成，协程恢复，尝试访问 `middleView` → **NPE**

---

### 💡 修复方案

#### 方案 1: 局部变量 + 空检查（推荐）

```kotlin
fun fetchBackground() {
    lifecycleScope.launch {
        val url = repository.getBackgroundUrl()

        // ✅ 使用局部变量，避免多线程竞态
        val currentMiddleView = middleView
        if (currentMiddleView == null) {
            PenLog.e(TAG, "middleView is null, activity may be destroyed")
            return@launch
        }

        currentMiddleView.setBackgroundImage(url)
    }
}
```

**优点**:
- ✅ 简单直接，易于理解
- ✅ 线程安全（局部变量不会被其他线程修改）
- ✅ 有详细日志，便于调试

**缺点**:
- ❌ 每次调用都需要空检查

---

#### 方案 2: 使用 `?.let` 安全调用

```kotlin
fun fetchBackground() {
    lifecycleScope.launch {
        val url = repository.getBackgroundUrl()

        // ✅ Kotlin 安全调用 + let 作用域
        middleView?.let { view ->
            view.setBackgroundImage(url)
        } ?: PenLog.e(TAG, "middleView is null")
    }
}
```

**优点**:
- ✅ 代码简洁，符合 Kotlin 风格
- ✅ 线程安全

**缺点**:
- ❌ 如果不加 `?: PenLog.e(...)`，失败时没有日志

---

#### 方案 3: 检查 Activity 状态

```kotlin
fun fetchBackground() {
    lifecycleScope.launch {
        val url = repository.getBackgroundUrl()

        // ✅ 检查 Activity 是否已销毁
        if (activity.isDestroyed || activity.isFinishing) {
            PenLog.w(TAG, "Activity is finishing, skip update")
            return@launch
        }

        middleView?.setBackgroundImage(url)
    }
}
```

**优点**:
- ✅ 从源头避免问题
- ✅ 适用于多个 UI 更新操作

**缺点**:
- ❌ 需要持有 Activity 引用（可能导致内存泄漏）
- ❌ 需要在 `release()` 中清理引用

---

#### 方案 4: 使用 `isActive` 检查协程状态

```kotlin
fun fetchBackground() {
    lifecycleScope.launch {
        val url = repository.getBackgroundUrl()

        // ✅ 检查协程是否仍然活跃
        if (!isActive) {
            PenLog.w(TAG, "Coroutine cancelled")
            return@launch
        }

        middleView?.setBackgroundImage(url)
    }
}
```

**优点**:
- ✅ 协程取消时自动跳过
- ✅ 适合长时间运行的协程

**缺点**:
- ❌ 只能检测协程取消，不能检测 `middleView` 为 null 的情况

---

### ✅ 推荐方案：方案 1（局部变量 + 空检查）

**最终代码**:

```kotlin
fun fetchBackground() {
    PenLog.d(TAG, "fetchBackground: start")

    lifecycleScope.launch {
        try {
            val url = withContext(Dispatchers.IO) {
                repository.getBackgroundUrl()
            }

            PenLog.d(TAG, "fetchBackground: url=$url")

            val currentMiddleView = middleView
            if (currentMiddleView == null) {
                PenLog.e(TAG, "fetchBackground: middleView is null, activity may be destroyed")
                return@launch
            }

            currentMiddleView.setBackgroundImage(url)
            PenLog.d(TAG, "fetchBackground: success")

        } catch (e: CancellationException) {
            PenLog.w(TAG, "fetchBackground: cancelled")
            throw e  // 重新抛出，不影响协程取消机制
        } catch (e: Exception) {
            PenLog.e(TAG, "fetchBackground: error - ${e.message}")
        }
    }
}
```

---

### 🧪 验证检查清单

- [ ] **编译验证**: 代码编译通过
- [ ] **单元测试**: 模拟 middleView 为 null 的情况
- [ ] **手动测试**:
  - [ ] 正常场景：进入页面 → 等待加载 → 背景显示
  - [ ] 边界场景：进入页面 → 立即返回 → 不崩溃
  - [ ] 压力测试：快速进入/退出 10 次 → 不崩溃
- [ ] **回归测试**: 检查其他使用 `middleView` 的地方是否有类似问题
- [ ] **日志验证**: 查看 Logcat，确认日志正确输出

---

### 🔍 类似问题排查

在项目中搜索其他可能存在的类似问题：

```bash
# 搜索协程中直接使用 middleView 的代码
grep -r "lifecycleScope.launch" yqPen/src/main/java/ | grep "middleView"

# 搜索其他可能为 null 的变量
grep -r "var.*: .*? = null" yqPen/src/main/java/
```

**发现的潜在问题**:
1. `PenJinshuManager.kt:450` - 类似问题，也在协程中使用 `middleView`
2. `JinshuLiveInfoManager.kt:280` - 使用 `drawView` 但未检查 null

**建议**: 统一修复所有类似问题。

---

### 📚 学习总结

**本次 Bug 的核心教训**:
1. ✅ 协程回调中，对象可能已被销毁，必须检查 null
2. ✅ 使用局部变量避免多线程竞态条件
3. ✅ 详细日志帮助快速定位问题
4. ✅ 异常处理区分 CancellationException

**更新到 skill-learner**:
本次修复将被记录到 `.claude/agents/skill-learner.md`，未来类似问题会自动检测。
```

---

## Agents 自主智能体

### Agent: skill-learner（自我学习系统）

#### 工作原理

```
代码审查 → 发现问题模式 → 记录到学习案例 → 更新 skills → 未来自动检测
```

#### 触发条件

**自动触发**：
- code-review 完成后自动运行
- 检测到重复出现的问题（≥2次）

**手动触发**：
```bash
"使用 skill-learner 分析最近的审查报告"
"从最近的 Bug 中学习"
```

#### 学习案例示例

**场景**: 连续 3 次审查都发现"协程中使用可能为 null 的对象"

**skill-learner 的行为**:

1. **识别模式**:
   ```
   问题类型: NullPointerException
   出现次数: 3 次
   位置: 协程 launch 块中
   根因: 异步回调时对象已被销毁
   ```

2. **生成学习案例**:
   ```markdown
   ## 学习案例 #001: 协程中的空指针问题

   ### 问题模式
   在 `lifecycleScope.launch` 中直接使用可能为 null 的对象（如 middleView）

   ### 检测规则
   - 代码位置：lifecycleScope.launch / viewModelScope.launch 块内
   - 访问对象：var 类型的可空属性（如 `var middleView: View?`）
   - 风险：异步回调时对象可能已被置为 null

   ### 标准修复模式
   ```kotlin
   // ❌ 危险
   lifecycleScope.launch {
       val data = fetchData()
       middleView.update(data)  // 可能 NPE
   }

   // ✅ 安全
   lifecycleScope.launch {
       val data = fetchData()
       val currentView = middleView
       if (currentView == null) {
           PenLog.e(TAG, "view is null")
           return@launch
       }
       currentView.update(data)
   }
   ```

   ### 自动检测
   在 code-review 时，自动检查：
   1. 是否在协程中使用了可空属性
   2. 是否有空检查
   3. 是否使用了局部变量
   ```

3. **更新 code-review skill**:
   - 在第 7 项"错误处理"中新增子项：
     - "协程中是否检查了可空对象"

4. **未来自动检测**:
   ```markdown
   ## 代码审查报告

   ### ❌ 未通过项

   7. ❌ **错误处理** - ⚠️ 发现协程中使用可空对象 `middleView` 但未检查 null
      - 位置：`MyManager.kt:125`
      - 建议：使用局部变量 + 空检查（参考学习案例 #001）
   ```

#### 学习成果存储

**文件位置**: `docs/learnings/case-001-coroutine-npe.md`

**索引**: `.claude/agents/skill-learner.md` 中记录所有案例

---

## Commands 命令工作流

### Command: /dev（完整开发工作流）

#### 6 个阶段

```
Phase 1: 需求分析 → Phase 2: 架构设计 → Phase 3: UI 设计 →
Phase 4: 代码实现 → Phase 5: 代码审查 → Phase 6: 学习优化
```

#### 使用方式

**基本用法**:
```bash
/dev 添加用户登录功能
```

**跳过 UI 设计**:
```bash
/dev 添加搜索功能 --skip-design
```

**仅审查现有代码**:
```bash
/dev 用户中心改造 --review-only
```

#### 详细流程

##### Phase 1: 需求分析（requirement-clarification）

**输入**: 用户需求描述
**输出**:
- `docs/requirements/req-{功能名}-{日期}.md`
- 内容：需求分析、任务拆解、技术方案、实施计划

**用户交互**:
- 如果需求不明确，会提问澄清
- 用户确认需求后进入下一阶段

##### Phase 2: 架构设计

**输入**: 需求文档
**输出**:
- `docs/architecture/arch-{功能名}-{日期}.md`
- 内容：
  - 涉及的文件和类
  - 类图和时序图
  - 数据流
  - 接口定义

**示例**:
```markdown
## 架构设计：用户登录功能

### 涉及文件
- `LoginActivity.kt` - 登录页面
- `LoginViewModel.kt` - ViewModel
- `UserRepository.kt` - 数据层
- `activity_login.xml` - 布局文件

### 类图
```
LoginActivity → LoginViewModel → UserRepository → API
```

### 数据流
```
用户输入 → LoginActivity → LoginViewModel.login()
  → UserRepository.login(phone, password)
  → API 请求
  → 返回 token
  → 保存到 SharedPreferences
  → 跳转到主页
```
```

##### Phase 3: UI 设计（ui-design-analysis）

**输入**: 设计稿图片（如果用户提供）
**输出**:
- `docs/design/ui-{功能名}-{日期}.md` - UI 分析报告
- `activity_*.xml` / `fragment_*.xml` - 布局文件
- `colors.xml`, `dimens.xml` - 资源文件

**可选**: 使用 `--skip-design` 跳过

##### Phase 4: 代码实现（code-implementation）

**输入**: 架构设计 + UI 设计
**输出**: 完整的 Kotlin 代码

**遵循规范**:
- ✅ Mediator 模式
- ✅ Kotlin 命名规范
- ✅ 空指针安全
- ✅ 协程使用规范
- ✅ 生命周期管理
- ✅ 防御性编程

##### Phase 5: 代码审查（code-review）

**自动触发**: Phase 4 完成后
**输出**: `docs/reviews/review-{功能名}-{日期}.md`

**15 项检查** + **评分** + **修复建议**

##### Phase 6: 学习优化（skill-learner）

**自动触发**: Phase 5 完成后
**输出**:
- 如果发现问题模式（≥2次），生成学习案例
- 更新相关 skills

#### 状态跟踪

/dev 命令会自动保存进度：

```json
{
  "feature": "用户登录",
  "current_phase": 3,
  "completed_phases": [1, 2],
  "artifacts": {
    "requirements": "docs/requirements/req-login-2026-01-12.md",
    "architecture": "docs/architecture/arch-login-2026-01-12.md",
    "ui_design": "docs/design/ui-login-2026-01-12.md"
  }
}
```

**恢复功能**:
```bash
# 如果中断，可以恢复
/dev resume
```

---

## Hooks 自动化触发

### Hook: post-edit.sh（自动格式化）

#### 触发时机

✅ **自动触发**，无需手动调用：

- 使用 Edit 工具编辑 `.kt` 文件后
- 使用 Write 工具创建 `.kt` 文件后

#### 执行逻辑

```bash
1. 检测文件扩展名是否为 .kt
2. 检查是否安装 ktlint
3. 如果已安装，运行 ktlint -F {文件路径}
4. 输出格式化结果
```

#### 安装 ktlint

**macOS**:
```bash
brew install ktlint
```

**Linux/Windows**:
```bash
# 下载 ktlint JAR
curl -sSLO https://github.com/pinterest/ktlint/releases/download/0.50.0/ktlint
chmod +x ktlint
sudo mv ktlint /usr/local/bin/
```

**验证安装**:
```bash
ktlint --version
```

#### 自定义规则

创建 `.editorconfig` 文件：

```ini
[*.{kt,kts}]
# 缩进
indent_size = 4
indent_style = space

# 最大行长度
max_line_length = 120

# 禁用某些规则
ktlint_standard_no-wildcard-imports = disabled
```

#### 禁用 Hook

如果不想自动格式化：

```bash
# 临时禁用（重命名）
mv .claude/hooks/post-edit.sh .claude/hooks/post-edit.sh.disabled

# 永久删除
rm .claude/hooks/post-edit.sh
```

---

## Scripts 脚本工具

### Script 1: create-activity.sh

#### 功能

快速生成标准 Activity 模板，包含：

- ✅ Kotlin Activity 代码
- ✅ XML 布局文件
- ✅ 生命周期方法
- ✅ ViewBinding 支持（注释）
- ✅ 协程使用示例
- ✅ 详细日志

#### 使用方法

**方式 1: 通过 Claude Code**
```bash
"运行脚本：create-activity LoginActivity"
```

**方式 2: 手动运行**
```bash
bash .claude/scripts/create-activity.sh LoginActivity
```

#### 生成的文件

1. **Kotlin 文件**: `yqPen/src/main/java/com/yiqizuoye/yqpen/LoginActivity.kt`

```kotlin
package com.yiqizuoye.yqpen

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.yiqizuoye.library.yqpensdk.utils.PenLog
import kotlinx.coroutines.launch

/**
 * LoginActivity
 *
 * 创建时间：2026-01-12
 * 描述：TODO 添加功能描述
 */
class LoginActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "LoginActivity"
        private const val EXTRA_DATA = "extra_data"

        /**
         * 创建 Intent
         */
        fun createIntent(context: Context, data: String = ""): Intent {
            return Intent(context, LoginActivity::class.java).apply {
                putExtra(EXTRA_DATA, data)
            }
        }
    }

    // TODO: 添加 ViewBinding
    // private lateinit var binding: ActivityLoginBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // TODO: 初始化 ViewBinding
        // binding = ActivityLoginBinding.inflate(layoutInflater)
        // setContentView(binding.root)

        PenLog.d(TAG, "onCreate")

        setupViews()
        loadData()
    }

    /**
     * 初始化视图
     */
    private fun setupViews() {
        // TODO: 设置视图监听器
        // binding.btnSubmit.setOnClickListener {
        //     handleSubmit()
        // }
    }

    /**
     * 加载数据
     */
    private fun loadData() {
        val data = intent.getStringExtra(EXTRA_DATA) ?: ""
        PenLog.d(TAG, "loadData: data=$data")

        // TODO: 加载数据
        lifecycleScope.launch {
            try {
                // 异步操作
            } catch (e: Exception) {
                PenLog.e(TAG, "loadData error: ${e.message}")
            }
        }
    }

    override fun onStart() {
        super.onStart()
        PenLog.d(TAG, "onStart")
    }

    override fun onResume() {
        super.onResume()
        PenLog.d(TAG, "onResume")
    }

    override fun onPause() {
        super.onPause()
        PenLog.d(TAG, "onPause")
    }

    override fun onStop() {
        super.onStop()
        PenLog.d(TAG, "onStop")
    }

    override fun onDestroy() {
        super.onDestroy()
        // TODO: 清理资源
        PenLog.d(TAG, "onDestroy")
    }
}
```

2. **XML 布局**: `yqPen/src/main/res/layout/activity_login.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".LoginActivity">

    <TextView
        android:id="@+id/tvTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="LoginActivity"
        android:textSize="24sp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"/>

</androidx.constraintlayout.widget.ConstraintLayout>
```

#### 下一步

脚本会提示：

```
✅ Activity 创建成功！

📁 已创建文件：
   - yqPen/src/main/java/com/yiqizuoye/yqpen/LoginActivity.kt
   - yqPen/src/main/res/layout/activity_login.xml

📝 下一步：
   1. 在 AndroidManifest.xml 中注册 Activity
   2. 启用 ViewBinding 并更新代码
   3. 实现业务逻辑
```

---

### Script 2: create-fragment.sh

#### 功能

快速生成标准 Fragment 模板，包含：

- ✅ Kotlin Fragment 代码
- ✅ XML 布局文件
- ✅ 生命周期方法（包含 onViewCreated, onDestroyView）
- ✅ ViewBinding 支持（带内存泄漏防护）
- ✅ viewLifecycleOwner.lifecycleScope（Fragment 专用）
- ✅ newInstance() 工厂方法
- ✅ 详细日志

#### 使用方法

**方式 1: 通过 Claude Code**
```bash
"运行脚本：create-fragment HomeFragment"
```

**方式 2: 手动运行**
```bash
bash .claude/scripts/create-fragment.sh HomeFragment
```

#### 生成的文件

1. **Kotlin 文件**: `yqPen/src/main/java/com/yiqizuoye/yqpen/HomeFragment.kt`

**关键差异（Fragment vs Activity）**:

```kotlin
class HomeFragment : Fragment() {

    companion object {
        private const val TAG = "HomeFragment"
        private const val ARG_DATA = "arg_data"

        /**
         * 创建实例
         */
        fun newInstance(data: String = ""): HomeFragment {
            return HomeFragment().apply {
                arguments = Bundle().apply {
                    putString(ARG_DATA, data)
                }
            }
        }
    }

    // ✅ ViewBinding（避免内存泄漏）
    // private var _binding: FragmentHomeBinding? = null
    // private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        PenLog.d(TAG, "onCreateView")
        // TODO: 初始化 ViewBinding
        // _binding = FragmentHomeBinding.inflate(inflater, container, false)
        // return binding.root

        return inflater.inflate(android.R.layout.simple_list_item_1, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        PenLog.d(TAG, "onViewCreated")

        setupViews()
        loadData()
    }

    /**
     * 加载数据
     */
    private fun loadData() {
        // ✅ 使用 viewLifecycleOwner（重要！）
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                // 异步操作
            } catch (e: Exception) {
                PenLog.e(TAG, "loadData error: ${e.message}")
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        // ✅ 清理 ViewBinding（避免内存泄漏）
        // _binding = null
        PenLog.d(TAG, "onDestroyView")
    }
}
```

2. **XML 布局**: `yqPen/src/main/res/layout/fragment_home.xml`

#### Fragment 特有注意事项

⚠️ **重要差异**：

| 项目 | Activity | Fragment |
|------|----------|----------|
| ViewBinding 清理 | 不需要 | ✅ 必须在 onDestroyView 中置为 null |
| 协程作用域 | lifecycleScope | ✅ viewLifecycleOwner.lifecycleScope |
| 生命周期 | onCreate → onDestroy | onCreate → onCreateView → onViewCreated → onDestroyView → onDestroy |

脚本会提示：

```
⚠️  重要提示：
   - Fragment 中使用 viewLifecycleOwner.lifecycleScope
   - onDestroyView 中清理 _binding（避免内存泄漏）
```

---

## 完整开发工作流

### 场景 1: 从需求到上线（完整流程）

#### 需求

"添加用户登录功能，支持手机号+验证码登录"

#### 执行步骤

**Step 1: 启动 /dev 工作流**

```bash
/dev 添加用户登录功能（手机号+验证码）
```

**Step 2: Phase 1 - 需求分析**

AI 自动使用 `requirement-clarification` skill：

```markdown
## 需求分析

### 核心功能
1. 手机号输入（11位，格式验证）
2. 发送验证码（60秒倒计时）
3. 验证码输入（6位数字）
4. 登录按钮（校验+请求）

### 需要澄清
1. 验证码有效期是多久？（默认5分钟）
2. 是否需要图形验证码防止刷接口？
3. 登录成功后跳转到哪个页面？
4. 是否需要记住登录状态？（默认7天）

### 技术方案
...
```

**用户确认** → 进入 Phase 2

**Step 3: Phase 2 - 架构设计**

生成 `docs/architecture/arch-login-2026-01-12.md`：

```markdown
## 架构设计

### 涉及文件
- LoginActivity.kt
- LoginViewModel.kt
- AuthRepository.kt
- activity_login.xml

### 数据流
用户输入手机号 → 点击"获取验证码"
  → AuthRepository.sendSmsCode()
  → API: POST /api/auth/sms
  → 返回成功，开始倒计时

用户输入验证码 → 点击"登录"
  → AuthRepository.loginWithSms()
  → API: POST /api/auth/login
  → 返回 token
  → 保存到 SharedPreferences
  → 跳转到主页
```

**用户确认** → 进入 Phase 3

**Step 4: Phase 3 - UI 设计**

用户上传设计稿 → AI 自动使用 `ui-design-analysis` skill：

生成：
- `activity_login.xml`
- `colors.xml`
- `dimens.xml`

**用户确认** → 进入 Phase 4

**Step 5: Phase 4 - 代码实现**

AI 自动使用 `code-implementation` skill，生成：

1. **LoginActivity.kt**（遵循 Mediator 模式）
2. **LoginViewModel.kt**
3. **AuthRepository.kt**
4. **网络接口定义**

**Step 6: Phase 5 - 代码审查**

✅ **自动触发** `code-review` skill

生成 `docs/reviews/review-login-2026-01-12.md`：

```markdown
## 代码审查报告

**评分**: 13/15 (87%) - ✅ 良好

### ❌ 未通过项
14. ❌ 依赖管理 - 缺少 Retrofit 依赖声明
15. ❌ Git 提交 - 尚未提交

### 修复建议
...
```

**用户修复问题** → AI 重新审查 → 通过

**Step 7: Phase 6 - 学习优化**

✅ **自动触发** `skill-learner` agent

检测是否有重复问题 → 如果有，生成学习案例

**Step 8: 提交代码**

```bash
git add .
git commit -m "feat: 添加用户登录功能（手机号+验证码）

- 实现手机号格式验证
- 实现验证码发送和倒计时
- 实现登录逻辑和 token 存储
- 添加错误提示和加载动画

Related: #123"

git push origin feature/login
```

**Step 9: 创建 Pull Request**

```bash
gh pr create --title "feat: 添加用户登录功能" --body "$(cat docs/reviews/review-login-2026-01-12.md)"
```

---

### 场景 2: 快速修复 Bug

#### 问题

App 崩溃：`NullPointerException at PenJinshuManager.kt:330`

#### 执行步骤

**Step 1: 粘贴崩溃日志**

```bash
"帮我分析这个崩溃：

java.lang.NullPointerException: Attempt to invoke virtual method ...
    at com.yiqizuoye.yqpen.PenJinshuManager.setBackgroundImage(PenJinshuManager.kt:330)
    ..."
```

**Step 2: AI 自动分析**

✅ **自动触发** `bug-analysis` skill

输出：
- 问题概述
- Stack Trace 分析
- 根本原因
- 4 个修复方案（推荐方案标注）
- 验证检查清单
- 类似问题排查

**Step 3: 选择修复方案**

```bash
"使用方案 1（局部变量 + 空检查）"
```

**Step 4: AI 自动修复**

使用 Edit 工具修改 `PenJinshuManager.kt:330`

**Step 5: 自动触发 code-review**

✅ **post-edit hook** 自动格式化
✅ **code-review** 自动检查

**Step 6: 验证修复**

```bash
"运行单元测试"
```

**Step 7: 提交修复**

```bash
git add yqPen/src/main/java/com/yiqizuoye/yqpen/jinshu/PenJinshuManager.kt
git commit -m "fix: 修复协程回调时 middleView 空指针崩溃

- 问题：异步回调时 middleView 可能已被置为 null
- 修复：使用局部变量 + 空检查
- 影响：PenJinshuManager.fetchBackground() 方法

Fixes: #456"
```

---

### 场景 3: UI 设计稿转代码（5 分钟完成）

#### 需求

产品给了一张"个人中心"页面设计稿

#### 执行步骤

**Step 1: 上传设计稿**

拖拽图片到 Claude Code 对话框

**Step 2: 触发 UI 分析**

```bash
"这是个人中心页面设计，帮我生成布局和代码"
```

**Step 3: AI 自动分析**

✅ **自动触发** `ui-design-analysis` skill

输出：
- UI 分析报告（元素、颜色、尺寸）
- `fragment_profile.xml`（完整布局）
- `colors.xml`（颜色资源）
- `dimens.xml`（尺寸定义）
- `ProfileFragment.kt`（Kotlin 代码）

**Step 4: 生成 Fragment**

```bash
"运行脚本：create-fragment ProfileFragment"
```

**Step 5: 复制 AI 生成的代码**

将 AI 生成的布局代码复制到 `fragment_profile.xml`

**Step 6: 自动审查**

✅ **自动触发** `code-review` skill

检查：
- 是否有硬编码字符串
- 是否缺少 contentDescription
- 是否使用了已弃用的 API

**Step 7: 运行预览**

```bash
./gradlew :yqPen:assembleDebug
```

---

## 实战案例

### 案例 1: 添加撤销/重做功能（完整流程）

#### 背景

用户要求："我想给笔迹添加撤销和重做功能，像画图软件那样"

#### 执行

##### 1. 需求澄清

**输入**:
```
"帮我澄清需求：添加笔迹撤销/重做功能"
```

**AI 输出**（使用 requirement-clarification skill）:
```markdown
## 需求分析

### 核心功能
1. 撤销：回退最后一次笔画
2. 重做：恢复已撤销的笔画

### 需要澄清
1. 撤销粒度：单笔画 / 批量操作 / 时间间隔？
2. 历史步数：无限 / 50步 / 基于内存？
3. 是否持久化：会话内 / 重启后恢复？
4. UI 交互：按钮 / 手势 / 快捷键？

### 技术方案
推荐：Command 模式 + 双栈结构
涉及文件：DrawView.kt, PenJinshuManager.kt, DrawCommand.kt（新建）
```

**用户回答**:
```
"单笔画撤销，最多50步，仅会话内，工具栏按钮"
```

##### 2. 架构设计

AI 自动生成架构文档，包含：

- Command 接口设计
- DrawHistoryManager 设计
- 与现有 DrawView 集成方案
- UI 按钮位置建议

##### 3. 代码实现

AI 自动生成：

**DrawCommand.kt**（新建）:
```kotlin
interface DrawCommand {
    fun execute()
    fun undo()
}

class AddStrokeCommand(
    private val drawView: DrawView,
    private val stroke: Stroke
) : DrawCommand {
    override fun execute() {
        drawView.addStroke(stroke)
    }

    override fun undo() {
        drawView.removeStroke(stroke)
    }
}
```

**DrawHistoryManager.kt**（新建）:
```kotlin
class DrawHistoryManager(
    private val maxHistorySize: Int = 50
) {
    private val undoStack = Stack<DrawCommand>()
    private val redoStack = Stack<DrawCommand>()

    fun executeCommand(command: DrawCommand) {
        command.execute()
        undoStack.push(command)
        redoStack.clear()

        // 限制历史步数
        if (undoStack.size > maxHistorySize) {
            undoStack.removeAt(0)
        }
    }

    fun undo(): Boolean {
        if (undoStack.isEmpty()) return false

        val command = undoStack.pop()
        command.undo()
        redoStack.push(command)
        return true
    }

    fun redo(): Boolean {
        if (redoStack.isEmpty()) return false

        val command = redoStack.pop()
        command.execute()
        undoStack.push(command)
        return true
    }

    fun canUndo() = undoStack.isNotEmpty()
    fun canRedo() = redoStack.isNotEmpty()
}
```

**修改 DrawView.kt**:
```kotlin
class DrawView : View {
    private val historyManager = DrawHistoryManager(maxHistorySize = 50)

    fun addPenMessages(msg: MsgPb.Msg) {
        val stroke = Stroke.fromMsg(msg)
        val command = AddStrokeCommand(this, stroke)
        historyManager.executeCommand(command)  // 使用 Command 模式
    }

    fun undo() {
        if (historyManager.undo()) {
            invalidate()  // 重绘
        }
    }

    fun redo() {
        if (historyManager.redo()) {
            invalidate()
        }
    }
}
```

**修改 PenJinshuManager.kt**:
```kotlin
class PenJinshuManager {
    fun undo() {
        middleView?.getDrawView()?.undo()
    }

    fun redo() {
        middleView?.getDrawView()?.redo()
    }

    fun canUndo() = middleView?.getDrawView()?.canUndo() ?: false
    fun canRedo() = middleView?.getDrawView()?.canRedo() ?: false
}
```

##### 4. 代码审查

✅ **自动触发** code-review

**输出**:
```markdown
## 代码审查报告

**评分**: 14/15 (93%) - ✅ 优秀

### ✅ 通过项（14项）
1. ✅ 功能完整性 - 撤销/重做功能完整
2. ✅ 准确性 - Command 模式实现正确
...
14. ✅ 符合项目规范 - 通过 PenJinshuManager 中介

### ❌ 未通过项
13. ❌ 依赖管理 - 无新增依赖（N/A）

### 建议
- ✅ 可以合并到主分支
- 建议添加单元测试验证边界情况（空栈、满栈）
```

##### 5. 测试验证

```bash
"生成单元测试代码"
```

AI 自动生成 `DrawHistoryManagerTest.kt`:
```kotlin
class DrawHistoryManagerTest {
    @Test
    fun `undo empty stack returns false`() {
        val manager = DrawHistoryManager()
        assertFalse(manager.undo())
    }

    @Test
    fun `undo after execute removes stroke`() {
        val manager = DrawHistoryManager()
        val drawView = mock<DrawView>()
        val stroke = mock<Stroke>()

        val command = AddStrokeCommand(drawView, stroke)
        manager.executeCommand(command)

        verify(drawView).addStroke(stroke)

        manager.undo()
        verify(drawView).removeStroke(stroke)
    }

    @Test
    fun `max history size limits stack`() {
        val manager = DrawHistoryManager(maxHistorySize = 3)
        // ... 测试限制逻辑
    }
}
```

##### 6. 提交代码

```bash
git add .
git commit -m "feat: 添加笔迹撤销/重做功能

- 实现 Command 模式和 DrawHistoryManager
- 支持最多 50 步历史记录
- 添加 undo/redo 方法到 PenJinshuManager
- 单元测试覆盖边界情况

Related: #789"
```

---

### 案例 2: 优化内存泄漏问题

#### 背景

LeakCanary 检测到内存泄漏：`PenJinshuManager` 被 Activity 持有导致无法回收

#### 执行

##### 1. 分析问题

**输入**:
```
"帮我分析这个内存泄漏：

LeakCanary detected memory leak:
...
PenJinshuManager instance retained by Activity
```

**AI 输出**（使用 bug-analysis skill）:
```markdown
## Bug 分析报告

### 根本原因
PenJinshuManager 持有 Activity 的强引用（context 参数），
导致 Activity 销毁后无法被 GC 回收。

### 泄漏路径
Activity → PenJinshuManager → context (Activity) → 循环引用

### 修复方案（推荐）
使用 WeakReference 或 ApplicationContext
```

##### 2. 修复代码

AI 自动修改 `PenJinshuManager.kt`:

```kotlin
// ❌ 之前（内存泄漏）
class PenJinshuManager(
    private val context: Context  // 持有 Activity 强引用
) {
    fun loadImage(url: String) {
        Glide.with(context).load(url).into(imageView)
    }
}

// ✅ 修复后
class PenJinshuManager(
    context: Context
) {
    private val appContext = context.applicationContext  // 使用 Application 上下文

    fun loadImage(url: String) {
        Glide.with(appContext).load(url).into(imageView)
    }
}
```

##### 3. 验证修复

```bash
"运行 LeakCanary 验证"
```

✅ 内存泄漏消失

---

### 案例 3: 从设计稿到上线（30 分钟）

#### 背景

产品提供了"作业批改"页面设计稿，要求当天上线

#### 执行（使用 /dev 工作流）

##### 1. 启动工作流

```bash
/dev 作业批改页面 --skip-architecture
```

（跳过架构设计，因为是简单页面）

##### 2. UI 分析（3 分钟）

上传设计稿 → AI 自动生成：
- `activity_homework_review.xml`
- `colors.xml`
- Kotlin 代码骨架

##### 3. 代码实现（15 分钟）

AI 自动生成完整代码，包括：
- HomeworkReviewActivity.kt
- 网络请求逻辑
- 图片加载
- 批改标注功能

用户只需填写业务逻辑细节

##### 4. 代码审查（2 分钟）

✅ 自动触发 code-review
✅ 自动格式化（post-edit hook）

**评分**: 14/15（优秀）

##### 5. 测试验证（5 分钟）

```bash
./gradlew :yqPen:assembleDebug
adb install -r yqPen/build/outputs/apk/debug/yqPen-debug.apk
```

##### 6. 提交上线（5 分钟）

```bash
git add .
git commit -m "feat: 添加作业批改页面"
git push origin feature/homework-review

gh pr create --title "feat: 作业批改页面" --body "..."
```

**总计**: 30 分钟完成需求 → 代码 → 审查 → 上线

---

## 高级技巧

### 技巧 1: 自定义 Skills

#### 场景

项目有特殊的数据库查询规范，希望 AI 自动遵循

#### 步骤

**1. 创建 skill 目录**:
```bash
mkdir -p .claude/skills/database-query
```

**2. 编写 SKILL.md**:
```markdown
# Database Query Skill

## Trigger
- User mentions "查询数据库", "database query"
- Code involves Room DAO methods

## Rules

### 1. Always use suspend functions
```kotlin
// ✅ 正确
@Query("SELECT * FROM user WHERE id = :userId")
suspend fun getUserById(userId: Long): User?

// ❌ 错误
@Query("SELECT * FROM user WHERE id = :userId")
fun getUserById(userId: Long): User?
```

### 2. Use Flow for observing data
```kotlin
@Query("SELECT * FROM user")
fun getAllUsers(): Flow<List<User>>
```

### 3. Transactions for multiple operations
```kotlin
@Transaction
suspend fun insertUserAndPosts(user: User, posts: List<Post>) {
    insertUser(user)
    insertPosts(posts)
}
```

## Auto-check
- [ ] All query methods are suspend or return Flow
- [ ] Complex operations use @Transaction
- [ ] No main thread database access
```

**3. 测试触发**:
```bash
"帮我写一个查询所有用户的 DAO 方法"
```

AI 会自动使用该 skill，生成符合规范的代码。

---

### 技巧 2: Hooks 链式调用

#### 场景

编辑代码后，依次执行：格式化 → Lint 检查 → 单元测试

#### 步骤

**修改 post-edit.sh**:
```bash
#!/bin/bash

FILE_PATH="${FILE_PATH:-$1}"

if [[ "$FILE_PATH" == *.kt ]]; then
    echo "🔧 Step 1: 格式化代码"
    ktlint -F "$FILE_PATH" 2>/dev/null

    echo "🔍 Step 2: Lint 检查"
    ./gradlew lint 2>/dev/null

    echo "🧪 Step 3: 运行单元测试"
    ./gradlew test 2>/dev/null

    echo "✅ 所有检查完成"
fi
```

**效果**: 每次编辑代码，自动执行 3 个步骤

---

### 技巧 3: MCP 集成（高级）

#### 场景

希望 AI 直接访问 Jira API 获取需求详情

#### 步骤

**1. 配置 MCP Server**

创建 `.claude/mcp-config.json`:
```json
{
  "servers": {
    "jira": {
      "command": "node",
      "args": ["/path/to/jira-mcp-server.js"],
      "env": {
        "JIRA_API_KEY": "your-api-key",
        "JIRA_URL": "https://your-company.atlassian.net"
      }
    }
  }
}
```

**2. 编写 MCP Server**

`jira-mcp-server.js`:
```javascript
const { MCPServer } = require('@anthropics/mcp-sdk');

const server = new MCPServer({
  name: 'Jira Integration',
  version: '1.0.0'
});

server.addTool({
  name: 'get_jira_issue',
  description: 'Get Jira issue details by ID',
  parameters: {
    issueId: { type: 'string', required: true }
  },
  async execute({ issueId }) {
    const response = await fetch(
      `${process.env.JIRA_URL}/rest/api/3/issue/${issueId}`,
      {
        headers: {
          'Authorization': `Bearer ${process.env.JIRA_API_KEY}`
        }
      }
    );
    return await response.json();
  }
});

server.start();
```

**3. 使用**

```bash
"获取 Jira 需求 PROJ-123 的详情，并开始开发"
```

AI 会：
1. 调用 MCP 工具获取 Jira 需求
2. 自动使用 requirement-clarification skill 分析需求
3. 启动 /dev 工作流

---

### 技巧 4: 多项目共享 Skills

#### 场景

公司有多个 Android 项目，希望共享同一套 Skills

#### 方案 1: Git Submodule

```bash
# 在主项目中
git submodule add https://github.com/your-company/claude-skills-android .claude/shared-skills

# 在 .claude/skills/ 中创建软链接
ln -s ../shared-skills/code-implementation code-implementation
```

#### 方案 2: 符号链接

```bash
# 创建共享目录
mkdir -p ~/claude-skills-android

# 在项目中创建软链接
ln -s ~/claude-skills-android .claude/shared-skills
```

---

### 技巧 5: 版本化 Skills（团队协作）

#### 场景

团队多人开发，需要统一 Skills 版本

#### 步骤

**1. Skills 添加版本号**

`.claude/skills/code-implementation/SKILL.md`:
```markdown
# Code Implementation Skill

**Version**: 2.1.0
**Last Updated**: 2026-01-12
**Changelog**:
- v2.1.0: 新增协程空指针检查
- v2.0.0: 添加 Mediator 模式规范
- v1.0.0: 初始版本
```

**2. 团队同步**

```bash
# 拉取最新 skills
git pull origin main

# 检查 skills 版本
cat .claude/skills/*/SKILL.md | grep "Version:"
```

**3. 自动检测版本**

在 `.claude/commands/dev.md` 中添加：
```markdown
## Pre-check
Before starting, verify skills versions:
- code-implementation: ≥ 2.1.0
- code-review: ≥ 1.5.0
```

---

## 常见问题

### Q1: Skills 没有自动触发？

**原因**:
- 触发关键词不匹配
- Skill 文件名不规范

**解决方案**:
```bash
# 检查 skill 文件结构
ls -la .claude/skills/code-implementation/

# 应该有 SKILL.md 文件
# 检查文件权限
chmod 644 .claude/skills/*/SKILL.md

# 手动触发测试
"使用 code-implementation skill 编写代码"
```

---

### Q2: Hooks 不执行？

**原因**:
- 脚本没有执行权限
- 脚本路径错误

**解决方案**:
```bash
# 添加执行权限
chmod +x .claude/hooks/post-edit.sh

# 测试脚本
bash .claude/hooks/post-edit.sh yqPen/src/main/java/Test.kt

# 检查 shebang
head -n 1 .claude/hooks/post-edit.sh
# 应该是：#!/bin/bash
```

---

### Q3: Scripts 生成的代码位置错误？

**原因**:
- 项目包名不匹配
- 脚本中硬编码的路径

**解决方案**:
```bash
# 修改脚本中的包路径
# 编辑 .claude/scripts/create-activity.sh

PACKAGE_PATH="com/yiqizuoye/yqpen"  # 改为你的包名
BASE_PATH="yqPen/src/main/java/${PACKAGE_PATH}"  # 改为你的模块名
```

---

### Q4: code-review 评分太严格？

**原因**:
- 15 项检查标准严格

**解决方案**:

自定义评分标准，编辑 `.claude/skills/code-review/SKILL.md`:
```markdown
## Scoring

### 自定义标准（根据项目调整）

✅ 优秀（87%+）：13-15 项通过
✅ 良好（67%-87%）：10-12 项通过
⚠️ 需改进（47%-67%）：7-9 项通过
❌ 不合格（<47%）：<7 项通过

### 可选项（N/A 不影响评分）
- 数据迁移（新功能无需迁移）
- 依赖管理（无新增依赖）
```

---

### Q5: /dev 工作流中断如何恢复？

**原因**:
- 网络中断
- 用户主动停止

**解决方案**:
```bash
# /dev 命令会自动保存进度
# 使用 resume 恢复
/dev resume

# 查看当前状态
/dev status

# 跳到特定阶段
/dev --start-from=phase-4
```

---

### Q6: 如何禁用某个 Skill？

**方法 1: 重命名文件**
```bash
mv .claude/skills/code-review/SKILL.md .claude/skills/code-review/SKILL.md.disabled
```

**方法 2: 添加禁用标记**

在 SKILL.md 开头添加：
```markdown
# Code Review Skill

**Status**: DISABLED
**Reason**: 暂时禁用，使用手动审查

...
```

AI 会识别该标记并跳过该 skill。

---

### Q7: 如何调试 Skills？

**方法 1: 详细日志**

在交互时明确要求：
```bash
"使用 code-implementation skill 编写代码，并输出调试日志"
```

**方法 2: 单独测试**

```bash
"仅使用 code-implementation skill，不触发其他 skills"
```

**方法 3: 检查 Skill 内容**

```bash
cat .claude/skills/code-implementation/SKILL.md
```

确认规则是否正确。

---

### Q8: 团队成员的 Skills 版本不一致怎么办？

**解决方案**:

**1. 将 .claude/ 目录纳入版本控制**

`.gitignore`:
```
# 保留 .claude/ 目录
!.claude/

# 但忽略个人设置
.claude/settings.local.json
```

**2. 提交 Skills 更新**

```bash
git add .claude/skills/
git commit -m "chore: 更新 code-implementation skill 到 v2.1.0"
git push
```

**3. 团队成员拉取**

```bash
git pull
```

**4. 验证版本**

```bash
"检查当前 skills 版本"
```

AI 会读取所有 SKILL.md 并输出版本号。

---

## 总结

### Claude Code Skills 核心价值

1. **标准化流程** - 统一需求分析、代码审查、Bug 诊断流程
2. **自动化工作** - Hooks 自动格式化，code-review 自动触发
3. **知识沉淀** - skill-learner 从每次审查中学习
4. **提升效率** - /dev 工作流完整覆盖开发全流程
5. **团队协作** - 共享 Skills，统一代码规范

### 快速上手清单

- [ ] 阅读 `.claude/README.md` 了解配置结构
- [ ] 阅读 `.claude/skills/README.md` 了解 5 个 Skills
- [ ] 尝试使用 `/dev` 命令开发一个简单功能
- [ ] 上传一张设计稿，体验 `ui-design-analysis` skill
- [ ] 故意写一段有问题的代码，观察 `code-review` 的输出
- [ ] 运行 `create-activity.sh` 脚本生成模板
- [ ] 修改一个 .kt 文件，观察 `post-edit` hook 是否执行

### 持续优化建议

1. **定期审查 Skills**: 每月检查一次 Skills 是否需要更新
2. **记录学习案例**: 将常见问题整理为学习案例
3. **团队分享**: 定期分享 Skills 使用技巧
4. **自定义扩展**: 根据项目特点添加自定义 Skills
5. **版本控制**: 将 .claude/ 目录纳入 Git，团队协作

---

**文档结束**

如有疑问，请参考：
- `.claude/README.md` - 配置概览
- `.claude/skills/README.md` - Skills 能力清单
- `CLAUDE.md` - 项目架构文档

或直接询问 Claude Code：
```
"如何使用 requirement-clarification skill？"
"/dev 命令有哪些参数？"
"如何自定义一个 skill？"
```
