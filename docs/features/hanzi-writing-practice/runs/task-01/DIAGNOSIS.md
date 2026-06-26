# DIAGNOSIS

## Failure Signature

`printing >=5.15.0` requires Dart SDK `>=3.12.0 <4.0.0`, but the project is running Dart `3.6.2`.

## Root Cause

The new print dependency was added at a version that is newer than the project's Dart SDK. Pub cannot resolve the dependency graph until the `printing` constraint is lowered to a Dart 3.6-compatible release.

## Evidence

- User-provided resolver error: current Dart SDK is `3.6.2`.
- User-provided resolver suggestion: use `printing:^5.14.3`.
- Affected file: `kiki_web/pubspec.yaml`.

## Affected Scope

- Mobile printing dependency resolution for the Hanzi writing practice feature.

## Patch Plan

1. Downgrade `printing` to `^5.14.3`.
2. Re-run `flutter pub get`.
3. Run `flutter analyze` and mobile smoke validation.

## Regression Risk

Low. The feature uses stable `Printing.layoutPdf`, which is available in the 5.14.x line.

## Verification Plan

```bash
cd kiki_web
flutter pub get
flutter analyze
flutter test
```
