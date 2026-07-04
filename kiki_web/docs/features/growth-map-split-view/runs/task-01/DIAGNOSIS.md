# Task 1 验证环境诊断

## Failure Signature

执行 `dart format` 时 shell 返回 `command not found: dart`。

## Root Cause

Flutter SDK 已安装在 `/Users/qisd/Documents/android/flutter_3_29_2/flutter`，但其 `bin` 目录未加入当前 Codex shell 的 `PATH`。这不是业务代码或项目依赖错误。

## Evidence

- `command -v flutter` 与 `command -v dart` 均无结果。
- Spotlight 能定位到 `/Users/qisd/Documents/android/flutter_3_29_2/flutter`。
- SDK 目录包含 Flutter 自带 Dart 工具链。

## Affected Scope

- 仅影响当前 shell 中 Flutter/Dart 验证命令的调用方式。

## Patch Plan

1. 使用 Flutter SDK 的绝对路径运行格式化、分析和测试。
2. 不修改用户全局 shell 配置。

## Regression Risk

无业务回归风险。

## Verification Plan

1. `/Users/qisd/Documents/android/flutter_3_29_2/flutter/bin/dart format ...`
2. `/Users/qisd/Documents/android/flutter_3_29_2/flutter/bin/flutter analyze --no-pub ...`

最后更新：2026-07-03
