# 笔迹功能需求澄清提示词（Android）

## 适用场景

用户提出"添加笔迹功能"、"手写支持"或类似需求时使用。

适用于：Android 手写笔应用、教育批改系统、笔记应用、电子白板等需要笔迹捕获和处理的场景。

## 核心问题（5个）

### 问题 1：笔迹捕获方式
**如何捕获笔迹数据？**

**建议选项**：
- 硬件笔（通过蓝牙协议，如本项目的 YQ 智能笔）
- 触摸屏手写（Android MotionEvent）
- 主动笔（如 S Pen）
- 混合模式（支持多种输入）

**追问**：
- 是否需要压感支持？
- 是否需要笔尖角度识别？
- 是否支持多点触控/多支笔同时书写？
- 笔迹数据采样率要求？（Hz）

### 问题 2：笔迹显示模式
**笔迹在界面上如何展示？**

**选项**：
- [ ] 自由绘制模式（全屏书写）
- [ ] 区域限制模式（只能在指定区域书写，如作业题目区域）
- [ ] 多页模式（ViewPager2 切换页面）
- [ ] 分区模式（页面划分多个独立书写区）
- [ ] 背景图叠加模式（在图片上书写）

**追问**：
- 是否需要实时同步显示？
- 是否需要笔迹平滑处理？
- 是否需要笔迹颜色/粗细调整？
- 背景图如何处理？（缩放、平移、固定）

### 问题 3：笔迹数据处理
**笔迹数据如何存储和传输？**

**数据格式选项**：
- Protobuf（高效，适合大数据量，如本项目使用 MsgPb.Msg）
- JSON（可读性好，调试方便）
- 自定义二进制格式
- SVG Path（Web 兼容）

**存储方案**：
- [ ] 本地 SQLite 数据库
- [ ] 本地文件（.dat/.pb）
- [ ] 服务器实时上传
- [ ] 混合方案（本地缓存 + 定期上传）

**追问**：
- 笔迹数据量预估？（每天多少笔迹？）
- 是否需要历史笔迹回放？
- 是否需要离线支持？
- 数据同步策略？（实时/定时/手动）

### 问题 4：笔迹交互功能
**用户可以对笔迹进行哪些操作？**

**选项**：
- [ ] 撤销/重做（Undo/Redo）
- [ ] 清空笔迹（单页/全部）
- [ ] 橡皮擦（擦除部分笔迹）
- [ ] 笔迹选择和移动
- [ ] 笔迹缩放
- [ ] 笔迹导出（图片/PDF）
- [ ] 笔迹识别（OCR 识别文字）

**追问**：
- 橡皮擦模式？（按笔画擦除 vs 按区域擦除）
- 导出格式？（PNG/JPG/PDF）
- 导出分辨率要求？

### 问题 5：特殊场景支持
**是否有特殊的业务场景？**

**本项目特有场景**：
- [ ] 教师批改场景（红笔批注、打分）
- [ ] 学生答题场景（填空题区域限制）
- [ ] 直播同屏场景（实时展示笔迹给观众）
- [ ] 多学生多页面场景（ViewPager2 切换不同学生作业）
- [ ] 截图和数据导出（用于提交批改结果）

**追问**：
- 是否需要笔迹权限控制？（谁可以书写？）
- 是否需要笔迹冲突检测？（多人同时书写）
- 是否需要笔迹回放功能？
- 是否需要笔迹统计？（书写时长、笔画数）

## 常见陷阱

⚠️ **陷阱 1**：忘记处理生命周期
- 问题：Activity 销毁时笔迹丢失
- 解决：在 onSaveInstanceState 保存状态，onDestroy 时保存数据

⚠️ **陷阱 2**：主线程绘制导致卡顿
- 问题：大量笔迹在主线程绘制，界面卡顿
- 解决：使用 SurfaceView 或 TextureView，后台线程绘制

⚠️ **陷阱 3**：内存泄漏
- 问题：Bitmap 未回收，笔迹 Path 对象未清理
- 解决：及时 recycle Bitmap，清空不需要的 Path

