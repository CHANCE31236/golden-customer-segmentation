# Product Backlog — Golden Customer Segmentation

> Jira-style backlog for the project. Priorities: **P0** = must have,
> **P1** = should have, **P2** = nice to have. Points use Fibonacci (1, 2, 3, 5, 8, 13).
> Labels: `data`, `model`, `reporting`, `qa`, `documentation`, `governance`.

## Epics

| Epic | Goal |
|---|---|
| E-1 Data Foundation | Get a clean, trusted customer-transaction dataset |
| E-2 Segmentation Model | Build and validate the RFM + clustering segmentation |
| E-3 Insights & Handover | Deliver segment profiles, visualisations and documentation |
| E-4 Quality & Governance | Tests, code review, reproducibility, data privacy |

---

## Backlog (ranked)

| ID | Epic | User story | Priority | Points | Labels |
|---|---|---|---|---|---|
| US-01 | E-1 | As a **data analyst**, I want to import customer and transaction data from a single reproducible script, so that every run uses the same input. | P0 | 3 | data |
| US-02 | E-1 | As a **data analyst**, I want duplicated transactions and refunds excluded from the analysis, so that revenue figures are not overstated. | P0 | 5 | data, qa |
| US-03 | E-1 | As a **data analyst**, I want missing channels flagged and normalised, so that later reporting has no blanks. | P1 | 2 | data |
| US-04 | E-1 | As a **data analyst**, I want a customer-level table with Recency / Frequency / Monetary, so that I can score customers. | P0 | 5 | data |
| US-05 | E-2 | As a **marketing analyst**, I want each customer scored 1–5 on RFM, so that I can rank customers consistently. | P0 | 5 | model |
| US-06 | E-2 | As a **marketing analyst**, I want customers assigned to business segments (Champions, At Risk, …), so that we can target campaigns. | P0 | 8 | model |
| US-07 | E-2 | As a **data scientist**, I want a k-means clustering as a cross-check of the rules, so that we can validate the segments. | P1 | 8 | model |
| US-08 | E-3 | As a **retail manager**, I want a segment profile table (size, revenue share, average order value), so that I can see where value concentrates. | P0 | 3 | reporting |
| US-09 | E-3 | As a **retail manager**, I want charts of customer and revenue share by segment, so that I can present results to the team. | P1 | 2 | reporting |
| US-10 | E-3 | As a **project lead**, I want the methodology documented as a Confluence-style spec, so that the project is shareable and reusable. | P0 | 5 | documentation |
| US-11 | E-4 | As a **developer**, I want the pipeline to run end-to-end with one command and a fixed random seed, so that results are reproducible. | P0 | 5 | qa, governance |
| US-12 | E-4 | As a **data owner**, I want a privacy note covering the (synthetic) personal data, so that we respect data governance rules. | P1 | 2 | governance |

**Sprint 1 scope (2 weeks):** US-01 → US-08 → US-10 → US-11 (P0 core) +
US-09 (reporting) as stretch. See [03-sprint-board.md](03-sprint-board.md).

## Definition of Ready (a story may enter a sprint when)

- [ ] Business value and acceptance criteria are written and understood
- [ ] Data / dependencies required are identified and available
- [ ] Size agreed by the team (points assigned)
- [ ] No open blocking question from the product owner
