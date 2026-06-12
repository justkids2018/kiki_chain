# Kiki 学习奖励规则（Star Reward System）

## 概述

学习卡片页（InteractiveImagePage）在右侧控制面板“互动学习”标题行右侧展示 **3 颗星星**，用户学习词语时动态点亮星星并播放动画音效。

---

## 星星数量规则

### 规则：按学习进度比例给星（3星制）

每张场景卡片有若干词语（`regions`），用户每成功点击一个新词即算"学会"该词。  
按照已学词数占总词数的比例，到达以下门槛时依次点亮星星：

| 已学比例 | 获得星星 |
|----------|----------|
| ≥ 30%    | ⭐       |
| ≥ 60%    | ⭐⭐     |
| ≥ 100%   | ⭐⭐⭐   |

> **示例**：一张卡片共有 10 个词。
> - 学会第 3 个词时（30%）获得第 1 颗星；
> - 学会第 6 个词时（60%）获得第 2 颗星；
> - 学会全部 10 个词时（100%）获得第 3 颗星（满星）。

---

## 重复学习规则

- 同一词语（同一 `region.text`）在同一次会话中只记一次进度。
- 跨会话进度从本地持久化中恢复。
- 若接口返回的星星数 > 本地计算值，以接口返回为准（服务器权威）。
- 若接口不可用，降级为纯本地计数。

---

## 交互与动画规则

1. **进入页面**：从本地缓存/接口加载已有进度，恢复星星数。
2. **点击词语**：播放音频后触发进度记录。
3. **获得新星星**：  
   - 金色星星图标从词语点击位置飞向右侧面板“互动学习”后面对应的星星目标位置。
   - 动画效果：起飞时伴随“嗖”的一声（使用 `star_1.mp3`），运行曲线采用前段加速飞出、后段减速落地的动感轨迹，整体耗时约 850ms，且飞出时自带轻微放大。
   - 到达目标位置后，该星星点亮（金色实心，无发散光晕）。
   - 星星落地时播放叮当音效：普通星星播放 `star_2.mp3`，满星完成播放 `star_3_complete.mp3`。
4. **退出页面**：调用 `saveProgress()` 保存进度到本地（同时尝试同步至服务器）。

---

## 降级策略

- 若接口调用失败（网络错误、超时等），**不影响本地学习**，保持本地计算的星星进度。
- 本地记录已学词集合并持久化到本地 `SharedPreferences`。

---

## API 协议（复用现有后端接口）

### 查询进度
```
GET /api/v1/learning/progress/{user_id}/{scene_id}

Response:
{
  "code": 0,
  "data": {
    "scene_id": "scene_xxx",
    "stars_earned": 3,
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
  "stars_earned": 3,
  "is_completed": true,
  "study_time": 60
}
```

---

## 音效规格

| 音效 | 文件 | 触发时机 |
|------|------|----------|
| 嗖声（起飞） | `assets/audio/star_1.mp3` | 星星飞出时 |
| 叮当声（获星） | `assets/audio/star_2.mp3` | 星星飞到位置并点亮时（第1、2颗星） |
| 完成声（满星） | `assets/audio/star_3_complete.mp3` | 第 3 颗星点亮时 |

---

## 技术实现说明

- 奖励计算由 **`RewardService`**（`lib/data/services/learning/reward_service.dart`）统一管理。
- 页面星星组件为 **`InlineStarBar`**（`lib/presentation/pages/interactive_image/widgets/glass_star_bar.dart`），背景采用灰色圆角设计，内含 3 颗无光晕金色实心或描边星星，清晰不散光。
- 星星飞翔动画：**`StarFlyAnimationController`** 使用 `Overlay` 层，从词语点击的全局坐标飞向右侧面板标题栏对应 `GlobalKey` 指向的星星坐标。
