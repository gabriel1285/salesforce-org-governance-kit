# Access model

Access is granted through permission set groups, one per persona. Profiles carry only the licence
and login settings; they hold no object or field access and are not stored in this repo.

## Personas

| Persona | Assign | Contains | Can | Cannot |
| --- | --- | --- | --- | --- |
| Service agent | PSG `Service_Agent` | `Service_Agent_Base` | Read, create, edit own and shared cases; escalate; set root cause | Delete cases, see all cases |
| Service supervisor | PSG `Service_Supervisor` | `Service_Agent_Base` + `Service_Supervisor_Addon` | Everything an agent can, see all cases, read the automation error log | Delete cases, Modify All |
| Integration user | PS `Integration_Case_API` | API access, Case create/read/edit | Create and update cases through the API | Log in to the UI as a person, delete, see other objects |
| Platform admin (temporary) | PS `Automation_Admin` | Bypass custom permissions, error log management | Skip flows and validation rules during a load or fix | Anything else; assigned for the task, then removed |

## Principles

1. **Least privilege, built up.** Start from nothing and add. A persona that needs more gets a new
   permission set in its group, not a wider existing one.
2. **No system superpowers in permission sets.** Modify All Data, View All Data, Manage Users,
   Customize Application and object-level Modify All are blocked by the governance check.
3. **Bypass is a permission, not a switch.** Validation rules and flows check custom permissions, so a
   data load never requires deactivating automation for the whole org.
4. **Integration users are personas too.** One integration user per system, with its own minimal
   permission set, so a leaked credential has a small blast radius and logs show which system did what.
5. **Every grant has a description.** If nobody can say why a permission exists, it is removed.

## Review routine

- Monthly: report on permission set group assignments; check that `Automation_Admin` is assigned to nobody.
- Quarterly: review Connected Apps and integration users; remove those with no logins in 90 days.
