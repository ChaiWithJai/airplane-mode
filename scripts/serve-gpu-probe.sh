#!/usr/bin/env bash
set -euo pipefail

# Capability-only browser GPU probe.
#
# This intentionally does NOT serve the Airplane Mode scrub UI, /api/scrub,
# /api/send, or /api/trajectory. It is safe to expose through an HTTPS tunnel
# because it collects browser/runtime capability only, not notes or PHI.

cd "$(dirname "$0")/.."

PORT="${AIRPLANE_GPU_PROBE_PORT:-8098}"
HOST="${AIRPLANE_GPU_PROBE_HOST:-127.0.0.1}"
PAGE="shells/web/static/gpu.html"

python3 - "$HOST" "$PORT" "$PAGE" <<'PY'
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

host, port, page = sys.argv[1], int(sys.argv[2]), Path(sys.argv[3])
latest = None

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write("gpu-probe: " + (fmt % args) + "\n")

    def _send(self, status, body, content_type):
        data = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        global latest
        if self.path in ("/", "/gpu"):
            self._send(200, page.read_text(), "text/html; charset=utf-8")
            return
        if self.path == "/api/status":
            self._send(
                200,
                json.dumps({"ok": True, "client_capability": latest}, indent=2),
                "application/json",
            )
            return
        self._send(404, "not found", "text/plain; charset=utf-8")

    def do_POST(self):
        global latest
        if self.path != "/api/client-capability":
            self._send(404, json.dumps({"ok": False, "error": "not found"}), "application/json")
            return
        raw = self.rfile.read(int(self.headers.get("Content-Length", "0") or "0"))
        try:
            data = json.loads(raw.decode("utf-8"))
        except Exception as exc:
            self._send(400, json.dumps({"ok": False, "error": f"parse request body: {exc}"}), "application/json")
            return
        latest = {
            "user_agent": str(data.get("user_agent", ""))[:240],
            "platform": str(data.get("platform", ""))[:80],
            "language": str(data.get("language", ""))[:32],
            "webgpu": bool(data.get("webgpu")),
            "webgl": bool(data.get("webgl")),
            "webgl2": bool(data.get("webgl2")),
            "webgpu_error": str(data.get("webgpu_error", ""))[:160],
            "hardware_concurrency": int(data.get("hardware_concurrency") or 0),
            "device_memory": float(data.get("device_memory") or 0),
            "screen": data.get("screen") if isinstance(data.get("screen"), dict) else {},
        }
        print("client-capability:", json.dumps(latest, sort_keys=True), flush=True)
        self._send(200, json.dumps({"ok": True, "capability": latest}, indent=2), "application/json")

server = ThreadingHTTPServer((host, port), Handler)
print(f"Airplane Mode GPU probe only: http://{host}:{port}/gpu", flush=True)
print("Tunnel only this port for HTTPS capability checks. Do not tunnel the scrub demo.", flush=True)
server.serve_forever()
PY
