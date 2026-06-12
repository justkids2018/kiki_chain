# 学习卡片生产全流程（Prompt -> 图片 -> JSON -> 校验 -> Admin）

本文档是可执行 SOP。目标是把每张卡片从 Markdown Prompt 一路产出到后台可上线数据。

## 0. 产物标准

每张卡片固定目录：

`kiki_web/doc/card-generation/scene-info/<scene_slug>/<card_slug>/`

同目录固定文件：

1. `<card_slug>.md`：给 Banana 的完整 Prompt（PRO），唯一可信来源
2. `prompt.md`：兼容入口，必须与 `<card_slug>.md` 完全一致；若不一致，禁止使用 `prompt.md`
3. `<card_slug>.png|jpg|webp`：生成并下载的图片
4. `<card_slug>.json`：items_data 热区 JSON

## 1. 生成卡片 Prompt（PRO）

### 1.1 批量生成

在 `kiki_web/` 下执行：

```bash
python3 scripts/card_generation/generate_prompts_from_scenes.py
```

### 1.2 人工确认

必须确认：

1. 每个卡片目录都有 `<card_slug>.md`
2. Prompt 是完整可复制版本，不依赖外部规则链接
3. `prompt.md` 若存在，内容与 `<card_slug>.md` 完全一致
4. `scene-info/index.json` 已更新

### 1.3 词条数量门禁

生图前必须从 `<card_slug>.md` 的 `### III. N Target Vocabulary Objects` 段读取词条数 `N`：

1. 图片必须生成 `N` 个目标物体
2. 图片必须生成 `N` 张标签卡片
3. 图片必须生成 `N` 根箭头
4. JSON 必须输出 `N` 个词条
5. 图片中的每张标签卡片必须逐字来自 md 的 `### III` 词表行
6. 图片中不得出现词表外标签词；额外场景物只能作为无标签背景

禁止把 8 个当成默认值覆盖 md。当前允许 7/8/10 等不同数量，只要 md 声明数量、词条行数、标签数、箭头数完全一致。

## 2. 去 Google / Gemini（Banana）生成图片

### 2.1 打开与模型设置

1. 打开 Gemini（Google）
2. 选择 Banana（你当前使用的图像生成模式）
3. 新建会话，粘贴 `<card_slug>.md` 全文

### 2.2 生成与筛选

1. 先生成第一版
2. 重点检查：主体是否齐全、中文卡片是否可读、场景是否符合 Prompt
3. 不满足就直接迭代重生，不要进入下一步
4. 若只有 1-2 个箭头或对象错配，也必须在图片阶段重生或人工修正，不能寄希望于 JSON 热区修复
5. 若图片出现 md 词表外的标签词、替换词或缺少 md 词条，直接判定失败并重生

### 2.3 下载与落盘

1. 下载最终图
2. 重命名为 `<card_slug>.<ext>`（建议 `jpg`）
3. 放到卡片目录：

`kiki_web/doc/card-generation/scene-info/<scene_slug>/<card_slug>/<card_slug>.<ext>`

## 3. 用技能生成热点 JSON（图片 -> items_data）

使用 `just-hotspot-generator`，输入：

1. 图片路径：`<card_slug>.<ext>`
2. 词汇来源：`<card_slug>.md`
3. 输出路径：`<card_slug>.json`

生成后要求：

1. JSON 根节点为数组
2. 使用词条分组结构（每词 `regions`）
3. 坐标基于 1024x1024，点位为整数

## 4. HTML 校验 + 打分（必须）

使用：

`kiki_web/doc/card-generation/hotspot-preview.html`

### 4.1 加载方式

1. 填 `baseRoot`
2. 填 `scene_slug` 和 `card_slug`
3. 点击 `按 scene/card 自动生成路径`
4. 点击 `加载并绘制`

### 4.2 评分规则

页面内置 100 分评分，包含：

1. 尺寸是否 1024x1024
2. 坐标格式（四点、整数）
3. 越界情况
4. 重复热区
5. 过小热区（card >= 48x48, object >= 36x36）
6. 跨词重叠风险（>10%）

通过门槛：

1. **分数 >= 89**
2. 页面显示 PASS

不通过处理：

1. 若只是坐标框偏差，回到 JSON 调整坐标
2. 若图片本身箭头落点、标签映射、目标物体数量错误，必须回到图片生成环节重做图片

## 5. 上传 Admin（详情页添加）

### 5.1 登录后台

1. 登录 `kiki_admin`
2. 进入对应内容详情页
3. 点击 `添加`

### 5.2 填写字段

按当前约定固定：

1. `type`：`chinese`
2. 图片：上传 `<card_slug>.<ext>`
3. 热区 JSON：上传或粘贴 `<card_slug>.json`

### 5.3 提交前复核

1. 图片与 JSON 文件名必须同名（仅扩展名不同）
2. 预览点击区域与标注一致
3. 仅当评分 >= 89 才允许提交

### 5.4 提交

1. 点击保存/提交
2. 记录卡片结果（成功/失败原因）

## 6. 一键复用建议（操作顺序）

单卡建议执行顺序：

1. 打开该卡目录，复制 `<card_slug>.md`，不要复制 stale `prompt.md`
2. Gemini(Banana) 生成并下载 `<card_slug>.jpg`
3. 运行 `just-hotspot-generator` 产出 `<card_slug>.json`
4. 用 `hotspot-preview.html` 打分，要求 >=89
5. 进入 Admin 上传并提交

批量建议：

1. 先批量生成全部图片
2. 再批量生成 JSON
3. 最后统一做评分校验和后台上传
