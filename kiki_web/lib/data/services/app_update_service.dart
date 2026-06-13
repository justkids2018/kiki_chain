import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_update_info.dart';

/// App 版本更新服务
///
/// 功能：
/// - 每周检查一次版本更新
/// - 解析远程 JSON 配置
/// - 静默下载 APK 到独立目录
/// - 提供安装接口
class AppUpdateService {
  static const String _updateUrlKey =
      'https://img.keepthinking.me/download/hikiki/hikik_version.json';
  static const String _lastCheckTimeKey = 'app_update_last_check_time';
  static const Duration _checkInterval = Duration(days: 7);

  final Dio _dio;
  final GetStorage _storage;

  AppUpdateService({Dio? dio, GetStorage? storage})
      : _dio = dio ?? Dio(),
        _storage = storage ?? GetStorage();

  Future<bool> _shouldCheckUpdate() async {
    final lastCheckTime = _storage.read<int>(_lastCheckTimeKey);
    if (lastCheckTime == null) {
      return true;
    }

    final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckTime);
    final now = DateTime.now();
    return now.difference(lastCheck) >= _checkInterval;
  }

  Future<void> _markCheckedNow() async {
    await _storage.write(
        _lastCheckTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// 首页数据加载完成后调用：超过 7 天才请求远程版本信息。
  Future<AppUpdateInfo?> checkUpdateIfDue() async {
    try {
      if (!await _shouldCheckUpdate()) {
        debugPrint('[AppUpdate] 距离上次检查未满7天，跳过检查');
        return null;
      }

      debugPrint('[AppUpdate] 开始检查版本更新: $_updateUrlKey');

      final response = await _dio.get(
        _updateUrlKey,
        options: Options(
          headers: {'Cache-Control': 'no-cache'},
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final updateInfo = AppUpdateInfo.fromJson(response.data);
        debugPrint('[AppUpdate] 获取到版本信息: $updateInfo');

        await _markCheckedNow();

        if (updateInfo.updateStatus) {
          final currentVersionCode = await _getCurrentVersionCode();
          if (updateInfo.versionCode > currentVersionCode) {
            debugPrint(
                '[AppUpdate] 发现新版本: ${updateInfo.version} (${updateInfo.versionCode}) > 当前版本: $currentVersionCode');
            return updateInfo;
          } else {
            debugPrint('[AppUpdate] 当前已是最新版本');
          }
        } else {
          debugPrint('[AppUpdate] updateStatus=false，无需更新');
        }
      }

      return null;
    } catch (e) {
      debugPrint('[AppUpdate] 检查更新失败: $e');
      return null;
    }
  }

  /// 获取当前 App 版本号
  Future<int> _getCurrentVersionCode() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return int.tryParse(packageInfo.buildNumber) ?? 0;
    } catch (e) {
      debugPrint('[AppUpdate] 获取版本号失败: $e');
      return 0;
    }
  }

  /// 静默下载 APK
  ///
  /// 返回下载的文件路径，失败返回 null
  Future<String?> downloadApk(
    String downloadUrl, {
    required String version,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // 仅支持 Android 平台
      if (!Platform.isAndroid) {
        debugPrint('[AppUpdate] 仅支持 Android 平台下载 APK');
        return null;
      }

      debugPrint('[AppUpdate] 开始下载 APK: $downloadUrl');

      // 获取下载目录
      final dir = await _getDownloadDirectory();
      final fileName = 'hikiki_$version.apk'; // 文件名包含版本号
      final filePath = '${dir.path}/$fileName';

      // 检查本地是否已有相同版本的 APK
      final localFile = File(filePath);
      if (await localFile.exists()) {
        final fileSize = await localFile.length();
        debugPrint(
            '[AppUpdate] 发现本地已有版本 $version 的 APK ($fileSize bytes)，跳过下载');
        return filePath;
      }

      // 下载文件
      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('[AppUpdate] 下载进度: $progress% ($received/$total)');
            onProgress?.call(received, total);
          }
        },
      );

      debugPrint('[AppUpdate] APK 下载完成: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('[AppUpdate] 下载 APK 失败: $e');
      return null;
    }
  }

  /// 检查本地是否已有指定版本的APK
  Future<bool> hasLocalApk(String version) async {
    try {
      final dir = await _getDownloadDirectory();
      final fileName = 'hikiki_$version.apk';
      final filePath = '${dir.path}/$fileName';
      final localFile = File(filePath);
      return await localFile.exists();
    } catch (e) {
      debugPrint('[AppUpdate] 检查本地APK失败: $e');
      return false;
    }
  }

  /// 获取本地APK路径
  Future<String?> getLocalApkPath(String version) async {
    try {
      final dir = await _getDownloadDirectory();
      final fileName = 'hikiki_$version.apk';
      final filePath = '${dir.path}/$fileName';
      final localFile = File(filePath);
      if (await localFile.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('[AppUpdate] 获取本地APK路径失败: $e');
      return null;
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads/apk');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    return downloadDir;
  }

  /// 清理旧的 APK 文件
  Future<void> cleanOldApkFiles() async {
    try {
      final dir = await _getDownloadDirectory();
      final files = dir.listSync();

      for (final file in files) {
        if (file is File && file.path.endsWith('.apk')) {
          await file.delete();
          debugPrint('[AppUpdate] 已清���旧 APK: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('[AppUpdate] 清理 APK 文件失败: $e');
    }
  }

  /// 安装 APK
  Future<bool> installApk(String apkPath) async {
    try {
      if (!Platform.isAndroid) {
        debugPrint('[AppUpdate] 仅支持 Android 平台安装 APK');
        return false;
      }

      final file = File(apkPath);
      if (!await file.exists()) {
        debugPrint('[AppUpdate] APK 文件不存在: $apkPath');
        return false;
      }

      // 检查并请求安装权限（Android 8.0+）
      if (Platform.isAndroid) {
        final status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          debugPrint('[AppUpdate] 请求安装未知应用权限');
          final result = await Permission.requestInstallPackages.request();
          if (!result.isGranted) {
            debugPrint('[AppUpdate] 用户拒绝了安装权限');
            return false;
          }
        }
      }

      debugPrint('[AppUpdate] 准备安装 APK: $apkPath');

      final result = await OpenFilex.open(
        apkPath,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type == ResultType.done) {
        debugPrint('[AppUpdate] APK 安装启动成功');
        return true;
      } else {
        debugPrint('[AppUpdate] APK 安装启动失败: ${result.message}');
        return false;
      }
    } catch (e) {
      debugPrint('[AppUpdate] 安装 APK 失败: $e');
      return false;
    }
  }
}
