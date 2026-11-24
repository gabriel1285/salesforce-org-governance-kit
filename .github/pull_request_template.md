## What changes

<!-- One or two sentences. Link the spec if there is one: specs/NNN-name/spec.md -->

## Why

<!-- The business need or the incident this fixes. -->

## Impact analysis

- [ ] Metadata touched is listed below (or see the delta artifact on this PR)
- [ ] Access: who gains or loses access? Permission sets / groups affected:
- [ ] Automation: flows or validation rules on the same object reviewed for interaction
- [ ] Integrations: does any integration user write to the objects/fields changed?
- [ ] Data: needs a data load or backfill? Plan attached?

## Evidence

- [ ] Tested in a sandbox or scratch org (screenshots or steps below)
- [ ] Governance check passes locally: `node scripts/governance-check.js`
- [ ] Release simulated: `scripts/simulate-release.sh origin/<base> HEAD <org>`

## Rollback

<!-- How to undo: revert PR, deactivate flow version, remove permission set assignment... -->

## AI assistance

- [ ] No AI-generated code in this PR
- [ ] AI-generated changes were reviewed line by line by the author (see docs/ai-assisted-delivery.md)
