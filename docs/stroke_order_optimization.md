# 笔顺数据优化实施指南

## 概述

混合策略：**Assets（常用字）+ 场景级预加载（新字）+ 网络降级**

## 实施步骤

### 1. 下载常用汉字的笔顺数据（30 分钟）

```bash
# 安装依赖
pip3 install requests

# 运行脚本（会扫描所有场景 JSON 并下载笔顺数据）
python3 scripts/download_stroke_data.py
```

**脚本会：**
- 扫描 `kiki_web/assets/data/` 目录中的所有 JSON 文件
- 提取所有汉字
- 从 CDN 下载笔顺数据到 `kiki_web/assets/data/stroke_order/`

### 2. 验证下载结果

```bash
# 查看下载了多少个汉字
ls kiki_web/assets/data/stroke_order/*.json | wc -l

# 查看文件大小
du -sh kiki_web/assets/data/stroke_order/
```

### 3. 运行 Flutter 应用

```bash
cd kiki_web

# 清理并重新构建
flutter clean
flutter pub get
flutter run
```

## 工作原理

### 加载顺序（四层降级）

```
1. 内存缓存（最快，0ms）
   ↓ 未命中
2. Assets（常用字，~10ms）
   ↓ 未命中
3. 磁盘缓存（预加载的，~50ms）
   ↓ 未命中
4. 网络下载（CDN，~500ms）
```

### 预加载时机

- 用户打开场景页面时
- 自动提取场景中的所有汉字
- 后台静默下载并缓存到磁盘
- 用户点击时从缓存读取

## 效果

| 汉字类型 | 加载方式 | 延迟 | 说明 |
|---------|---------|------|------|
| **常用汉字** | Assets | 0ms | 打包到 App，零延迟 |
| **当前场景汉字** | 磁盘缓存 | ~10ms | 预加载，几乎零延迟 |
| **新汉字** | 网络下载 | ~500ms | 首次访问，后续缓存 |

## 预期体积

- 每个汉字笔顺数据：~2-5KB
- 500 个常用汉字：~1-2.5MB
- 对于 3.9GB 的 App，这个增量可以忽略

## 故障排查

### 问题 1：脚本运行失败

```bash
# 检查 Python 版本
python3 --version  # 需要 3.6+

# 安装 requests
pip3 install requests
```

### 问题 2：Assets 未加载

```bash
# 清理并重新构建
flutter clean
flutter pub get
flutter run
```

### 问题 3：网络下载失败

- 检查网络连接
- CDN 可能被墙，脚本会自动尝试多个 CDN
- 如果全部失败，手动下载并放到 `assets/data/stroke_order/`

## 后续优化（可选）

### 1. 预加载下一个场景

在 `InteractiveImageController` 中添加：

```dart
void _preloadNextScene() {
  final nextScene = _getNextScene();
  if (nextScene != null) {
    final characters = _extractCharactersFromScene(nextScene);
    StrokeOrderService().preloadCharacters(characters);
  }
}
```

### 2. 添加预加载进度提示

在场景加载时显示：
```
"正在准备笔顺数据... (23/45)"
```

### 3. 定期更新 Assets

每次发布新版本前，重新运行脚本更新常用汉字。

## 监控

查看日志：

```dart
// 成功从 Assets 加载
AppLogger.debug('Loaded stroke data from assets for "字"');

// 预加载开始
AppLogger.info('Preloading stroke data for 45 characters');

// 预加载完成
AppLogger.info('Preload complete for 45 characters');
```

## 总结

✅ **已完成：**
1. 修改 `StrokeOrderService` 添加 Assets 读取
2. 修改 `InteractiveImageController` 添加场景级预加载
3. 创建下载脚本 `scripts/download_stroke_data.py`
4. 更新 `pubspec.yaml` 声明 assets

⏭️ **下一步：**
1. 运行下载脚本
2. 测试效果
3. 如果满意，提交代码
