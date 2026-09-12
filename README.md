# Golden Customer Segmentation

Customer segmentation for a multi-channel jewellery retailer, built end to end
in R: a messy transaction export goes in, an RFM-scored and segmented customer
table comes out.

The repository also contains the project-management artefacts that would
normally live in Jira and Confluence, so the whole delivery — backlog, sprint
board, methodology spec, code — is in one place.

## Business question

The retailer sells through boutiques, a flagship store and an e-commerce site,
and currently treats every customer identically. The question this project
answers: **which customers are worth the most, and how should marketing treat
each group differently?**

## What is in here

```
golden-customer-segmentation/
├── agile/                        # project-management artefacts
│   ├── 01-product-backlog.md     # epics + prioritised user stories
│   ├── 02-user-stories.md        # stories with acceptance criteria
│   ├── 03-sprint-board.md        # two-week sprint walkthrough
│   └── 04-workflow-and-definition-of-done.md
├── docs/
│   └── confluence-spec-golden-customer-segmentation.md   # methodology spec
├── analysis/
│   ├── 01-data-preparation.R     # clean transactions -> customer-level RFM
│   └── 02-rfm-segmentation.R     # RFM scoring, segmentation, k-means check
├── data/
│   ├── 00_generate_sample_data.py  # deterministic synthetic data generator
│   ├── customer_master.csv         # 352 customers
│   └── customer_transactions.csv   # 934 orders (with deliberate data issues)
├── analysis_output/             # created at runtime (gitignored)
└── README.md
```

The customer data is synthetic. The generator injects the problems a real CRM
export usually has, so the cleaning steps have something to do: duplicate
transaction IDs, blank channel values, refunds recorded as negative lines,
transactions pointing at customers who are not in the master table, and
customers who never ordered at all.

## Running it

R 4.1 or newer with `readr`, `dplyr` and `stringr`. Both sample CSVs are
committed, so the pipeline runs as-is:

```r
# from the repository root
source("analysis/01-data-preparation.R")   # -> analysis_output/customer_rfm.csv
source("analysis/02-rfm-segmentation.R")   # -> segment_profiles.csv + two charts
```

To rebuild the sample data from scratch (Python 3, no dependencies):

```bash
python data/00_generate_sample_data.py
```

The generator is seeded, so the sample stays stable across runs.

## Method

1. **Cleaning** (`01-data-preparation.R`) — drop duplicate transaction IDs,
   exclude refunds and negative lines, fill blank channels with `Unknown`, drop
   transactions whose customer is missing from the master table.
2. **RFM** — per customer: days since last order, number of orders, total
   revenue. The reference date is fixed at 2026-09-01 so output is stable.
3. **Scoring** (`02-rfm-segmentation.R`) — each dimension is cut into quintiles,
   5 being best, giving a 3–15 composite score.
4. **Segmentation** — business rules map the scores to eight segments. The
   rules are evaluated in order, first match wins:

   | Segment | Rule |
   | --- | --- |
   | Champions | R = 5, F ≥ 4, M ≥ 4 |
   | Loyal Customers | R ≥ 4, F ≥ 3, M ≥ 3 |
   | New Customers | R = 5, F ≤ 2 |
   | At Risk – High Value | R ≤ 2, M ≥ 4 |
   | At Risk | R ≤ 2, M ≥ 2 |
   | Lost | R = 1, F ≤ 2, M ≤ 2 |
   | Hibernating | R = 2, F ≤ 2, M ≤ 2 |
   | Needs Attention | everything else |

   `Lost` is a subset of the conditions that define `Hibernating`, so it has to
   be tested first; otherwise it can never be reached.
5. **Cross-check** — k-means (k = 4) on log-transformed RFM, as a data-driven
   second opinion on the rule-based segments. The script prints the
   segment-by-cluster cross-tabulation.

Full methodology, data dictionary and acceptance criteria are in
[docs/confluence-spec-golden-customer-segmentation.md](docs/confluence-spec-golden-customer-segmentation.md).

## Result on the sample data

328 of the 352 customers have at least one valid order; the other 24 are
dormant and get `NA` RFM values.

| Segment | Customers | % customers | % revenue | Avg recency (days) | Avg orders | Avg spend |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Champions | 23 | 7.0 | 12.2 | 37 | 4.7 | €6,562 |
| Loyal Customers | 52 | 15.9 | 25.1 | 105 | 4.0 | €5,963 |
| At Risk – High Value | 38 | 11.6 | 20.6 | 456 | 3.1 | €6,694 |
| At Risk | 50 | 15.2 | 7.2 | 567 | 2.0 | €1,787 |
| New Customers | 18 | 5.5 | 4.0 | 43 | 1.7 | €2,769 |
| Lost | 23 | 7.0 | 0.6 | 766 | 1.1 | €347 |
| Hibernating | 17 | 5.2 | 0.6 | 426 | 1.4 | €467 |
| Needs Attention | 107 | 32.6 | 29.5 | 203 | 2.9 | €3,410 |

The two high-value groups (Champions and At Risk – High Value) hold 33% of
revenue between them on 18% of the customer base, which is the actionable
part: the At Risk – High Value group spends like Champions but has not ordered
in over a year.

Figures come from a reference run against the committed sample data; R's
quintile tie-breaking can shift the exact counts by a customer or two.

## License

MIT — see [LICENSE](LICENSE).
