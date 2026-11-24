# Changelog

## 1.0.1 (2026-11-24)

First deploy to a real org (Developer Edition) and acceptance test of spec 001.

- Fix: `Root_Cause_Required_On_Close` let a case close without a root cause, because `IsClosed` keeps the
  prior value while the closing save is validated. The rule now checks `Status` as well.
- Fix: the supervisor permission set had the same API name as its permission set group, which the
  platform rejects. Renamed to `Service_Supervisor_Addon`.
- CI: the org login no longer prints the username or instance URL (logs of a public repo are public).
- CI: PR validation on GitHub runs on every PR, so the required "governance" check never waits forever
  on a docs-only PR.
- CI: deploys diff from a per-environment checkpoint tag (`deployed/<env>`) instead of `HEAD~1`, so a
  failed deploy is retried by the next run.
- CI: a delta that deletes a whole object is refused unless `ALLOW_OBJECT_DELETION=true`; deletions run
  with `--ignore-warnings` so a component missing in an older environment does not fail the release.
- CI: Azure DevOps PR validation picks the environment at runtime with `target-env.sh` and runs one
  validation stage per environment, since the PR target branch is not available at compile time.

## 1.0.0 (2026-11)

- Four-layer project structure (base, config, service, ui)
- Case escalation: fields, validation rules with bypass, after-save flow with fault path (spec 001)
- Automation error log object and reusable logging subflow
- Persona-based permission sets and permission set groups; least-privilege integration permission set
- Governance check script with self-test
- Delta release pipeline for GitHub Actions and Azure DevOps sharing the same scripts
- Release simulation and retrieve organisation scripts
- Docs: access model, automation standards, release process, change runbook, RCA template and example,
  AI-assisted delivery
