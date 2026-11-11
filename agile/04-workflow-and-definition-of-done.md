# Workflow & Definition of Done — Golden Customer Segmentation

## Issue workflow (Jira)

```
                 ┌───────────┐
        Create   │  Backlog  │
        ────────▶│ (product  │
                 │  backlog) │
                 └─────┬─────┘
                       │ sprint planning (Definition of Ready)
                       ▼
                 ┌───────────┐    Start      ┌───────────────┐
                 │  To Do    │──────────────▶│  In Progress  │
                 └───────────┘               └───────┬───────┘
                                                     │ submit
                                                     ▼
                 ┌───────────┐    approve    ┌───────────────┐
                 │   Done    │◀──────────────│  In Review    │
                 └───────────┘               └───────────────┘
```

### Transition rules

| From | To | Allowed when |
|---|---|---|
| Backlog | To Do | Sprint planning: story is Ready (see DoR in backlog doc) |
| To Do | In Progress | Assignee starts; set in-progress date |
| In Progress | In Review | Code/artifact pushed, self-check done, PR or link attached |
| In Review | Done | Reviewer approved + Definition of Done verified |
| In Review | In Progress | Review found issues (rework loop) |
| Done | Backlog | Only via explicit product-owner decision (re-scope) |

## Definition of Done (applies to every story)

- [ ] **Code / artifact:** committed to the repository with a clear message
  (e.g. `feat: build customer-level RFM table`)
- [ ] **Runs:** the pipeline step runs end-to-end without errors
- [ ] **Outputs:** expected file(s) produced in `analysis_output/`
- [ ] **Quality:** edge cases handled (duplicates, refunds, missing channels,
      orphans, dormant customers) and counted in the console log
- [ ] **Reproducibility:** deterministic seed / fixed reference date documented
- [ ] **Review:** at least one other person (peer or product owner) reviewed
- [ ] **Documentation:** anything non-obvious explained in the script header
      or the spec

## Examples: status history of a real issue

**US-04 Customer-level RFM table**

```
2026-08-31  Backlog      → To Do         (sprint planning)
2026-09-01  To Do        → In Progress   (Chance starts)
2026-09-02  In Progress  → In Review     (PR GH-3 + self-check output)
2026-09-03  In Review    → Done          (reviewer approved; DoD checked)
```

**US-07 k-means cross-check (illustrates a rework loop)**

```
2026-09-04  In Progress  → In Review     (PR GH-5)
2026-09-05  In Review    → In Progress   (reviewer: seed not fixed in code)
2026-09-05  In Progress  → In Review     (set.seed(2026) added)
2026-09-06  In Review    → Done          (approved)
```

## Why this matters in an interview

Walk an interviewer through this workflow and you have demonstrated:

1. you understand **agile ceremonies** (planning, review, retro);
2. you can define **quality gates** (DoR / DoD) that make deliverables auditable;
3. you have used **Jira** as a tool, not just heard of it.
