# Plan 001: Case escalation

## Design

| Requirement | Solution | Layer |
| --- | --- | --- |
| 1 | Field `Case.Escalated__c` (checkbox) | base |
| 2 | Picklist `Case.Escalation_Reason__c` + validation rule `Escalation_Reason_Required` | base |
| 3 | After-save flow `Case_AfterSave_Escalation`, entry: Escalated changed to true | service |
| 4 | Picklist `Case.Root_Cause_Category__c` + validation rule `Root_Cause_Required_On_Close` | base |
| 5 | Custom permissions `Bypass_Validation_Rules`, `Bypass_Automation`, granted only by `Automation_Admin` | base + config |
| 6 | Fault path to subflow `Subflow_Log_Automation_Error`, writing `Automation_Error_Log__c` | service + base |
| Access | `Service_Agent_Base` and `Service_Supervisor_Addon` permission sets, delivered through permission set groups | config |

## Decisions

- **Custom permission bypass instead of deactivating rules.** Deactivation is an org-wide change during a
  load; a custom permission affects only the user doing the load and is auditable.
- **Log object instead of fault emails.** Fault emails go to whoever last edited the flow and get lost. A
  record can be reported on and trended.
- **Entry formula uses `$Record__Prior`.** The task is created only on the change to escalated, not on
  every save of an escalated case.
- **Root cause rule checks `Status`, not only `IsClosed`.** Found in the Developer Edition test: during the
  save that closes the case, `IsClosed` still holds the prior value, so a rule on `IsClosed` alone let the
  case close and then blocked the next edit. The rule checks `ISPICKVAL(Status, "Closed")` too; an org with
  more closed statuses adds them to the `OR`.
- **Permission set and group names never collide.** Permission sets and permission set groups share one
  API namespace, so the supervisor add-on is `Service_Supervisor_Addon` and the group is `Service_Supervisor`.

## Risks

- Existing open cases with no root cause will block closure. Mitigation: backfill `Root_Cause_Category__c`
  with a data load under Automation Admin before activating the rule.
