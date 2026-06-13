# App 版本更新功能使用说明

## 功能概述

App 启动时会自动检查版本更新（每周一次），如果有新版本且 `updateStatus=true`，会弹出更新提示窗口，支持静默下载并自动安装。

## 文件结构

```
kiki_web/lib/
├── data/
│   ├── models/
│   │   └── app_update_info.dart           # 版本更新信息模型
│   └── services/
│       └── app_update_service.dart        # 版本更新服务
├── presentation/
│   ├── controllers/
│   │   └── app_update_controller.dart     # 版本更新控制器（含弹窗UI）
│   └── pages/
│       └── splash_page.dart               # 启动页（已集成更新检查）
```

## 远程配置 JSON 格式

**URL:** `https://img.keepthinking.me/download/hikiki/hikik_version.json`

```json
{
  "version": "1.0.1",
  "versionCode": 21,
  "updateTime": "2024-06-01 12:00:00",
  "updateContent": "1. 修复了已知的bug\n2. 优化了用户界面\n3. 提升了应用性能",
  "downloadUrl": "https://img.keepthinking.me/download/hikiki/hikiki_app_new.apk",
  "updateStatus": true
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| version | String | 版本号（显示用） |
| versionCode | int | 版本代码（用于比对，必须大于当前版本才更新） |
| updateTime | String | 更新时间 |
| updateContent | String | 更新内容（支持换行符 `\n`） |
| downloadUrl | String | APK 下载链接 |
| updateStatus | bool | **true** = 弹窗提示更新，**false** = 不提示 |

## 工作流程

```
启动 App
  ↓
进入启动页（SplashPage）
  ↓
1秒后异步检查更新（不阻塞页面跳转）
  ↓
检查距离上次检查是否满7天
  ├─ 否 → 跳过检查
  └─ 是 → 请求远程 JSON
      ↓
  解析 updateStatus
      ├─ false → 跳过
      └─ true → 比对 versionCode
          ├─ 本地版本 ≥ 远程 → 跳过
          └─ 本地版本 < 远程 → 显示更新弹窗
              ↓
          用户点击"立即更新"
              ↓
          静默下载 APK 到独立目录
              ↓
          下载完成 → 弹窗提示安装
              ↓
          调用安装接口（需集成插件）
```

## 核心功能

### 1. 每周检查一次

使用 `GetStorage` 存储上次检查时间，间隔 7 天才会请求远程配置。

```dart
// 存储键
static const String _lastCheckTimeKey = 'app_update_last_check_time';
static const Duration _checkInterval = Duration(days: 7);
```

### 2. 版本比对

只有当远程 `versionCode` 大于本地版本时才提示更新。

```dart
final currentVersionCode = await _getCurrentVersionCode();
if (updateInfo.versionCode > currentVersionCode) {
  // 显示更新弹窗
}
```

### 3. 静默下载

APK 下载到独立目录：`{AppDocuments}/downloads/apk/`

```dart
final downloadDir = Directory('${appDir.path}/downloads/apk');
```

### 4. 下载进度

弹窗中实时显示下载进度条。

```dart
await _updateService.downloadApk(
  info.downloadUrl,
  onProgress: (received, total) {
    downloadProgress.value = received / total;
  },
);
```

## 使用方式

### 自动检查（推荐）

启动页会自动检查，无需额外代码。

### 手动触发

```dart
final updateController = Get.find<AppUpdateController>();
await updateController.checkUpdateOnStartup();
```

## 安装 APK（需要额外配置）

### ⚠️ 重要提示

当前代码中 `installApk()` 方法只是占位符，**实际安装需要集成第三方插件**。

### 推荐插件

#### 方案1：install_plugin（推荐）

```yaml
dependencies:
  install_plugin: ^2.1.0
```

```dart
import 'package:install_plugin/install_plugin.dart';

Future<bool> installApk(String apkPath) async {
  final result = await InstallPlugin.installApk(apkPath, 'com.example.kikichain');
  return result['isSuccess'] == true;
}
```

#### 方案2：open_file

```yaml
dependencies:
  open_file: ^3.3.2
```

```dart
import 'package:open_file/open_file.dart';

Future<bool> installApk(String apkPath) async {
  final result = await OpenFile.open(apkPath);
  return result.type == ResultType.done;
}
```

### Android 权限配置

在 `android/app/src/main/AndroidManifest.xml` 添加：

```xml
<!-- 安装 APK 权限 -->
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>

<!-- Android 7.0+ FileProvider 配置 -->
<application>
    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.fileprovider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/file_paths" />
    </provider>
</application>
```

创建 `android/app/src/main/res/xml/file_paths.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <files-path name="internal_files" path="." />
</paths>
```

## 测试

### 1. 修改远程 JSON

将 `updateStatus` 设为 `true`，`versionCode` 设为比当前版本大（例如 22）。

### 2. 清除检查时间

```dart
GetStorage().remove('app_update_last_check_time');
```

或者重新安装 App。

### 3. 重启 App

启动页会自动弹出更新提示。

## 注意事项

1. **仅支持 Android 平台**：iOS 平台不支持 APK 安装
2. **7天检查间隔**：避免频繁请求，节省流量
3. **不阻塞启动**：更新检查异步执行，不影响页面跳转速度
4. **需要网络权限**：确保 App 有网络访问权限
5. **需要存储权限**：下载 APK 需要存储权限
6. **需要安装权限**：Android 8.0+ 需要"安装未知来源应用"权限

## 自定义配置

### 修改检查间隔

在 `app_update_service.dart` 中修改：

```dart
static const Duration _checkInterval = Duration(days: 3); // 改为3天
```

### 修改下载目录

```dart
Future<Directory> _getDownloadDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final downloadDir = Directory('${appDir.path}/custom/path'); // 自定义路径
  ...
}
```

### 修改远程 URL

```dart
static const String _updateUrlKey = 'https://your-domain.com/version.json';
```

## 版本控制

**当前 App 版本（pubspec.yaml）：**
```yaml
version: 1.0.1+21  # 1.0.1 = version, 21 = versionCode
```

更新版本时同步修改两处：
1. `pubspec.yaml` 中的 `version`
2. 远程 JSON 中的 `versionCode`

## 完成状态

✅ 版本更新检查服务
✅ 每周检查一次机制
✅ 版本比对逻辑
✅ 静默下载功能
✅ 更新弹窗 UI
✅ 下载进度显示
✅ 启动页集成
⚠️ APK 安装（需集成第三方插件）

## 后续优化建议

1. 集成 `install_plugin` 完成自动安装
2. 添加强制更新逻辑（某些版本必须更新才能使用）
3. 添加增量更新（差分包）
4. 添加断点续传
5. 添加更新失败重试机制
