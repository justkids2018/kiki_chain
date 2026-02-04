import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 加密工具类
class CryptoUtils {
  /// SHA256 加密
  ///
  /// 用于密码加密后传输到服务器
  ///
  /// 参数:
  /// - [input] 需要加密的字符串
  ///
  /// 返回:
  /// - [String] SHA256加密后的十六进制字符串
  static String sha256Encrypt(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 生成游客ID
  ///
  /// 生成一个唯一的游客ID，格式为: guest_{timestamp}_{random}
  ///
  /// 返回:
  /// - [String] 游客ID
  static String generateGuestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'guest_${timestamp}_$random';
  }
}
