# Android 签名证书信息

> ⚠️ 此文件包含敏感信息，请勿提交到公开仓库。

## Keystore 文件

| 项目 | 值 |
|------|-----|
| 文件路径 | `android/kiki_release.jks` |
| 格式 | PKCS12 |
| 有效期 | 10000 天（约 27 年） |
| 生成日期 | 2026-03-25 |

## 签名凭证

| 项目 | 值 |
|------|-----|
| Keystore 密码 (storePassword) | `KikiChain2026!Secure` |
| Key 别名 (keyAlias) | `kiki_release` |
| Key 密码 (keyPassword) | `KikiChain2026!Secure` |

## 证书信息

| 项目 | 值 |
|------|-----|
| 组织 (CN) | Kiki Chain |
| 部门 (OU) | Mobile |
| 公司 (O) | Kiki Chain |
| 城市 (L) | Shenzhen |
| 省份 (ST) | Guangdong |
| 国家 (C) | CN |

## 构建 Release APK

```bash
cd kiki_web
flutter build apk --release
# APK 路径: build/app/outputs/flutter-apk/app-release.apk

# 构建 App Bundle（上架 Google Play 用）
flutter build appbundle --release
# AAB 路径: build/app/outputs/bundle/release/app-release.aab
```

## 相关文件

- `android/kiki_release.jks` — keystore 文件（不提交 git）
- `android/key.properties` — 密码配置（不提交 git）
- `android/app/build.gradle` — 签名配置代码
