#!/usr/bin/env bash
# Simulates a release locally before opening the PR.
#
# Shows exactly what the pipeline would deploy and delete between two refs, runs the
# governance check, and optionally runs a check-only deploy against an org you are
# already logged into. Nothing is deployed.
#
# Usage:
#   scripts/simulate-release.sh <from-ref> [to-ref] [org-alias]
#
# Examples:
#   scripts/simulate-release.sh origin/main release/2026.12          # what goes to prod
#   scripts/simulate-release.sh origin/develop HEAD my-dev-sandbox    # plus check-only deploy
set -euo pipefail

FROM="${1:?usage: simulate-release.sh <from-ref> [to-ref] [org-alias]}"
TO="${2:-HEAD}"
ORG="${3:-}"
OUT="$(mktemp -d)/delta"

echo "== Commits in this release ($FROM..$TO) =="
git log --oneline --no-merges "$FROM..$TO" || true
echo

echo "== Governance check =="
node scripts/governance-check.js
echo

echo "== Delta =="
scripts/ci/build-delta.sh "$FROM" "$TO" "$OUT"
echo

if [[ -n "$ORG" ]]; then
  echo "== Check-only deploy against $ORG =="
  scripts/ci/deploy.sh validate "$ORG" "$OUT"
else
  echo "No org alias given: skipped the check-only deploy."
fi

echo
echo "Delta kept at: $OUT"
