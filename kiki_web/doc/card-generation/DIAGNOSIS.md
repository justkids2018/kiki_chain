## Failure Signature

学习卡片通过 md 生图时，图片没有严格按 md 词条生成；部分卡片默认只生成 8 个词；最终图片常有 1-2 个对象或箭头指示错误。

## Root Cause

当前规则层和产物层存在三个漂移点。第一，公共规则把 `8 个目标物体 / 8 张标签卡片 / 8 个箭头` 写死，但实际卡片允许 7/8/10 个词条，例如 `数字乐园` 是 10 个词。第二，部分目录的 `prompt.md` 与 `<card>.md` 不一致，生图时如果复制了 stale `prompt.md`，就会使用旧词表。第三，旧规则没有把 `### III` 词表定义为闭合集合，图片模型会把场景装饰物、近义物或更常见物体替换成学习目标。

词表替换和箭头错配都属于图片生成阶段的视觉语义问题，不是 JSON 坐标阶段能彻底修复的问题。JSON 只能框选图片里已经正确存在的 card/object，不能修正图片中箭头指错、对象缺失、标签错配或词表外标签。

## Evidence

- `kiki_web/doc/card-generation/scene-info/scene_02_数学思维/kik_数学思维_01_数字乐园/kik_数学思维_01_数字乐园.md` 声明 `### III. 10 Target Vocabulary Objects`。
- 同目录旧 `prompt.md` 曾声明 `### III. 8 Target Vocabulary Objects`，并只包含 8 个数字词条。
- `card-promp-rule/RULES.md` 原先写死 8 个对象、8 张标签卡片、8 个箭头。
- `PIPELINE.md` 原先也将词汇表描述为固定 8 个物品。

## Affected Scope

- `kiki_web/doc/card-generation/card-promp-rule/*`
- `kiki_web/doc/card-generation/CARD_PRODUCTION_WORKFLOW.md`
- `kiki_web/doc/card-generation/PIPELINE.md`
- `kiki_web/doc/card-generation/scene-info/**/prompt.md`

## Patch Plan

1. 将公共规则从固定 8 个改为从当前 `<card>.md` 读取词条数量 `N`。
2. 明确 `<card>.md` 是唯一可信 Prompt，`prompt.md` 只做兼容副本。
3. 批量同步所有现有 `prompt.md`，让它们与主 md 完全一致。
4. 强化箭头规则：标签卡片必须贴近对象，箭头必须短且不跨对象；任何 1-2 个箭头错配都必须回到图片阶段重生或人工修正。
5. 增加 CLOSED VOCAB SCAN：标签卡片必须逐字来自 md 词表，不允许词表外标签或近义替换。

## Regression Risk

低。改动只收紧文档和 prompt 规则，不改变运行时 JSON 合同；唯一行为变化是禁止继续把 8 作为默认数量。

## Verification Plan

1. 扫描所有 `scene-info` 卡片目录，确认存在 `prompt.md` 的内容与 `<card>.md` 一致。
2. 对 `### III. N Target Vocabulary Objects` 段做数量校验，确保声明数量等于词条行数。
3. 生图前检查：对象数、标签数、箭头数必须等于 `N`。
4. 生图后检查：若出现词表外标签、md 词条缺失、箭头/标签/对象映射有任一错配，图片不进入 JSON 阶段。
