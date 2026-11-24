#!/usr/bin/env bash
# Builds a delta package (only what changed between two git refs) with sfdx-git-delta.
# Usage: scripts/ci/build-delta.sh <from-ref> [to-ref] [output-dir]
#
# Output:
#   <output-dir>/package/package.xml                       what to deploy
#   <output-dir>/destructiveChanges/destructiveChanges.xml what to delete
#   <output-dir>/force-app-*/...                           the changed source files
#
# sfdx-git-delta reads sfdx-project.json, so all four layers (base, config, service, ui)
# are covered in one run.
set -euo pipefail

FROM="${1:?usage: build-delta.sh <from-ref> [to-ref] [output-dir]}"
TO="${2:-HEAD}"
OUT="${3:-delta}"

rm -rf "$OUT"
mkdir -p "$OUT"

sf sgd source delta \
  --from "$FROM" \
  --to "$TO" \
  --output-dir "$OUT" \
  --generate-delta

echo "== package.xml =="
cat "$OUT/package/package.xml"; echo
echo "== destructiveChanges.xml =="
cat "$OUT/destructiveChanges/destructiveChanges.xml"; echo
