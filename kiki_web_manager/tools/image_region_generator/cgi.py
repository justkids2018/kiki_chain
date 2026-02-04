"""Compatibility shim for the deprecated stdlib `cgi` module.

Python 3.13 removed the legacy `cgi` helpers. Some third-party
packages (for example googletrans via httpx 0.13.x) still import
`cgi.parse_header`. We recreate the small portion that we need so the
rest of the application keeps working without pinning to an older
Python runtime.
"""

from __future__ import annotations

from typing import Dict, Tuple


def parse_header(line: str) -> Tuple[str, Dict[str, str]]:
    """Return the main content type and parameter dict.

    Mirrors the behaviour of ``cgi.parse_header`` from Python 3.12 for
    the limited usage required by httpx. Only ``;`` separated key/value
    pairs are supported and parameter names are lower-cased.
    """

    if not line:
        return "", {}

    parts = [segment.strip() for segment in line.split(";")]
    ctype = parts[0]

    params: Dict[str, str] = {}
    for segment in parts[1:]:
        if not segment:
            continue
        if "=" in segment:
            key, value = segment.split("=", 1)
            key = key.strip().lower()
            value = value.strip()
            if len(value) >= 2 and value[0] == value[-1] == '"':
                value = value[1:-1]
            params[key] = value
        else:
            params[segment.lower()] = True

    return ctype, params
