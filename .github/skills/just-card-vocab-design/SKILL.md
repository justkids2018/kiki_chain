---
name: just-card-vocab-design
description: 学习卡片词条与角色阵容设计技能。用于为新场景/新卡片选词、查重、去重、设计 8 个目标词条，并按"Mimi 必出 + Yuki/Kiki 常驻 + Jack 场景性"角色规则决定角色组合。强制场景合理性、跨卡去重门禁、角色出场层级。
---

# just-card-vocab-design

## 触发场景

- 卡片词条设计、选词、换词、查重、去重
- 多卡之间出现"一样的词"、"重复词"、要求"换一批"
- 生成新卡 / 新场景 / 拓展第 N 张卡
- 用户提到 vocab / 词表设计 / 八个词条 / 8 words
- 用户提到角色搭配 / 谁出场 / 男孩女孩搭配 / 出场组合 / Jack 出不出
- 用户问"这卡里要画几个人"、"姐妹和男孩怎么搭"

## 单一事实源

按以下顺序读取，全部以这些文件为准，**不得脑补**：

1. `kiki_web/docs/card-generation/card-promp-rule/RULES.md` —— 全局硬约束 §1
2. `kiki_web/docs/card-generation/card-promp-rule/scene-presets/scene_<NN>_*.md` —— 当前场景背景与禁忌
3. `kiki_web/docs/card-generation/card-promp-rule/components/CHARACTER_CAST.md` —— **角色阵容（Mimi/Yuki/Kiki/Jack）**
4. `kiki_web/docs/card-generation/card-promp-rule/CARD_PROMPT_SCHEMA.md` —— 卡片 8 章节 Markdown 模板
5. `kiki_web/docs/card-generation/scene-info/scene_<NN>_*/kik_*_*/` —— 同场景已存在的兄弟卡（用于去重比对）

> 任何冲突时：RULES > scene-preset > CHARACTER_CAST > 兄弟卡现状。

## 词表设计硬约束

### 1. 具象优先（Concrete-First）
- 所有 8 个目标词条必须是**画面中可单独识别的实物**，不是抽象概念。
- 禁止：自律 / 礼貌 / 团结 / 美好 / 童年 / 温暖 / 友谊。
- 允许：粉笔 / 书包 / 单杠 / 月饼 / 红领巾 / 调色盘。

### 2. 字数控制（≤ 3 汉字）
- 默认每个词条 ≤ 3 个汉字。
- **4+ 字白名单**（仅当物品本身就是 4+ 字常用名时允许）：
  ```
  呼啦圈 / 卷笔刀 / 红领巾 / 调色盘 / 千纸鹤 / 三角铁 / 便当袋 /
  麦克风 / 地球仪 / 小铲子 / 橡皮泥 / 橡皮筋 / 纸飞机 / 借书卡 / 故事书
  ```

### 3. 8 词组合（按场景类型）
| 场景类型 | 推荐组合 |
|---------|---------|
| 校园 | 3-4 学习 + 2-3 空间 + 1-2 自理 |
| 节日 | 2-3 食物 + 2-3 标志物 + 1-2 道具 + 0-1 人物 |
| 家庭日常 | 3-4 用品 + 2-3 食物 + 1-2 场景 |

### 4. 易混淆控制
- 同一卡内不同时出现两个功能极相似的物品对：
  - ❌ 书 / 绘本   ❌ 勺子 / 调羹   ❌ 杯子 / 水壶
  - ✅ 书 / 书签   ✅ 勺子 / 筷子   ✅ 杯子 / 餐盘

### 5. 汉字与英文难度（学前友好）

**原则**：所有词条以**场景语义**为第一优先级；在满足场景需要的前提下，汉字和英文尽量简单。

- **汉字**：优先小学一年级之前的常见简单字，避免生僻字/笔画过多/幼儿不常接触的字。
  - ✅ 书 / 笔 / 花 / 灯 / 鱼 / 鸟 / 云 / 雨 / 球 / 床 / 桌 / 椅 / 包 / 帽 / 鞋
  - ❌ 菖蒲 / 茱萸 / 徽章 / 陀螺（「螺」「陀」偏难）/ 奖状（「奖」「状」较书面）
