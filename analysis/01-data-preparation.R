# =============================================================================
# Golden Customer Segmentation - Step 1: Data Preparation
# -----------------------------------------------------------------------------
# What this script does:
#   1. Loads the raw customer master and transaction CSVs
#   2. Cleans transaction-level data (duplicates, refunds, missing channel,
#      orphan transactions)
#   3. Aggregates transactions to customer level and computes the RFM table
#      (Recency / Frequency / Monetary)
#   4. Writes `analysis_output/customer_rfm.csv`
#
# Input : data/customer_master.csv, data/customer_transactions.csv
# Output: analysis_output/customer_rfm.csv
#
# Run:  setwd("..") then source("analysis/01-data-preparation.R")
#       or run from an RStudio project rooted at the repo.
# =============================================================================

library(readr)
library(dplyr)
library(stringr)

DATA_DIR <- file.path("data")
OUT_DIR  <- file.path("analysis_output")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# --- 1. Load raw data ---------------------------------------------------------
master       <- read_csv(file.path(DATA_DIR, "customer_master.csv"), show_col_types = FALSE)
transactions <- read_csv(file.path(DATA_DIR, "customer_transactions.csv"), show_col_types = FALSE)

cat("Raw dimensions:\n")
cat("  customers    :", nrow(master), "\n")
cat("  transactions :", nrow(transactions), "\n\n")

# --- 2. Transaction-level cleaning --------------------------------------------
valid_ids <- master$customer_id

txn_clean <- transactions %>%
  # 2.1 remove duplicated transaction ids (keep first occurrence)
  distinct(transaction_id, .keep_all = TRUE) %>%
  # 2.2 keep only genuine sales (drop refunds / negative lines)
  filter(reason_code != "R", quantity > 0, revenue_eur > 0) %>%
  # 2.3 parse order date
  mutate(order_date = as.Date(order_date)) %>%
  # 2.4 normalise channel: blank / missing values -> "Unknown"
  mutate(channel = if_else(is.na(channel) | str_trim(channel) == "",
                           "Unknown", str_trim(channel))) %>%
  # 2.5 flag transactions that reference a customer absent from the master
  mutate(is_orphan = !(customer_id %in% valid_ids))

n_duplicated <- sum(duplicated(transactions$transaction_id))
n_refunds    <- sum(transactions$reason_code == "R" | transactions$quantity < 0)
n_orphans    <- sum(txn_clean$is_orphan)
n_blank_ch   <- sum(transactions$channel == "")

cat("Data quality issues found and handled:\n")
cat("  duplicated transaction ids :", n_duplicated, "(deduplicated)\n")
cat("  refund / negative lines    :", n_refunds, "(excluded)\n")
cat("  orphan transactions        :", n_orphans, "(excluded from RFM)\n")
cat("  blank channel values       :", n_blank_ch, "(set to 'Unknown')\n\n")

txn_valid <- txn_clean %>% filter(!is_orphan)

# --- 3. Customer-level RFM table ----------------------------------------------
as_of <- as.Date("2026-09-01")   # fixed analysis reference date (data ends Aug 2026)

rfm <- txn_valid %>%
  group_by(customer_id) %>%
  summarise(
    last_order_date = max(order_date),
    frequency       = n(),                     # number of orders
    monetary        = sum(revenue_eur),        # total revenue (EUR)
    avg_order_value = mean(revenue_eur),
    .groups = "drop"
  ) %>%
  mutate(recency_days = as.numeric(as_of - last_order_date)) %>%
  select(customer_id, recency_days, frequency, monetary, avg_order_value)

# keep every master customer; dormant accounts simply have NA RFM values
rfm_full <- master %>%
  left_join(rfm, by = "customer_id")

n_active  <- sum(!is.na(rfm_full$recency_days))
n_dormant <- sum(is.na(rfm_full$recency_days))

cat("Customer coverage:\n")
cat("  customers with >= 1 valid order (active):", n_active, "\n")
cat("  dormant customers (no valid order)      :", n_dormant, "\n\n")

# --- 4. Write output ------------------------------------------------------------
write_csv(rfm_full, file.path(OUT_DIR, "customer_rfm.csv"))
cat("Saved:", file.path(OUT_DIR, "customer_rfm.csv"), "\n")

# quick peek
print(rfm_full %>% select(customer_id, recency_days, frequency, monetary) %>% head(6))
