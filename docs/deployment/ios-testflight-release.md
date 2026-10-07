# iOS 发布说明

原 Flutter iOS 自动打包流程已停用。当前唯一 iOS 打包入口为原生 SwiftUI 工程 `kiki_ios/KikiNative.xcodeproj`，见 [原生 iOS GitHub Actions 打包](ios-native-github-actions.md)。

新流程复用 `com.just.kiki` 的签名资产，随 `main` 分支的原生工程变更自动构建，并提供签名 IPA 下载。目前不自动上传 TestFlight；如需分发至 TestFlight，可下载 IPA 后通过 Apple Transporter 或后续发布流程上传。