- **英文**：优先最通用、最简单的 1-2 个单词；同一物品多种英文说法时，**永远选最普及的那个**。
  - ✅ `Ball` / `Book` / `Flower` / `Moon` / `Apple` / `Bed` / `Hat` / `Shoes` / `Cup` / `Bag`
  - ❌ `Certificate`（正式）→ 改为 `Award`；`Sphere` / `Gyroscope` / `Glutinous Rice Dumpling`（生僻/过长）

## 跨卡去重规则

### 核心门禁（必须全部通过）

| 规则 | 阈值 |
|------|------|
| 单卡内 8 词唯一 | 100% |
| 同场景任意两张卡之间词条重叠 | ≤ 2 个 |
| 同场景同一汉字（≥1 字）出现频次 | ≤ 3 张卡 |
| 跨场景重叠 | 不限制 |

### 场景合理性硬约束（高于去重）

> 当"≤2 重叠"与"场景合理性"冲突时，**优先保场景合理性**。
> 例：操场卡的 `单杠/双杠/滑梯/沙坑` 是场景必备，不能为去重把"单杠"换成"粉笔"。

### 象征物豁免（仍受 ≤3 频次约束）

以下词具有强场景标识性，**计入但不强制减重**：
```
国旗 / 红领巾 / 校徽 / 月饼 / 粽子 / 饺子 / 花朵 / 树叶 / 月亮
```
即：可以在多张卡出现，但单一汉字仍 ≤3 张卡。

### 去重检测脚本（Python heredoc）

```python
python3 - <<'PY'
import re, pathlib, collections, itertools

# 修改 SCENE 与 CARDS_DIR 为当前场景路径
SCENE = "scene_01_晨光乐趣"
SCENE_DIR = pathlib.Path(f"kiki_web/docs/card-generation/scene-info/{SCENE}")

VOCAB_LINE = re.compile(r"^-\s*\[[^\]]+\]\s*/\s*([^/]+?)\s*/\s*([^(\n]+?)(?:\s*\(|$)", re.MULTILINE)

def load_card_vocab(md_path):
    """从主 md 中抽取 § III. 8 Target Vocabulary Objects 的 8 个词条。
    返回形如 [(汉字, English), ...] 的列表，便于做中英分别去重。"""
    text = md_path.read_text(encoding="utf-8")
    iii = re.search(r"###\s*III\.[^\n]*\n(.*?)(?=\n###\s|\Z)", text, re.DOTALL)
    if not iii:
        return []
    pairs = []
    for hanzi, english in VOCAB_LINE.findall(iii.group(1)):
        pairs.append((hanzi.strip(), english.strip()))
    return pairs

# 选每个 kik_* 子目录下与目录主题对应的主 md（剔除 prompt.md / workflow_checklist.md）
cards = []
for sub in sorted(SCENE_DIR.glob("kik_*")):
    if not sub.is_dir():
        continue
    for md in sorted(sub.glob("*.md")):
        if md.name in {"prompt.md", "workflow_checklist.md"}:
            continue
        cards.append(md); break

vocab_per_card = {p.parent.name: load_card_vocab(p) for p in cards}

# 1. 单卡 8 词唯一
for card, words in vocab_per_card.items():
    dupes = [w for w, c in collections.Counter(words).items() if c > 1]
    assert not dupes, f"{card} 内重复: {dupes}"
    assert len(words) == 8, f"{card} 词数 {len(words)} ≠ 8"

# 2. 任意两卡 ≤2 重叠
for (a, wa), (b, wb) in itertools.combinations(vocab_per_card.items(), 2):
    overlap = set(wa) & set(wb)
    assert len(overlap) <= 2, f"{a} vs {b} 重叠 {overlap}"

# 3. 单一汉字频次 ≤3 卡
char_card_count = collections.Counter()
for card, words in vocab_per_card.items():
    for ch in {c for w in words for c in w}:
        char_card_count[(ch, card)] = 1
char_freq = collections.Counter(ch for (ch, _) in char_card_count)
over = [(ch, n) for ch, n in char_freq.items() if n > 3]
assert not over, f"汉字超频: {over}"

print("✅ vocab dedup PASS:", len(cards), "cards")
PY
```

## 角色默认穿着速查表（生成指令用）

在卡片生成指令中出场角色时，**必须同时描述当季穿着**。下表是默认值，可直接引用：

