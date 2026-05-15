# TTS 优化实现报告

## 实现内容

已完成 TTS 三层降级策略的代码实现：

### 1. 新增文件

- `kiki_web/lib/presentation/pages/interactive_image/services/cloud_tts_service.dart`
  - 云 TTS 服务类
  - 支持 Edge TTS 和 Azure TTS
  - 实现音频缓存（24 小时过期，100MB 限制）
  - 自动降级策略

### 2. 修改文件

- `kiki_web/lib/presentation/pages/interactive_image/services/text_to_speech_service.dart`
  - 集成 CloudTtsService
  - 实现三层降级：Edge TTS → Azure TTS → 系统 TTS

- `kiki_web/pubspec.yaml`
  - 添加依赖：`crypto: ^3.0.3`
  - 添加依赖：`http: ^1.1.0`

## 降级策略

```
用户点击发音
    ↓
1. Edge TTS（免费无限，3秒超时）
    ↓ 失败
2. Azure TTS（500万字符/月免费，5秒超时）
    ↓ 失败
3. 系统 TTS（flutter_tts，离线保底）
```

## 音频缓存

- 缓存位置：`app_documents/tts_cache/`
- 缓存 key：`md5(text + voice + language)`
- 缓存时长：24 小时
- 缓存大小：100MB（LRU 淘汰）
- 格式：MP3（24khz, 48kbps, mono）

## 语音选择

- 中文：`zh-CN-XiaoxiaoNeural`（晓晓，儿童声音）
- 英文：`en-US-JennyNeural`（Jenny）

## Azure TTS 配置（可选）

如果需要使用 Azure TTS 作为备份，需要：

1. 注册 Azure 账号：https://portal.azure.com
2. 创建 Speech Service 资源
3. 获取 API Key 和 Region
4. 在代码中配置：

```dart
final cloudTts = CloudTtsService(
  azureApiKey: 'YOUR_API_KEY',
  azureRegion: 'eastasia',  // 或其他区域
);
```

当前实现中 Azure TTS 配置为可选，如果不配置则直接从 Edge TTS 降级到系统 TTS。

## 测试方法

1. 运行 App
2. 进入任意场景的交互页面
3. 点击任意文字区域
4. 观察日志输出：
   - `Cloud TTS success` - 云 TTS 成功
   - `Fallback to system TTS` - 降级到系统 TTS
   - `Edge TTS success` - Edge TTS 成功
   - `Azure TTS success` - Azure TTS 成功

## 注意事项

### Edge TTS 限制

- Edge TTS 是非官方 API，可能随时被微软封禁
- 建议监控失败率，如果超过 10% 考虑切换到 Azure TTS
- 早期用户量小时完全够用

### 网络要求

- Edge TTS 和 Azure TTS 都需要网络连接
- 网络失败时会自动降级到系统 TTS
- 缓存可以减少网络请求

### 成本

- Edge TTS：完全免费
- Azure TTS：500 万字符/月免费，超出后 ~$16/百万字符
- 系统 TTS：完全免费

## 下一步

1. **测试 Edge TTS 稳定性**
   - 在真实设备上测试
   - 监控成功率和延迟
   - 收集用户反馈

2. **注册 Azure TTS（可选）**
   - 如果 Edge TTS 不稳定，配置 Azure 作为备份
   - 获取 API Key 和 Region
   - 更新 CloudTtsService 初始化代码

3. **添加监控**
   - 记录每次 TTS 调用的层级（edge/azure/system）
   - 统计成功率和延迟
   - 每日汇总报告

4. **优化缓存策略**
   - 根据实际使用情况调整缓存大小
   - 考虑预加载常用词汇
   - 优化缓存淘汰策略

## 实现状态

✅ 代码实现完成
✅ 依赖安装完成
✅ 静态分析通过
⏳ 等待真机测试
⏳ 等待 Azure TTS 注册（可选）
