#!/usr/bin/env bash
# Authenticates the CLI against a target org from an SFDX auth URL.
# Usage: SFDX_AUTH_URL=... scripts/ci/auth.sh <alias>
# The auth URL comes from a CI secret (GitHub environment secret or Azure DevOps variable group),
# never from the repository.
set -euo pipefail

ALIAS="${1:?usage: auth.sh <alias>}"

if [[ -z "${SFDX_AUTH_URL:-}" ]]; then
  echo "SFDX_AUTH_URL is not set for this environment." >&2
  exit 1
fi

AUTH_FILE="$(mktemp)"
trap 'rm -f "$AUTH_FILE"' EXIT
printf '%s' "$SFDX_AUTH_URL" > "$AUTH_FILE"

# --json keeps the username and org Id out of the log: CI logs of a public repo are public.
if ! RESULT="$(sf org login sfdx-url --sfdx-url-file "$AUTH_FILE" --alias "$ALIAS" --json 2>/dev/null)"; then
  echo "Login failed:" >&2
  printf '%s' "$RESULT" | grep -oE '"message": *"[^"]*"' >&2 || true
  exit 1
fi
echo "Authenticated as alias '$ALIAS'."
