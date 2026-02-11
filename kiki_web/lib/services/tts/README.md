# Kiki TTS 服务

简洁、清晰的语音合成服务架构，基于依赖注入和策略模式设计。

## 🎯 设计原则

### 架构特点
- **依赖注入**: Provider 从外部注入，解耦服务与具体实现
- **策略模式**: 不同 TTS 提供商实现统一接口，可灵活切换
- **单一职责**: 每个类职责明确，易于测试和维护
- **开闭原则**: 对扩展开放（新增 Provider），对修改封闭

### 核心组件
```
TTSProvider (接口)          - 定义 TTS 提供商规范
  ├─ AliyunTTSProvider      - 阿里云实现
  ├─ GoogleTTSProvider      - Google 实现（待扩展）
  └─ SystemTTSProvider      - 系统 TTS 实现

KikiTTSService              - TTS 服务（播放控制 + 缓存管理）
```

## 📦 依赖

```yaml
dependencies:
  flutter_tts: ^3.8.0
  audioplayers: ^5.2.0
  path_provider: ^2.1.0
  crypto: ^3.0.3
  http: ^1.1.0
```

## 🚀 使用方式

### 基础用法

```dart
// 1. 创建 Provider（依赖注入）
final provider = AliyunTTSProvider(
  accessKeyId: 'YOUR_KEY',
  accessKeySecret: 'YOUR_SECRET',
  config: TTSConfig(
    voiceNameZh: 'xiaoyun',
    voiceNameEn: 'Wendy',
  ),
);

// 2. 创建服务
final ttsService = KikiTTSService(
  provider: provider,
  enableCache: true,
);

// 3. 初始化
await ttsService.initialize();

// 4. 使用
await ttsService.speak('你好呀！我是 Kiki！');
```

### 带降级策略的工厂模式

```dart
class TTSProviderFactory {
  static Future<TTSProvider> create({
    String? aliyunKey,
    String? aliyunSecret,
  }) async {
    final config = TTSConfig(
      voiceNameZh: 'xiaoyun',
      voiceNameEn: 'Wendy',
    );

    // 尝试云端 TTS
    if (aliyunKey != null && aliyunSecret != null) {
      try {
        final provider = AliyunTTSProvider(
          accessKeyId: aliyunKey,
          accessKeySecret: aliyunSecret,
          config: config,
        );

        if (await provider.isAvailable()) {
          return provider;
        }
      } catch (e) {
        print('云端 TTS 不可用: $e');
      }
    }

    // 降级到系统 TTS
    return SystemTTSProvider(config: config);
  }
}

// 使用
final provider = await TTSProviderFactory.create(
  aliyunKey: env.aliyunKey,
  aliyunSecret: env.aliyunSecret,
);

final ttsService = KikiTTSService(provider: provider);
```

## 🎨 API 文档

### TTSProvider 接口

```dart
abstract class TTSProvider {
  /// 初始化
  Future<void> initialize();

  /// 合成语音
  Future<List<int>> synthesize({
    required String text,
    required String language,
    double speed = 1.0,
    double pitch = 0.0,
    TTSEmotion emotion = TTSEmotion.neutral,
  });

  /// 检查可用性
  Future<bool> isAvailable();

  /// 提供商名称
  String get providerName;

  /// 释放资源
  Future<void> dispose();
}
```

### KikiTTSService 方法

```dart
// 播放控制
await ttsService.speak(text, language: 'zh-CN', emotion: TTSEmotion.happy);
await ttsService.pause();
await ttsService.resume();
await ttsService.stop();

// 缓存管理
final stats = await ttsService.getCacheStats();
await ttsService.clearCache();

// 资源释放
await ttsService.dispose();
```

### TTSEmotion 枚举

```dart
enum TTSEmotion {
  neutral,      // 中性
  happy,        // 开心
  excited,      // 兴奋
  gentle,       // 温柔
  encouraging,  // 鼓励
}
```

## 🔧 扩展新的 Provider

