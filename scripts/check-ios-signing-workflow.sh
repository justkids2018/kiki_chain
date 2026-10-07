#!/usr/bin/env bash

set -euo pipefail

workflow=".github/workflows/ios-native-release.yml"
project="kiki_ios/KikiNative.xcodeproj/project.pbxproj"

required_patterns=(
  'kiki_ios/KikiNative.xcodeproj'
  'secrets.IOS_CERTIFICATE_P12_BASE64'
  'secrets.IOS_CERTIFICATE_PASSWORD'
  'secrets.IOS_PROVISIONING_PROFILE_BASE64'
  'EXPECTED_BUNDLE_ID="com.just.kiki"'
  '<key>signingStyle</key><string>manual</string>'
  'CODE_SIGN_STYLE=Manual'
  'PROVISIONING_PROFILE_SPECIFIER='
  '-exportArchive'
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Fq -- "${pattern}" "${workflow}"; then
    echo "Missing required native iOS signing setting: ${pattern}"
    exit 1
  fi
done

if [[ -e .github/workflows/ios-release.yml ]]; then
  echo "Legacy Flutter iOS release workflow must remain disabled."
  exit 1
fi

if [[ "$(grep -Fc 'PRODUCT_BUNDLE_IDENTIFIER = com.just.kiki;' "${project}")" -ne 2 ]]; then
  echo "Native iOS Debug and Release bundle IDs must both be com.just.kiki."
  exit 1
fi

echo "Native iOS release workflow manual-signing guard passed."
