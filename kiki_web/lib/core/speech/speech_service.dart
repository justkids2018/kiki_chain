import '../../domain/entities/interactive_region.dart';

/// 语音服务统一接口，供页面控制器调用
abstract class SpeechService {
  Future<void> initialize();
  Future<void> speakRegion(InteractiveRegion region);
  Future<void> speakPinyin(InteractiveRegion region);
  Future<void> speak(String text, {String language = 'zh-CN'});
  Future<void> stop();
  void dispose();
}

/// 语音模型加载状态
enum SpeechModelState {
  /// 模型文件尚未下载
  notDownloaded,

  /// 正在下载模型
  downloading,

  /// 模型就绪，可推理
  ready,

  /// 下载或加载失败
  failed,
}
