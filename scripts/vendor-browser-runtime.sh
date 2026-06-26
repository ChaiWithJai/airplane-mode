#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VENDOR_DIR="${AIRPLANE_BROWSER_VENDOR_DIR:-.airplane/browser-vendor}"
OUT="$VENDOR_DIR/transformers.js"
BASE_URL="${AIRPLANE_TRANSFORMERS_JS_BASE_URL:-https://cdn.jsdelivr.net/npm/@huggingface/transformers@4.1.0/dist}"
URL="${AIRPLANE_TRANSFORMERS_JS_URL:-$BASE_URL/transformers.web.min.js}"
SIDECARS=("ort-wasm-simd-threaded.jsep.mjs")

mkdir -p "$VENDOR_DIR"

tmp="$(mktemp "$VENDOR_DIR/transformers.XXXXXX.js")"
curl -fsSL "$URL" -o "$tmp"

if ! grep -q "pipeline" "$tmp"; then
  echo "downloaded runtime did not look like Transformers.js: $URL" >&2
  rm -f "$tmp"
  exit 1
fi

mv "$tmp" "$OUT"

for file in "${SIDECARS[@]}"; do
  sidecar_tmp="$(mktemp "$VENDOR_DIR/$file.XXXXXX")"
  curl -fsSL "$BASE_URL/$file" -o "$sidecar_tmp"
  mv "$sidecar_tmp" "$VENDOR_DIR/$file"
done

cat <<EOF
Vendored browser runtime:
  source: $URL
  output: $OUT
  sidecars: ${SIDECARS[*]}

The web worker loads /vendor/transformers.js first and falls back to CDN only
when this file is missing. Do not commit .airplane/.
EOF
