# 本地语音公共模块技术方案（Sherpa-ONNX Only）

**日期**: 2026-05-14  
**版本**: 1.0  
**状态**: Draft（用于当前技术决策与后续实施）

---

## 1. 背景与目标

当前项目在学习卡片详情页（Interactive Image）里，点击图片热区/学习卡片后可触发语音播放。现有链路包含：

- 云 TTS（Edge/Azure）
- 系统 TTS（`flutter_tts`）兜底
- `just_audio` 播放缓存音频

本次决策改为：**只保留本地方案，统一使用 sherpa-onnx，移除云服务依赖**。  
后续希望可平滑接入本地大模型（Ollama/llama.cpp 等），但不影响当前点读功能先落地。

---

## 2. 决策结论

1. 语音能力统一为本地：**TTS/ASR（可选）均走 sherpa-onnx**。
2. 构建独立公共模块，不与 `interactive_image` 页面强绑定。
3. 默认只启用这一套，不保留云 TTS 分支。
4. 先保证“点图/点卡片发音”稳定，再扩展“本地 ASR + 本地 LLM + TTS 回读”。

---

## 3. 当前代码基线（已存在）

### 3.1 关键依赖

- `pubspec.yaml`
  - `just_audio: ^0.9.39`
  - `flutter_tts: ^3.8.3`

### 3.2 关键文件路径

- `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`
- `lib/presentation/pages/interactive_image/services/cloud_tts_service.dart`
- `lib/presentation/pages/interactive_image/interactive_image_controller.dart`
- `lib/presentation/pages/interactive_image/interactive_image_page.dart`
- `lib/core/settings/app_settings_service.dart`
- `lib/presentation/widgets/settings_dialog.dart`

### 3.3 当前触发点（UI -> 发音）

- 热区点击发音：`interactive_image_page.dart` -> `controller.speakRegion(...)`
- 学习卡片点击发音：`controller.speakRegion(...)`
- 英文点击发音：`controller.speakEnglishWord(...)`
- 拼音点击发音：`controller.speakPinyin(...)`
- 单字点击发音：`controller.speakChineseChar(...)`

---

## 4. 目标架构（本地优先 / 可扩展）

```text
UI点击（热区/卡片/单字）
  -> InteractiveImageController
    -> SpeechService（公共接口）
      -> SherpaTtsProvider（本地）
        -> 本地模型文件（assets/models/sherpa_onnx/...）
        -> PCM/WAV 输出
      -> AudioPlayback（本地播放，just_audio）
```

> 说明：`SpeechService` 设计为公共服务层，`interactive_image` 仅调用接口，不关心具体实现。

---

## 5. 目录与模块规划

新增公共模块（建议）：

```text
lib/core/speech/
  speech_service.dart                 # 对外统一入口
  speech_types.dart                   # 请求/响应/错误类型
  providers/
    sherpa_tts_provider.dart          # sherpa-onnx TTS实现
    sherpa_asr_provider.dart          # 可选：后续ASR
  playback/
    audio_playback_service.dart       # just_audio 封装
  model/
    model_registry.dart               # 模型路径、语言、speaker配置
    model_downloader.dart             # 可选：后续模型下载/校验
```

页面侧改造（保留）：

- `interactive_image_controller.dart` 由 `TextToSpeechService` 切换到 `SpeechService`
- `interactive_image_page.dart` 点击逻辑不变（继续调用 controller）

待删除（迁移完成后）：

- `lib/presentation/pages/interactive_image/services/cloud_tts_service.dart`
- `lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`（由适配层替换后删除）
- `pubspec.yaml` 中 `flutter_tts`（确认无其他页面依赖后删除）

---

## 6. 依赖与版本策略

## 6.1 Sherpa-ONNX 参考信息

- GitHub: `k2-fsa/sherpa-onnx`
- Release（latest）: `v1.13.2`（2026-05-13 发布）
- Flutter 文档入口: `https://k2-fsa.github.io/sherpa/onnx/flutter/index.html`
- pub.dev 包: `sherpa_onnx`

## 6.2 项目依赖策略

1. 新增：`sherpa_onnx`（版本按 lock/pin 固定）
2. 保留：`just_audio`（仅用于本地音频播放）
3. 移除：云 TTS 调用链、`flutter_tts`（确认无页面依赖后）

> 注意：`sherpa_onnx` 负责推理，不等于完整播放器；本地播放建议继续用 `just_audio`。

---

## 7. 集成步骤（实施顺序）

## 阶段 A：公共模块落地

1. 新建 `lib/core/speech/` 目录与接口定义。
2. 实现 `SherpaTtsProvider`：
   - 输入：文本、语言、语速、speaker
   - 输出：可播放音频（文件路径或内存PCM）
3. 实现 `AudioPlaybackService`（封装 `just_audio`）。

## 阶段 B：页面接入

1. `InteractiveImageController` 改依赖 `SpeechService`。
2. 保留现有方法签名（`speakRegion/speakPinyin/speakEnglishWord/speakChineseChar`）。
3. 保持 `_interruptAndSpeak` 行为，确保点击打断一致。

## 阶段 C：清理旧链路

1. 删除云 TTS 服务和相关配置读取。
2. 删除 `flutter_tts` 依赖及调用。
3. 清理文档中云TTS描述，更新为本地-only。

## 阶段 D：验收

1. 热区点击、卡片点击、拼音、英文、单字点击全部可发音。
2. 离线网络环境可正常工作。
3. 首次加载性能和连续点击中断行为符合预期。

---

## 8. 模型与资源路径建议

建议将本地模型资源统一管理：

```text
assets/models/sherpa_onnx/tts/<lang>/<model_name>/
assets/models/sherpa_onnx/asr/<lang>/<model_name>/   # 后续可选
```

并在 `pubspec.yaml` 中统一声明 `assets/models/`，由 `model_registry.dart` 维护逻辑名称到真实路径的映射。

---

## 9. 与本地大模型的未来结合

目标链路（后续）：

```text
Mic -> Sherpa ASR -> Local LLM -> Sherpa TTS -> Speaker
```

为避免返工，当前 `SpeechService` 与未来 `ChatService` 解耦：

- `SpeechService` 只负责“听/说”
- `ChatService` 只负责“理解/生成文本”
- Controller 只编排流程，不持有模型细节

这样可以先独立完成点读，再逐步进入本地对话能力。

---

## 10. 风险与对策

1. **模型体积大**  
   - 对策：分平台分语言模型；首发仅保留必要语言。

2. **端侧性能差异**  
   - 对策：低端机默认轻量模型；支持语速和质量分级。

3. **多端兼容复杂**  
   - 对策：先锁定主平台（如 Android/iOS 之一）完成稳定再扩展。

4. **迁移期回归风险**  
   - 对策：先接入新模块，再删除旧模块，分阶段切换。

---

## 11. 本次文档对应的实施边界

本文件先覆盖：

- 架构方向确认
- 路径与模块规划
- 依赖策略
- 迁移步骤

不包含（下一步实施）：

- 具体 Dart 代码改造
- pubspec 实际依赖变更
- 旧模块删除提交

---

## 12. 参考链接

- Sherpa-ONNX GitHub: `https://github.com/k2-fsa/sherpa-onnx`
- Latest release API: `https://api.github.com/repos/k2-fsa/sherpa-onnx/releases/latest`
- Flutter docs: `https://k2-fsa.github.io/sherpa/onnx/flutter/index.html`
- Pub package: `https://pub.dev/packages/sherpa_onnx`

