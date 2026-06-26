#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

URL="${AIRPLANE_WEB_URL:-http://127.0.0.1:8099}"
TIMEOUT_SECS="${AIRPLANE_PHONE_WAIT_SECS:-180}"
OUT="${AIRPLANE_PHONE_REQUEST_OBSERVATION:-.airplane/phone-browser-request-latest.json}"
LOCAL_CA="${AIRPLANE_CERT_DIR:-.airplane/certs}/airplane-local-ca.pem"

CURL_ARGS=(-fsS)
if [[ "$URL" == https://* && -f "$LOCAL_CA" ]]; then
  CURL_ARGS+=(--cacert "$LOCAL_CA")
fi

mkdir -p "$(dirname "$OUT")"

cat <<EOF
Airplane Mode passive phone request observer
  app:     $URL
  status:  $URL/api/status
  output:  $OUT

Open or refresh the phone URL printed by ./run.sh web, then wait here.
EOF

start="$(date +%s)"
while true; do
  status="$(curl "${CURL_ARGS[@]}" "$URL/api/status" 2>/dev/null || true)"
  if [[ -n "$status" ]]; then
    event="$(
      jq -c '
        .browser_requests // []
        | map(select(.looks_like_iphone == true and (.client | test("^127\\.|^::1$") | not)))
        | last // empty
      ' <<<"$status" 2>/dev/null || true
    )"
    if [[ -n "$event" ]]; then
      jq '.' <<<"$event" | tee "$OUT"
      echo
      client="$(jq -r '.client // ""' <<<"$event")"
      route="$(jq -r '.route // ""' <<<"$event")"
      path="$(jq -r '.path // ""' <<<"$event")"
      echo "phone browser request observed from ${client:-unknown-client}: ${route:-unknown-route} ${path:-unknown-path}"
      exit 0
    fi
  fi

  now="$(date +%s)"
  if (( now - start >= TIMEOUT_SECS )); then
    echo "timed out waiting for passive phone request after ${TIMEOUT_SECS}s" >&2
    echo "last status:" >&2
    if [[ -n "$status" ]]; then
      jq '{ok, slack, model, client_capability, browser_requests: (.browser_requests[-6:] // [])}' <<<"$status" >&2 || echo "$status" >&2
    else
      echo "could not reach $URL/api/status" >&2
    fi
    exit 1
  fi

  sleep 2
done
