# 原生 SwiftUI iOS GitHub Actions 打包

## 工作流边界

- `.github/workflows/ios-release.yml` 继续负责 `kiki_web` Flutter iOS App，本流程不修改它。
- `.github/workflows/ios-native-release.yml` 负责 `kiki_ios/KikiNative.xcodeproj` 原生 SwiftUI App。
- 原生 workflow 在 `main` 上 iOS 工程文件变化时运行，也支持从 Actions 手动运行。它签名归档、导出 IPA，并上传 IPA 和 `.xcarchive` Artifacts；不上传 TestFlight。
- 原生 App Bundle ID 为 `me.keepthinking.kiki.KikiNative`。它需要自己的 Provisioning Profile，不能使用 Flutter `Runner` Bundle ID 的 Profile。

## Apple Developer 签名资产

在 Apple Developer 账号中准备以下文件：

1. App ID / Bundle ID：`me.keepthinking.kiki.KikiNative`。
2. Apple Distribution 证书及其私钥，导出为带密码保护的 `.p12` 文件。
3. 针对上述 Bundle ID、使用现有 Apple Distribution 证书创建的 Provisioning Profile。选择的导出方式必须与 Profile 的类型一致。

不要把 `.p12`、密码或 `.mobileprovision` 提交到 Git。将值放入 GitHub 仓库的 **Settings → Secrets and variables → Actions → New repository secret**。

| GitHub Secret | 内容 |
|---|---|
| `IOS_NATIVE_PROVISIONING_PROFILE_BASE64` | `.mobileprovision` 的单行 Base64 |
| `IOS_NATIVE_KEYCHAIN_PASSWORD` | 可选；CI 临时钥匙串密码，不设置时由 workflow 随机生成 |

仓库已经配置 Flutter iOS 使用的 `IOS_CERTIFICATE_P12_BASE64` 和 `IOS_CERTIFICATE_PASSWORD`，原生 workflow 会复用这张 Apple Distribution 证书，不复制或覆盖原 Flutter Secrets。只需要额外创建并配置针对 `me.keepthinking.kiki.KikiNative` 的 Provisioning Profile。

macOS 上生成 Profile Base64：

```bash
base64 < KikiNative.mobileprovision | tr -d '\n'
```

将命令输出的单行值粘贴到 `IOS_NATIVE_PROVISIONING_PROFILE_BASE64`。不要把 Profile 文件或 Base64 内容提交到仓库，也不要发到聊天或 issue 中。

## 可选仓库变量

在 **Settings → Secrets and variables → Actions → Variables** 中配置：

- `IOS_NATIVE_BASE_VERSION`：营销版本，默认 `1.0.0`。构建号自动使用 GitHub Actions run number。
- `IOS_NATIVE_EXPORT_METHOD`：默认导出方式 `app-store-connect`；也可在手动运行时选择 `release-testing` 或 `enterprise`。这些选项与 Xcode 26.5 的 `xcodebuild -help` 一致。

## 运行与下载

打开 **Actions → Native iOS Release Build → Run workflow**，选择导出方式并运行。成功后，在该次运行页面的 Artifacts 下载：

- `kiki-native-ios-<版本>-<构建号>-ipa`：签名 IPA。
- `kiki-native-ios-<版本>-<构建号>-archive`：Xcode `.xcarchive`。

构建依赖 GitHub macOS runner 上的 Xcode 26.5 和对应 iOS SDK。若签名检查失败，先确认 Profile 的 Bundle ID、Distribution 证书和导出方式一致；若提示缺少 Secret，按上表配置。

## Flutter iOS 工作流

现有 `.github/workflows/ios-release.yml` 仍从 `kiki_web` 安装 Flutter 依赖、构建 `Runner`、按其现有签名配置导出 IPA，并可按原设置上传 TestFlight。本原生 SwiftUI 流程与 Flutter 流程的工程、Bundle ID、Profile 和产物路径相互独立。
