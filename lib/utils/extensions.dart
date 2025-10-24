import 'dart:convert';

/// 字符串扩展
extension StringExtension on String {
  /// 判断是否为空字符串
  bool get isEmptyOrNull => isEmpty;
  
  /// 判断是否不为空字符串
  bool get isNotEmptyOrNull => isNotEmpty;
  
  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  /// 每个单词首字母大写
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// 移除所有空格
  String get removeSpaces => replaceAll(' ', '');
  
  /// 移除首尾空格
  String get trimmed => trim();
  
  /// 转换为Base64
  String get toBase64 => base64Encode(utf8.encode(this));
  
  /// 从Base64解码
  String get fromBase64 => utf8.decode(base64Decode(this));
  
  /// 验证是否为有效的URL
  bool get isValidUrl {
    return Uri.tryParse(this) != null;
  }
  
  /// 验证是否为有效的邮箱
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  /// 验证是否为有效的手机号
  bool get isValidPhone {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }
  
  /// 验证是否只包含数字
  bool get isNumeric {
    return RegExp(r'^-?\d+\.?\d*$').hasMatch(this);
  }
  
  /// 验证是否只包含字母
  bool get isAlpha {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }
  
  /// 验证是否只包含字母和数字
  bool get isAlphaNumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }
}

/// 列表扩展
extension ListExtension<T> on List<T> {
  /// 获取第一个元素，如果为空则返回null
  T? get firstOrNull => isEmpty ? null : first;
  
  /// 获取最后一个元素，如果为空则返回null
  T? get lastOrNull => isEmpty ? null : last;
  
  /// 安全获取指定索引的元素
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
  
  /// 分组
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keyFunction(item);
      if (!map.containsKey(key)) {
        map[key] = <T>[];
      }
      map[key]!.add(item);
    }
    return map;
  }
  
  /// 去重
  List<T> get distinct {
    final seen = <T>{};
    return where((item) => seen.add(item)).toList();
  }
  
  /// 打乱顺序
  List<T> shuffled() {
    final list = List<T>.from(this);
    list.shuffle();
    return list;
  }
}

/// 日期时间扩展
extension DateTimeExtension on DateTime {
  /// 格式化为字符串
  String format([String pattern = 'yyyy-MM-dd HH:mm:ss']) {
    return pattern
        .replaceAll('yyyy', year.toString())
        .replaceAll('MM', month.toString().padLeft(2, '0'))
        .replaceAll('dd', day.toString().padLeft(2, '0'))
        .replaceAll('HH', hour.toString().padLeft(2, '0'))
        .replaceAll('mm', minute.toString().padLeft(2, '0'))
        .replaceAll('ss', second.toString().padLeft(2, '0'));
  }
  
  /// 获取相对时间
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// 是否为本周
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }
  
  /// 获取月份的第一天
  DateTime get firstDayOfMonth => DateTime(year, month, 1);
  
  /// 获取月份的最后一天
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);
}

/// 数字扩展
extension IntExtension on int {
  /// 转换为文件大小格式
  String get fileSize {
    if (this < 1024) {
      return '${this}B';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(1)}KB';
    } else if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
  
  /// 转换为时长格式
  String get duration {
    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final seconds = this % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  /// 转换为货币格式
  String get currency {
    return '¥${toStringAsFixed(2)}';
  }
}

/// 双精度浮点数扩展
extension DoubleExtension on double {
  /// 转换为货币格式
  String get currency {
    return '¥${toStringAsFixed(2)}';
  }
  
  /// 转换为百分比格式
  String get percentage {
    return '${(this * 100).toStringAsFixed(1)}%';
  }
}
