# Sprint 1 Board — Golden Customer Segmentation

> 2-week sprint (2 weeks / 10 working days), 21 story points committed.
> Columns: **To Do → In Progress → In Review → Done**
> (full workflow in [04-workflow-and-definition-of-done.md](04-workflow-and-definition-of-done.md)).

## Sprint goal

> Deliver a clean customer-level RFM dataset, a first segmentation with a
> segment profile, and the methodology spec — enough to demo to stakeholders.

## Board

### To Do
| Key | Title | Pts |
|---|---|---|
| US-09 | Charts: customer & revenue share by segment | 2 |

### In Progress
| Key | Title | Pts | Notes |
|---|---|---|---|
| US-10 | Methodology spec (Confluence-style) | 5 | 60% drafted; needs Decisions log |

### In Review
| Key | Title | Pts | Reviewer |
|---|---|---|---|
| US-08 | Segment profile table | 3 | Product owner |

### Done
| Key | Title | Pts |
|---|---|---|
| US-01 | Reproducible data import | 3 |
| US-02 | Exclude duplicates & refunds | 5 |
| US-04 | Customer-level RFM table | 5 |
| US-11 | End-to-end reproducible pipeline | 5 |

## Burndown (story points)

| Day | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Remaining | 21 | 21 | 18 | 13 | 13 | 11 | 8 | 8 | 5 | 2 |

*Illustrative tracking for the demo; in a real Jira board this updates automatically
from status changes.*

## How to walk through this board in a real Jira project

1. Create a **Company-managed or Team-managed project** (free plan) named
   `Golden Customer Segmentation`.
2. Create the **epics** (E-1 … E-4) and the **stories** (US-01 … US-12) from
   [01-product-backlog.md](01-product-backlog.md) as issues; set type = Story,
   add story points and labels.
3. Create a **Sprint** (2 weeks) and drag in the Sprint 1 scope above.
4. **Move issues through the workflow** (To Do → In Progress → In Review → Done)
   while adding comments and linking commits/PRs (e.g. `GH-1`).
5. At the sprint end, run the **Sprint Report** to show completed vs uncompleted
   points — that is the artifact you can screenshot for your portfolio.

## Sprint retrospective (what to say in an interview)

- **Went well:** data cleaning was cheap because the generator script made
  issues explicit; acceptance criteria written upfront caught edge cases
  (orphan transactions, dormant customers) early.
- **To improve:** US-09 charts slipped to the end because base-R plotting was
  an afterthought; next sprint move visualisation to the top and agree the
  chart style in the Definition of Ready.
- **Takeaway:** a fixed reference date for Recency (`2026-09-01`) was decided
  mid-sprint — logged in the Decisions log so the model stays reproducible.
