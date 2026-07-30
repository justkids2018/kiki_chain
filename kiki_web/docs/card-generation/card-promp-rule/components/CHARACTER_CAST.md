# 角色与小猫统一 Prompt（公共引用）

本文件是学习卡片中"人物与宠物"的唯一公共规范。
所有场景 Prompt 必须直接引用本文件，不再重复手写角色描述。

## 角色阵容总览

| 角色 | 英文名 | 年龄 | 出场层级 | 出场频率 | 是否强制 |
|------|--------|------|----------|---------|
| 🐱 小白猫主角 | **Mimi** | — | L1 永远在场 | 100%（每张卡必出） | ✅ 强制 |
| 👧 姐姐 | **Yuki** | 10 岁 | L2 常驻嘉宾 | 大多数卡，可单独缺席 | ⭕ 默认在，可缺席 |
| 👶 妹妹 | **Kiki** | 4 岁 | L2 常驻嘉宾 | 大多数卡，可单独缺席 | ⭕ 默认在，可缺席 |
| 👦 邻居男孩 | **Jack** | 7 岁 | L3 场景性嘉宾 | 按场景需要，约 40-60% 卡 | ❌ 不强制，可选 |

> 注：项目代号 `kiki_chain`/`kiki_web` 是产品品牌，与角色 Kiki（妹妹）分层不冲突。
> 主角猫一律使用专名 **Mimi**（不写 cat / kitten / 小猫做名字）。

## 出场组合（合法配置）

每张卡片必须从以下组合中选 1 种，**Mimi 永远在场**：

### 三人 + 猫（最热闹，适合活动/集体场景）
- ✅ Mimi + Yuki + Kiki + Jack（四角全员，推荐用于课间游戏、放学、节日）

### 二人 + 猫（默认主流配置）
- ✅ Mimi + Yuki + Kiki（经典姐妹组，适合大多数日常场景）
- ✅ Mimi + Yuki + Jack（同龄/同班伙伴，适合校园集体活动）
- ✅ Mimi + Kiki + Jack（哥哥带妹妹玩，适合萌系互动）

### 一人 + 猫（独处/静谧场景）
- ✅ Mimi + Kiki（妹妹独处萌卡）
- ✅ Mimi + Yuki（姐姐独处书卷气）
- ✅ Mimi + Jack（男孩独自玩耍）

### 仅猫（极少数）
- ⚠️ Mimi 单独：仅限纯静物展示卡（如教室角落、空餐桌），需额外审核

## 固定约束（必须命中）

- **Mimi（白色小猫主角）100% 必出**：每张卡片画面必须包含 1 只清晰可见的白色小猫，不得被完全遮挡。
- **Yuki + Kiki（姐妹常驻）**：默认两人都在；允许 1 人临时缺席，但同卡内禁止把姐妹替换成其他女孩或换性别。
- **Jack（场景性）**：根据场景预设决定是否出场，单卡内不得出现 2 个男孩或换种族换年龄。
- **角色总数上限**：单张卡画面中人物（不含猫）≤ 3 人，避免拥挤。
- 角色必须自然融入场景，不得仅作为装饰摆件。

## 各角色穿搭与动作规则

## 跨卡角色连续性锁（所有主 Prompt 必须展开注入）

角色名字本身不足以保证一致性。只要当前卡出现 Yuki、Kiki、Jack 或 Mimi，主卡片 MD 就必须把对应角色的年龄、脸型、五官、发型、体态、身高关系和神态基线写入 fenced prompt；禁止只写 `Use Mimi + Yuki + Kiki` 后依赖模型自行理解。

### 不可变身份特征

