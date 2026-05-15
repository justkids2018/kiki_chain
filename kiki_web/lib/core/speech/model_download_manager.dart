import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
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
  static const String _bundledModelsDir = 'assets/tts_models';

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

  Future<bool> _filesExist(TtsModelConfig config) async {
    final dir = await modelDirPath(config);
    for (final spec in config.files) {
      final f = File('$dir/${spec.localPath}');
      if (!await f.exists()) return false;
    }
    return true;
  }

  Future<bool> _tryCopyBundledFiles(TtsModelConfig config) async {
    final dir = await modelDirPath(config);
    await Directory(dir).create(recursive: true);

    var copiedAny = false;
    for (final spec in config.files) {
      final target = File('$dir/${spec.localPath}');
      if (await target.exists()) continue;

      final assetPath =
          '$_bundledModelsDir/${config.dirName}/${spec.localPath}';
      try {
        final data = await rootBundle.load(assetPath);
        await target.parent.create(recursive: true);
        await target.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        copiedAny = true;
        AppLogger.info('[ModelManager] Copied bundled model file: $assetPath');
      } catch (e) {
        AppLogger.warning(
            '[ModelManager] Bundled asset not found: $assetPath ($e)');
      }
    }

    final nestedDirs = config.files
        .map((f) => f.localPath)
        .where((p) => p.contains('/'))
        .map((p) => p.split('/').first)
        .toSet();

    for (final nestedDir in nestedDirs) {
      final copied = await _tryCopyBundledDirectory(
        config: config,
        modelRootDir: dir,
        nestedDir: nestedDir,
      );
      if (copied > 0) {
        copiedAny = true;
        AppLogger.info(
          '[ModelManager] Copied bundled directory $nestedDir: $copied files',
        );
      }
    }

    if (copiedAny && await _filesExist(config)) {
      AppLogger.info(
          '[ModelManager] Bundled model is ready: ${config.dirName}');
      return true;
    }

    return false;
  }

  Future<int> _tryCopyBundledDirectory({
    required TtsModelConfig config,
    required String modelRootDir,
    required String nestedDir,
  }) async {
    final prefix = '$_bundledModelsDir/${config.dirName}/$nestedDir/';

    List<String> assets;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      assets = manifest.listAssets();
    } catch (e) {
      AppLogger.warning('[ModelManager] Unable to read asset manifest: $e');
      return 0;
    }

    final keys = assets.where((k) => k.startsWith(prefix)).toList();
    if (keys.isEmpty) {
      return 0;
    }

    var copied = 0;
    for (final assetPath in keys) {
      final relative =
          assetPath.substring('$_bundledModelsDir/${config.dirName}/'.length);
      final target = File('$modelRootDir/$relative');
      if (await target.exists()) continue;

      try {
        final data = await rootBundle.load(assetPath);
        await target.parent.create(recursive: true);
        await target.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        copied++;
      } catch (e) {
        AppLogger.warning(
            '[ModelManager] Failed to copy bundled directory asset: $assetPath ($e)');
      }
    }

    return copied;
  }

  /// 返回指定模型配置的本地根目录路径
  Future<String> modelDirPath(TtsModelConfig config) async {
    final base = await _getBaseDir();
    return '${base.path}/${config.dirName}';
  }

  /// 检查模型所有文件是否已存在
  Future<bool> isReady(TtsModelConfig config) async {
    if (await _filesExist(config)) return true;

    // 优先尝试从打包的 assets 复制模型到本地磁盘。
    if (await _tryCopyBundledFiles(config)) return true;

    return false;
  }

  /// 获取当前模型状态
  Future<SpeechModelState> getState(TtsModelConfig config) async {
    if (await isReady(config)) return SpeechModelState.ready;
    return SpeechModelState.notDownloaded;
  }

  /// 下载模型所有文件，通过 [progressStream] 广播进度
  Future<bool> download(TtsModelConfig config) async {
    AppLogger.warning(
      '[ModelManager] Runtime model download is disabled. '
      'Please bundle models under assets/tts_models and reinstall the app.',
    );
    return false;
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