⚠️ **陷阱 4**：坐标系转换错误
- 问题：笔迹坐标与实际显示位置不匹配
- 解决：正确处理 PhotoView 的 Matrix 变换，图片坐标 → 屏幕坐标

⚠️ **陷阱 5**：协程未取消导致崩溃
- 问题：异步操作时 View 已销毁
- 解决：使用 lifecycleScope，检查 isActive

⚠️ **陷阱 6**：笔迹数据丢失
- 问题：App 崩溃或强制关闭时数据未保存
- 解决：实时保存到数据库，使用 WorkManager 定期备份

## 输出模板

基于用户回答，生成需求概要：

```markdown
## 笔迹功能需求（Android）

### 核心信息
- **捕获方式**：[硬件笔 / 触摸屏 / 主动笔]
- **硬件型号**：[YQ 智能笔 / S Pen / 通用]
- **连接方式**：[蓝牙 BLE / USB / 无线]
- **采样率**：[100Hz / 200Hz / 自适应]

### UI 设计
- **显示模式**：[自由绘制 / 区域限制 / 多页模式]
- **背景处理**：
  - 背景图来源：[本地 / 服务器 URL]
  - 缩放模式：[PhotoView 可缩放 / 固定比例]
  - 背景图分辨率：[1080x1920 / 自适应]
- **笔迹样式**：
  - 颜色：[黑色 / 红色 / 可选]
  - 粗细：[3dp / 可调节]
  - 透明度：[100% / 可调节]

### 数据处理
- **数据格式**：[Protobuf (MsgPb.Msg) / JSON]
- **存储方案**：
  - 本地：[SQLite (YQDbLineEntity) / 文件]
  - 服务器：[实时上传 / 定期同步]
- **压缩策略**：[Protocol Buffers / 无压缩]
- **数据量预估**：[每天 1000 笔 / 每笔 50KB]

### 功能范围
- [x] 实时笔迹绘制
- [x] 笔迹持久化（SQLite）
- [x] 撤销/重做（最近 20 步）
- [x] 清空笔迹
- [ ] 橡皮擦功能
- [x] 截图导出（PNG）
- [x] 数据导出（.dat 文件）
- [ ] OCR 识别
- [x] 历史笔迹加载

### 特殊场景
- **教师批改**：
  - 红笔模式：[支持]
  - 打分功能：[支持]
  - 批注模板：[预设评语]
- **区域限制**：
  - 限制模式：[FILL_BLANK / SUBAREA_DISPLAY]
  - 区域检测：[实时检测笔迹是否在区域内]
  - 区域外处理：[不绘制 / 灰显]
- **多页面**：
  - 页面切换：[ViewPager2]
  - 页面数量：[1-50 页]
  - 独立绘制：[每页独立 DrawView]

### 性能优化
- **绘制优化**：
  - Canvas 硬件加速：[开启]
  - 离屏渲染：[SurfaceView]
  - Path 简化：[Douglas-Peucker 算法]
- **内存优化**：
  - Bitmap 复用池：[开启]
  - 笔迹分页加载：[按需加载]
  - 定期清理：[LRU 缓存]
- **卡顿优化**：
  - 绘制线程：[后台线程]
  - 数据保存：[协程 Dispatchers.IO]
  - 防抖处理：[300ms]

### 技术选型
- **绘制组件**：[DrawView (自定义 View) / SurfaceView]
- **图片加载**：[Glide / Coil]
- **图片缩放**：[PhotoView (chrisbanes)]
- **数据库**：[Room / SQLite]
- **协程**：[Kotlin Coroutines]
- **网络**：[Retrofit / OkHttp]
- **协议**：[Protobuf / JSON]

### 边界条件
- **权限要求**：[蓝牙 / 存储 / 网络]
- **最低 Android 版本**：[API 21 (Android 5.0)]
- **设备要求**：[触摸屏 / 压感笔支持]
- **离线支持**：[完全离线 / 需要联网]
- **并发控制**：[单人书写 / 多人协作]

### 数据迁移
- **现有数据兼容**：[检查旧版本数据格式]
- **迁移策略**：[一次性迁移 / 渐进式]
- **回滚方案**：[保留原始数据备份]
```

