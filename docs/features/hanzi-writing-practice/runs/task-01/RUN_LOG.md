# Run Log

## 当前环境

`flutter` 和 `dart` 命令未在 shell 中可用。

## 已执行

- `which flutter`
- `which dart`
- `git diff --check`
- `flutter analyze`
- `flutter test`

## 结果

`git diff --check` 通过，退出码 `0`。

`flutter analyze` 与 `flutter test` 均因 `flutter: command not found` 未执行，退出码 `127`。

## 待在 Flutter 环境执行

```bash
cd kiki_web
flutter pub get
flutter analyze
flutter test
```
