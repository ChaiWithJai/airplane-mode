#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

URL="${AIRPLANE_WEB_URL:-http://127.0.0.1:8099}"
TIMEOUT_SECS="${AIRPLANE_PHONE_WAIT_SECS:-180}"
OUT="${AIRPLANE_PHONE_OBSERVATION:-.airplane/phone-capability-latest.json}"

mkdir -p "$(dirname "$OUT")"

cat <<EOF
Airplane Mode phone observer
  app:     $URL
  status:  $URL/api/status
  output:  $OUT

Open or refresh the phone URL printed by ./run.sh web, then wait here.
EOF

start="$(date +%s)"
while true; do
  status="$(curl -fsS "$URL/api/status" 2>/dev/null || true)"
  if [[ -n "$status" ]] && jq -e '.client_capability != null' >/dev/null 2>&1 <<<"$status"; then
    jq '.client_capability' <<<"$status" | tee "$OUT"
    echo
    observed_from="$(jq -r '.client_capability.observed_from // ""' <<<"$status")"
    platform="$(jq -r '.client_capability.platform // ""' <<<"$status")"
    ua="$(jq -r '.client_capability.user_agent // ""' <<<"$status")"
    if [[ "$platform" != *"iPhone"* && "$ua" != *"iPhone"* ]]; then
      echo "warning: capability reported, but it does not look like iPhone telemetry" >&2
      echo "  observed_from: $observed_from" >&2
      echo "  platform:      $platform" >&2
    fi
    echo "phone capability observed from ${observed_from:-unknown-client}"
    exit 0
  fi

  now="$(date +%s)"
  if (( now - start >= TIMEOUT_SECS )); then
    echo "timed out waiting for phone capability after ${TIMEOUT_SECS}s" >&2
    echo "last status:" >&2
    if [[ -n "$status" ]]; then
      jq '{ok, slack, model, client_capability}' <<<"$status" >&2 || echo "$status" >&2
    else
      echo "could not reach $URL/api/status" >&2
    fi
    exit 1
  fi

  sleep 2
done
