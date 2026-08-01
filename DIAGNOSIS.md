## Failure Signature

Android real-device run stalls during Flutter/Gradle debug build.

## Root Cause

The app itself is not the primary failure point. The local Android build environment had multiple stacked issues: the default Java on shell is Java 8 while this Android Gradle setup needs Java 17, several Gradle/Flutter dependencies were missing and slow or failing from Maven/Google sources, Flutter SDK's embedded Gradle plugin had to rebuild its Kotlin/Groovy plugin classes, and Android build daemons intermittently stalled during resource or Kotlin/Java compile phases.

## Evidence

- `adb devices -l` detects the real Android device `R89DMZAQ6HM7NRVS`.
- Android manifest already contains landscape orientation.
- iOS `Info.plist` now restricts both iPhone and iPad to landscape orientations.
- `flutter clean` and `flutter pub get` completed.
- Gradle failed earlier resolving `org.jetbrains.kotlin:kotlin-gradle-plugin-idea-proto:2.0.20` from Maven with `Remote host terminated the handshake`.
- `curl` to Maven Central for Kotlin 2.1.21 was extremely slow, while Aliyun mirror completed quickly.
- `./gradlew :app:tasks` succeeded after dependency cache repair and mirror configuration.
- `:app:assembleDebug` progressed to Android app compilation, but local Gradle/Flutter wrapper sessions repeatedly remained waiting after worker child processes exited.

## Affected Scope

- Local Android build environment.
- `kiki_web/android` Gradle configuration.
- Flutter SDK local cache and Gradle cache.

## Patch Plan

1. Keep Java 17 explicitly for Android builds.
2. Prefer stable mirror repositories for Android/Gradle dependencies.
3. Keep iOS and Android native orientation configs aligned to landscape.
4. Replace one-line Android Kotlin `MainActivity` with Java to avoid unnecessary app-level Kotlin compilation.
5. If local Gradle wrapper still hangs, restart the terminal/IDE or reboot the local build environment, then run a fresh `flutter clean`, `flutter pub get`, and `flutter run`.

## Regression Risk

Low for app behavior; changes are limited to native orientation and local Android build plumbing.

## Verification Plan

1. Run `flutter analyze`.
2. Run Android real-device debug build with Java 17 and Flutter mirror enabled.
3. Confirm the app opens on the connected device in landscape.
