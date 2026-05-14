# 学习卡片生成系统

> Hi Kiki 场景学习卡片的端到端生成规范

---

## 目录结构

```
card-generation/
├── README.md              ← 本文件（总览 & 入口）
├── PIPELINE.md            ← 生成流程图（Step-by-Step）
├── PROMPT.md              ← Banana (Google AI) 图片生成 Prompt 模板
├── JSON_SPEC.md           ← items_data JSON 结构规范
├── hotspot-preview.html   ← 本地热区校验页
└── scene-info/            ← 场景资料统一目录（推荐）
	├── README.md
	├── index.json
	└── <scene_slug>/<card_slug>/
		├── <card_slug>.jpg|png|webp
		├── <card_slug>.json
		└── prompt.md
```

## 统一管理原则（推荐）

- 同一卡片的图片和 JSON 必须同名，仅扩展名不同
- 每张卡片目录固定包含：图片 + JSON + `prompt.md`
- 所有生产资料统一放在 `scene-info/`，便于脚本化与批量维护
- 运行时资产（`assets/images` / `assets/data`）可由脚本从 `scene-info/` 同步生成
- 学习卡片 Prompt 统一命名：`kik_场景_01_功能.md`

## 批量结构（SCENES.md -> scene-info）

```text
scene-info/
	scene_01_晨光乐趣/
		kik_晨光乐趣_01_操场晨练/
			kik_晨光乐趣_01_操场晨练.md
			prompt.md
			kik_晨光乐趣_01_操场晨练.png
			kik_晨光乐趣_01_操场晨练.json
	scene_02_数学思维/
	scene_03_日常生活/
	scene_04_游乐场景/
```

## 脚本化（推荐）

在 `kiki_web/` 目录执行：

```bash
# 1) 初始化场景卡片目录（生成目录、prompt.md、空 json）
./scripts/card_generation/init_scene_card.sh <scene_slug> <card_slug> [image_ext]

# 1.1) 从 SCENES.md 批量生成 4 场景全部学习卡片 Prompt
python3 scripts/card_generation/generate_prompts_from_scenes.py

# 2) 将同目录的图片+json 同步到 Flutter 运行时 assets
./scripts/card_generation/sync_scene_card_assets.sh <scene_slug> <card_slug> [image_ext]
```

## 快速概览

| 阶段 | 输入 | 输出 | 工具 |
|------|------|------|------|
| 1. 选题 | 场景主题 | 词汇表（8 词） | 人工 / AI |
| 2. 生图 | 词汇表 + Prompt | 场景学习图 (1024×1024) | Banana (Google AI) |
| 3. 标注 | 图片 + 词汇表 | 热区坐标 JSON | 人工 / 图像识别 |
| 4. 上线 | 图片 + JSON | 移动端可交互场景 | Admin 后台 |

## 相关文档

- [场景结构定义](../business/场景结构定义.md) — 所有分类和场景的词汇规划
- [InteractiveImage 功能文档](../features/interactive_image.md) — 前端交互实现细节
