# Tasks 001: Case escalation

- [x] T1 Fields `Escalated__c`, `Escalation_Reason__c`, `Root_Cause_Category__c` (base)
- [x] T2 Validation rules with bypass (base)
- [x] T3 Custom permissions `Bypass_Validation_Rules`, `Bypass_Automation` (base)
- [x] T4 Object `Automation_Error_Log__c` and fields (base)
- [x] T5 Subflow `Subflow_Log_Automation_Error` (service)
- [x] T6 After-save flow `Case_AfterSave_Escalation` with fault path (service)
- [x] T7 Permission sets and permission set groups (config)
- [x] T8 Governance check passes
- [x] T9 Backfill plan for open cases without root cause (see plan.md, Risks)
- [x] T10 Deployed to a Developer Edition org and acceptance criteria verified there (2026-11-24):
      escalate without reason and close without root cause both fail on the right field; Automation Admin
      loads a case breaking both rules with no review task created; a forced Task insert failure leaves the
      user's save intact and writes an `Automation_Error_Log__c` record
- [ ] T11 Deployed through the pipeline: develop → release → main
