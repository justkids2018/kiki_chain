# Kiki iOS 功能迁移对照

目标是把 `kiki_web` 的用户功能迁移为原生 SwiftUI。此表按当前可验证的 iOS 实现记录，不能仅凭页面占位视为完成。

| Flutter 功能 | SwiftUI 迁移 | 当前状态 / 限制 |
|---|---|---|
| Xcode iOS App 工程 | `KikiNative.xcodeproj`、共享 scheme `KikiNative` | 可构建并运行 iOS Simulator；最低 iOS 16 |
| 首页主题、场景浏览 | `HomeView`、`SceneListView` | 在线主题与场景可加载；首页星星积分沿用 Flutter 原始星星 SVG；二级页改为中间高亮、两侧层叠的玻璃卡片，点击侧卡选中、点击中卡学习；VIP 内容统一显示毛玻璃确认卡，选择开通后进入套餐购买页；内置三场景作为离线目录 |
| 热区点读 | `SceneCardView`、`InteractiveRegion` | 在线原始场景图可显示；按原图坐标点击词条，展示英文四线三格、英语音标、中文拼音及田字格。汉字每行两个，更多汉字在学习面板内向下滚动；笔顺按字串行播放，当前字全部笔画完成后才开始下一个字，播放速度对应 Flutter 的 `animationSpeed = 2.0`；笔顺数据坐标已转换为正向，先读内置资源，缺字时从 Flutter 同源 CDN 下载并缓存。中文/英文音频优先使用既有素材，缺失时使用 TTS；发音评测与部分特效仍有差距 |
| 三星奖励 | `LearningProgressStore`、`CrystalStar`、`CrystalStarBar` | 每次学习会话按可点词条数 30%/60%/100% 飞入 1/2/3 颗饱满立体金星；全 App 获得星星共用实体金色样式，空星保持浅色轮廓；历史进度仍按词条数保存 |
| 成长地图历史方案 | `GrowthMapView` | 文件保留供历史参考；当前首页主题入口使用 `SceneListView` |
| 学习档案 | `LearningRecordView` | 用本地真实进度统计；周/月分组、服务端进度全量合并和贡献热力图待继续完善 |
| 汉字练写 | `WritingPracticeView` | 已生成拼音田字格练习纸并支持系统分享/打印入口；PDF 分页导出与 Flutter 描红笔迹交互待完善 |
| 手机号登录/注册 | `LoginView`、`AuthViewModel` | 请求字段对齐 Flutter；登录页图片显示仍待处理，本轮按要求暂不修改 |
| AI 语音伴学 | `AIVoiceAssistantView` | 基础 UI/API 调用存在，需真实账号和服务端继续端到端验证 |
| VIP 订阅 | `SubscriptionViewModel` | 已接入 StoreKit 2 商品拉取、交易签名和服务端权益确认；仍需在 App Store Connect 配置商品并用 sandbox 账号端到端验证；服务端当前尚未校验 Apple JWS 签名，真实收费上线前必须增加后端验签 |
| 个人资料、反馈、语言、更新 | `ProfileView`、`ProfileSupportViews`、`SettingsView` | 资料编辑、帮助反馈、关于入口已补；语言选择当前只持久化偏好，界面完整本地化仍有缺口。Flutter APK 更新仅针对 Android，不迁移到 iOS App Store 分发 |

## 环境限制

2026-10-01 在 iPhone 17 Pro 模拟器上已通过 `https://kiki.keepthinking.me` 加载在线主题和场景。服务端部分场景图/音频字段仍返回旧的 `http://img.mtrain.xyz`，iOS 端只对这一旧域名改用证书有效的 `https://img.keepthinking.me`；保持系统 TLS 校验。登录、进度同步、AI 和订阅接口仍需使用真实账号分别验证。
