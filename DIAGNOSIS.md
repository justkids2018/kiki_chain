# Mobile Release Actions Failure Diagnosis

## Failure Signature

- Android Release Build #64: `Gradle task assembleRelease failed with exit code 1`.
- iOS Release Build #59: IPA export succeeded, then TestFlight upload failed with App Store validation code `90474`.

## Root Cause

The two workflows fail for different reasons. Android is a real package-build failure: the workflow follows Flutter's moving `stable` channel, which advanced from 3.44.9 to 3.47.2 while the repository still uses Gradle 8.11.1; Flutter 3.47.2 now requires Gradle 8.14.0 or newer. iOS successfully compiles, archives, signs, and exports the IPA, but App Store Connect rejects it because the iPad target supports multitasking while its `Info.plist` declares only landscape orientations.

## Evidence

- Both latest runs use commit `2e3bb42d341fd3e80d995e4646d2ef2398b49689`, so no repository code change separates the successful and failed Android runs.
- Android run #57 succeeded on 2026-08-10 with Flutter 3.44.9; its log warned that Gradle 8.11.1 would soon become unsupported.
- Android run #64 failed on 2026-09-04 with Flutter 3.47.2 and the explicit message: `Your project's Gradle version (8.11.1) is lower than Flutter's minimum supported version of 8.14.0`.
- At the time of failure, `.github/workflows/android-release.yml` selected `channel: stable` without pinning a Flutter version.
- `kiki_web/android/gradle/wrapper/gradle-wrapper.properties` pins Gradle 8.11.1.
- iOS run #59 completed `Build Flutter iOS app without signing`, `Archive and export IPA with manual signing`, and `Locate IPA` successfully.
- TestFlight then returned validation code `90474`, requiring portrait, upside-down portrait, landscape-left, and landscape-right orientations for iPad multitasking.
- `kiki_web/ios/Runner/Info.plist` declares only `UIInterfaceOrientationLandscapeLeft` and `UIInterfaceOrientationLandscapeRight` for iPad, while the Xcode project targets both iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- Android signing preparation and iOS signing/export succeeded, ruling out missing signing secrets as the direct cause of these runs.

## Affected Scope

- Android APK and AAB release generation.
- iOS TestFlight delivery; local IPA generation itself is successful.
- Scheduled workflows remain vulnerable to future Flutter `stable` changes because the SDK is not pinned.

## Patch Plan

1. Pin the same tested Flutter SDK version in both mobile workflows so scheduled builds are reproducible.
2. Upgrade the Android Gradle wrapper to at least 8.14.0 and validate the compatible Android Gradle Plugin/Kotlin versions; do not use the dependency-validation bypass as the permanent fix.
3. Choose the intended iPad behavior:
   - if landscape-only full-screen is required, opt the iPad app out of multitasking with the appropriate full-screen setting; or
   - if iPad multitasking is required, add both portrait orientations and verify the UI at supported sizes.
4. Make artifact upload steps run on build/upload failure where useful, so a successfully generated IPA is still available for inspection even when TestFlight rejects it.

## Regression Risk

Medium. The Android toolchain versions must be upgraded as a compatible set, and the iOS orientation choice affects actual iPad windowing behavior rather than only CI configuration.

## Verification Plan

1. Run the Android release build locally or in a non-publishing CI job and confirm both APK and AAB are produced.
2. Run the iOS archive/export flow and inspect the archived app's effective `Info.plist` orientation/full-screen keys.
3. Upload a new iOS build to App Store Connect and confirm validation code `90474` is gone.
4. Re-run both GitHub Actions and confirm artifact, tag, Qiniu upload, and TestFlight stages separately.

## Investigated Runs

- Android: https://github.com/justkids2018/kiki_chain/actions/runs/33829087575
- iOS: https://github.com/justkids2018/kiki_chain/actions/runs/33838606910

Last updated: 2026-09-05
