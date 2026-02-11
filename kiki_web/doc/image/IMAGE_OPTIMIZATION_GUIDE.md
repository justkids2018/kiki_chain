# 图片资源优化指南

## 📱 多分辨率支持策略

### 为什么需要多分辨率？

现代移动设备使用高像素密度显示屏（Retina/高清屏），如果只提供低分辨率图片，会导致：
- 图片模糊、不清晰
- 用户体验下降
- 品牌形象受损

### 设备像素密度对照表

| 设备类型 | 像素密度 | 倍率 | 示例设备 |
|---------|---------|------|---------|
| 标准屏幕 | ~160 dpi | 1x | 旧款 Android 设备 |
| Retina 屏幕 | ~320 dpi | 2x | iPad, iPhone 8-14, 大部分现代设备 |
| 超高清屏幕 | ~480 dpi | 3x | iPhone Plus/Pro 系列 |

---

## 🎯 图片尺寸规范

### 统一规格 (CategoryCard & SceneCard)

**显示尺寸**: 350 x 450 点 (7:9 宽高比)

所有卡片（分类卡片和场景卡片）统一使用相同的尺寸规格，保持视觉一致性。

| 倍率 | 实际像素尺寸 | 文件大小目标 | 优先级 | 用途 |
|------|-------------|-------------|--------|------|
| @1x | 350 x 450 | < 200KB | 低 | 备用/降级 |
| @2x | 700 x 900 | < 500KB | **高** | **主要使用** |
| @3x | 1050 x 1350 | < 800KB | 中 | 高端设备 |

**推荐策略**:
- 必须提供 @2x 版本（覆盖 90% 设备）
- 可选提供 @3x 版本（提升高端设备体验）
- @1x 作为降级备用

**设计优势**:
- 统一的宽高比便于批量生成和管理
- 一致的视觉体验
- 简化图片生成流程

---

## 📁 Flutter 资源目录结构

### 推荐的目录组织方式

```
assets/images/
├── categories/              # 分类卡片封面图 (350x450, 7:9)
│   ├── daily_life.png       # @1x (350x450)
│   ├── playground.png
│   ├── numbers.png
│   ├── 2.0x/                # @2x Retina 版本
│   │   ├── daily_life.png   # (700x900) ⭐ 主要使用
│   │   ├── playground.png
│   │   └── numbers.png
│   └── 3.0x/                # @3x 高清版本
│       ├── daily_life.png   # (1050x1350)
│       ├── playground.png
│       └── numbers.png
│
└── scenes/                  # 场景卡片封面图 (350x450, 7:9)
    ├── living_room.png      # @1x (350x450)
    ├── kitchen.png
    ├── 2.0x/                # @2x Retina 版本
    │   ├── living_room.png  # (700x900) ⭐ 主要使用
    │   └── kitchen.png
    └── 3.0x/                # @3x 高清版本
        ├── living_room.png  # (1050x1350)
        └── kitchen.png
```

### pubspec.yaml 配置

```yaml
flutter:
  assets:
    - assets/images/categories/
    - assets/images/scenes/
```

**注意**: Flutter 会自动识别 `2.0x/` 和 `3.0x/` 子目录，无需额外配置。

---

## 🛠️ 图片优化工具

### 1. PNG 压缩工具

#### TinyPNG (推荐)
- **网站**: https://tinypng.com
- **特点**: 智能有损压缩，肉眼几乎无差异
- **压缩率**: 50-70%
- **使用**: 拖拽上传，下载压缩后的文件

#### ImageOptim (Mac)
- **下载**: https://imageoptim.com
- **特点**: 批量处理，无损压缩
- **使用**: 拖拽文件夹即可批量优化

#### pngquant (命令行)
```bash
# 安装
brew install pngquant

# 批量压缩
pngquant --quality=65-80 --ext .png --force assets/images/**/*.png
```

### 2. 批量生成多分辨率

#### 使用 ImageMagick
```bash
# 安装
brew install imagemagick

# 从 @3x 生成 @2x 和 @1x
convert input@3x.png -resize 66.67% output@2x.png
convert input@3x.png -resize 33.33% output@1x.png
```

