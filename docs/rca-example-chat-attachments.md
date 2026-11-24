# Root cause analysis: customers can no longer send files in web chat

*Illustrative example based on a common failure pattern. Names and figures are generic.*

| | |
| --- | --- |
| Detected by | Agent reports: customers say the attach button disappeared |
| Impact | All web chat customers; agents asked for documents by email instead |
| Severity | 3 (workaround exists) |
| Status | Resolved |

## Symptom

After the web chat moved from the legacy chat product to Messaging for In-App and Web, the file
attachment option was missing in the customer's chat window. Text messages worked normally.

## Timeline

| When | What |
| --- | --- |
| Day 0 | Channel migration released |
| Day 2 | First agent report |
| Day 2 | Workaround: agents send a secure upload link |
| Day 3 | Root cause confirmed |
| Day 9 | Fix live after licence provisioning |

## Investigation

1. **Channel configuration.** File attachments were enabled in the deployment settings. Ruled out.
2. **Agent permissions.** Agents had the messaging permission sets; the problem was on the customer side. Ruled out.
3. **Browser or network.** Reproduced on several browsers and networks. Ruled out.
4. **Feature availability.** Compared the org's licences with the feature requirements: file transfer in
   the new channel depends on an add-on licence the legacy product did not need. The org did not have it.
   Confirmed.

## Root cause

A product migration changed the licensing behind an existing feature. The migration plan compared
configuration screens but not licence requirements, so the regression was invisible until customers hit it.
Category: **Licensing**.

## Fix

- Mitigation: secure upload link sent by agents.
- Permanent: add-on licence provisioned, attachments re-enabled and tested with an external user.

## Prevention

- Migration checklist now includes a licence and feature-entitlement comparison between old and new products.
- Smoke test after any channel release covers attachments from a customer's point of view, not an admin's.