- **脸型与五官不可变**：同一角色跨卡保持相同脸部轮廓、眼睛形状与间距、眉形、鼻形、嘴形、肤色和发色。表情变化不得改变脸部骨相或把角色画成另一张脸。
- **年龄与体态不可变**：Yuki 始终是 10 岁学龄姐姐；Jack 始终是 7 岁男孩；Kiki 始终是 4 岁幼儿。禁止三人同龄化、成人化或婴儿化。
- **身高关系不可变**：同一画面站在可比较景深时，Yuki 约为 Kiki 身高的 1.35-1.45 倍；Jack 明显高于 Kiki、略矮于 Yuki。坐姿或透视不得让 Yuki 看起来与 Kiki 同龄同高。
- **头身比例不可变**：Yuki 四肢较修长、头部占比更小；Kiki 头部占比更大、四肢更短、幼儿体态明显；Jack 介于二者之间。
- **核心发型与发色不可变**：Yuki 纯黑色长发自然散落；Kiki 棕褐色双马尾；Jack 黑色短发配可见棒球帽。三人的发色必须明显区分并跨卡保持一致，不得因场景、光线或生成批次互换发色。
- **Mimi 不可变**：白色短毛、圆脸、蓝绿色大眼、粉色鼻子、红色或金色铃铛项圈；不得变成长毛猫、其他颜色猫或不同脸型。

### 固定神态语言与有限表情库

- **Yuki**：温柔、沉静、有照顾妹妹的感觉。只使用温柔微笑、专注观察、鼓励妹妹、轻微惊喜、安静开心；禁止夸张大笑、成人妩媚、冷漠或搞怪脸。
- **Kiki**：明亮、好奇、天真、有幼儿活力。只使用明亮微笑、好奇观察、开心惊喜、专注学习、轻微委屈；禁止成人表情、夸张鬼脸或与 Yuki 完全相同的成熟神态。
- **Jack**：阳光、好奇、略带活泼。只使用开朗微笑、专注参与、开心惊喜、运动兴奋；禁止攻击性或成人化神态。
- **Mimi**：好奇、开心、安静陪伴或轻微惊讶；禁止凶猛、写实捕猎或拟人表情。
- 表情可按场景从上述集合中选择，但默认使用角色的自然微笑。**换表情不等于换脸**：眼睛轮廓、眼距、脸颊形状、鼻子和嘴部基础比例必须保持一致。

### 参考图优先级

当生成工具支持参考图时，必须同时传入当前出场角色的已批准标准参考图和姐妹身高关系图。参考图决定脸型、五官、发型、体态和身高；当前主 Prompt 只决定动作、服装、场景和本次表情。若无标准参考图，使用本文件完整身份合同，并以 `scene_05_中国节日` 及之前已确认卡片的角色视觉为连续性基线，不得采用最近一张漂移图片作为新基线。

### 🐱 Mimi（白色小猫，主角）

- **固定**：白色短毛、可爱、清晰可见、大眼睛、粉色小鼻子。
- **识别符号**：可佩戴红色小领结或铃铛项圈（可选，提升识别度）。
- **随机**：动作可为伸懒腰、趴着、睡觉、坐着盯看目标物体、跳跃、追蝴蝶。
- **禁止**：替换为其他颜色主猫（橘/黑/花）、凶猛攻击姿态、恐怖风格、拟人站立穿衣。
- **prompt 用名**：在所有英文 prompt 中统一写 `Mimi the white cat`，不写 `cat` / `kitten` 单独做主语。

### 👧 Yuki（姐姐，10 岁）

- **固定**：柔和椭圆脸、深棕色大眼、自然细眉、小巧圆鼻、柔和嘴形；黑色长发自然散落（不扎辫）；整体可爱亲和、温柔大姐姐气质。
- **默认**：优先夏季风格。
- **随机**：可根据场景季节切换为夏/秋/冬穿搭，服装可在裙子、背带裤、短袖套装、秋冬外搭之间变化。
- **冬季可选**：可佩戴白色毛绒耳暖（耳罩）等保暖配件。
- **禁止**：成人化妆造型、与季节明显冲突的极端服饰、扎双马尾（与妹妹混淆）。
- **prompt 用名**：`Yuki, the 10-year-old elder sister with long flowing hair`。

### 👶 Kiki（妹妹，4 岁）

