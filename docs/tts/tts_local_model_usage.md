# 学习卡片本地 TTS 模型使用说明

## 目标

让学习卡片“点击朗读”优先使用项目内置模型，不依赖运行时网络下载。

## 当前逻辑

1. 进入学习卡片页面后会初始化语音服务。
2. 朗读触发时先检查模型是否就绪。
3. 若本地磁盘无模型，则优先从 `assets/tts_models/<model_dir>/` 复制到应用本地目录。
4. 若 assets 中也没有，才回退到网络下载。
5. 模型准备完成后，用 `sherpa_onnx` 生成 WAV，再由 `just_audio` 播放。

对应关键代码：

- `kiki_web/lib/core/speech/model_download_manager.dart`
- `kiki_web/lib/core/speech/local_speech_service.dart`
- `kiki_web/lib/core/speech/sherpa_tts_engine.dart`

## 模型目录约定

本项目使用两个模型目录（目录名必须一致）：

- `assets/tts_models/vits-zh-aishell3/`
- `assets/tts_models/vits-piper-en_US-amy-low/`

## 一键下载模型

在项目根目录执行：

```bash
cd kiki_web
bash scripts/download_tts_models.sh
```

脚本会自动下载并解压：

- `vits-zh-aishell3.tar.bz2`
- `vits-piper-en_US-amy-low.tar.bz2`

## Flutter 资源声明

`pubspec.yaml` 已包含：

```yaml
assets:
  - assets/tts_models/
```

下载完成后需要重新运行应用，让新资源被打包。

## 故障排查

1. 点击朗读无声
- 检查模型目录是否存在且有文件。
- 检查设备音量和系统输出设备。

2. 中文有声，英文无声
- 检查 `assets/tts_models/vits-piper-en_US-amy-low/` 是否完整。
- 尤其确认 `en_US-amy-low.onnx`、`tokens.txt`、`espeak-ng-data/`。

3. 首次朗读较慢
- 正常现象。首次会初始化引擎并准备模型，后续会明显变快。

## 备注

这是“离线优先”方案：

- 有内置模型时：完全离线可用。
- 无内置模型时：仍可回退网络下载，兼容旧流程。
