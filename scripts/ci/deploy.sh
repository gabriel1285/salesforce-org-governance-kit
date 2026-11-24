#!/usr/bin/env bash
# Validates or deploys a delta package built by build-delta.sh.
# Usage: scripts/ci/deploy.sh <validate|deploy> <org-alias> [delta-dir]
#
# Rules:
#   - Empty delta: nothing to do, exit 0 (a docs-only PR must not fail the pipeline).
#   - validate: always a check-only deploy with RunLocalTests.
#   - deploy:   RunLocalTests when the delta has Apex; otherwise the org default
#               (no tests for metadata-only releases).
#   - Deletions run after the deploy (post-destructive), so references are removed first.
set -euo pipefail

MODE="${1:?usage: deploy.sh <validate|deploy> <org-alias> [delta-dir]}"
ORG="${2:?usage: deploy.sh <validate|deploy> <org-alias> [delta-dir]}"
DELTA="${3:-delta}"

PKG="$DELTA/package/package.xml"
DESTRUCTIVE="$DELTA/destructiveChanges/destructiveChanges.xml"

has_types() { [[ -f "$1" ]] && grep -q '<types>' "$1"; }

if ! has_types "$PKG" && ! has_types "$DESTRUCTIVE"; then
  echo "No metadata changes in this delta. Skipping $MODE."
  exit 0
fi

# sfdx-git-delta always writes package.xml (empty for a deletion-only release),
# so the manifest is always passed and the destructive file rides along when needed.
ARGS=(--target-org "$ORG" --wait 60 --verbose --manifest "$PKG")
if has_types "$DESTRUCTIVE"; then
  ARGS+=(--post-destructive-changes "$DESTRUCTIVE")
fi

HAS_APEX=false
if grep -qE '<name>(ApexClass|ApexTrigger)</name>' "$PKG" 2>/dev/null; then
  HAS_APEX=true
fi

case "$MODE" in
  validate)
    sf project deploy validate "${ARGS[@]}" --test-level RunLocalTests
    ;;
  deploy)
    if $HAS_APEX; then
      sf project deploy start "${ARGS[@]}" --test-level RunLocalTests
    else
      sf project deploy start "${ARGS[@]}"
    fi
    ;;
  *)
    echo "Unknown mode: $MODE (use validate or deploy)" >&2
    exit 1
    ;;
esac
