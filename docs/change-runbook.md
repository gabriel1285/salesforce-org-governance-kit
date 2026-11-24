# Change runbook

Checklist for any change to the org, from request to production.

## 1. Intake

- [ ] Request has a business owner and a reason
- [ ] Existing configuration checked first: can a current flow, field or permission set absorb it?
- [ ] Spec written in `specs/NNN-name/` for anything beyond a one-field change

## 2. Impact analysis

- [ ] "Where is this used" checked for every field, flow and permission set touched
- [ ] Other automation on the same object reviewed (one flow per object per context)
- [ ] Integration users that write to the object identified
- [ ] Reports, list views and page layouts that show the field identified
- [ ] Data needed? Backfill or load planned, under `Automation_Admin`

## 3. Build

- [ ] Built in a sandbox or scratch org, retrieved into the repo
- [ ] `scripts/organize.sh` run after retrieve
- [ ] `node scripts/governance-check.js` passes

## 4. Validate

- [ ] `scripts/simulate-release.sh origin/develop HEAD <alias>` reviewed
- [ ] PR opened with the template filled in; validation green

## 5. Release

- [ ] Merged to `develop`, checked in DEV
- [ ] Promoted in `release/*`, business sign-off in HML
- [ ] Release window and communication agreed for production
- [ ] Merged to `main`, environment approval given

## 6. After release

- [ ] Smoke test in production with a non-admin user of each affected persona
- [ ] `Automation_Error_Log__c` checked 24 hours later
- [ ] `Automation_Admin` assignments removed, if any were made for the release
- [ ] Spec marked delivered; CONTEXT document updated if the workstream continues
