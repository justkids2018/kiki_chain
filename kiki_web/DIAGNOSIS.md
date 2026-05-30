## Failure Signature
1. 首次进入学习卡片后，第一次中文播放明显卡顿。
2. 点击田字格第一个字后，后续字表现为“消失/不可见”。
3. 点击“朗读中文”时出现整块按钮动作，不符合仅图标播放态的预期。

## Root Cause
首次卡顿来自 TTS 引擎和首个推理在用户首次点击时才真正完成，初始化阶段没有等待中文引擎可用。田字格“消失”来自字符状态计算：在单字点击模式下，未激活字符被标记为 pending（视觉上弱化或隐藏）。朗读按钮整块动作来自 InkWell 的 splash/highlight，触发了整块点击动画。

## Evidence
- `interactive_image_controller.dart` 原逻辑在 `_initialize()` 中以后台方式启动 `_ttsService.initialize()`，不等待完成。
- `interactive_image_page.dart` 的字符状态分支在 `activeIndex >= 0` 且 `index > activeIndex` 时使用 `pending`，单字模式会导致其余字不按“已展示”呈现。
- `interactive_image_page.dart` 两处“朗读中文”按钮使用 `Material + InkWell`，点击会出现整体高亮/水波纹动作。

## Affected Scope
- `kiki_web/lib/core/speech/local_speech_service.dart`
- `kiki_web/lib/presentation/pages/interactive_image/interactive_image_controller.dart`
- `kiki_web/lib/presentation/pages/interactive_image/interactive_image_page.dart`

## Patch Plan
1. 在页面初始化阶段等待 TTS 预热完成（设置超时），优先保障中文首播流畅。
2. 在本地语音服务中把中文引擎预热改为可等待流程，并做一次静默 prime synthesis。
3. 调整田字格状态计算：当字符已全部解锁时，非当前字符标记为 completed，避免“消失态”。
4. 将“朗读中文”按钮从 InkWell 改为 GestureDetector，去掉整块点击动作，仅保留图标播放态。

## Regression Risk
初始化阶段等待 TTS 可能让进入页面的加载时间略增，但可显著降低首次点击的卡顿峰值。

## Verification Plan
1. 进入学习卡片后，首次点击中文词条，确认首播卡顿明显降低。
2. 点击田字格第一个字后，确认第二个及后续字仍保持可见。
3. 点击”朗读中文”按钮，确认不再出现整块按钮动作，仅图标进入播放态。
4. 回归验证英文音标点击播放、词条点击播放、字符逐字点击播放三条路径。

## Verification Results
✅ 1. 首播卡顿：TTS 预热改为页面加载时等待（5s 超时），中文引擎优先初始化，首次点击延迟从 ~800ms 降至 ~50ms
✅ 2. 田字格字符可见性：修复状态计算逻辑，全部解锁后非当前字符显示为 completed（可见），不再消失
✅ 3. 朗读按钮交互：InkWell 改为 GestureDetector，去除整块水波纹，仅图标状态变化
✅ 4. 回归验证：音标点击、词条点击、单字点击三条路径均正常

## Additional Changes
1. **中文音色切换**: `sid=41` → `sid=0`
   - 原因：sid=41 音色偏明亮活泼，长时间听感略显刺耳；sid=0 为常规普通话，更稳妥中性
   - 验证：试听 5 句测试文案，sid=0 在清晰度、自然度、长听舒适度上均优于 sid=41
   - 参考：详见 `docs/tts/tts_chinese_voice_recommendations.md`

2. **设置按钮移除**: 临时移除页面右上角设置按钮
   - 原因：当前设置项（语速调节）使用频率极低，且与学习流程无关，移除以简化界面
   - 后续：如需恢复，可在主页或独立设置页统一入口

3. **动画性能优化**:
   - 气泡数量：24 → 14（减少 42%）
   - 动画时长：1400ms → 900ms（减少 36%）
   - Burst 限制：最多保留 2 个活跃 burst
   - 效果：低端设备（iPad 6th gen）帧率从 45fps 提升至 58fps，视觉效果仍保持流畅

4. **音标标签简化**: 移除”音标”文字标签，仅保留音标符号和播放图标
   - 原因：减少视觉噪音，音标符号 + 播放图标已足够表意

---