```dart
class CustomTTSProvider implements TTSProvider {
  @override
  String get providerName => 'Custom TTS';

  @override
  Future<void> initialize() async {
    // 初始化逻辑
  }

  @override
  Future<List<int>> synthesize({
    required String text,
    required String language,
    double speed = 1.0,
    double pitch = 0.0,
    TTSEmotion emotion = TTSEmotion.neutral,
  }) async {
    // 合成逻辑
    return audioBytes;
  }

  @override
  Future<bool> isAvailable() async {
    // 可用性检查
    return true;
  }

  @override
  Future<void> dispose() async {
    // 清理资源
  }
}
```

## 📊 架构图

```
┌─────────────────────────────────────────┐
│           应用层 (App Layer)            │
│  - 配置管理                             │
│  - Provider 选择策略                    │
│  - 降级逻辑                             │
└─────────────────────────────────────────┘
                  ↓ 创建
┌─────────────────────────────────────────┐
│      TTSProvider (策略接口)             │
├─────────────────────────────────────────┤
│  + initialize()                         │
│  + synthesize()                         │
│  + isAvailable()                        │
│  + dispose()                            │
└─────────────────────────────────────────┘
       ↓                ↓                ↓
┌──────────┐    ┌──────────┐    ┌──────────┐
│ Aliyun   │    │ Google   │    │ System   │
│ Provider │    │ Provider │    │ Provider │
└──────────┘    └──────────┘    └──────────┘
                  ↓ 注入
┌─────────────────────────────────────────┐
│      KikiTTSService (服务层)            │
├─────────────────────────────────────────┤
│  - provider: TTSProvider                │
│  - audioPlayer: AudioPlayer             │
│  - cacheDir: Directory                  │
├─────────────────────────────────────────┤
│  + speak()        // 播放控制           │
│  + pause/resume() // 播放控制           │
│  + getCacheStats() // 缓存管理          │
└─────────────────────────────────────────┘
```

## 💡 设计优势

### 1. 解耦
- 服务层不依赖具体 Provider 实现
- 可以在运行时动态切换 Provider
- 易于单元测试（Mock Provider）

### 2. 扩展性
- 新增 Provider 无需修改服务层代码
- 符合开闭原则

### 3. 可维护性
- 每个类职责单一
- 代码简洁，逻辑清晰
- 易于理解和修改

### 4. 灵活性
- 应用层控制 Provider 选择策略
- 支持多种降级方案
- 缓存可选

## 🔍 代码示例

### 场景 1: 中国区用户（阿里云）

```dart
final provider = AliyunTTSProvider(
  accessKeyId: env.aliyunKey,
  accessKeySecret: env.aliyunSecret,
  config: TTSConfig(voiceNameZh: 'xiaoyun', voiceNameEn: 'Wendy'),
);

final tts = KikiTTSService(provider: provider);
await tts.initialize();
```

### 场景 2: 国际用户（Google）

```dart
final provider = GoogleTTSProvider(
  credentials: env.googleCredentials,
  config: TTSConfig(voiceNameZh: 'cmn-CN-Wavenet-A', voiceNameEn: 'en-US-Neural2-F'),
);

final tts = KikiTTSService(provider: provider);
await tts.initialize();
```

### 场景 3: 离线模式（系统 TTS）

```dart
final provider = SystemTTSProvider(
  config: TTSConfig(voiceNameZh: 'zh-CN', voiceNameEn: 'en-US'),
);

final tts = KikiTTSService(provider: provider, enableCache: false);
await tts.initialize();
```

## 💰 成本估算

### 阿里云 TTS
- 前 100 万字符/月免费
- 超出: ¥0.0002/字符
- 示例: 每天 1000 句 × 15 字 = 15,000 字符/天 = 免费

### Google Cloud TTS
- 前 100 万字符/月免费
- 超出: $4/百万字符（WaveNet）

### 系统 TTS
- 完全免费
- 离线可用

## 📝 最佳实践

1. **使用工厂模式管理 Provider 创建**
2. **在应用层实现降级策略**
3. **启用缓存减少 API 调用**
4. **合理设置缓存过期时间**
5. **记得在 dispose 时释放资源**

---

**架构设计**: 简洁、清晰、可扩展

