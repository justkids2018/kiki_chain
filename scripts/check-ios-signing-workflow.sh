#!/usr/bin/env bash

set -euo pipefail

workflow=".github/workflows/ios-release.yml"
project="kiki_web/ios/Runner.xcodeproj/project.pbxproj"

required_patterns=(
  'flutter build ios --release --no-codesign'
  '<key>signingStyle</key>'
  '<string>manual</string>'
  '<key>signingCertificate</key>'
  '<string>Apple Distribution</string>'
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

project_patterns=(
  'CODE_SIGN_STYLE = Manual;'
  'CODE_SIGN_IDENTITY = "Apple Distribution";'
  'PROVISIONING_PROFILE_SPECIFIER = "Hi Kiki App Store";'
)

for pattern in "${project_patterns[@]}"; do
  if ! grep -Fq -- "${pattern}" "${project}"; then
    echo "Missing required Runner release signing setting: ${pattern}"
    exit 1
  fi
done

echo "iOS release workflow manual-signing guard passed."
