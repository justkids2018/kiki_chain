#!/usr/bin/env python3
"""Local writeback server for hotspot preview.

Usage (from repo root):
  python3 kiki_web/tools/hotspot_writeback_server.py
"""

from __future__ import annotations

import argparse
import json
import os
import tempfile
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse


def is_within_root(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def normalize_local_path(raw_path: str) -> Path:
    value = (raw_path or "").strip()
    if value.startswith("file://"):
        parsed = urlparse(value)
        value = unquote(parsed.path)
    return Path(value).expanduser().resolve()


class WritebackHandler(BaseHTTPRequestHandler):
    server_version = "HotspotWriteback/1.0"

    def _send_json(self, status: int, payload: dict) -> None:
        body = (json.dumps(payload, ensure_ascii=False) + "\n").encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self) -> None:  # noqa: N802
        self._send_json(200, {"ok": True})

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/health":
            self._send_json(200, {"ok": True, "service": "hotspot-writeback"})
            return
        self._send_json(404, {"ok": False, "error": "Not found"})

    def do_POST(self) -> None:  # noqa: N802
        if self.path != "/api/hotspot/write-json":
            self._send_json(404, {"ok": False, "error": "Not found"})
            return

        content_len = int(self.headers.get("Content-Length", "0") or "0")
        raw_body = self.rfile.read(content_len)
        try:
            payload = json.loads(raw_body.decode("utf-8"))
        except Exception:
            self._send_json(400, {"ok": False, "error": "Invalid JSON body"})
            return

        raw_path = str(payload.get("path") or "").strip()
        text = payload.get("text")

        if not raw_path:
            self._send_json(400, {"ok": False, "error": "Missing path"})
            return
        if not isinstance(text, str):
            self._send_json(400, {"ok": False, "error": "Missing text"})
            return

        target = normalize_local_path(raw_path)
        allowed_root: Path = self.server.allowed_root  # type: ignore[attr-defined]

        if not target.is_absolute():
            self._send_json(400, {"ok": False, "error": "Path must be absolute"})
            return
        if target.suffix.lower() != ".json":
            self._send_json(400, {"ok": False, "error": "Only .json files are allowed"})
            return
        if not is_within_root(target, allowed_root):
            self._send_json(
                403,
                {
                    "ok": False,
                    "error": f"Path outside allowed root: {allowed_root}",
                },
            )
            return

        target.parent.mkdir(parents=True, exist_ok=True)

        temp_path = None
        try:
            fd, tmp_name = tempfile.mkstemp(prefix=target.name + ".", suffix=".tmp", dir=str(target.parent))
            temp_path = Path(tmp_name)
            with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
                f.write(text)
            os.replace(temp_path, target)
        except Exception as exc:
            if temp_path and temp_path.exists():
                temp_path.unlink(missing_ok=True)
            self._send_json(500, {"ok": False, "error": f"Write failed: {exc}"})
            return

        self._send_json(200, {"ok": True, "path": str(target)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Hotspot preview local writeback server")
    parser.add_argument("--host", default="127.0.0.1", help="Host to bind")
    parser.add_argument("--port", type=int, default=18765, help="Port to bind")
    parser.add_argument(
        "--allow-root",
        default=str(Path(__file__).resolve().parents[2]),
        help="Allowed write root directory",
    )
    args = parser.parse_args()

    allowed_root = Path(args.allow_root).expanduser().resolve()
    server = ThreadingHTTPServer((args.host, args.port), WritebackHandler)
    server.allowed_root = allowed_root  # type: ignore[attr-defined]

    print(f"[hotspot-writeback] listening on http://{args.host}:{args.port}")
    print(f"[hotspot-writeback] allowed root: {allowed_root}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
