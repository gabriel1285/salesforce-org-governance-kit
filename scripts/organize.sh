#!/usr/bin/env bash
# Moves retrieved metadata into the right layer folder.
#
# `sf project retrieve start` writes everything into the default package directory
# (force-app-base). Run this script right after a retrieve to move each metadata type
# to the layer that owns it, so the repo keeps its four-layer structure.
#
#   force-app-base     data model: objects, fields, validation rules, custom permissions,
#                      custom metadata types, global value sets
#   force-app-config   access and settings: permission sets, permission set groups,
#                      sharing rules, queues, groups, named credentials, custom metadata records
#   force-app-service  behaviour: flows, Apex classes and triggers
#   force-app-ui       presentation: layouts, Lightning pages, LWC, Aura, tabs, apps
#
# Usage: scripts/organize.sh [--dry-run]
set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

SRC="force-app-base/main/default"

declare -A LAYER=(
  [permissionsets]=config
  [permissionsetgroups]=config
  [sharingRules]=config
  [queues]=config
  [groups]=config
  [namedCredentials]=config
  [externalCredentials]=config
  [customMetadata]=config
  [flows]=service
  [classes]=service
  [triggers]=service
  [layouts]=ui
  [flexipages]=ui
  [lwc]=ui
  [aura]=ui
  [tabs]=ui
  [applications]=ui
  [quickActions]=ui
  [compactLayouts]=ui
)

moved=0
for type in "${!LAYER[@]}"; do
  from="$SRC/$type"
  [[ -d "$from" ]] || continue
  to="force-app-${LAYER[$type]}/main/default/$type"

  while IFS= read -r -d '' file; do
    rel="${file#"$from"/}"
    dest="$to/$rel"
    if $DRY_RUN; then
      echo "would move $file -> $dest"
    else
      mkdir -p "$(dirname "$dest")"
      mv -f "$file" "$dest"
      echo "moved $file -> $dest"
    fi
    moved=$((moved + 1))
  done < <(find "$from" -type f -print0)

  $DRY_RUN || find "$from" -type d -empty -delete
done

# Object-level list views and compact layouts live under objects/ but are UI concerns.
# They stay in base on purpose: splitting an object folder across layers breaks
# source tracking for that object.

echo "$moved file(s) $($DRY_RUN && echo 'to move' || echo 'moved')."
