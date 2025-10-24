import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/logging/app_logger.dart';

/// 平台信息
class PlatformInfo {
  final String platform;
  final String version;
  final String buildNumber;
  final String deviceModel;
  final String deviceId;
  final String osVersion;
  final bool isPhysicalDevice;
  
  PlatformInfo({
    required this.platform,
    required this.version,
    required this.buildNumber,
    required this.deviceModel,
    required this.deviceId,
    required this.osVersion,
    required this.isPhysicalDevice,
  });
  
  Map<String, dynamic> toJson() => {
    'platform': platform,
    'version': version,
    'buildNumber': buildNumber,
    'deviceModel': deviceModel,
    'deviceId': deviceId,
    'osVersion': osVersion,
    'isPhysicalDevice': isPhysicalDevice,
  };
}

/// 平台配置管理器
class PlatformConfigManager {
  static PlatformInfo? _platformInfo;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  /// 获取平台信息
  static Future<PlatformInfo> getPlatformInfo() async {
    if (_platformInfo != null) return _platformInfo!;
    
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      String platform = '';
      String deviceModel = '';
      String deviceId = '';
      String osVersion = '';
      bool isPhysicalDevice = true;
      
      if (kIsWeb) {
        platform = 'web';
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceModel = webInfo.browserName.name;
        deviceId = webInfo.vendor ?? 'unknown';
        osVersion = webInfo.platform ?? 'unknown';
        isPhysicalDevice = false;
      } else if (Platform.isAndroid) {
        platform = 'android';
        final androidInfo = await _deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        deviceId = androidInfo.id;
        osVersion = 'Android ${androidInfo.version.release}';
        isPhysicalDevice = androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        platform = 'ios';
        final iosInfo = await _deviceInfo.iosInfo;
        deviceModel = iosInfo.model ?? 'unknown';
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
        isPhysicalDevice = iosInfo.isPhysicalDevice;
      } else if (Platform.isWindows) {
        platform = 'windows';
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceModel = windowsInfo.computerName;
        deviceId = windowsInfo.computerName;
        osVersion = windowsInfo.displayVersion;
        isPhysicalDevice = true;
      } else if (Platform.isMacOS) {
        platform = 'macos';
        final macInfo = await _deviceInfo.macOsInfo;
        deviceModel = macInfo.model;
        deviceId = macInfo.computerName;
        osVersion = macInfo.osRelease;
        isPhysicalDevice = true;
      } else if (Platform.isLinux) {
        platform = 'linux';
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceModel = linuxInfo.name;
        deviceId = linuxInfo.machineId ?? 'unknown';
        osVersion = linuxInfo.version ?? 'unknown';
        isPhysicalDevice = true;
      }
      
      _platformInfo = PlatformInfo(
        platform: platform,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        deviceModel: deviceModel,
        deviceId: deviceId,
        osVersion: osVersion,
        isPhysicalDevice: isPhysicalDevice,
      );
      
      AppLogger.info('Platform Info: ${_platformInfo!.toJson()}');
      return _platformInfo!;
    } catch (e) {
      AppLogger.error('Failed to get platform info', e);
      // 返回默认值
      _platformInfo = PlatformInfo(
        platform: 'unknown',
        version: '1.0.0',
        buildNumber: '1',
        deviceModel: 'unknown',
        deviceId: 'unknown',
        osVersion: 'unknown',
        isPhysicalDevice: true,
      );
      return _platformInfo!;
    }
  }
  
  /// 获取平台特定的存储路径
  static Future<String> getStoragePath() async {
    if (kIsWeb) {
      return '/web_storage';
    } else if (Platform.isAndroid) {
      return '/data/data/com.qiqimanyou.app/files';
    } else if (Platform.isIOS) {
      return '/Documents';
    } else if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Documents\\QiqiManyou';
    } else if (Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Documents/QiqiManyou';
    } else {
      return '/tmp/qiqimanyou';
    }
  }
  
  /// 获取平台特定的缓存路径
  static Future<String> getCachePath() async {
    if (kIsWeb) {
      return '/web_cache';
    } else if (Platform.isAndroid) {
      return '/data/data/com.qiqimanyou.app/cache';
    } else if (Platform.isIOS) {
      return '/Library/Caches';
    } else if (Platform.isWindows) {
      return '${Platform.environment['TEMP']}\\QiqiManyou';
    } else if (Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Library/Caches/QiqiManyou';
    } else {
      return '/tmp/qiqimanyou/cache';
    }
  }
  
  /// 检查是否为移动平台
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  
  /// 检查是否为桌面平台
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  /// 检查是否为Web平台
  static bool get isWeb => kIsWeb;
}
