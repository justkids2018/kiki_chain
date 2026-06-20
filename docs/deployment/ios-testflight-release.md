# iOS TestFlight Release Runbook

## Purpose

This runbook describes how to build the Flutter iOS app in `kiki_web`, sign it, upload the IPA to TestFlight, and keep the build artifact for audit.

## Current Pipeline

Workflow: `.github/workflows/ios-release.yml`

Trigger:

- Manual: GitHub Actions -> iOS Release Build -> Run workflow
- Scheduled: Monday, Wednesday, Friday 08:30 Asia/Shanghai, only on `main`

The workflow performs:

1. Compute version metadata from `IOS_BASE_VERSION` plus `github.run_number`.
2. Restore Apple signing certificate and provisioning profile.
3. Build signed IPA with `flutter build ipa --release`.
4. Upload the IPA to TestFlight when `upload_to_testflight` is true.
5. Push an annotated release tag.
6. Upload IPA, archive, and build summary artifacts.

## Required GitHub Variables

Configure these in GitHub repository settings:

- `IOS_BASE_VERSION`: base semantic version, for example `1.0.1`.
- `IOS_EXPORT_METHOD`: use `app-store` for TestFlight.

## Required GitHub Secrets

Configure these in GitHub repository settings:

- `IOS_CERTIFICATE_P12_BASE64`: base64 encoded Apple distribution certificate `.p12`.
- `IOS_CERTIFICATE_PASSWORD`: password used when exporting the `.p12`.
- `IOS_PROVISIONING_PROFILE_BASE64`: base64 encoded App Store provisioning profile for `com.just.kiki`.
- `IOS_KEYCHAIN_PASSWORD`: optional CI keychain password.
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect issuer ID.
- `APP_STORE_CONNECT_API_PRIVATE_KEY_BASE64`: base64 encoded App Store Connect `.p8` private key.

## Secret Generation Commands

Encode local files without newlines:

```bash
base64 < cert.p12 | tr -d '\n'
base64 < profile.mobileprovision | tr -d '\n'
base64 < AuthKey_KEYID.p8 | tr -d '\n'
```

Use an Apple Distribution certificate and an App Store provisioning profile that matches bundle ID `com.just.kiki`.

## Manual Release

1. Open GitHub Actions.
2. Select `iOS Release Build`.
3. Click `Run workflow`.
4. Set `base_version` if you need to override `IOS_BASE_VERSION`.
5. Keep `upload_to_testflight` enabled for TestFlight delivery.
6. Wait for the workflow to finish.
7. Check App Store Connect -> TestFlight for the uploaded build.

## Local Compile Precheck

This validates code and native iOS project compilation only. It does not prove signing or TestFlight upload.

```bash
cd kiki_web
flutter pub get
flutter build ios --release --no-codesign --build-name 1.0.1 --build-number 22
```

## Failure Handling

- Missing signing secrets: verify all `IOS_*` secrets are set and base64 values contain no newlines.
- Profile mismatch: regenerate an App Store provisioning profile for `com.just.kiki`.
- Upload authentication failure: recreate the App Store Connect API key and update the three `APP_STORE_CONNECT_*` secrets.
- Duplicate build number: rerun after incrementing `IOS_BASE_VERSION`, or wait for a new GitHub run number.
