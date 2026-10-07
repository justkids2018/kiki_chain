# 原生 SwiftUI iOS GitHub Actions 打包

## 唯一 iOS 打包入口

`.github/workflows/ios-native-release.yml` 从 `kiki_ios/KikiNative.xcodeproj` 构建原生 SwiftUI App。`main` 分支的 `kiki_ios/**` 或该 workflow 变更会自动触发，也可从 Actions 手动运行。成功后上传签名 IPA 和 Xcode archive。原 Flutter iOS 自动打包工作流已移除；`kiki_web` 的 Flutter 源码保留。

原生 App 沿用 Flutter iOS 的 Bundle ID `com.just.kiki`、团队 `32YC6822Q7`、Apple Distribution 证书和 App Store Provisioning Profile。相同 Bundle ID 的新安装包会被系统视作同一个 App；提交 App Store Connect 时仍须满足版本号、能力配置和审核要求。

## GitHub 签名配置

在仓库 **Settings → Secrets and variables → Actions** 中沿用以下 Secrets：

| Secret | 内容 |
|---|---|
| `IOS_CERTIFICATE_P12_BASE64` | Apple Distribution `.p12` 的单行 Base64 |
| `IOS_CERTIFICATE_PASSWORD` | `.p12` 导出密码 |
| `IOS_PROVISIONING_PROFILE_BASE64` | 对应 `com.just.kiki` 的 App Store `.mobileprovision` 单行 Base64 |
| `IOS_KEYCHAIN_PASSWORD` | 可选，临时钥匙串密码；未设置时自动生成 |

签名前 workflow 会检查 Profile 的 Bundle ID。证书和 Profile 均不提交到 Git。原生项目无需新建 App ID 或新 Profile，只需确认现有 Profile 有效、包含导入的 Distribution 证书，并适用于导出方式。

## 版本与运行

可设置仓库变量 `IOS_NATIVE_BASE_VERSION`（默认 `1.0.0`）及 `IOS_NATIVE_EXPORT_METHOD`（默认 `app-store-connect`）。构建号使用 GitHub run number。手动运行时可选择 `app-store-connect`、`release-testing` 或 `enterprise`；选择的方式须与 Profile 类型一致。沿用的 App Store Profile 应选择 `app-store-connect`。

打开 **Actions → Native iOS Release Build → Run workflow**；`main` 上的原生工程修改会自动打包。成功后从该次运行的 Artifacts 下载 `kiki-native-ios-<版本>-<构建号>-ipa`。当前流程生成 IPA，不自动上传 TestFlight。

若签名失败，检查 Profile 有效期、Bundle ID、团队、证书及导出方式。切换后首次构建应核对 IPA 内嵌 Profile 和签名身份。
