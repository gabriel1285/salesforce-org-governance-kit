# Spec 001: Case escalation with mandatory reason and root cause

Status: Delivered · Owner: platform team

## Problem

Supervisors could not tell which cases were escalated or why, and closed cases carried no root cause,
so the same incidents kept coming back without anyone being able to measure it.

## Requirements

1. An agent can mark a case as escalated.
2. An escalated case must have an escalation reason.
3. When a case becomes escalated, the person who escalated it gets a review task.
4. A case cannot be closed without a root cause category.
5. Data loads and controlled fixes can skip these rules without deactivating them.
6. If the automation fails, the agent's save still works and the failure is recorded somewhere an admin can report on.

## Out of scope

- Notifications by email or Slack.
- Changing case assignment or queues.

## Acceptance criteria

- Escalating without a reason shows the error on the Escalation Reason field.
- Closing without a root cause shows the error on the Root Cause Category field.
- A user with Automation Admin can load cases that break both rules.
- A forced failure in task creation produces an Automation Error Log record and no error for the user.
