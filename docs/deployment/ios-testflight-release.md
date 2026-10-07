# iOS 发布说明

原 Flutter iOS 自动打包流程已停用。当前唯一 iOS 打包入口为原生 SwiftUI 工程 `kiki_ios/KikiNative.xcodeproj`，见 [原生 iOS GitHub Actions 打包](ios-native-github-actions.md)。

新流程复用 `com.just.kiki` 的签名资产和 App Store Connect API Key，随 `main` 分支的原生工程变更自动构建并上传 IPA 至 TestFlight，同时保留签名 IPA 下载。Apple 处理完成后，在 App Store Connect 选择该构建并提交审核或发布。手动运行时可关闭上传。