| 角色 | 主色/肤色 | 春夏上衣 | 春夏下装 | 秋冬上衣 | 秋冬下装 | 标志性配饰（固定） | 可选配饰（按场景） |
|------|-----------|----------|----------|----------|----------|--------------------|--------------------|
| 🐱 Mimi | 白色短毛，蓝眼睛 | 无（猫咪本体） | 无 | 无（猫咪本体） | 无 | 粉色蝴蝶结项圈（右耳） | 草帽、围巾 |
| 👧 Yuki | 米白/浅桃肤色 | 浅蓝/浅紫/淡粉短袖 T 恤（纯色或细条纹） | 卡其/牛仔短裤，白色中筒袜，棕/粉色运动鞋 | 浅灰/米白/姜黄卫衣/薄毛衣，内搭白 T | 深蓝/黑色紧身长裤/连裤袜，深棕短靴 | 无（散发即标志） | 围巾、贝雷帽、帆布包 |
| 👶 Kiki | 米白/浅桃肤色 | 粉红/鹅黄背带裙，内搭白短袖 T 恤 | 白色连裤袜，粉红/红色小皮鞋 | 粉红/红色呢子外套，白色高领毛衣 | 深红/藏青连裤袜，深棕/黑色小短靴 | 双马尾（粉红发圈） | 绒线帽、小挎包 |
| 👦 Jack | 浅棕/健康肤色 | 白/浅灰短袖 T 恤，带简单图案（条纹/小 logo） | 深蓝/卡其工装短裤，白短袜，灰/蓝运动鞋 | 藏青/军绿夹克/冲锋衣，内搭连帽卫衣 | 深蓝/黑色长裤，高帮运动鞋 | 深蓝/黑色棒球帽（反戴） | 背包、耳机、围巾 |

> **使用规则**：
> 1. 若场景无季节要求，默认按 **春夏季** 穿着描述。
> 2. 「标志性配饰」必须在指令中写明；「可选配饰」只在场景需要时加。
> 3. 颜色可以轻微变动（如浅蓝→浅紫），但 **不要脱离主色域**（如 Yuki 不要穿大红，Kiki 不要穿深黑）。

## 角色出场规则（核心）

> 三层出场层级 + 合法组合 + 单卡 ≤3 人，详细规则见 `CHARACTER_CAST.md`。

### 三层出场层级

| 层级 | 角色 | 出场频率 | 是否强制 |
|------|------|---------|---------|
| L1 永远在场 | 🐱 **Mimi**（白色小猫） | 100%（每张卡必出） | ✅ 强制 |
| L2 常驻嘉宾 | 👧 **Yuki**（10 岁姐姐，散发） | 大多数卡，可单独缺席 | ⭕ 默认在，可缺席 |
| L2 常驻嘉宾 | 👶 **Kiki**（4 岁妹妹，双马尾） | 大多数卡，可单独缺席 | ⭕ 默认在，可缺席 |
| L3 场景性嘉宾 | 👦 **Jack**（7 岁邻居，棒球帽） | 按场景需要，约 40-60% 卡出场 | ❌ **不强制，可选** |

> **关键区分**：Mimi/Yuki/Kiki 是固定阵容（只是 Yuki/Kiki 允许单人缺席）；**Jack 完全按场景氛围决定，可以不出场**。不要为凑出场率而硬塞 Jack。

### 合法角色组合（每卡选 1 种）

```
Mimi + Yuki + Kiki + Jack    ← 四角全员（集体/热闹）
Mimi + Yuki + Kiki           ← 经典姐妹（默认主流）
Mimi + Yuki + Jack           ← 同班伙伴
Mimi + Kiki + Jack           ← 哥哥带妹妹
Mimi + Kiki                  ← 妹妹独处萌
Mimi + Yuki                  ← 姐姐独处书卷
Mimi + Jack                  ← 男孩独处
Mimi 单独                    ← 仅静物展示卡，需审核
```

**单卡人物（不含猫）≤ 3 人**。

### Jack 出场决策表