## 技术建议（Android/Kotlin）

### 1. 自定义 DrawView
```kotlin
class DrawView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    private val paint = Paint().apply {
        color = Color.BLACK
        strokeWidth = 3f.dp
        style = Paint.Style.STROKE
        isAntiAlias = true
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }

    private val paths = mutableListOf<Path>()
    private var currentPath: Path? = null

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        paths.forEach { canvas.drawPath(it, paint) }
        currentPath?.let { canvas.drawPath(it, paint) }
    }

    fun addPenMessage(msg: MsgPb.Msg) {
        val path = Path()
        msg.dotsList.forEachIndexed { index, dot ->
            val (x, y) = convertCoordinates(dot.x, dot.y)
            if (index == 0) path.moveTo(x, y)
            else path.lineTo(x, y)
        }
        paths.add(path)
        invalidate()
    }

    fun clear() {
        paths.clear()
        currentPath = null
        invalidate()
    }
}
```

### 2. 笔迹数据持久化
```kotlin
// Entity
@Entity(tableName = "pen_strokes")
data class YQDbLineEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val pageId: String,
    val timestamp: Long,
    val data: ByteArray  // Protobuf 序列化数据
)

// Repository
class PenRepository(private val dao: PenDao) {
    suspend fun saveStroke(msg: MsgPb.Msg, pageId: String) = withContext(Dispatchers.IO) {
        val entity = YQDbLineEntity(
            pageId = pageId,
            timestamp = System.currentTimeMillis(),
            data = msg.toByteArray()
        )
        dao.insert(entity)
    }

    suspend fun loadStrokes(pageId: String): List<MsgPb.Msg> = withContext(Dispatchers.IO) {
        dao.getByPageId(pageId).map { MsgPb.Msg.parseFrom(it.data) }
    }
}
```

### 3. 坐标转换处理
```kotlin
// PhotoView 图片坐标 → 屏幕坐标
fun mapImageRectToPhotoView(photoView: PhotoView, imageRect: RectF): RectF {
    val matrix = Matrix()
    photoView.getSuppMatrix(matrix)

    val points = floatArrayOf(
        imageRect.left, imageRect.top,
        imageRect.right, imageRect.bottom
    )
    matrix.mapPoints(points)

    return RectF(points[0], points[1], points[2], points[3])
}
```

### 4. 生命周期管理
```kotlin
class PenActivity : AppCompatActivity() {
    private val penManager by lazy { PenJinshuManager(this) }
    private var strokeJob: Job? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        penManager.initView(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        strokeJob?.cancel()
        penManager.release()
    }

    private fun saveStrokesAsync() {
        strokeJob = lifecycleScope.launch {
            try {
                penRepository.saveAllStrokes()
            } catch (e: Exception) {
                Log.e(TAG, "Save failed", e)
            }
        }
    }
}
```

## 相关资源

- **项目文档**：`CLAUDE.md` - 完整架构说明
- **核心类**：
  - `PenJinshuManager.kt` - 笔迹管理中介者
  - `DrawView.kt` - 自定义绘制 View
  - `DbManager.kt` - 数据库管理
  - `MsgPb.Msg` - Protobuf 消息定义
- **架构模式**：Mediator 模式 + MVVM
- **测试工具**：需要物理 YQ 智能笔硬件

## 成功案例

参考本项目实现：
- 自由笔记模式：`NoteType.NOTE`
- 作业填空模式：`NoteType.FILL_BLANK`
- 多页展示模式：`NoteType.NOTE_DISPLAY`
- 分区展示模式：`NoteType.SUBAREA_DISPLAY`

---

**使用方法**：
```
帮我澄清需求：添加新的笔迹书写区域
帮我设计：多页面笔迹同步功能
```
