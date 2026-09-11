# Golden Customer Segmentation

A **customer segmentation project for a jewellery retailer**, built end-to-end:

- **Agile / Jira-style artefacts** – product backlog, user stories with acceptance
  criteria, a sprint board and a workflow with Definition of Ready / Done
- **Confluence-style specification** – the full project methodology documented as
  a spec page (objectives, data dictionary, method, acceptance criteria, decisions)
- **Reproducible R pipeline** – data preparation + RFM scoring + rules-based
  segmentation with a complementary k-means view, run on synthetic sample data

> This is a portfolio project: it demonstrates hands-on experience with agile
> project management tools (Jira, Confluence) **and** with the analytics workflow
> (R, data cleaning, RFM / clustering) that a retail analyst would own.

## Business context

A multi-channel jewellery retailer (boutiques, flagship store, e-commerce) wants
to move from "all customers treated the same" to segment-specific marketing and
inventory decisions. The project answers one question:

> **Who are our most valuable customers, and how should marketing treat each
> segment differently?**

## Repository structure

```
golden-customer-segmentation/
├── agile/                        # Jira-style project management artefacts
│   ├── 01-product-backlog.md     # epics + prioritised user stories
│   ├── 02-user-stories.md        # detailed stories with acceptance criteria
│   ├── 03-sprint-board.md        # 2-week sprint board walkthrough
│   └── 04-workflow-and-definition-of-done.md
├── docs/
│   └── confluence-spec-golden-customer-segmentation.md   # methodology spec
├── analysis/
│   ├── 01-data-preparation.R     # clean + build customer-level RFM table
│   └── 02-rfm-segmentation.R     # RFM scoring, segmentation, k-means
├── data/
│   ├── 00_generate_sample_data.py  # deterministic synthetic data generator
│   ├── customer_master.csv         # 352 customers
│   └── customer_transactions.csv   # ~930 orders (with realistic data issues)
├── analysis_output/             # created at runtime (gitignored)
└── README.md
```

## How to run

Requirements: **R ≥ 4.1** with the `tidyverse` packages (`readr`, `dplyr`,
`stringr`). Sample data is already committed, so no data generation is needed:

```r
# from the repository root
source("analysis/01-data-preparation.R")   # -> analysis_output/customer_rfm.csv
source("analysis/02-rfm-segmentation.R")   # -> segment_profiles.csv + charts
```

To regenerate the sample data from scratch:

```bash
python data/00_generate_sample_data.py
```

## Methodology (summary)

1. **Data preparation** – deduplicate transactions, exclude refunds, normalise
   missing channels, drop orphan transactions, then aggregate to customer level:
   **Recency** (days since last order), **Frequency** (number of orders),
   **Monetary** (total revenue).
2. **RFM scoring** – each customer is scored 1–5 per dimension (quintiles,
   5 = best), giving a composite 3–15 score.
3. **Segmentation** – business rules map RFM scores to segments
   (Champions, Loyal Customers, At Risk – High Value, At Risk, New Customers,
   Hibernating, Lost, Needs Attention).
4. **Validation view** – k-means (k = 4) on log-scaled RFM as a data-driven
   cross-check of the rule-based segments.

Full details: [docs/confluence-spec-golden-customer-segmentation.md](docs/confluence-spec-golden-customer-segmentation.md)

## Key results (sample data)

| Segment | Customers | Revenue share | Typical behaviour |
|---|---|---|---|
| Champions | ~8% | high | buy recently, often, and big |
| Loyal Customers | ~16% | high | steady, valuable repeat buyers |
| At Risk – High Value | ~12% | high | big spenders who stopped buying |
| At Risk | ~15% | medium | declining frequency |
| New Customers | ~5% | low | first recent orders |
| Hibernating / Lost | ~12% | low | long absence, low value |
| Needs Attention | ~33% | medium | average on all dimensions |

(*Exact figures depend on the generated sample; run the pipeline to reproduce.*)

## What this shows an interviewer

- **Jira:** you can write user stories, acceptance criteria, plan a sprint,
  and reason about a workflow with explicit Definition of Ready / Done.
- **Confluence:** you can document a methodology in a structured, shareable spec.
- **Analytics:** you can clean real-world-messy data in R, build an RFM model,
  and translate statistical output into business segments.

## License

MIT
