import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../logging/app_logger.dart';
import 'speech_service.dart';

/// 单个模型文件的下载描述
class ModelFileSpec {
  final String url;

  /// 相对于模型根目录的本地路径，例如 'model.onnx'
  final String localPath;

  const ModelFileSpec({required this.url, required this.localPath});
}

/// 单语言 TTS 模型配置
class TtsModelConfig {
  final String language;

  /// 模型根目录名（在 <appDocDir>/sherpa_onnx/ 下）
  final String dirName;

  /// 需要下载的文件列表
  final List<ModelFileSpec> files;

  const TtsModelConfig({
    required this.language,
    required this.dirName,
    required this.files,
  });
}

/// 管理 sherpa-onnx 模型文件的下载与本地缓存
class ModelDownloadManager {
  static const String _baseDirName = 'sherpa_onnx';

  final Dio _dio = Dio()
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(minutes: 10);

  Directory? _baseDir;

  final _progressController =
      StreamController<ModelDownloadProgress>.broadcast();

  Stream<ModelDownloadProgress> get progressStream =>
      _progressController.stream;

  Future<Directory> _getBaseDir() async {
    if (_baseDir != null) return _baseDir!;
    final appDir = await getApplicationDocumentsDirectory();
    _baseDir = Directory('${appDir.path}/$_baseDirName');
    await _baseDir!.create(recursive: true);
    return _baseDir!;
  }

  /// 返回指定模型配置的本地根目录路径
  Future<String> modelDirPath(TtsModelConfig config) async {
    final base = await _getBaseDir();
    return '${base.path}/${config.dirName}';
  }

  /// 检查模型所有文件是否已存在
  Future<bool> isReady(TtsModelConfig config) async {
    final dir = await modelDirPath(config);
    for (final spec in config.files) {
      final f = File('$dir/${spec.localPath}');
      if (!await f.exists()) return false;
    }
    return true;
  }

  /// 获取当前模型状态
  Future<SpeechModelState> getState(TtsModelConfig config) async {
    if (await isReady(config)) return SpeechModelState.ready;
    return SpeechModelState.notDownloaded;
  }

  /// 下载模型所有文件，通过 [progressStream] 广播进度
  Future<bool> download(TtsModelConfig config) async {
    final dir = await modelDirPath(config);
    await Directory(dir).create(recursive: true);

    final total = config.files.length;
    for (var i = 0; i < total; i++) {
      final spec = config.files[i];
      final dest = File('$dir/${spec.localPath}');

      // 父目录可能需要创建（例如子目录文件）
      await dest.parent.create(recursive: true);

      if (await dest.exists()) {
        AppLogger.info('[ModelManager] Skip (cached): ${spec.localPath}');
        _progressController.add(ModelDownloadProgress(
          language: config.language,
          fileIndex: i,
          fileCount: total,
          fileName: spec.localPath,
          receivedBytes: -1,
          totalBytes: -1,
        ));
        continue;
      }

      AppLogger.info('[ModelManager] Downloading: ${spec.url}');
      try {
        await _dio.download(
          spec.url,
          dest.path,
          onReceiveProgress: (received, totalBytes) {
            _progressController.add(ModelDownloadProgress(
              language: config.language,
              fileIndex: i,
              fileCount: total,
              fileName: spec.localPath,
              receivedBytes: received,
              totalBytes: totalBytes,
            ));
          },
          options: Options(responseType: ResponseType.stream),
        );
        AppLogger.info('[ModelManager] Done: ${spec.localPath}');
      } catch (e) {
        AppLogger.error('[ModelManager] Failed: ${spec.localPath}', e);
        // 删除不完整文件
        if (await dest.exists()) await dest.delete();
        return false;
      }
    }
    return true;
  }

  /// 删除指定模型的所有本地文件（可用于重置）
  Future<void> deleteModel(TtsModelConfig config) async {
    final dir = Directory(await modelDirPath(config));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      AppLogger.info('[ModelManager] Deleted: ${config.dirName}');
    }
  }

  void dispose() {
    _progressController.close();
    _dio.close();
  }
}

/// 下载进度事件
class ModelDownloadProgress {
  final String language;
  final int fileIndex;
  final int fileCount;
  final String fileName;
  final int receivedBytes;
  final int totalBytes;

  const ModelDownloadProgress({
    required this.language,
    required this.fileIndex,
    required this.fileCount,
    required this.fileName,
    required this.receivedBytes,
    required this.totalBytes,
  });

  /// 当前文件的下载百分比（0~1），-1 表示已缓存跳过
  double get fileProgress {
    if (receivedBytes < 0) return 1.0;
    if (totalBytes <= 0) return 0.0;
    return receivedBytes / totalBytes;
  }

  /// 整体进度（基于文件数量）
  double get overallProgress =>
      (fileIndex + fileProgress) / fileCount.clamp(1, fileCount);
}
