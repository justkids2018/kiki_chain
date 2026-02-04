#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
VENV_DIR="$SCRIPT_DIR/.venv"

if [ ! -d "$VENV_DIR" ]; then
  echo "[INFO] Virtual environment not found, creating..."
  python3 -m venv "$VENV_DIR"
  echo "[INFO] Virtual environment created at $VENV_DIR"
fi

if [ ! -x "$VENV_DIR/bin/python" ]; then
  chmod +x "$VENV_DIR/bin/python"
fi

source "$VENV_DIR/bin/activate"

pip install --upgrade pip >/dev/null
pip install -r "$SCRIPT_DIR/requirements.txt"

python "$SCRIPT_DIR/gui_app_new.py"

