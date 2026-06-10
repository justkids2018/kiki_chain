# Kiki 学习奖励规则（Star Reward System）

## 概述

学习卡片页（InteractiveImagePage）在右上角展示 **5 颗星星**，用户学习词语时动态点亮星星并播放动画音效。

> 本系统是原有3星系统（33%/67%/100%）的升级版，将满星从3颗扩展至5颗，API端点保持兼容。

---

## 星星数量规则

### 规则：按学习进度比例给星（5星制）

每张场景卡片有若干词语（`regions`），用户每成功点击一个新词即算"学会"该词。  
按照已学词数占总词数的比例，到达以下门槛时依次点亮星星：

| 已学比例 | 获得星星 |
|----------|----------|
| ≥ 20%    | ⭐       |
| ≥ 40%    | ⭐⭐     |
| ≥ 60%    | ⭐⭐⭐   |
| ≥ 80%    | ⭐⭐⭐⭐ |
| ≥ 100%   | ⭐⭐⭐⭐⭐ |

> **示例**：一张卡片共有 10 个词。学会第 2 个词时得第 1 颗星，学会第 4 个词时得第 2 颗星，依此类推。学完全部 10 个词得满星。

> **为何不用"每 2 个词给 1 颗星"**：部分场景词语数量较少（如 4~6 个），若绑定固定数量则会出现某些场景永远无法获得满星的问题。比例制可以保证所有场景都能达到 5 颗星。

---

## 重复学习规则

- 同一词语（同一 `region.text`）在同一次会话中只记一次进度。
- 跨会话进度从本地持久化中恢复。
- 若接口返回的星星数 > 本地计算值，以接口返回为准（服务器权威）。
- 若接口不可用，降级为纯本地计数。

---

## 交互规则

1. **进入页面**：从本地缓存/接口加载已有进度，恢复星星数。
2. **点击词语**：播放音频后触发进度记录。
3. **获得新星星**：  
   - 金色星星图标从词语点击位置飞向右上角星星栏对应位置。  
   - 到达目标位置后，该星星点亮（金色实心 + glow 光晕）。  
   - 播放叮咚音效（`assets/audio/star_ding.mp3`，暂用 `star_1.mp3` 占位）。
4. **退出页面**：调用 `saveProgress()` 保存进度到本地（尝试同步至服务器）。

---

## 降级策略

- 若接口调用失败（网络错误、超时等），**不授予星星**，保持当前已有进度不变。
- 本地不做独立计数，以服务器返回结果为权威。
- 只有接口成功返回时才触发星星点亮动画。

---

## API 协议（复用现有后端接口）

后端接口文档参考：`docs/STAR_REWARD_SYSTEM_README.md` 及 `docs/star_reward_system_implementation.md`

### 查询进度
```
GET /api/v1/learning/progress/{user_id}/{scene_id}

Response:
{
  "code": 0,
  "data": {
    "scene_id": "scene_xxx",
    "stars_earned": 3,         // 原为0-3，升级后客户端映射至0-5
    "learned_regions": ["苹果", "香蕉"],
    "learned_count": 6,
    "total_regions": 10,
    "is_completed": false
  }
}
```

### 提交进度
```
POST /api/v1/learning/progress/batch

Body:
{
  "user_id": "guest_user",
  "scene_id": "scene_xxx",
  "learned_regions": [{"region_id": "苹果", "region_text": "苹果", "learned_at": "..."}],
  "stars_earned": 2,        // 客户端计算的5星制值
  "is_completed": false,
  "study_time": 60
}

Response:
{
  "code": 0
}
```

> **注意**：后端目前存储0-3星，客户端扩展到0-5星。服务器返回值仅用于恢复历史进度，实时奖励判断由客户端比例规则决定。

---

## 音效规格

| 音效 | 文件 | 触发时机 |
|------|------|----------|
| 叮咚声（获星） | `assets/audio/star_ding.mp3`（暂用 `star_1.mp3` 占位） | 星星飞到位置并点亮时 |
| 完成声（满星） | `assets/audio/star_3_complete.mp3` | 第 5 颗星点亮时 |

> **TODO**：使用微软 Azure TTS 或其他工具生成叮咚音效，保存为 `assets/audio/star_ding.mp3` 后在 `pubspec.yaml` 中注册并替换占位文件。

---

## 技术实现说明

- 奖励计算由 **`RewardService`**（`lib/data/services/learning/reward_service.dart`）统一管理。
- 控制器状态：`starsEarned`（已获星星数，0~5）、`showStarAnimation`（飞翔动画触发）、`latestStarIndex`（最新获得的是第几颗星，1~5）。
- 星星飞翔动画：**`StarFlyAnimationController`** — 使用 `Overlay` 层，从词语点击的全局坐标飞向右上角星星栏对应星星的全局坐标。
- 本地持久化：`SharedPreferences`，key 格式为 `reward_progress_{userId}_{sceneId}`。
