# Run from the repository root: Rscript --vanilla tests/smoke.R
options(warn = 2)
suppressPackageStartupMessages({ library(readr); library(dplyr); library(stringr) })

check_pipeline <- function() {
  repo <- normalizePath(".", winslash = "/")
  scratch <- tempfile("golden-smoke-")
  dir.create(file.path(scratch, "data"), recursive = TRUE)
  stopifnot(all(file.copy(list.files("data", pattern = "\\.csv$", full.names = TRUE),
                         file.path(scratch, "data"))))
  on.exit(setwd(repo), add = TRUE)
  setwd(scratch)
  source(file.path(repo, "analysis/01-data-preparation.R"), local = TRUE)
  stopifnot(nrow(rfm_full) == 352L, n_active == 328L, n_dormant == 24L,
            n_duplicated == 6L, n_refunds == 4L, n_orphans == 8L, n_blank_ch == 14L,
            nrow(txn_valid) == 916L, sum(rfm_full$frequency, na.rm = TRUE) == 916L,
            !anyDuplicated(rfm_full$customer_id),
            all(txn_valid$quantity > 0), all(txn_valid$revenue_eur > 0),
            all(txn_valid$customer_id %in% master$customer_id),
            all(rfm_full$recency_days[!is.na(rfm_full$recency_days)] >= 0))
  source(file.path(repo, "analysis/02-rfm-segmentation.R"), local = TRUE)
  assignments <- read_csv("analysis_output/customer_segments.csv", show_col_types = FALSE)
  stopifnot(nrow(assignments) == 328L, !anyNA(assignments$segment),
            all(assignments$r_score %in% 1:5), all(assignments$f_score %in% 1:5),
            all(assignments$m_score %in% 1:5), all(assignments$cluster %in% 1:4),
            sum(profile$n_customers) == 328L, nrow(profile) == 8L,
            file.info("analysis_output/segment_customer_share.png")$size > 0,
            file.info("analysis_output/segment_revenue_share.png")$size > 0)

  # Tied scores must remain stable when the customer CSV is reordered.
  write_csv(rfm_full[nrow(rfm_full):1, ], "analysis_output/customer_rfm.csv")
  source(file.path(repo, "analysis/02-rfm-segmentation.R"), local = TRUE)
  repeated <- read_csv("analysis_output/customer_segments.csv", show_col_types = FALSE)
  stopifnot(isTRUE(all.equal(as.data.frame(assignments), as.data.frame(repeated),
                             check.attributes = FALSE)))
  cat("Golden pipeline checks passed.\n")
}
check_pipeline()
