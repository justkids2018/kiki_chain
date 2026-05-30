#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/deploy-release/bin/common.sh
source "$SCRIPT_DIR/bin/common.sh"

PROFILE_NAME="${1:-}"
load_profile "$PROFILE_NAME"

load_backend_qiniu_defaults() {
	local backend_env_file="$ROOT_DIR/kiki_server/.env"

	if [[ ! -f "$backend_env_file" ]]; then
		return 0
	fi

	set -a
	# shellcheck disable=SC1090
	source "$backend_env_file"
	set +a

	DEPLOY_QINIU_ACCESS_KEY="${DEPLOY_QINIU_ACCESS_KEY:-${QINIU_ACCESS_KEY:-}}"
	DEPLOY_QINIU_SECRET_KEY="${DEPLOY_QINIU_SECRET_KEY:-${QINIU_SECRET_KEY:-}}"
	DEPLOY_QINIU_BUCKET="${DEPLOY_QINIU_BUCKET:-${QINIU_BUCKET:-}}"
	DEPLOY_QINIU_DOMAIN="${DEPLOY_QINIU_DOMAIN:-${QINIU_DOMAIN:-}}"
	DEPLOY_QINIU_UPLOAD_REGION="${DEPLOY_QINIU_UPLOAD_REGION:-${QINIU_UPLOAD_REGION:-z2}}"
}

