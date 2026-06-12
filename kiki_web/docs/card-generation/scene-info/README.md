# 场景资料统一目录（scene-info）

此目录用于统一管理学习卡片生产资料，按“场景 -> 卡片”组织。

## 目录规范

```text
scene-info/
  <scene_slug>/
    <card_slug>/
      <card_slug>.jpg|png|webp   # 场景图
      <card_slug>.json           # 热区数据（items_data）
      prompt.md                  # 生图提示词
```

## 命名规则

- 同一卡片的图片与 JSON 必须同名（仅扩展名不同）
- 推荐使用小写英文+下划线命名：`kiki_jiaoshi`
- `prompt.md` 固定文件名，便于脚本读取

## 当前示例

- `demo_animals/kiki_dongwuyuan/`
- `demo_plants/kiki_zhiwuyuan/`
- `demo_classroom/kiki_jiaoshi/`

## 当前规划分类

- `scene_01_晨光乐趣/`：校园晨间、阅读、手工、花园等场景
- `scene_02_数学思维/`：数字、形状、计数、测量、配对、比较
- `scene_03_日常生活/`：超市、公园、生日、洗澡、穿衣、看医生
- `scene_04_游乐场景/`：恐龙、太空、海盗船、城堡、马戏团、沙滩
- `scene_05_入学准备/`：家庭成员、身体动作、情绪礼貌、天气四季、空间方位、生活自理

## 入学准备内容原则

- 面向 3-6 岁儿童，优先覆盖入小学前应掌握的高频生活词、社交词、身体动作词、天气自然词、空间方位词和自理物品词。
- 每张卡默认 8 个目标词，保持中文、拼音、英文、英文音标四列完整。
- 新增内容只借鉴年龄发展目标和分级词汇范围，不复制外部书籍的图片、故事、版式或角色。
- 先维护 `<card_slug>.md` 作为生图与后续 JSON 解析的语义源；图片、热区 JSON、音频可以按卡片逐张生成。

## 迁移建议

- 生产资料放在本目录维护
- Flutter 运行时资产（`assets/images` 和 `assets/data`）可由脚本从本目录同步生成