#### 使用 Python 脚本
```python
from PIL import Image
import os

def generate_multi_resolution(source_path, output_dir):
    """从 @3x 图片生成 @2x 和 @1x 版本"""
    img = Image.open(source_path)
    filename = os.path.basename(source_path)

    # @3x (原图)
    img.save(os.path.join(output_dir, '3.0x', filename))

    # @2x (66.67%)
    img_2x = img.resize((int(img.width * 2/3), int(img.height * 2/3)), Image.LANCZOS)
    img_2x.save(os.path.join(output_dir, '2.0x', filename))

    # @1x (33.33%)
    img_1x = img.resize((int(img.width / 3), int(img.height / 3)), Image.LANCZOS)
    img_1x.save(os.path.join(output_dir, filename))

# 使用示例
generate_multi_resolution('daily_life@3x.png', 'assets/images/categories/')
```

---

## 📊 性能优化建议

### 1. 文件大小控制

| 图片类型 | @1x | @2x | @3x |
|---------|-----|-----|-----|
| 所有卡片 (7:9) | < 200KB | < 500KB | < 800KB |

### 2. 加载策略

```dart
// 使用 Flutter 的自动分辨率选择
Image.asset(
  'assets/images/categories/daily_life.png',
  // Flutter 会根据设备像素密度自动选择 @1x/@2x/@3x
)

// 使用缓存提升性能
Image.asset(
  'assets/images/categories/daily_life.png',
  cacheWidth: 700,  // 限制缓存宽度，节省内存
  cacheHeight: 900,
)
```

### 3. 预加载关键图片

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // 预加载分类卡片图片
  precacheImage(
    AssetImage('assets/images/categories/daily_life.png'),
    context,
  );
}
```

---

## ✅ 质量检查清单

### 生成图片时
- [ ] 使用 AI 生成工具时，指定 @2x 尺寸 (700x900 或 600x440)
- [ ] 确保宽高比正确 (分类: 7:9, 场景: 15:11)
- [ ] 检查图片清晰度，无模糊或锯齿
- [ ] 色彩饱和度适中，适合儿童观看

### 优化图片时
- [ ] 使用 TinyPNG 或 ImageOptim 压缩
- [ ] 检查压缩后文件大小符合目标
- [ ] 生成 @2x 和 @1x 版本（@3x 可选）
- [ ] 验证压缩后图片质量无明显损失

### 集成到项目时
- [ ] 按照目录结构放置文件
- [ ] 文件命名一致（不含 @2x/@3x 后缀）
- [ ] 在 pubspec.yaml 中配置资源路径
- [ ] 运行 `flutter pub get` 更新资源
- [ ] 在设备上测试显示效果

---

## 🎨 AI 图片生成 Prompt 模板

### 统一规格 (分类卡片 & 场景卡片) - @2x Retina

```
Create a detailed 3D rendered cover image for [CARD_NAME].

Technical Specifications:
- Format: PNG with transparency
- Resolution: 700 x 900 pixels (7:9 portrait, @2x Retina)
- File size target: < 500KB after compression
- Style: Cinema 4D cute render, child-friendly

[其他具体要求...]
```

**说明**: 所有卡片统一使用 7:9 宽高比，简化生成流程。

---

## 📈 实施计划

### 阶段 1: 立即实施 (必须)
1. 为所有分类卡片生成 @2x (700x900) 版本
2. 使用 TinyPNG 压缩到 < 500KB
3. 按目录结构组织文件
4. 更新 pubspec.yaml 配置

### 阶段 2: 短期优化 (推荐)
1. 为所有场景卡片生成 @2x (700x900) 版本
2. 从 @2x 生成 @1x 降级版本
3. 实施图片预加载策略
4. 在真实设备上测试效果

### 阶段 3: 长期优化 (可选)
1. 为高端设备生成 @3x 版本
2. 实施懒加载和渐进式加载
3. 监控图片加载性能
4. 根据用户反馈持续优化

---

**文��版本**: v1.0
**更新日期**: 2026-02-04
**维护者**: Kiki 开发团队
