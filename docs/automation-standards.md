# Automation standards

## One flow per object per context

Each object has at most one before-save and one after-save record-triggered flow. New logic is added
to the existing flow as a decision branch or a subflow. This keeps execution order predictable and
makes "what runs when a case is saved" answerable by opening two files.

| Context | Use for | Avoid |
| --- | --- | --- |
| Before save | Field defaults and derived values on the same record | DML, callouts |
| After save | Related records, tasks, platform events | Updating the triggering record again |
| Subflow | Logic reused by more than one flow (logging, notifications) | Object-specific logic |

## Naming

- Record-triggered: `<Object>_<BeforeSave|AfterSave>_<Purpose>` (e.g. `Case_AfterSave_Escalation`)
- Subflows: `Subflow_<Verb>_<Noun>` (e.g. `Subflow_Log_Automation_Error`)
- Elements: verb first, PascalCase with underscores (`Create_Review_Task`)

## Required in every flow

1. **Description** saying what it does and when it runs.
2. **Bypass**: record-triggered flows include `NOT({!$Permission.Bypass_Automation})` in the entry formula.
3. **Tight entry criteria**: run only on the change that matters (use `$Record__Prior`), not on every save.
4. **Fault paths** on every create, update, delete and action, connected to `Subflow_Log_Automation_Error`.
5. **No hard-coded Ids**: use custom metadata, custom labels or a lookup by developer name.

## Validation rules

- Start with `NOT($Permission.Bypass_Validation_Rules)`.
- Show the error on the field the user must fix (`errorDisplayField`), with a message that says what to do.

## Monitoring

`Automation_Error_Log__c` collects every failure caught by a fault path. A report grouped by
`Flow_Name__c` over the last 7 days is the first thing to check when users report odd behaviour, and a
recurring flow name is a candidate for a root cause analysis (see `rca-template.md`).
