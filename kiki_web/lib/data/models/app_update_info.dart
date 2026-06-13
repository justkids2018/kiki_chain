/// App 版本更新信息模型
class AppUpdateInfo {
  final String version;
  final int versionCode;
  final String updateTime;
  final String updateContent;
  final String downloadUrl;
  final bool updateStatus;

  AppUpdateInfo({
    required this.version,
    required this.versionCode,
    required this.updateTime,
    required this.updateContent,
    required this.downloadUrl,
    required this.updateStatus,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] as String,
      versionCode: json['versionCode'] as int,
      updateTime: json['updateTime'] as String,
      updateContent: json['updateContent'] as String,
      downloadUrl: json['downloadUrl'] as String,
      updateStatus: json['updateStatus'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'versionCode': versionCode,
      'updateTime': updateTime,
      'updateContent': updateContent,
      'downloadUrl': downloadUrl,
      'updateStatus': updateStatus,
    };
  }

  @override
  String toString() {
    return 'AppUpdateInfo(version: $version, versionCode: $versionCode, updateStatus: $updateStatus)';
  }
}
