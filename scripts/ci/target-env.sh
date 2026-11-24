#!/usr/bin/env bash
# Maps a branch to its target environment, so every pipeline uses the same promotion rules.
# Usage: scripts/ci/target-env.sh <branch-name>   ->  prints dev | hml | prod
#
#   develop      -> dev   (integration sandbox)
#   release/*    -> hml   (homologation / UAT sandbox)
#   hotfix/*     -> hml   (validated in HML before main)
#   main         -> prod
set -euo pipefail

BRANCH="${1:?usage: target-env.sh <branch>}"
BRANCH="${BRANCH#refs/heads/}"

case "$BRANCH" in
  develop)              echo dev ;;
  release/*|hotfix/*)   echo hml ;;
  main|master)          echo prod ;;
  *) echo "Branch '$BRANCH' does not deploy to any environment." >&2; exit 1 ;;
esac
