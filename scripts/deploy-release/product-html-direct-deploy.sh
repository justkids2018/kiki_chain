#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/deploy-release/product-html-direct-deploy.sh --ip <server_ip> --user <ssh_user> [options]

Options:
  --ip <server_ip>              Deploy server IP (required)
  --user <ssh_user>             Deploy SSH user (required)
  --remote-dir <path>           Remote base directory (default: ~/product_site_static)
  --source-dir <path>           Local source dir (default: kiki_product_html)
  --site-url <url>              Optional URL to verify, e.g. https://all.keepthinking.me/
  --hikiki-url <url>            Optional URL to verify, e.g. https://all.keepthinking.me/hikiki/
  --insecure-url-check          Use curl -k for URL verification
  --identity-file <path>        SSH identity file for scp/ssh
  -h, --help                    Show this help

URL Mapping after deploy:
  /             -> /all/index.html
  /hikiki/      -> /hikiki/index.html
  /hikiki.html  -> /hikiki/
EOF
}

SERVER_IP=""
SSH_USER=""
REMOTE_DIR="~/product_site_static"
SOURCE_DIR="kiki_product_html"
SITE_URL=""
HIKIKI_URL=""
INSECURE_URL_CHECK="false"
IDENTITY_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ip)
      SERVER_IP="$2"
      shift 2
      ;;
    --user)
      SSH_USER="$2"
      shift 2
      ;;
    --remote-dir)
      REMOTE_DIR="$2"
      shift 2
      ;;
    --source-dir)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --site-url)
      SITE_URL="$2"
      shift 2
      ;;
    --hikiki-url)
      HIKIKI_URL="$2"
      shift 2
      ;;
    --insecure-url-check)
      INSECURE_URL_CHECK="true"
      shift 1
      ;;
    --identity-file)
      IDENTITY_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$SERVER_IP" || -z "$SSH_USER" ]]; then
  echo "Error: --ip and --user are required." >&2
  usage
  exit 1
fi

test -f "${SOURCE_DIR}/all/index.html"
test -f "${SOURCE_DIR}/hikiki/index.html"
test -f "${SOURCE_DIR}/hikiki/hikik_version.json"

RELEASE_ID="manual-$(date +%Y%m%d%H%M%S)"
REMOTE_TAR="/tmp/product-html-site-${RELEASE_ID}.tar.gz"
LOCAL_TAR="/tmp/product-html-site.tar.gz"

SSH_CMD=(ssh)
if [[ -n "$IDENTITY_FILE" ]]; then
  SSH_CMD+=( -i "$IDENTITY_FILE" )
fi

echo "[1/4] Packaging product html from ${SOURCE_DIR} (all + hikiki)"
tar -C "${SOURCE_DIR}" \
  --exclude './hikiki/https' \
  --exclude './hikiki/https/**' \
  -czf "$LOCAL_TAR" all hikiki

if tar -tzf "$LOCAL_TAR" | grep -E '(^|/)(privkey|.*\.key$)' >/dev/null; then
  echo "Private key detected in package" >&2
  exit 1
fi

echo "[2/4] Uploading package to ${SSH_USER}@${SERVER_IP}:${REMOTE_TAR}"
if [[ -n "$IDENTITY_FILE" ]]; then
  scp -i "$IDENTITY_FILE" "$LOCAL_TAR" "${SSH_USER}@${SERVER_IP}:${REMOTE_TAR}"
else
  scp "$LOCAL_TAR" "${SSH_USER}@${SERVER_IP}:${REMOTE_TAR}"
fi

echo "[3/4] Deploying release on remote server"
"${SSH_CMD[@]}" "${SSH_USER}@${SERVER_IP}" "bash -s" -- "$REMOTE_DIR" "$RELEASE_ID" "$REMOTE_TAR" <<'REMOTE_SCRIPT'
set -euo pipefail

if [[ "$#" -ne 3 ]]; then
  echo "Remote script expected 3 args (REMOTE_DIR, RELEASE_ID, REMOTE_TAR), got $#" >&2
  exit 2
fi

REMOTE_DIR="$1"
RELEASE_ID="$2"
REMOTE_TAR="$3"

case "$REMOTE_DIR" in
  "~")
    REMOTE_DIR="$HOME"
    ;;
  "~/"*)
    REMOTE_DIR="$HOME/${REMOTE_DIR#~/}"
    ;;
esac

RELEASE_DIR="${REMOTE_DIR}/releases/${RELEASE_ID}"
mkdir -p "$RELEASE_DIR"
tar -xzf "$REMOTE_TAR" -C "$RELEASE_DIR"
rm -f "$REMOTE_TAR"
ln -sfn "$RELEASE_DIR" "${REMOTE_DIR}/current"

RELEASE_DIRS=()
while IFS= read -r release_dir; do
  RELEASE_DIRS+=("$release_dir")
done < <(find "${REMOTE_DIR}/releases" -mindepth 1 -maxdepth 1 -type d | sort)

if ((${#RELEASE_DIRS[@]} > 5)); then
  printf '%s\0' "${RELEASE_DIRS[@]:0:${#RELEASE_DIRS[@]}-5}" | xargs -0 rm -rf
fi

echo "REMOTE_DIR=$REMOTE_DIR"
echo "CURRENT_PATH=$(readlink -f "${REMOTE_DIR}/current")"
REMOTE_SCRIPT

verify_url() {
  local url="$1"
  if [[ -z "$url" ]]; then
    return 0
  fi

  if [[ "$INSECURE_URL_CHECK" == "true" ]]; then
    curl -kfsSIL --retry 5 --retry-delay 3 "$url"
  else
    curl -fsSIL --retry 5 --retry-delay 3 "$url"
  fi
}

echo "[4/4] Verifying URLs"
if [[ -n "$SITE_URL" ]]; then
  echo "- ${SITE_URL}"
  verify_url "$SITE_URL"
fi
if [[ -n "$HIKIKI_URL" ]]; then
  echo "- ${HIKIKI_URL}"
  verify_url "$HIKIKI_URL"
fi
if [[ -z "$SITE_URL" && -z "$HIKIKI_URL" ]]; then
  echo "No URL verification requested"
fi

echo "Done: release ${RELEASE_ID} deployed to ${SSH_USER}@${SERVER_IP}:${REMOTE_DIR}/current"
