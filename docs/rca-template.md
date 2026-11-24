# Root cause analysis: <short title>

| | |
| --- | --- |
| Date reported | |
| Detected by | user report / monitoring / error log |
| Impact | who was affected, how many, for how long |
| Severity | 1 (service down) · 2 (feature broken, no workaround) · 3 (workaround exists) · 4 (cosmetic) |
| Status | open · mitigated · resolved |

## Symptom

What users saw, in their words, with the exact error message if there was one.

## Timeline

| When | What |
| --- | --- |
| | First report |
| | Mitigation in place |
| | Root cause confirmed |
| | Permanent fix released |

## Investigation

Hypotheses tested, in order, and what ruled each one in or out. Include the evidence: debug logs,
setup audit trail entries, login history, error log records, SOQL queries.

## Root cause

One paragraph. The cause, not the symptom. Set `Root_Cause_Category__c` on the related cases to match.

## Fix

- Immediate mitigation:
- Permanent fix (PR link):

## Prevention

What stops this class of problem from coming back: a governance check rule, a monitor, a runbook
step, a training item. Each with an owner.
