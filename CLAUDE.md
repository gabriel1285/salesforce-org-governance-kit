# Instructions for AI coding agents (Claude Code and similar)

This repo is a Salesforce org managed as code. These rules apply to any change an agent proposes.
A human reviews and merges every change. The agent never deploys to an org on its own.

## Structure

- Four layers, each a package directory in `sfdx-project.json`:
  - `force-app-base`: objects, fields, validation rules, custom permissions
  - `force-app-config`: permission sets and permission set groups
  - `force-app-service`: flows (and Apex, if any)
  - `force-app-ui`: layouts, Lightning pages, LWC
- After any `sf project retrieve start`, run `scripts/organize.sh` so files land in the right layer.

## Rules the governance check enforces (`node scripts/governance-check.js`)

- Validation rules start with `NOT($Permission.Bypass_Validation_Rules)`.
- Record-triggered flows check `NOT({!$Permission.Bypass_Automation})` in the entry formula.
- Every DML or action element in a flow has a fault connector to `Subflow_Log_Automation_Error`.
- No hard-coded record Ids. No Modify All Data / View All Data / Modify All in permission sets.
- Bypass custom permissions are granted only by `Automation_Admin`.
- No profiles in the repo. Every field, flow, validation rule and permission set has a description.

## How to work

1. Start from a spec in `specs/NNN-name/` (spec.md, plan.md, tasks.md). If there is none, write it first and stop for review.
2. One record-triggered flow per object per context (before save / after save). Extend it, do not add a second one.
3. Before proposing the PR, run the governance check and `scripts/simulate-release.sh origin/develop HEAD`.
4. Fill the PR template, including the AI assistance section.
5. At the end of a large piece of work, write or update a `CONTEXT_<topic>.md` from `templates/CONTEXT_TEMPLATE.md` so the next session starts with the decisions already made.

## Never

- Deploy, run destructive changes or change org data.
- Commit auth URLs, tokens, usernames or org Ids.
- Bypass a failing governance check by editing the check.
