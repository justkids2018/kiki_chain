# Kiki iOS 原生工程 (SwiftUI)

基于 SwiftUI + Swift Concurrency 构建的纯原生 Kiki iOS 客户端，全面对齐 `kiki_server` 接口体系（`docs/api/`）与 `kiki_web` (Flutter) 的核心功能。

## 目录架构

```text
kiki_ios/
├── README.md                        # 工程架构与运行使用说明
├── Package.swift                    # iOS 源码包配置（iOS 16+；不支持 macOS）
└── Sources/
    ├── App/
    │   ├── KikiApp.swift            # App @main 主入口
    │   └── MainTabView.swift        # 底部四栏导航（探索 / 成长地图 / 成长 / 我的）
    ├── Core/
    │   ├── Network/                 # 原生 URLSession 网络层
    │   │   ├── APIConfiguration.swift # 环境配置、BaseURL 与 Header
    │   │   ├── APIEndpoint.swift      # 严格对齐服务端的接口枚举
    │   │   ├── APIResponse.swift      # API 统一封包模型
    │   │   ├── NetworkError.swift     # 统一网络错误体系
    │   │   └── APIClient.swift        # async/await 异步请求客户端
    │   └── Storage/
    │       └── TokenManager.swift   # 用户 Token 与鉴权持久化存储
    ├── Models/                      # Codable 数据模型（与 kiki_server DTO 1:1 对齐）
    │   ├── SceneCategory.swift      # 场景主题模型
    │   ├── Scene.swift              # 学习场景模型（包含付费墙状态）
    │   ├── SceneItem.swift          # 热区词条模型（相对坐标、拼音、音频）
    │   ├── User.swift               # 用户与鉴权数据模型
    │   ├── Subscription.swift       # 订阅商品与 VIP 权益模型
    │   └── AIVoice.swift            # AI 伴学助手动作与会话模型
    ├── Audio/                       # 原生音频与发音管理
    │   ├── AudioPlayerManager.swift # AVFoundation 词条点读发音播放
    │   └── AudioRecorderManager.swift # AVAudioRecorder 孩子语音跟读录音
    └── Features/                    # 业务功能模块
        ├── Home/                    # 沉浸式场景探索主页（7:9 横向探索大卡片流）
        ├── CategoryList/            # 主题列表备用视图（骨架屏、卡片展示）
        ├── SceneList/               # 主题下场景卡片列表（网格排列、VIP锁状态拦截）
        ├── SceneCard/               # 交互式学习卡片（热区点读 + 录音跟读 + AI助手 + 3星奖励）
        ├── AIVoice/                 # Kiki AI 伴学语音助手（对话流、智能应答）
        ├── Subscription/            # VIP 会员中心与订阅付费墙（多套餐选择、权益清单）
        ├── Settings/                # 系统与音频设置（发音语速、音量、音效、清理缓存）
        ├── LearningRecord/          # 成长档案与足迹记录（统计看板、时间线）
        ├── Profile/                 # 个人中心（登录态展示、成就卡片、设置入口、退出登录）
        └── Auth/                    # 手机号登录、隐私协议勾选与状态联动
```

## Flutter 功能迁移状态

迁移以 `kiki_web` 的实际用户功能为对照，当前完成情况和明确缺口见 [docs/feature-parity.md](docs/feature-parity.md)。StoreKit 2 已接入但待 App Store Connect 商品与 sandbox 验证；资料编辑、帮助反馈、关于入口已补；界面完整本地化和学习档案周/月视图仍有缺口，语言偏好目前只保存设置。服务端尚未校验 Apple JWS 凭证，真实收费上线前需补齐后端验签。

## 在 Xcode 中运行 iOS App

`Package.swift` 仅用于 iOS 源码包；其中包含 UIKit、AVAudioSession、UIDevice 等 iOS 专属 API，不支持 macOS 构建。它也不是可直接运行的 iOS App。请在 Xcode 中打开仓库内的 `KikiNative.xcodeproj`（不要打开 `Package.swift`），选择共享 scheme `KikiNative`，再选择 iOS Simulator 并点击 Run。若在 iOS App scheme 下仍出现 `Unable to resolve module dependency: 'UIKit'`，请确认 Run Destination 是 iOS Simulator 或已连接的 iPhone，而不是 My Mac。

命令行构建示例（最低支持 iOS 16）：

```sh
xcodebuild -project kiki_ios/KikiNative.xcodeproj \
  -scheme KikiNative \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
  CODE_SIGNING_ALLOWED=NO build
```

App bundle identifier 为 `me.keepthinking.kiki.KikiNative`，显示名称为 `Hi Kiki`。首次使用跟读功能时会请求麦克风权限。
