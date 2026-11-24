#!/usr/bin/env bash
# Remembers the last commit deployed to each environment, as a git tag deployed/<env>.
# Usage:
#   scripts/ci/checkpoint.sh get <env>   prints the checkpoint commit, or HEAD~1 when there is none yet
#   scripts/ci/checkpoint.sh set <env>   moves the checkpoint to HEAD and pushes it
#
# Why: a delta of HEAD~1..HEAD only covers the last merge. If a deploy fails and another merge
# lands before the fix, the failed change would never reach the org. Diffing from the last
# successful deploy means every run catches up with whatever is still missing.
set -euo pipefail

ACTION="${1:?usage: checkpoint.sh <get|set> <env>}"
ENV_NAME="${2:?usage: checkpoint.sh <get|set> <env>}"
TAG="deployed/$ENV_NAME"

case "$ACTION" in
  get)
    git fetch --quiet --force origin "refs/tags/$TAG:refs/tags/$TAG" 2>/dev/null || true
    if git rev-parse --quiet --verify "refs/tags/$TAG^{commit}" > /dev/null; then
      git rev-parse "refs/tags/$TAG^{commit}"
    else
      echo "No checkpoint $TAG yet, using HEAD~1." >&2
      git rev-parse HEAD~1
    fi
    ;;
  set)
    git tag --force "$TAG" HEAD
    git push --force origin "refs/tags/$TAG"
    echo "Checkpoint $TAG -> $(git rev-parse --short HEAD)"
    ;;
  *)
    echo "Unknown action: $ACTION (use get or set)" >&2
    exit 1
    ;;
esac
