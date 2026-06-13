# 版本更新测试说明

## 测试模式已启用

当前代码处于**测试模式**，`forceCheck = true`，具有以下特性：

### ✅ 测试模式特性

1. **忽略7天时间限制** - 每次启动都会检查
2. **忽略 updateStatus** - 即使 `updateStatus=false` 也会弹窗
3. **总是显示更新信息** - 方便测试弹窗和下载流程

### 📍 测试模式代码位置

**文件:** `kiki_web/lib/presentation/pages/splash_page.dart`

```dart
// 🧪 测试模式：forceCheck = true
await updateController.checkUpdateOnStartup(forceCheck: true);
```

### 🔄 切换到生产模式

测试完成后，修改为：

```dart
// 生产模式：forceCheck = false
await updateController.checkUpdateOnStartup(forceCheck: false);
```

或者直接删除参数（默认为 false）：

```dart
await updateController.checkUpdateOnStartup();
```

## 测试步骤

### 1. 准备测试环境

确保远程 JSON 可访问：
```
https://img.keepthinking.me/download/hikiki/hikik_version.json
```

### 2. 测试 updateStatus=false

修改远程 JSON：
```json
{
  "version": "1.0.2",
  "versionCode": 22,
  "updateTime": "2026-06-13 10:00:00",
  "updateContent": "测试更新弹窗（updateStatus=false）",
  "downloadUrl": "https://img.keepthinking.me/download/hikiki/hikiki_app_new.apk",
  "updateStatus": false
}
```

**预期结果：** ✅ 仍然会弹出更新提示窗口

### 3. 测试频繁检查

连续重启 App 多次。

**预期结果：** ✅ 每次启动都会检查更新（不受7天限制）

### 4. 测试下载功能

点击"立即更新"按钮。

**预期结果：**
- ✅ 显示下载进度条
- ✅ 下载到 `{AppDocuments}/downloads/apk/`
- ✅ 下载完成后弹出安装提示

### 5. 测试版本比对

修改 `pubspec.yaml`：
```yaml
version: 1.0.3+23  # versionCode = 23
```

远程 JSON 保持 versionCode = 22

**预期结果：** ✅ 仍然会弹窗（因为测试模式忽略版本比对）

## 查看日志

Flutter 运行时查看控制台输出：

```
[AppUpdate] 开始检查版本更新: https://...
[AppUpdate] 获取到版本信息: AppUpdateInfo(...)
[AppUpdate] 测试模式：强制返回更新信息
[AppUpdateController] 发现新版本，显示弹窗
```

## 生产模式行为

当 `forceCheck = false` 时：

1. ✅ 只在距离上次检查 ≥7天 时才检查
2. ✅ 只在 `updateStatus=true` 时弹窗
3. ✅ 只在 `versionCode > 本地版本` 时弹窗

## 注意事项

⚠️ **上线前必须切换回生产模式！**

测试完成后，务必修改：
```dart
// kiki_web/lib/presentation/pages/splash_page.dart
await updateController.checkUpdateOnStartup(forceCheck: false);
```

否则用户每次启动都会看到更新弹窗。

## 测试清单

- [ ] updateStatus=false 时弹窗正常显示
- [ ] 频繁启动 App 不受7天限制
- [ ] 下载进度显示正常
- [ ] 下载完成后提示安装
- [ ] 日志输出正确
- [ ] 测试完成后切换回生产模式

---

**当前状态：** 🧪 测试模式  
**切换方法：** 修改 `splash_page.dart` 中的 `forceCheck` 参数
