#!/usr/bin/env bash
# 从 kiki_web/android/key.properties 读取签名信息并写入 GitHub Actions Secrets
# 用法: gh auth login && bash scripts/setup_android_secrets.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_PROPS="${SCRIPT_DIR}/../kiki_web/android/key.properties"

if [[ ! -f "${KEY_PROPS}" ]]; then
  echo "❌ key.properties not found: ${KEY_PROPS}"
  exit 1
fi

get_prop() {
  grep "^${1}=" "${KEY_PROPS}" | cut -d'=' -f2-
}

STORE_PASSWORD=$(get_prop storePassword)
KEY_PASSWORD=$(get_prop keyPassword)
KEY_ALIAS=$(get_prop keyAlias)
KEYSTORE_BASE64=$(get_prop androidKeystoreBase64)

if [[ -z "${STORE_PASSWORD}" || -z "${KEY_PASSWORD}" || -z "${KEY_ALIAS}" || -z "${KEYSTORE_BASE64}" ]]; then
  echo "❌ key.properties 中缺少必要字段"
  exit 1
fi

echo "→ 设置 ANDROID_STORE_PASSWORD"
echo -n "${STORE_PASSWORD}" | gh secret set ANDROID_STORE_PASSWORD

echo "→ 设置 ANDROID_KEY_PASSWORD"
echo -n "${KEY_PASSWORD}" | gh secret set ANDROID_KEY_PASSWORD

echo "→ 设置 ANDROID_KEY_ALIAS"
echo -n "${KEY_ALIAS}" | gh secret set ANDROID_KEY_ALIAS

echo "→ 设置 ANDROID_KEYSTORE_BASE64"
echo -n "${KEYSTORE_BASE64}" | gh secret set ANDROID_KEYSTORE_BASE64

echo ""
echo "✅ 4 个 Android signing secrets 已写入 GitHub Actions"
echo "   现在可以重新触发 android-release workflow"