- **固定**：饱满圆脸、深棕色圆眼、眼距略宽、短小圆鼻、明显柔软脸颊；棕褐色 2 个马尾辫、年龄感幼态、优先裙装。
- **默认**：优先夏季风格。
- **随机**：可根据场景季节切换为夏/秋/冬穿搭，可在连衣裙、背带裙、轻薄背带裤等范围变化。
- **冬季可选**：可佩戴白色毛绒耳暖（耳罩）等保暖配件。
- **禁止**：单马尾、散发、成人化妆造型。
- **prompt 用名**：`Kiki, the 4-year-old little sister with twin pigtails`。

### 👦 Jack（邻居男孩，7 岁）

- **性格基调**：开朗、爱笑、阳光帅气、爱运动、好奇心强、有点小调皮但善良。
- **固定外貌**：
  - 圆脸，大眼睛明亮，自然小虎牙感
  - 短黑发，发尾微翘有活力
  - 健康肤色（比 Yuki/Kiki 略深一点点，体现户外活动多）
  - 表情常态：笑着、好奇地观察周围
- **固定服装（基础款，跨卡识别）**：
  - 上衣：黄色 / 橙黄色短袖 T 恤（可有简单卡通图案：小恐龙、小火箭、星星、闪电等）
  - 下装：深蓝色或卡其色短裤（夏）/ 同色长裤（秋冬）
  - 鞋子：白色运动鞋 + 彩色鞋带
- **🧢 标志性配件：棒球帽**（浅蓝色或红色，可与 T 恤配色协调）
  - 户外/运动/玩耍场景：戴帽（默认正戴，运动时可反戴）
  - 室内安静场景（图书角、午睡）：可摘下挂在书包上或拿在手里，但帽子必须在画面内可见
  - 帽子是 Jack 的核心识别符号，**任何场景都必须有帽子（戴或拿）**
- **季节/场景变体**：
  - 春节：红色唐装外套 + 帽子
  - 中秋：浅色 polo 衫 + 帽子
  - 雨天：黄色雨衣（帽子收起在书包）
  - 运动场景：运动短裤 + 帽子反戴
- **禁止**：长发、戴眼镜、文静书呆子造型、与 Yuki/Kiki 服装撞色完全雷同。
- **prompt 用名**：`Jack, the 7-year-old cheerful neighbor boy with a baseball cap`。

## 出场决策原则（场景性嘉宾 Jack）

设计每张卡时按以下逻辑决定 Jack 是否出场：

| 场景特征 | Jack 出场建议 |
|----------|--------------|
| 户外运动/集体游戏（操场、课间、放学路上） | ✅ **强烈建议** |
| 校园集体活动（升旗、音乐律动、午餐） | ⭕ 可选，加进来更热闹 |
| 中性日常（晨读、手工课、教室整理） | ⭕ 可选 |
| 静谧观察/私密家庭（图书角、午睡、校园花园） | ❌ 建议没有，保留 Mimi+姐妹 |
| 节日热闹场景（春节、中秋、元宵） | ✅ 强烈建议（邻居小伙伴自然出现） |
| 节日家庭场景（团圆饭、贴春联） | ❌ 建议没有，保留家庭感 |

**单场景 12 张卡 Jack 总出场数建议：5-7 张**，做到"经常出现但非每张"。

## 标准引用片段（直接粘贴到 prompt）

将以下段落根据当前卡的角色组合**选择性**注入：

### 模板 A：四人 + 猫（全员）
```md
角色与宠物（统一规则，必须满足）：
1) Mimi：1 只可爱的白色小猫主角，清晰可见，自然融入场景。
2) Yuki：10 岁姐姐，长发散着，季节适配穿搭。
3) Kiki：4 岁妹妹，2 个马尾辫，优先裙装。
4) Jack：7 岁开朗邻居男孩，黄色/橙色 T 恤 + 棒球帽（戴或拿在手），健康肤色。
5) 角色动作要适配当前场景主题，自然互动。
6) 不允许替换、增加或删除任何角色；总人数（不含猫）≤ 3 人。
```

