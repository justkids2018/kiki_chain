#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_NAME="${1:-tencent}"

"$SCRIPT_DIR/step1-prepare.sh" "$PROFILE_NAME"
"$SCRIPT_DIR/step2-deploy.sh" "$PROFILE_NAME"
