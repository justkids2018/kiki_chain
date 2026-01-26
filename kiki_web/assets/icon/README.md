# 应用图标配置说明

## 使用步骤

### 1. 准备图标文件
将您的应用图标（1024x1024 像素，PNG 格式）保存为：
```
assets/icon/app_icon.png
```

**图标要求：**
- 尺寸：1024x1024 像素
- 格式：PNG
- 背景：建议使用浅蓝色 (#E0F2F7) 或透明背景
- 内容：确保图标在安全区域内（避免边缘被裁剪）

### 2. 安装依赖
```bash
flutter pub get
```

### 3. 生成所有尺寸的图标
```bash
flutter pub run flutter_launcher_icons
```

这个命令会自动生成：
- **iOS**: 所有需要的尺寸（20x20 到 1024x1024）
- **Android**: 所有密度的图标（mdpi 到 xxxhdpi）
- **Android 自适应图标**: 前景和背景图层

### 4. 验证生成结果

**iOS 图标位置：**
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

**Android 图标位置：**
```
android/app/src/main/res/mipmap-*/
```

### 5. 重新构建应用
```bash
# iOS
flutter build ios

# Android
flutter build apk
```

## 当前配置

- **应用名称**: Hi Kiki
- **图标背景色**: #E0F2F7 (浅蓝色)
- **图标路径**: assets/icon/app_icon.png

## 注意事项

1. **iOS 要求**：
   - 图标不能有透明通道（已配置自动移除）
   - 图标会自动添加圆角

2. **Android 自适应图标**：
   - 前景图层：您的图标内容
   - 背景图层：浅蓝色 (#E0F2F7)
   - 系统会根据设备自动应用形状（圆形、方形、圆角方形等）

3. **图标安全区域**：
   - 建议将重要内容保持在中心 80% 的区域内
   - 避免在边缘放置重要元素

## 更新图标

如果需要更新图标：
1. 替换 `assets/icon/app_icon.png`
2. 重新运行 `flutter pub run flutter_launcher_icons`
3. 重新构建应用
