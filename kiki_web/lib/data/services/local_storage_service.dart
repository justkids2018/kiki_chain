import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';

/// 本地存储服务
class LocalStorageService {
  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;

  /// 初始化本地存储服务
  Future<void> onInit() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
        webOptions: WebOptions());
    AppLogger.info('💾 本地存储服务初始化完成');
  }

  // =============================================================================
  // 普通存储 (SharedPreferences)
  // =============================================================================

  /// 存储字符串
  Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      AppLogger.debug('Stored string: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('Failed to store string: $key', e);
      return false;
    }
  }

  /// 获取字符串
  String? getString(String key) {
    try {
      final value = _prefs.getString(key);
      AppLogger.debug('Retrieved string: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve string: $key', e);
      return null;
    }
  }

  /// 存储整数
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      AppLogger.debug('Stored int: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('Failed to store int: $key', e);
      return false;
    }
  }

  /// 获取整数
  int? getInt(String key) {
    try {
      final value = _prefs.getInt(key);
      AppLogger.debug('Retrieved int: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve int: $key', e);
      return null;
    }
  }

  /// 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      AppLogger.debug('Stored bool: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('Failed to store bool: $key', e);
      return false;
    }
  }

  /// 获取布尔值
  bool? getBool(String key) {
    try {
      final value = _prefs.getBool(key);
      AppLogger.debug('Retrieved bool: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve bool: $key', e);
      return null;
    }
  }

  /// 存储双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await _prefs.setDouble(key, value);
      AppLogger.debug('Stored double: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('Failed to store double: $key', e);
      return false;
    }
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    try {
      final value = _prefs.getDouble(key);
      AppLogger.debug('Retrieved double: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve double: $key', e);
      return null;
    }
  }

  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await _prefs.setStringList(key, value);
      AppLogger.debug('Stored string list: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('Failed to store string list: $key', e);
      return false;
    }
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    try {
      final value = _prefs.getStringList(key);
      AppLogger.debug('Retrieved string list: $key = $value');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve string list: $key', e);
      return null;
    }
  }

  /// 存储JSON对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await _prefs.setString(key, jsonString);
      AppLogger.debug('Stored JSON: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('Failed to store JSON: $key', e);
      return false;
    }
  }

  /// 获取JSON对象
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        final value = jsonDecode(jsonString) as Map<String, dynamic>;
        AppLogger.debug('Retrieved JSON: $key = $value');
        return value;
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to retrieve JSON: $key', e);
      return null;
    }
  }

  /// 删除指定键的值
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      AppLogger.debug('Removed key: $key');
      return result;
    } catch (e) {
      AppLogger.error('Failed to remove key: $key', e);
      return false;
    }
  }

  /// 清空所有数据
  Future<bool> clear() async {
    try {
      final result = await _prefs.clear();
      AppLogger.debug('Cleared all preferences');
      return result;
    } catch (e) {
      AppLogger.error('Failed to clear preferences', e);
      return false;
    }
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// 获取所有键
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // =============================================================================
  // 安全存储 (FlutterSecureStorage)
  // =============================================================================

  /// 安全存储字符串
  Future<void> setSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      AppLogger.debug('Stored secure string: $key');
    } catch (e) {
      AppLogger.error('Failed to store secure string: $key', e);
    }
  }

  /// 获取安全存储的字符串
  Future<String?> getSecureString(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      AppLogger.debug('Retrieved secure string: $key');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve secure string: $key', e);
      return null;
    }
  }

  /// 删除安全存储的值
  Future<void> deleteSecureString(String key) async {
    try {
      await _secureStorage.delete(key: key);
      AppLogger.debug('Deleted secure string: $key');
    } catch (e) {
      AppLogger.error('Failed to delete secure string: $key', e);
    }
  }

  /// 清空所有安全存储
  Future<void> clearSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
      AppLogger.debug('Cleared all secure storage');
    } catch (e) {
      AppLogger.error('Failed to clear secure storage', e);
    }
  }

  /// 获取所有安全存储的键
  Future<Map<String, String>> getAllSecureStorage() async {
    try {
      final result = await _secureStorage.readAll();
      AppLogger.debug('Retrieved all secure storage');
      return result;
    } catch (e) {
      AppLogger.error('Failed to retrieve all secure storage', e);
      return {};
    }
  }

  // =============================================================================
  // 便捷方法
  // =============================================================================

  /// 存储用户ID
  Future<bool> setUserId(int userId) async {
    return await setInt(AppConstants.keyUserId, userId);
  }

  /// 获取用户ID
  int? getUserId() {
    return getInt(AppConstants.keyUserId);
  }

  /// 存储访问令牌
  Future<void> setAccessToken(String token) async {
    await setSecureString(AppConstants.keyAccessToken, token);
  }

  /// 获取访问令牌
  Future<String?> getAccessToken() async {
    return await getSecureString(AppConstants.keyAccessToken);
  }

  /// 存储刷新令牌
  Future<void> setRefreshToken(String token) async {
    await setSecureString(AppConstants.keyRefreshToken, token);
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await getSecureString(AppConstants.keyRefreshToken);
  }

  /// 存储用户信息
  Future<bool> setUserInfo(Map<String, dynamic> userInfo) async {
    return await setJson(AppConstants.keyUserInfo, userInfo);
  }

  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    return getJson(AppConstants.keyUserInfo);
  }

  /// 清除认证相关数据
  Future<void> clearAuthData() async {
    await Future.wait([
      deleteSecureString(AppConstants.keyAccessToken),
      deleteSecureString(AppConstants.keyRefreshToken),
      remove(AppConstants.keyUserId),
      remove(AppConstants.keyUserInfo),
      remove(AppConstants.keyChatDifyArguments),
    ]);
  }

  /// 清除用户数据（包括认证数据）
  Future<void> clearUserData() async {
    await clearAuthData();
  }
}
