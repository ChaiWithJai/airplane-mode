#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

MODEL="${AIRPLANE_BONSAI_BROWSER_MODEL:-onnx-community/Bonsai-1.7B-ONNX}"
REVISION="${AIRPLANE_HF_REVISION:-main}"
MODEL_ROOT="${AIRPLANE_BROWSER_MODEL_DIR:-.airplane/browser-models}"
BASE_URL="${AIRPLANE_HF_BASE_URL:-https://huggingface.co}"
OUT_DIR="$MODEL_ROOT/$MODEL"

FILES=(
  "config.json"
  "generation_config.json"
  "tokenizer.json"
  "tokenizer_config.json"
  "chat_template.jinja"
  "onnx/model_q1.onnx"
  "onnx/model_q1.onnx_data"
)

mkdir -p "$OUT_DIR"

total_bytes=0
for file in "${FILES[@]}"; do
  case "$file" in
    *..*|/*)
      echo "refusing unsafe model path: $file" >&2
      exit 1
      ;;
  esac

  url="$BASE_URL/$MODEL/resolve/$REVISION/$file"
  out="$OUT_DIR/$file"
  mkdir -p "$(dirname "$out")"
  tmp="$(mktemp "$out.XXXXXX")"
  echo "fetch $file"
  curl -fL --retry 3 --retry-delay 2 "$url" -o "$tmp"
  bytes="$(wc -c < "$tmp" | tr -d ' ')"
  if [ "$bytes" = "0" ]; then
    echo "downloaded empty model artifact: $file" >&2
    rm -f "$tmp"
    exit 1
  fi
  mv "$tmp" "$out"
  total_bytes=$((total_bytes + bytes))
done

cat <<EOF
Vendored browser model:
  model: $MODEL
  revision: $REVISION
  output: $OUT_DIR
  files: ${#FILES[@]}
  bytes: $total_bytes

The web worker checks /models/$MODEL/ first. Keep .airplane/ out of git.
EOF