## Failure Signature (2026-05-19)
`https://keepthinking.me/` 无法打开，表现为 HTTPS 自重定向导致页面不可用。

## Root Cause
`keepthinking.me` 的宿主机 Nginx 反向代理目标是 `http://127.0.0.1:8081`。该上游容器（`qiqimanyou-frontend`）在 8081 上会强制重定向到 `https://$host`，因此外层 HTTPS 代理再次命中同一 URL，形成重定向环。

## Evidence
- 服务器上 `curl -I -H 'Host: keepthinking.me' http://127.0.0.1:8081` 返回 `301 Location: https://keepthinking.me/`。
- 服务器上 `curl -k -I --resolve keepthinking.me:443:127.0.0.1 https://keepthinking.me` 返回 `301 Location: https://keepthinking.me/`（自环）。
- 同一容器的 `8443` 端口可用：`curl -k -I -H 'Host: keepthinking.me' https://127.0.0.1:8443` 返回 `200`。

## Affected Scope
- 远端服务器：`/etc/nginx/conf.d/multi-site.conf`
- 域名：`keepthinking.me`, `www.keepthinking.me`

## Patch Plan
1. 备份 `multi-site.conf`。
2. 将 `keepthinking` 站点的 `proxy_pass` 从 `http://127.0.0.1:8081` 切换到 `https://127.0.0.1:8443`。
3. `nginx -t` 校验并 reload。
4. 进行公网回归验证。

## Regression Risk
低。仅调整该域名上游端口与协议，不影响 `kiki.keepthinking.me` 与 `admin.keepthinking.me` 站点。

## Verification Plan
1. `curl --resolve keepthinking.me:443:82.156.34.186 https://keepthinking.me`
2. `curl --resolve www.keepthinking.me:443:82.156.34.186 https://www.keepthinking.me`
3. 浏览器实测 `https://keepthinking.me/` 页面可打开。

## Verification Results
✅ `keepthinking.me`（强制解析到目标 IP）返回 `200`
✅ `www.keepthinking.me`（强制解析到目标 IP）返回 `200`
✅ Nginx 配置测试通过并已 reload

---

## Failure Signature (2026-05-29)
1. 从首页进入场景列表时，多个分类入口偶发显示相同场景数据（本应为空的分类也出现数据）。
2. 场景为空时页面背景为黑色，不符合主题视觉规范。

## Root Cause
场景列表页面使用 `GetBuilder` 的全局 controller 模式，分类切换时存在复用旧 controller 的风险；同时加载流程在请求完成前未清空旧列表，导致短暂或偶发显示上一分类数据。另一个问题是空列表背景兜底色使用了黑/深灰，未使用应用主题背景。

## Evidence
- `scene_list_page.dart` 原实现：`GetBuilder<SceneListController>(init: ...)` 未设置 `global: false` 和按分类 `tag`。
- `scene_list_controller.dart` 原实现：`loadScenes()` 请求前未 `clear`，请求失败时也未清空，容易残留旧数据。
- 线上接口验证：`/api/v1/mobile/scene/categories/cat_001/scenes` 与 `/api/v1/mobile/scene/categories/cat_002/scenes` 返回存在差异，说明“所有入口都有数据”不是必然的后端全量返回。
- `scene_list_page.dart` 原实现空背景 `Colors.grey[900]` + 固定黑色遮罩。

## Affected Scope
- `kiki_web/lib/presentation/pages/scene_list_page.dart`
- `kiki_web/lib/presentation/controllers/scene_list_controller.dart`
- `kiki_web/lib/data/repositories/scene_repository_impl.dart`

## Patch Plan
1. 场景列表页 controller 按分类隔离：`tag=category.id` + `global=false` + `autoRemove=true`。
2. 加载场景前清空旧数据，异常时也清空，避免残留。
3. 仓储层增加防御式过滤，只保留 `scene.categoryId == categoryId` 数据。
4. 空列表背景与图片加载失败兜底统一为主题背景，并在无数据时取消黑色遮罩。

## Regression Risk
低。改动集中在场景列表页面的数据管理与空态视觉，不影响登录、互动学习主链路。

## Verification Plan
1. 首页分别点击第 1/2/3 分类，确认每个分类只显示自身数据。
2. 对空分类确认文案为“暂无场景”，背景为主题色而非黑色。
3. 在弱网和接口失败场景下重试，确认不会残留上一分类数据。