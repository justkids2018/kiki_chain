# Flutter 中 sherpa-onnx 引用与落地说明（基于当前项目）

## 1. 这份文档解决什么问题

你提到“Flutter 的引用使用不清楚”。
这份文档把两件事合在一起讲清楚：

1. 官方 flutter-examples 的标准用法是什么
2. 在本项目 kiki_web 里应该如何稳定落地

目标是让你后续新增语言、换模型、排查无声问题时，都按同一套规则执行。

## 2. 官方 flutter-examples 的关键结论

参考目录：
https://github.com/k2-fsa/sherpa-onnx/tree/master/flutter-examples

官方示例（尤其 tts）的共性：

1. 依赖层：
   - Flutter 依赖 sherpa_onnx
   - 配合 path_provider/path 处理模型和输出文件路径
   - 再配合播放器（示例里常见 audioplayers/media_kit）播放 wav

2. 初始化顺序：
   - 先调用 sherpa_onnx.initBindings()
   - 再创建 OfflineTts 配置并实例化
   - 生成音频后写出 wav，再交给播放器

3. 模型配置核心：
   - OfflineTtsVitsModelConfig 中最关键的是 model、tokens
   - 中文常带 lexicon
   - 英文 piper 常需要 dataDir 指向 espeak-ng-data

4. 平台注意事项：
   - Android/iOS 需要额外工程配置（minSdk、签名、麦克风权限等）
   - 官方示例是“演示工程”，直接照抄到业务项目前必须先做路径与平台适配

## 3. 本项目当前实现（已对齐官方思路）

你项目已实现“离线优先 + 回退下载”的结构：

> 当前已切换为“本地模型强制模式”：运行时不再进行网络下载。

1. 模型管理：
   - 先检查本地磁盘
   - 不存在则尝试从 assets 复制到 app documents
   - 若 assets 也缺失，则直接报错并提示重新完整安装（不走网络下载）

2. 引擎封装：
   - 每个语言一个 SherpaOnnxTtsEngine
   - 通过 OfflineTtsConfig 构建并缓存

3. 业务调用：
   - LocalSpeechService 负责按语言取引擎
   - 生成 wav 后用 just_audio 播放

## 4. 你项目里“正确的引用方式”

### 4.1 pubspec 依赖引用

在 pubspec.yaml 中保留以下关键依赖：

- sherpa_onnx
- path_provider
- path
- just_audio

说明：
- sherpa_onnx 负责本地推理和写 wav
- path_provider/path 负责跨平台路径
- just_audio 负责播放

### 4.2 pubspec 资源引用

在 flutter.assets 中声明：

- assets/tts_models/

注意：
- 目录声明后，子目录和文件才会被打包
- 更新模型后要重新运行应用，不能只 hot reload

### 4.3 代码层 import 引用

代码中使用包引用：

- import package:sherpa_onnx/sherpa_onnx.dart as sherpa_onnx;

并保证在首次使用推理前调用：

- sherpa_onnx.initBindings()

## 5. 模型目录规范（本项目约定）

### 5.1 中文模型

目录：assets/tts_models/vits-zh-aishell3/

必备文件（当前项目已存在）：

- vits-aishell3.onnx
- tokens.txt
- lexicon.txt

可选附加文件：

- number.fst
- date.fst
- phone.fst
- new_heteronym.fst
- rule.far
- int8 量化模型文件

### 5.2 英文模型

目录：assets/tts_models/vits-piper-en_US-amy-low/

必备文件：

- en_US-amy-low.onnx
- tokens.txt
- espeak-ng-data/ 目录（至少包含以下核心文件）
   - en_dict
   - phontab
   - phonindex
   - phondata
   - phondata-manifest

当前状态：
- 该英文目录已补齐

## 6. 一键下载模型（项目已提供）

在项目根目录执行：

    cd kiki_web
    bash scripts/download_tts_models.sh

脚本默认从 tts-models 标签下载：

- vits-zh-aishell3.tar.bz2
- vits-piper-en_US-amy-low.tar.bz2

下载后检查：

1. assets/tts_models/vits-zh-aishell3/ 存在
2. assets/tts_models/vits-piper-en_US-amy-low/ 存在
3. 重新运行 Flutter 应用

## 7. 运行时时序（建议保持）

1. 进入页面时初始化 LocalSpeechService（不阻塞页面）
2. 首次朗读时：
   - ensureBindings
   - ensureEngine
   - 检查/复制/下载模型
   - 构建 OfflineTts
3. generate 生成 wav
4. just_audio 播放
5. 播放后删除临时 wav

这套时序可以保证：
- 首次慢但稳定
- 后续复用引擎，速度明显更快

## 8. 常见问题与对应修复

### 8.1 点击朗读没声音

优先检查：

1. 模型是否真的存在（尤其英文目录）
2. 模型文件名是否和代码配置一致
3. 日志是否出现 Engine init failed / generated empty audio
4. 设备输出音量和音频路由

### 8.2 中文有声音，英文没声音

通常是英文模型缺失或 dataDir 不完整：

1. en_US-amy-low.onnx 不存在
2. tokens.txt 不存在
3. espeak-ng-data/en_dict 不存在

### 8.3 改了模型但仍旧行为异常

执行全量重启而不是 hot reload：

1. flutter clean
2. flutter pub get
3. 重新 flutter run

## 9. 当前项目建议的统一实践

1. 模型来源统一用 tts-models 标签，不混用代码版本页面
2. 模型文件名与代码配置一一对应，禁止“猜测式命名”
3. 引擎初始化失败要保留明确日志，便于定位
4. 仅使用本地 assets（无运行时网络下载）
5. 英文模型补齐后再做最终回归测试

## 10. 你现在可以直接执行的最短路径

1. 在 kiki_web 下运行脚本补齐英文模型
2. 重新启动应用（非 hot reload）
3. 在学习卡片里分别测试中文和英文朗读
4. 若英文仍无声，按第 8 节逐项排查并抓日志

---

如果后续你希望，我可以在这份文档基础上再补一份“新增第三种语言模型（例如日语）”的操作模板，直接按表格填参数就能接入。