| 场景特征 | Jack 出场 |
|---------|----------|
| 户外运动 / 集体游戏（操场、课间、放学） | ✅ 强烈建议 |
| 校园集体活动（升旗、音乐、午餐） | ⭕ 可选 |
| 中性日常（晨读、手工、教室） | ⭕ 可选 |
| 静谧观察 / 私密（图书角、午睡、花园） | ❌ 建议没有 |
| 节日热闹（春节、中秋、元宵） | ✅ 强烈建议 |
| 家庭团聚（年夜饭、贴春联） | ❌ 建议没有 |

### Jack 视觉硬约束

- 黄色 / 橙色 T 恤（可有小恐龙/小火箭/星星图案）
- 深蓝或卡其短裤 + 白运动鞋（彩鞋带）
- **🧢 棒球帽（浅蓝或红色）必须在画面内可见**：
  - 户外/运动 → 戴帽（运动可反戴）
  - 室内安静（图书角、午睡）→ 摘下挂书包或拿手里
  - 雨天 → 收进黄色雨衣的书包里
- 健康肤色（比姐妹略深一点点），短黑发尾微翘
- 表情：开朗、爱笑、好奇

## 工作流（8 步）

```
1. 读规则       → RULES.md §1 + scene_<NN> + CHARACTER_CAST + 当前 schema
2. 列基线       → 同场景兄弟卡 IV 词表 + 角色组合
3. 候选 12-15   → 给当前卡草拟 12-15 个候选词条 + 候选角色组合
4. 易混淆扫描   → 剔除两两功能相似词
5. 五位同步     → 草定 8 词后，同步更新：
                   ① IV 词表
                   ② IV 物体放置策略
                   ③ IV 易混淆控制
                   ④ V 标签卡布置
                   ⑤ VI 箭头映射
                   （+ VII 角色出场，如组合变化）
6. 跑脚本       → 上方去重脚本，必须 exit 0
7. 更新索引     → kiki_web/docs/card-generation/scenes/<scene>/index.json
8. 交接         → 转给 just-card-image-generation-workflow
```

## 交付清单

- [ ] 8 词全部具象、≤ 3 汉字（或在白名单）
- [ ] 单卡 8 词唯一
- [ ] 与同场景任意一张兄弟卡重叠 ≤ 2
- [ ] 单一汉字跨卡频次 ≤ 3
- [ ] 易混淆物品对未同时出现
- [ ] 角色组合属于合法 8 种之一
- [ ] 单卡人物（不含猫）≤ 3 人
- [ ] Jack 若出场，棒球帽可见（戴或拿）
- [ ] 场景预设的 §角色出场建议表已确认

## 反例（明确禁止）

- ❌ 把"自律"作为词条（抽象）
- ❌ 把"绘本图书馆"作为词条（4+ 字非白名单）
- ❌ 操场卡同时收"单杠"和"双杠"作为目标（功能极相似）
- ❌ 为了凑去重把"国旗"从升旗卡换掉（破坏场景合理性）
- ❌ 把 Jack 强塞进午睡卡（违反静谧场景规则）
- ❌ 一张卡画 4 个人 + Jack（人物超 3）
- ❌ Jack 出场但忘画棒球帽
- ❌ 把"小白猫"换成橘猫或黑猫（违反 Mimi 固定）
- ❌ 让 Yuki 扎双马尾（与 Kiki 撞型）

## 技能边界

| 技能 | 输入 | 输出 |
|------|-----|------|
| **just-card-vocab-design**（本技能） | 场景预设 + 兄弟卡 | 8 词条 + 角色组合 + 卡片 MD |
| just-card-image-generation-workflow | 卡片 MD | 1024×1024 PNG |
| just-hotspot-generator | PNG + MD | items_data 热区 JSON |
| just-card-audio-qiniu-workflow | JSON | TTS 音频 + 七牛 URL |

## 快速参考

- 角色英文名：`Mimi` / `Yuki` / `Kiki` / `Jack`
- 在英文 prompt 中：`Mimi the white cat`、`Yuki, the 10-year-old elder sister with long flowing hair`、`Kiki, the 4-year-old little sister with twin pigtails`、`Jack, the 7-year-old cheerful neighbor boy with a baseball cap`
- 项目代号 `kiki_chain` / `kiki_web` 是品牌，不是角色
- 单场景 Jack 总出场建议：12 卡中 5-7 张
- 任何冲突优先级：RULES > scene-preset > CHARACTER_CAST > 兄弟卡
