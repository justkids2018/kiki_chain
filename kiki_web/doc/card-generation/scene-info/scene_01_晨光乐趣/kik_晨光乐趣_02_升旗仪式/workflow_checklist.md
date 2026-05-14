# 升旗仪式卡片执行工作单

## 卡片识别信息

- scene_slug: scene_01_晨光乐趣
- card_slug: kik_晨光乐趣_02_升旗仪式
- 分类: 晨光乐趣
- 主题序号: 1.2

## 当前状态（自动检查）

- Prompt 文件已存在: kik_晨光乐趣_02_升旗仪式.md
- 兼容 prompt 已存在: prompt.md
- 图片文件缺失: kik_晨光乐趣_02_升旗仪式.png
- JSON 当前是占位空数组: []
- 流程状态: BLOCKED（等待图片输入）

## 目标产物

同目录最终要有 4 个文件：

1. kik_晨光乐趣_02_升旗仪式.md
2. prompt.md
3. kik_晨光乐趣_02_升旗仪式.png
4. kik_晨光乐趣_02_升旗仪式.json

## 执行步骤

### Step 1: 生成图片（Gemini / Banana，人工）

1. 打开 Gemini，选择 Banana 模式。
2. 复制本目录 `kik_晨光乐趣_02_升旗仪式.md` 全文作为输入。
3. 生成后下载图片，重命名为 `kik_晨光乐趣_02_升旗仪式.png`。
4. 把图片放到本目录。

完成标准：

- 图片尺寸目标是 1024x1024。
- 场景内容满足升旗仪式 8 词对象。

### Step 2: 生成热区 JSON（技能）

在聊天中发送：

"根据图片和md生成这张卡的items_data：
scene_slug=scene_01_晨光乐趣，
card_slug=kik_晨光乐趣_02_升旗仪式，
image=doc/card-generation/scene-info/scene_01_晨光乐趣/kik_晨光乐趣_02_升旗仪式/kik_晨光乐趣_02_升旗仪式.png，
prompt=doc/card-generation/scene-info/scene_01_晨光乐趣/kik_晨光乐趣_02_升旗仪式/kik_晨光乐趣_02_升旗仪式.md，
output=doc/card-generation/scene-info/scene_01_晨光乐趣/kik_晨光乐趣_02_升旗仪式/kik_晨光乐趣_02_升旗仪式.json"。

完成标准：

- JSON 不再是空数组。
- 结构为词条 + regions。

### Step 3: HTML 打分校验（>=89）

使用 `kiki_web/doc/card-generation/hotspot-preview.html`：

1. baseRoot 填：
   /Users/qisd/Documents/development/my_project/kiki_chain/kiki_web/doc/card-generation/scene-info
2. scene_slug 填：scene_01_晨光乐趣
3. card_slug 填：kik_晨光乐趣_02_升旗仪式
4. 点击“按 scene/card 自动生成路径”
5. 点击“加载并绘制”

通过标准：

- 页面评分 >= 89
- 页面显示 PASS

不通过处理：

- 优先调 JSON 坐标
- 仍不通过则重生图片

### Step 4: Admin 上传提交（人工）

1. 登录 admin 后台，进入对应详情页。
2. 点击“添加”。
3. 上传同名图片和 JSON：
   - kik_晨光乐趣_02_升旗仪式.png
   - kik_晨光乐趣_02_升旗仪式.json
4. type 固定 `chinese`。
5. 提交。

## 验收门禁

- [x] Prompt 文件存在且可用
- [x] 前置检查已完成（当前阻塞：待生成图片）
- [ ] 图片 1024x1024
- [ ] JSON 非空且结构正确
- [ ] hotspot-preview 得分 >=89 且 PASS
- [ ] Admin 已提交成功