### 模板 B：姐妹 + 猫（默认主流）
```md
角色与宠物（统一规则，必须满足）：
1) Mimi：1 只可爱的白色小猫主角，清晰可见。
2) Yuki：10 岁姐姐，长发散着。
3) Kiki：4 岁妹妹，2 个马尾辫，优先裙装。
4) 穿搭默认夏季；可根据场景切换秋/冬风格。
5) 冬季场景可随机加入白色毛绒耳暖等保暖配件。
6) 小猫动作允许随机（伸懒腰/趴着/睡觉/盯看），需自然融入场景。
```

### 模板 C：男孩 + 1 个女孩 + 猫
```md
角色与宠物（统一规则，必须满足）：
1) Mimi：1 只可爱的白色小猫主角，清晰可见。
2) Yuki / Kiki（二选一，按当前卡指定）。
3) Jack：7 岁开朗男孩，黄色/橙色 T 恤 + 棒球帽，健康肤色。
4) 男孩与女孩自然互动（玩耍、交谈、合作）。
5) 总人数（不含猫）= 2 人。
```

### 必加尾段：英文身份连续性合同

以下尾段必须添加到所有包含品牌角色的英文主 Prompt；再根据当前阵容删除未出场角色的行：

```text
Character identity continuity is a hard requirement. These must be the same approved recurring Hi Kiki characters, not newly designed generic children or a different cat.
- Yuki: the same 10-year-old elder sister, soft oval face, deep-brown eyes, natural thin brows, small rounded nose, gentle mouth shape, long flowing pure-black hair, and a taller slender school-age body. Her emotional baseline is warm, calm, and caring.
- Kiki: the same 4-year-old younger sister, full round face, slightly wide-set round deep-brown eyes, small round nose, soft cheeks, two warm chestnut-brown pigtails, a shorter toddler body, and a larger head-to-body ratio. Her emotional baseline is bright, curious, and innocent.
- Jack: the same 7-year-old cheerful boy, round energetic face, bright dark eyes, short slightly tousled black hair, healthy skin tone, and a visible baseball cap. His height is between Yuki and Kiki.
- Mimi: the same white short-haired cat, round face, blue-green eyes, pink nose, and bell collar.
- Preserve the exact same face geometry, eye shape and spacing, skin tone, character-specific hair color, age, body proportions, and signature silhouette across every card. Yuki has pure-black hair, Kiki has warm chestnut-brown hair, and Jack has black hair. Lighting may add soft highlights but must never swap or homogenize these base hair colors. At comparable depth, Yuki is approximately 1.35-1.45 times Kiki's height. Expression may be selected from the approved expression library for the current scene, but expression changes must never redesign the face. Do not make Yuki and Kiki look the same age or height.
```

## 质检清单（人物与宠物）

- [ ] Mimi（白色小猫）出现且清晰可见（必须）。
- [ ] 当前卡指定的人物组合全部到位，没有多人也没有少人。
- [ ] Yuki 散发、Kiki 双马尾的核心识别正确，未被混淆。
- [ ] Yuki 与 Kiki 的脸型、五官、肤色和发色符合统一身份合同，没有出现“同名不同脸”。
- [ ] 可比较景深下 Yuki 约为 Kiki 身高的 1.35-1.45 倍；Kiki 幼儿头身比明显。
- [ ] 表情来自有限表情库，角色神态基调一致，且表情变化没有改变脸型与五官结构。
- [ ] Mimi 保持白色短毛、圆脸、蓝绿色大眼、粉鼻和铃铛项圈。
- [ ] Jack 在画面内（如果该卡有 Jack），且**棒球帽可见**（戴或拿）。
- [ ] 服装符合场景季节（默认夏季，秋冬切换需合理）。
- [ ] 所有角色保持清晰可见，未喧宾夺主，不挡核心目标物体。
- [ ] 角色动作与当前场景语义匹配（学习/运动/进餐/休憩等）。
- [ ] 没有出现规则外角色（其他男孩、其他女孩、其他动物）。
