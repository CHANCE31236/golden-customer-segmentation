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
committed. Install the dependencies, then run from the repository root:

```r
install.packages(c("readr", "dplyr", "stringr"))  # once
# from the repository root
source("analysis/01-data-preparation.R")   # -> analysis_output/customer_rfm.csv
source("analysis/02-rfm-segmentation.R")   # -> customer_segments.csv, segment_profiles.csv + two charts
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

   The rules are evaluated in order. `Lost` uses R = 1 and `Hibernating`
   uses R = 2, so the two recency conditions are distinct.
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
| Champions | 25 | 7.6 | 13.7 | 40.2 | 4.6 | €6,777 |
| Loyal Customers | 50 | 15.2 | 23.8 | 101.7 | 3.9 | €5,874 |
| At Risk – High Value | 38 | 11.6 | 20.6 | 456.3 | 3.1 | €6,694 |
| At Risk | 50 | 15.2 | 7.2 | 566.6 | 2 | €1,787 |
| New Customers | 18 | 5.5 | 3 | 42.5 | 1.7 | €2,082 |
| Lost | 24 | 7.3 | 0.7 | 769.2 | 1.1 | €364 |
| Hibernating | 15 | 4.6 | 0.6 | 427.8 | 1.3 | €461 |
| Needs Attention | 108 | 32.9 | 30.4 | 203.4 | 2.9 | €3,476 |

The values describe the committed synthetic sample. Customers are sorted by
`customer_id` before scoring so quintile tie-breaking and k-means inputs stay
stable when input rows are reordered. `customer_segments.csv` contains the
RFM scores, segment, and cluster assignment for each active customer.

## Validation

```bash
Rscript --vanilla tests/smoke.R
```

The smoke check runs the pipeline in a temporary directory and verifies the
916 valid transactions, 328 active and 24 dormant customers, quality counters,
customer assignments, generated charts, and stable results under row reordering.
GitHub Actions runs the same checks for every pull request.

## License

MIT — see [LICENSE](LICENSE).
