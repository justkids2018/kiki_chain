# items_data JSON 结构规范

> 场景物品热区数据的标准格式定义

---

## 1. 概述

每个场景的 `items_data` 是一个 JSON 数组，描述图片上所有可点击的学习区域。
前端根据此数据在图片上渲染热区，用户点击后触发学习卡片展示和 TTS 朗读。

从真实场景模式开始，`items_data` 推荐使用“词条分组”结构：
- 每个词条只保留一份公共信息（`id`、`text`、拼音、英文等）
- `regions` 中配置多个可点击区域
- `card` 区域：标签卡片区域，稳定、易点，必须优先保证
- `object` 区域：物体主体区域，更自然，只有在主体清晰且不易误触时才添加

兼容规则：
- 新数据推荐“一个词条 + 多个 regions”
- 旧数据（一条记录一个热区）仍可兼容
- 无论点 `card` 还是 `object`，都触发同一个词条内容

---

## 2. 字段定义

### 2.1 词条级字段（推荐主结构）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `type` | string | ✅ | 词条类型，固定值 `"chinese"` |
| `id` | string | ✅ | 词条唯一标识，建议 `"chinese_{两位序号}"`，如 `"chinese_01"` |
| `index` | int | ✅ | 词汇顺序，从 1 开始 |
| `text` | string | ✅ | 中文名称（简体），如 `"积木"` |
| `text_pinyin` | string | ✅ | 汉语拼音（带声调），如 `"jī mù"` |
| `text_english` | string | ✅ | 英文名称（首字母大写），如 `"Blocks"` |
| `text_phonetic` | string | ✅ | 英文国际音标 (IPA)，如 `"/blɑːks/"` |
| `regions` | array | ✅ | 热区数组，至少 1 个元素 |

### 2.2 region 子项字段（regions 内）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `region_type` | string | ✅ | 热区类型，推荐值：`"card"` 或 `"object"` |
| `coordinate` | array | ✅ | 4 个坐标点，定义矩形热区 |

---

## 3. coordinate 坐标规范

### 3.1 坐标系

- 原点 `(0, 0)` 在图片**左上角**
- `x` 轴向右递增
- `y` 轴向下递增
- 单位：**像素**（基于原始图片分辨率，如 1024×1024）

### 3.2 四点顺序

```
coordinate[0] (左上) ──── coordinate[1] (右上)
       │                         │
       │       热区区域            │
       │                         │
coordinate[2] (左下) ──── coordinate[3] (右下)
```

### 3.3 标注原则

| 规则 | 说明 |
|------|------|
| card 优先 | 每个词至少应有 1 个 `region_type = "card"` 热区，优先保证点击稳定性 |
| object 可选 | `region_type = "object"` 只在主体清晰、独立、不易误触时添加 |
| 覆盖主体 | `object` 热区只框选物体可见主体，不吞并相邻目标物 |
| 适当留白 | 热区比主体略大 10-15%，方便触摸 |
| 不重叠 | 不同词之间的热区不应交叉；同一词的 `card` 和 `object` 通常也应分离 |
| 对齐语义 | `card` 对准标签卡片本体；`object` 对准实际物体本体 |

### 3.4 真实场景下的特殊规则

- 黑板这类大物体：只框选主体面板，不包含粉笔、板擦、粉笔槽等附属小物体
- 桌子、讲台这类承载物：若上面放有其他目标物，仍需保留一块可单独框选的主体区域
- 粉笔、书签、眼镜这类小物体：若主体太小或与邻近物体过近，可以只保留 `card` 热区
- 当两个目标物紧邻且容易误触时，优先缩小或取消 `object` 热区，不要牺牲点击准确率

---

## 4. 完整示例

```json
[
  {
    "type": "chinese",
    "id": "chinese_01",
    "index": 1,
    "text": "球",
    "text_pinyin": "qiú",
    "text_english": "Ball",
    "text_phonetic": "/bɔːl/",
    "regions": [
      {
        "region_type": "card",
        "coordinate": [
          { "x": 573, "y": 892 },
          { "x": 847, "y": 892 },
          { "x": 573, "y": 1179 },
          { "x": 847, "y": 1179 }
        ]
      },
      {
        "region_type": "object",
        "coordinate": [
          { "x": 610, "y": 960 },
          { "x": 788, "y": 960 },
          { "x": 610, "y": 1138 },
          { "x": 788, "y": 1138 }
        ]
      }
    ]
  },
  {
    "type": "chinese",
    "id": "chinese_02",
    "index": 2,
    "text": "鸭子",
    "text_pinyin": "yā zi",
    "text_english": "Duck",
    "text_phonetic": "/dʌk/",
    "regions": [
      {
        "region_type": "card",
        "coordinate": [
          { "x": 915, "y": 766 },
          { "x": 1180, "y": 766 },
          { "x": 915, "y": 1032 },
          { "x": 1180, "y": 1032 }
        ]
      }
    ]
  }
]
```

说明：
- 示例中“球”在同一词条下同时配置了 `card` 与 `object` 两个热区
- “鸭子”只配置了 `card` 热区，表示该词当前不适合添加物体热区
- 点击任一 region，都应触发该词条（同一 `id`）的学习反馈

---

## 5. 前端解析规则

```dart
// 推荐做法：解析词条后，将每个 region 展平成当前运行时可消费的点击层。
// 运行时可继续使用现有 InteractiveRegion 实体，不必改 UI 渲染逻辑。
```

当前前端按“每条点击层独立渲染”工作。
若源数据使用本规范的分组结构，建议在 repository 层进行一次 flatten 转换再下发给 UI。

---

## 6. 数据存储位置

| 存储方式 | 位置 | 说明 |
|----------|------|------|
| 嵌入式 | `scenes.items_data` (JSONB) | 完整 JSON 数组（推荐词条分组结构），前端优先读取 |
| 行存储 | `scene_items` 表 | 每行一个物品，coordinate 为 JSONB |
| 本地文件 | `assets/data/{scene}/kiki_{scene}.json` | 开发/离线兜底 |

---

## 7. 校验清单

生成 JSON 后的自检项：

- [ ] 每个目标词至少有 1 个 region；若使用双热区，`regions` 通常为 2
- [ ] 词条级 `id` 全局唯一且格式正确
- [ ] 不同词的 `index` 从 1 连续递增
- [ ] `text_pinyin` 声调正确
- [ ] `text_phonetic` 使用标准 IPA
- [ ] 每个 region 的 `coordinate` 都由 4 个点构成合理矩形
- [ ] 热区不超出图片边界
- [ ] 不同词之间热区无重叠或误触冲突
- [ ] 每个词至少保留 1 个稳定可点区，优先保证 `region_type = "card"`

---

## 8. 兼容旧格式（扁平结构）

旧格式示例（仍可读取）：

```json
[
  {
    "type": "chinese",
    "id": "card_chinese_01",
    "index": 1,
    "text": "球",
    "text_pinyin": "qiú",
    "text_english": "Ball",
    "text_phonetic": "/bɔːl/",
    "region_role": "card",
    "coordinate": [
      { "x": 573, "y": 892 },
      { "x": 847, "y": 892 },
      { "x": 573, "y": 1179 },
      { "x": 847, "y": 1179 }
    ]
  }
]
```

建议：新生成数据统一使用词条分组结构；旧数据通过解析层兼容。
