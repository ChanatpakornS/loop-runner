#!/usr/bin/env bash
#
# HoYoLAB daily check-in ("sol/sign") for a single account.
#
# Required environment:
#   HOYOLAB_COOKIE   Full cookie string copied from a logged-in browser session.
#                    Must contain ltoken_v2, ltuid_v2, ltmid_v2. Treat as a secret.
#
# Optional environment (defaults target Genshin Impact):
#   HOYOLAB_ENDPOINT   Sign endpoint URL.
#   HOYOLAB_ACT_ID     Event act_id sent in the request body.
#   HOYOLAB_SIGNGAME   x-rpc-signgame header value.
#   HOYOLAB_DEVICE_ID  x-rpc-device_id header value. Sent only when set.
#
# Exit codes:
#   0  signed in now, or already signed in today
#   1  sign-in failed (auth expired, bad request, server error)
#   2  usage / configuration error

set -euo pipefail

ENDPOINT="${HOYOLAB_ENDPOINT:-https://sg-act-public-api.hoyolab.com/event/sol/sign?lang=en-us}"
ACT_ID="${HOYOLAB_ACT_ID:-e202102251931481}" # actID for sign_in
SIGNGAME="${HOYOLAB_SIGNGAME:-hk4e}"
USER_AGENT="${HOYOLAB_USER_AGENT:-Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:154.0) Gecko/20100101 Firefox/154.0}"

if [[ -z "${HOYOLAB_COOKIE:-}" ]]; then
	echo "error: HOYOLAB_COOKIE is not set" >&2
	exit 2
fi

headers=(
	-H "Accept: application/json, text/plain, */*"
	-H "Content-Type: application/json;charset=utf-8"
	-H "x-rpc-platform: 4"
	-H "x-rpc-signgame: ${SIGNGAME}"
	-H "Origin: https://act.hoyolab.com"
	-H "Referer: https://act.hoyolab.com/"
	-H "User-Agent: ${USER_AGENT}"
	-H "Cookie: ${HOYOLAB_COOKIE}"
)
if [[ -n "${HOYOLAB_DEVICE_ID:-}" ]]; then
	headers+=(-H "x-rpc-device_id: ${HOYOLAB_DEVICE_ID}")
fi

body="$(printf '{"act_id":"%s"}' "${ACT_ID}")"
response="$(mktemp)"
trap 'rm -f "${response}"' EXIT

http_code="$(
	curl --silent --show-error --location \
		--connect-timeout 15 --max-time 60 \
		--retry 3 --retry-delay 5 --retry-all-errors \
		--output "${response}" --write-out '%{http_code}' \
		-X POST "${ENDPOINT}" \
		"${headers[@]}" \
		--data "${body}"
)"

retcode="$(jq -r '.retcode // empty' <"${response}" 2>/dev/null || true)"
message="$(jq -r '.message // empty' <"${response}" 2>/dev/null || true)"

echo "http=${http_code} retcode=${retcode:-<none>} message=${message:-<none>}"

case "${retcode}" in
	0)
		echo "result: signed in"
		;;
	-5003)
		echo "result: already signed in today"
		;;
	*)
		echo "result: sign-in failed" >&2
		exit 1
		;;
esac
