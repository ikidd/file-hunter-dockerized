#!/usr/bin/env bash
# Tier A: fresh data dir, minimal /host mount, core HTTP + auth API checks.
set -euo pipefail

IMAGE="${1:?usage: tier-a-smoke.sh IMAGE:TAG}"
NAME="fh-tier-a-$$"
PORT="${TIER_A_PORT:-18080}"
DATA="$(mktemp -d)"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  rm -rf "$DATA"
}
trap cleanup EXIT

docker rm -f "$NAME" >/dev/null 2>&1 || true

docker run -d --name "$NAME" \
  -p "${PORT}:8000" \
  -v "${DATA}:/data" \
  -v /tmp:/host:ro \
  "$IMAGE"

echo "Waiting for /api/auth/status (empty DB)…"
echo "(Connection errors while the container starts are normal; they are not printed here.)"
ready=
for i in $(seq 1 240); do
  # No -S: during startup the server often resets the connection; stderr would flood the log.
  code=$(curl -s -o /tmp/tier_a_status.json -w "%{http_code}" \
    --connect-timeout 2 --max-time 5 \
    "http://127.0.0.1:${PORT}/api/auth/status" 2>/dev/null || printf '000')
  if [ "$code" = "200" ]; then
    ready=1
    break
  fi
  if [ $((i % 30)) -eq 0 ]; then
    echo "… still waiting (${i}s — first boot may install deps)"
  fi
  sleep 1
done
if [ -z "${ready:-}" ]; then
  echo "FAILED: timed out after 240s waiting for HTTP 200 on /api/auth/status"
  docker logs "$NAME" >&2 || true
  exit 1
fi
echo "OK: API up (HTTP 200 on /api/auth/status)."

jq -e '.ok == true and .data.needsSetup == true' /tmp/tier_a_status.json >/dev/null

code=$(curl -sS -o /tmp/tier_a_root.html -w "%{http_code}" "http://127.0.0.1:${PORT}/")
[ "$code" = "200" ]

curl -sS -X POST "http://127.0.0.1:${PORT}/api/auth/setup" \
  -H 'Content-Type: application/json' \
  -d '{"username":"tiera_ci","password":"tiera_ci_pass","displayName":"Tier A"}' \
  -o /tmp/tier_a_setup.json

jq -e '.ok == true and (.data.token | type == "string") and (.data.token | length) > 0' /tmp/tier_a_setup.json >/dev/null
TOKEN=$(jq -r '.data.token' /tmp/tier_a_setup.json)

code=$(curl -sS -o /tmp/tier_a_me.json -w "%{http_code}" \
  -H "Authorization: Bearer ${TOKEN}" \
  "http://127.0.0.1:${PORT}/api/auth/me")
[ "$code" = "200" ]
jq -e '.ok == true and (.data.username == "tiera_ci")' /tmp/tier_a_me.json >/dev/null

code=$(curl -sS -o /tmp/tier_a_version.json -w "%{http_code}" \
  -H "Authorization: Bearer ${TOKEN}" \
  "http://127.0.0.1:${PORT}/api/version")
[ "$code" = "200" ]
jq -e '.ok == true' /tmp/tier_a_version.json >/dev/null

echo ""
echo "=== Tier A smoke PASSED ==="
echo "Image: ${IMAGE}"
echo "Checks: GET /, GET /api/auth/status, POST /api/auth/setup, GET /api/auth/me, GET /api/version"
