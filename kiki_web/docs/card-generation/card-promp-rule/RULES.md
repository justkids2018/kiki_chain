# Prompt Rules (Unified)

这份文件是学习卡片 Prompt 的唯一规则入口，分为三层：

1. 写死规则（必须遵守）
2. 场景强化（可迭代）
3. 组装流程（可执行）

---

## 1) 写死规则（必须遵守）

### 输出硬约束

- 必须是 1024x1024 正方形。
- 目标词条数必须从当前卡片 `<card>.md` 的 `### III. N Target Vocabulary Objects` 段读取，记为 `N`。
- 必须是 `N` 个目标物体。
- 必须是 `N` 张标签卡片。
- 必须是 `N` 个箭头。
- 不允许使用默认 8 个覆盖当前 md 的实际词条数；若 md 是 7/8/10 个词，图片、标签、箭头和 JSON 都必须对应 7/8/10。
- 当前 md 的 `### III` 词表是唯一允许学习的闭合集合：不得替换、改写、增删、扩展或用近义词代替任何词条。
- 图片中的 `N` 张标签卡片只能使用 `### III` 中逐行列出的 `[pinyin] / hanzi / english`，不得生成任何不在 md 词表内的标签词。
- 场景装饰物允许存在，但只能作为无标签背景；不得让装饰物获得标签卡片或箭头，不得把装饰物当成目标物体。
- 必须完整使用画布，无内边框、无大面积空白。
- 每张卡片必须是完整页面场景，且具备前景/中景/后景的分层空间。
- 每张卡片必须固定出现 2 个可爱小女孩（姐妹）+ 1 只可爱的白色小猫。
- 人物与小猫的固定/随机细则统一引用：`card-promp-rule/components/CHARACTER_CAST.md`。
- 画布、视角、整体风格锁统一引用：`card-promp-rule/components/CANVAS_STYLE.md`。
- 生成前质量门禁统一引用：`card-promp-rule/components/QUALITY_GATE.md`。

### 三行文本铁律

每张标签卡片固定三行，顺序不可变：

1. `[pinyin]`
2. `hanzi`
3. `english`

禁止出现任何污染标记：

- `[cite:x]`、`[ref:x]`、`[source:x]`
- 上标序号、括号序号、额外注释
- 超出三行结构的任何文本

### 词表闭集铁律

- `### III` 中每一行词条必须逐字出现在对应标签卡片中。
- 不允许把词条替换成同类物、近义词、上位词或更常见物体。
- 不允许新增任何不在 `### III` 中的标签卡片。
- 如果场景需要额外环境元素，它们必须保持无标签、无箭头、低视觉权重。

### 箭头铁律

- 每个箭头必须触达目标物体本体。
- 箭头不能交叉，不能悬空，不能指向背景。
- `N` 个箭头风格必须一致。

### 品牌与视觉铁律

- 角标只能是 `Hi Kiki` 单行，固定右上角。
- 禁止大标题、无关装饰、过度拥挤。
- 禁止影响物体识别的统一重着色。

### 生成前强制检查

- DIRTY TEXT SCAN
- CLOSED VOCAB SCAN
- COUNT CHECK
- MAPPING CHECK
- ARROW PRECISION
- VISUAL CHECK

任一项失败必须重生成。

---

## 2) 场景强化（可迭代）

允许强化的内容：

- 场景锚点（墙/地面/家具/空间基准）
- 易混淆对象对的区分规则
- 小物体可见性增强策略
- 氛围和光照描述

不允许强化的内容：

- 不能修改写死规则的语义
- 不能弱化三行文本与脏标记禁令
- 不能改变 `N` 对象 / `N` 卡片 / `N` 箭头约束
- 不能删除或替换"10 岁姐姐 + 4 岁双马尾妹妹 + 可爱白色小猫"基础角色配置
- 不能违反 `components/CHARACTER_CAST.md` 中的固定约束

四类场景强化方向：

- 晨光乐趣：校园/课堂/晨间活动语义
- 数学思维：可计数、可配对、认知清晰分组
- 日常生活：真实生活空间与自然摆放
- 游乐场景：想象力与可识别性平衡

---

## 3) 组装流程（可执行）

数据源：

- 词表来源：当前卡片目录下的 `<card>.md`，只读取 `### III. N Target Vocabulary Objects` 段
- 模板来源：`card-promp-rule/PROMPT_REAL_SCENE.md`
- 组件来源：`card-promp-rule/components/*`
- 场景预设来源：`card-promp-rule/scene-presets/*`
- 对象防混淆规则来源：`card-promp-rule/object-rules/*`
- 单卡变量协议：`card-promp-rule/assembly/CARD_PROMPT_SCHEMA.md`

组装层次：

1. 画布与风格锁注入
2. 场景预设注入
3. 人物与小猫注入
4. 卡片词表、词条数量 `N` 与落点映射注入
5. 标签、文字、箭头、角标组件注入
6. 生成前质检注入

每张卡片目录交付物：

- `kik_场景_01_功能.md`
- `prompt.md`（同内容）
- `kik_场景_01_功能.png`
- `kik_场景_01_功能.json`

执行命令：

```bash
python3 scripts/card_generation/generate_prompts_from_scenes.py
```

验证与同步：

1. 先用 `hotspot-preview.html` 做叠加校验
2. 每张卡片保留一张校验截图
3. 校验通过后再同步到运行时 assets
