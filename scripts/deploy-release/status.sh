#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/deploy-release/bin/common.sh
source "$SCRIPT_DIR/bin/common.sh"

PROFILE_NAME="${1:-}"
load_profile "$PROFILE_NAME"

print_header "Hi Kiki - Unified 状态检查 (${DEPLOY_PROVIDER})"
ensure_ssh

remote_compose "ps"

echo ""
echo "Host localhost port mapping on server ${DEPLOY_SERVER_IP}:"
echo "- backend: 127.0.0.1:${DEPLOY_BACKEND_HOST_PORT}"
echo "- admin:   127.0.0.1:${DEPLOY_ADMIN_HOST_PORT}"
echo "- pg:      127.0.0.1:${DEPLOY_POSTGRES_HOST_PORT}"
