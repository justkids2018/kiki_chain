#!/usr/bin/env bash
set -euo pipefail

# Local Flutter quality gate for kiki_web.
# Default: pub get + analyze
# Optional: --run to launch app after checks pass
# Usage:
#   ./scripts/flutter_local_check.sh
#   ./scripts/flutter_local_check.sh --run -d chrome

RUN_APP="false"
RUN_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)
      RUN_APP="true"
      shift
      ;;
    *)
      RUN_ARGS+=("$1")
      shift
      ;;
  esac
done

echo "[1/3] flutter pub get"
flutter pub get

echo "[2/3] flutter analyze"
flutter analyze

echo "[3/3] checks passed"
if [[ "$RUN_APP" == "true" ]]; then
  echo "Running app: flutter run ${RUN_ARGS[*]}"
  flutter run "${RUN_ARGS[@]}"
fi
