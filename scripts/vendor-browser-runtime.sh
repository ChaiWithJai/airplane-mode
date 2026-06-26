#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VENDOR_DIR="${AIRPLANE_BROWSER_VENDOR_DIR:-.airplane/browser-vendor}"
OUT="$VENDOR_DIR/transformers.js"
URL="${AIRPLANE_TRANSFORMERS_JS_URL:-https://cdn.jsdelivr.net/npm/@huggingface/transformers@4.1.0}"

mkdir -p "$VENDOR_DIR"

tmp="$(mktemp "$VENDOR_DIR/transformers.XXXXXX.js")"
curl -fsSL "$URL" -o "$tmp"

if ! grep -q "pipeline" "$tmp"; then
  echo "downloaded runtime did not look like Transformers.js: $URL" >&2
  rm -f "$tmp"
  exit 1
fi

mv "$tmp" "$OUT"

cat <<EOF
Vendored browser runtime:
  source: $URL
  output: $OUT

The web worker loads /vendor/transformers.js first and falls back to CDN only
when this file is missing. Do not commit .airplane/.
EOF
