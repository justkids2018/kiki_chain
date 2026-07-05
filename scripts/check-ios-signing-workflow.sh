#!/usr/bin/env bash

set -euo pipefail

workflow=".github/workflows/ios-release.yml"

required_patterns=(
  'flutter build ios --release --no-codesign'
  'CODE_SIGN_STYLE=Manual'
  "'CODE_SIGN_IDENTITY=Apple Distribution'"
  'PROVISIONING_PROFILE_SPECIFIER="${PROFILE_NAME}"'
  '-exportArchive'
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Fq -- "${pattern}" "${workflow}"; then
    echo "Missing required manual iOS signing command: ${pattern}"
    exit 1
  fi
done

if grep -Fq -- 'flutter build ipa' "${workflow}"; then
  echo "flutter build ipa re-enables automatic signing in CI; use explicit xcodebuild archive/export instead."
  exit 1
fi

echo "iOS release workflow manual-signing guard passed."