require_qiniu_runtime() {
	local missing=()

	[[ -n "${DEPLOY_QINIU_ACCESS_KEY:-}" ]] || missing+=("QINIU_ACCESS_KEY")
	[[ -n "${DEPLOY_QINIU_SECRET_KEY:-}" ]] || missing+=("QINIU_SECRET_KEY")
	[[ -n "${DEPLOY_QINIU_BUCKET:-}" ]] || missing+=("QINIU_BUCKET")
	[[ -n "${DEPLOY_QINIU_DOMAIN:-}" ]] || missing+=("QINIU_DOMAIN")

	if (( ${#missing[@]} > 0 )); then
		echo -e "${RED}❌ 缺少七牛运行时配置: ${missing[*]}${NC}"
		echo "请在 kiki_server/.env 中补齐对应的 QINIU_* 配置。"
		exit 1
	fi
}

load_backend_qiniu_defaults
require_qiniu_runtime

# 优先使用项目内固定版本文件；显式传入 DEPLOY_IMAGE_TAG 时以显式值为准。
VERSION_FILE="$SCRIPT_DIR/versions/current.env"
if [[ -f "$VERSION_FILE" && ( -z "${DEPLOY_IMAGE_TAG:-}" || "${DEPLOY_IMAGE_TAG}" == "latest" ) ]]; then
	# shellcheck disable=SC1090
	source "$VERSION_FILE"
fi

DEPLOY_IMAGE_TAG="${DEPLOY_IMAGE_TAG:-latest}"
DEPLOY_BACKEND_IMAGE="ghcr.io/justkids2018/kiki-chain-backend:${DEPLOY_IMAGE_TAG}"
DEPLOY_ADMIN_IMAGE="ghcr.io/justkids2018/kiki-chain-admin:${DEPLOY_IMAGE_TAG}"

print_header "Step 1/2 - 生成部署产物 (${DEPLOY_PROVIDER})"

echo -e "${YELLOW}使用配置文件: ${PROFILE_FILE}${NC}"

ARTIFACT_ID="$(date +%Y%m%d_%H%M%S)_${DEPLOY_PROVIDER}"
ARTIFACT_RELEASE_DIR="$LOCAL_RELEASES_DIR/$ARTIFACT_ID"

mkdir -p "$LOCAL_LATEST_DIR" "$ARTIFACT_RELEASE_DIR"

cat >"$ARTIFACT_RELEASE_DIR/deploy.env" <<EOF
DEPLOY_DATABASE_NAME=${DEPLOY_DATABASE_NAME}
DEPLOY_DATABASE_USER=${DEPLOY_DATABASE_USER}
DEPLOY_DATABASE_PASSWORD=${DEPLOY_DATABASE_PASSWORD}
DEPLOY_JWT_SECRET=${DEPLOY_JWT_SECRET}
DEPLOY_LOG_LEVEL=${DEPLOY_LOG_LEVEL}
DEPLOY_QINIU_ACCESS_KEY=${DEPLOY_QINIU_ACCESS_KEY}
DEPLOY_QINIU_SECRET_KEY=${DEPLOY_QINIU_SECRET_KEY}
DEPLOY_QINIU_BUCKET=${DEPLOY_QINIU_BUCKET}
DEPLOY_QINIU_DOMAIN=${DEPLOY_QINIU_DOMAIN}
DEPLOY_QINIU_UPLOAD_REGION=${DEPLOY_QINIU_UPLOAD_REGION}
DEPLOY_ADMIN_API_BASE_URL=${DEPLOY_ADMIN_API_BASE_URL}
DEPLOY_IMAGE_TAG=${DEPLOY_IMAGE_TAG}
DEPLOY_BACKEND_IMAGE=${DEPLOY_BACKEND_IMAGE}
DEPLOY_ADMIN_IMAGE=${DEPLOY_ADMIN_IMAGE}
DEPLOY_PRIMARY_DOMAIN=${DEPLOY_PRIMARY_DOMAIN}
DEPLOY_MOBILE_DOMAIN=${DEPLOY_MOBILE_DOMAIN}
DEPLOY_ADMIN_DOMAIN=${DEPLOY_ADMIN_DOMAIN}
DEPLOY_API_DOMAIN=${DEPLOY_API_DOMAIN}
DEPLOY_API_PATH_PREFIX=${DEPLOY_API_PATH_PREFIX}
DEPLOY_ADMIN_HOST_PORT=${DEPLOY_ADMIN_HOST_PORT}
DEPLOY_BACKEND_HOST_PORT=${DEPLOY_BACKEND_HOST_PORT}
DEPLOY_POSTGRES_HOST_PORT=${DEPLOY_POSTGRES_HOST_PORT}
EOF

cat >"$ARTIFACT_RELEASE_DIR/deploy-manifest.txt" <<EOF
artifact_id=${ARTIFACT_ID}
generated_at=$(date '+%Y-%m-%d %H:%M:%S')
provider=${DEPLOY_PROVIDER}
server=${DEPLOY_SSH_USER}@${DEPLOY_SERVER_IP}
remote_dir=${DEPLOY_REMOTE_DIR}
stack=${DEPLOY_STACK_NAME}
compose=scripts/deploy-release/docker-compose.yml
mobile_domain=${DEPLOY_MOBILE_DOMAIN}
admin_domain=${DEPLOY_ADMIN_DOMAIN}
api_domain=${DEPLOY_API_DOMAIN}
backend_local_port=${DEPLOY_BACKEND_HOST_PORT}
admin_local_port=${DEPLOY_ADMIN_HOST_PORT}
postgres_local_port=${DEPLOY_POSTGRES_HOST_PORT}
EOF

cp "$ARTIFACT_RELEASE_DIR/deploy.env" "$LOCAL_LATEST_DIR/deploy.env"
cp "$ARTIFACT_RELEASE_DIR/deploy-manifest.txt" "$LOCAL_LATEST_DIR/deploy-manifest.txt"

echo -e "${GREEN}✅ 已生成部署产物:${NC}"
echo "- scripts/deploy-release/deploy_files/latest/deploy.env"
echo "- scripts/deploy-release/deploy_files/latest/deploy-manifest.txt"
echo "- scripts/deploy-release/deploy_files/releases/${ARTIFACT_ID}/"
echo "- image_tag=${DEPLOY_IMAGE_TAG}"
echo ""
echo -e "${CYAN}下一步执行:${NC}"
echo "./scripts/deploy-release/step2-deploy.sh ${PROFILE_NAME:-tencent}"
