#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ASSET_DIR="$ROOT_DIR/assets/tts_models"
TMP_DIR="$ROOT_DIR/tmp/tts_models"
BASE_URL="${SHERPA_TTS_BASE_URL:-https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models}"

mkdir -p "$ASSET_DIR" "$TMP_DIR"

fetch_and_extract() {
  local url="$1"
  local name="$2"
  local archive="$TMP_DIR/$name.tar.bz2"

  echo "[TTS] Downloading $name ..."
  if command -v curl >/dev/null 2>&1; then
    if ! curl -L --fail --retry 8 --retry-delay 3 --retry-all-errors --continue-at - -o "$archive" "$url"; then
      if command -v wget >/dev/null 2>&1; then
        echo "[TTS] curl failed, fallback to wget ..."
        wget -O "$archive" "$url"
      else
        echo "[TTS] ERROR: curl failed and wget is not installed"
        return 1
      fi
    fi
  else
    if ! command -v wget >/dev/null 2>&1; then
      echo "[TTS] ERROR: neither curl nor wget is available"
      return 1
    fi
    wget -O "$archive" "$url"
  fi

  echo "[TTS] Extracting $name ..."
  tar -xjf "$archive" -C "$ASSET_DIR"

  rm -f "$archive"
}

fetch_and_extract \
  "$BASE_URL/vits-zh-aishell3.tar.bz2" \
  "vits-zh-aishell3"

fetch_and_extract \
  "$BASE_URL/vits-piper-en_US-amy-low.tar.bz2" \
  "vits-piper-en_US-amy-low"

echo "[TTS] Done. Models are under: $ASSET_DIR"
