import 'dart:io';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
import '../logging/app_logger.dart';
import 'model_download_manager.dart';

/// 对 sherpa-onnx VITS OfflineTts 的轻量封装
///
/// 每个实例对应一个语言模型（中文或英文）。
/// [generate] 返回 WAV 文件路径，调用方负责播放。
class SherpaOnnxTtsEngine {
  final TtsModelConfig config;
  final String modelDir;

  sherpa_onnx.OfflineTts? _tts;
  bool _initialized = false;

  SherpaOnnxTtsEngine({required this.config, required this.modelDir});

  bool get isInitialized => _initialized;

  /// 从磁盘加载模型（同步操作，建议在 Isolate 或 compute 中调用）
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _tts = _buildTts();
      _initialized = true;
      AppLogger.info('[SherpaEngine] Loaded model: ${config.dirName}');
    } catch (e) {
      AppLogger.error('[SherpaEngine] Init failed: ${config.dirName}', e);
      rethrow;
    }
  }

  sherpa_onnx.OfflineTts _buildTts() {
    final dir = modelDir;
    final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
      model: _filePath(dir, config.modelFile),
      lexicon:
          config.lexiconFile != null ? _filePath(dir, config.lexiconFile!) : '',
      tokens: _filePath(dir, config.tokensFile),
      dataDir: config.dataDir != null ? _filePath(dir, config.dataDir!) : '',
      dictDir: config.dictDir != null ? _filePath(dir, config.dictDir!) : '',
    );

    final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
      vits: vits,
      numThreads: 2,
      debug: false,
      provider: 'cpu',
    );

    final ttsConfig = sherpa_onnx.OfflineTtsConfig(
      model: modelConfig,
      ruleFsts: '',
      maxNumSenetences: 1,
    );

    return sherpa_onnx.OfflineTts(ttsConfig);
  }

  String _filePath(String dir, String filename) => '$dir/$filename';

  /// 生成语音并写入临时 WAV 文件，返回文件路径
  ///
  /// [sid] 说话人 ID（默认 0）
  /// [speed] 语速系数（1.0 = 正常）
  Future<String> generate({
    required String text,
    required String wavPath,
    int sid = 0,
    double speed = 1.0,
  }) async {
    if (!_initialized || _tts == null) {
      throw StateError('SherpaOnnxTtsEngine not initialized');
    }
    final audio = _tts!.generate(text: text, sid: sid, speed: speed);
    if (audio.samples.isEmpty) {
      throw StateError('Sherpa generated empty audio for: "$text"');
    }
    final ok = sherpa_onnx.writeWave(
      filename: wavPath,
      samples: audio.samples,
      sampleRate: audio.sampleRate,
    );
    if (!ok) throw StateError('writeWave failed: $wavPath');
    AppLogger.debug(
        '[SherpaEngine] Generated WAV: $wavPath (${audio.samples.length} samples)');
    return wavPath;
  }

  void dispose() {
    _tts?.free();
    _tts = null;
    _initialized = false;
  }
}

/// sherpa-onnx VITS 模型的扩展配置（文件布局）
extension TtsModelConfigFiles on TtsModelConfig {
  String get modelFile => _lookup('modelFile') ?? 'model.onnx';
  String get tokensFile => _lookup('tokensFile') ?? 'tokens.txt';
  String? get lexiconFile => _lookup('lexiconFile');
  String? get dataDir => _lookup('dataDir');
  String? get dictDir => _lookup('dictDir');

  String? _lookup(String key) => _extras[key];

  /// 内部使用的额外配置 map，通过工厂方法填入
  static final Map<String, Map<String, String>> _extrasStore = {};

  Map<String, String> get _extras => _extrasStore[_key] ?? const {};

  String get _key => '$language/$dirName';

  static void _register(
    TtsModelConfig config,
    Map<String, String> extras,
  ) {
    _extrasStore['${config.language}/${config.dirName}'] = extras;
  }
}

/// 预定义的中文 VITS 模型（vits-zh-aishell3）
TtsModelConfig zhAishell3Config() {
  const lang = 'zh-CN';
  const dir = 'vits-zh-aishell3';
  const base =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models';

  final config = TtsModelConfig(
    language: lang,
    dirName: dir,
    files: const [
      ModelFileSpec(
          url: '$base/vits-zh-aishell3/model.onnx', localPath: 'model.onnx'),
      ModelFileSpec(
          url: '$base/vits-zh-aishell3/lexicon.txt', localPath: 'lexicon.txt'),
      ModelFileSpec(
          url: '$base/vits-zh-aishell3/tokens.txt', localPath: 'tokens.txt'),
    ],
  );

  TtsModelConfigFiles._register(config, const {
    'modelFile': 'model.onnx',
    'tokensFile': 'tokens.txt',
    'lexiconFile': 'lexicon.txt',
  });

  return config;
}

/// 预定义的英文 VITS 模型（vits-piper-en_US-lessac-medium）
TtsModelConfig enLessacConfig() {
  const lang = 'en-US';
  const dir = 'vits-piper-en_US-lessac-medium';
  const base =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models';

  final config = TtsModelConfig(
    language: lang,
    dirName: dir,
    files: const [
      ModelFileSpec(
        url:
            '$base/vits-piper-en_US-lessac-medium.tar.bz2/en_US-lessac-medium.onnx',
        localPath: 'en_US-lessac-medium.onnx',
      ),
      ModelFileSpec(
        url: '$base/vits-piper-en_US-lessac-medium.tar.bz2/tokens.txt',
        localPath: 'tokens.txt',
      ),
    ],
  );

  TtsModelConfigFiles._register(config, const {
    'modelFile': 'en_US-lessac-medium.onnx',
    'tokensFile': 'tokens.txt',
  });

  return config;
}

/// 检查并创建临时 WAV 文件路径
Future<String> buildWavTempPath(Directory tmpDir, String label) async {
  await tmpDir.create(recursive: true);
  final ts = DateTime.now().millisecondsSinceEpoch;
  return '${tmpDir.path}/sherpa_tts_${label}_$ts.wav';
}
