# TTS 模型备份与 S1 精简执行记录

## 1. 本次目标

按 S1（最简单、低风险）执行一次精简：

1. 先完整备份当前模型，避免后续找不到。
2. 项目内只保留运行必需模型文件。
3. 打包清单改成精确白名单，避免全目录打包。

## 2. 独立备份目录

已把完整模型目录复制到：

- `docs/tts/model_data_backup/tts_models_full_20260515/`
- `docs/tts/model_data_backup/tts_models_full_copy_20260515/`

说明：

1. 这两份都是整套模型数据的完整拷贝（不是只拷被删除的文件）。
2. 项目精简后，如果要恢复全量模型，可从任意一份完整备份恢复。
3. 已生成校验清单，便于确认完整性：
	- `docs/tts/model_data_backup/tts_models_full_copy_20260515.FILELIST.txt`
	- `docs/tts/model_data_backup/tts_models_full_copy_20260515.SHA256.txt`

## 2.1 真实模型压缩包（推荐下次直接使用）

当前仅保留真实模型压缩包（已清理旧的错误包）：

1. `docs/tts/model_data_backup/packages/tts_models_s1_runtime_real_20260515.tar.gz`
2. `docs/tts/model_data_backup/packages/tts_models_s1_runtime_real_20260515.tar.gz.sha256`

并提供 latest 别名，方便固定路径调用：

1. `docs/tts/model_data_backup/packages/tts_models_runtime_real_latest.tar.gz`
2. `docs/tts/model_data_backup/packages/tts_models_runtime_real_latest.tar.gz.sha256`

下次直接使用步骤：

1. 清空 `kiki_web/assets/tts_models/`
2. 解压 `tts_models_runtime_real_latest.tar.gz`
3. 将解压目录下内容覆盖到 `kiki_web/assets/tts_models/`

该包约 164MB，包含真实 onnx 二进制，不是 LFS 指针文本。

## 3. 项目内最小文件集（当前保留）

中文模型（`vits-zh-aishell3`）：

1. `vits-aishell3.onnx`
2. `tokens.txt`
3. `lexicon.txt`

英文模型（`vits-piper-en_US-amy-low`）：

1. `en_US-amy-low.onnx`
2. `tokens.txt`
3. `espeak-ng-data/en_dict`
4. `espeak-ng-data/phontab`
5. `espeak-ng-data/phonindex`
6. `espeak-ng-data/phondata`
7. `espeak-ng-data/phondata-manifest`
8. `espeak-ng-data/lang/gmw/en-US`
9. `espeak-ng-data/voices/!v/Annie`

## 4. 打包策略改动

已更新 `kiki_web/pubspec.yaml`：

1. 删除 `assets/tts_models/` 及大范围目录声明。
2. 改为上述最小文件白名单。

效果：

1. 不改变当前 TTS 业务逻辑。
2. 避免把未使用语言资源打入包体。

## 5. 精简结果（目录体积）

说明：

1. 早期看到约 2.8MB，是因为 onnx 还是 LFS 指针文件（文本占位），不是真实模型。
2. 现在已替换为真实 onnx，当前 `kiki_web/assets/tts_models` 目录约 192MB（以当前工作区实际文件为准）。

## 6. 回滚方式

如需回滚为全量模型：

1. 清空 `kiki_web/assets/tts_models/`
2. 用以下任一完整备份覆盖回去：
	- `docs/tts/model_data_backup/tts_models_full_20260515/`
	- `docs/tts/model_data_backup/tts_models_full_copy_20260515/`
3. 恢复 `pubspec.yaml` 中原有目录级 assets 声明（或按需要调整）

## 7. 下一步建议

1. 先做一次真机回归（中英文朗读、首次加载、切换页面）。
2. 回归通过后进入 S2（中文内置 + 英文公共目录按需下载）。
