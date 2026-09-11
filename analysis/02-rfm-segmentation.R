# =============================================================================
# Golden Customer Segmentation - Step 2: RFM Scoring & Segmentation
# -----------------------------------------------------------------------------
# What this script does:
#   1. Loads the customer-level RFM table produced in step 1
#   2. Scores customers 1-5 on Recency / Frequency / Monetary (quintiles)
#   3. Assigns a business segment using a rules-based framework
#   4. Runs k-means (k = 4) as a complementary, data-driven view
#   5. Writes `analysis_output/segment_profiles.csv` + two base-R charts
#
# Input : analysis_output/customer_rfm.csv
# Output: analysis_output/segment_profiles.csv
#         analysis_output/segment_customer_share.png
#         analysis_output/segment_revenue_share.png
# =============================================================================

library(readr)
library(dplyr)

OUT_DIR <- "analysis_output"

# --- 1. Load ------------------------------------------------------------------
rfm <- read_csv(file.path(OUT_DIR, "customer_rfm.csv"), show_col_types = FALSE)

# segmentation applies to customers with at least one valid order
active <- rfm %>% filter(!is.na(recency_days))
cat("Active customers analysed:", nrow(active), "\n\n")

# --- 2. RFM scores (quintiles, 5 = best) ----------------------------------------
active <- active %>%
  mutate(
    r_score = ntile(desc(recency_days), 5),   # most recent -> 5
    f_score = ntile(frequency, 5),            # most frequent -> 5
    m_score = ntile(monetary, 5),             # highest value -> 5
    rfm_total = r_score + f_score + m_score   # composite score 3..15
  )

# --- 3. Rules-based business segments ------------------------------------------
# Rules are evaluated in order (first match wins).
active <- active %>%
  mutate(segment = case_when(
    r_score == 5 & f_score >= 4 & m_score >= 4 ~ "Champions",
    r_score >= 4 & f_score >= 3 & m_score >= 3 ~ "Loyal Customers",
    r_score == 5 & f_score <= 2                 ~ "New Customers",
    r_score <= 2 & m_score >= 4                 ~ "At Risk - High Value",
    r_score <= 2 & m_score >= 2                 ~ "At Risk",
    r_score == 1 & f_score <= 2 & m_score <= 2  ~ "Lost",
    r_score <= 2 & f_score <= 2 & m_score <= 2  ~ "Hibernating",
    TRUE                                        ~ "Needs Attention"
  ))

# --- 4. Complementary k-means view (k = 4) --------------------------------------
# log-transform reduces the skew of monetary; scale() standardises.
set.seed(2026)
km_input <- active %>%
  select(recency_days, frequency, monetary) %>%
  mutate(across(everything(), ~ log1p(.x))) %>%
  scale()

set.seed(2026)
km <- kmeans(km_input, centers = 4, nstart = 25)
active$cluster <- km$cluster

cat("K-means cluster sizes:", paste(km$size, collapse = ", "), "\n\n")

# cross-tab: how the rule-based segments map onto the statistical clusters
ct <- table(Segment = active$segment, Cluster = active$cluster)
print(ct)

# --- 5. Segment profile ---------------------------------------------------------
profile <- active %>%
  group_by(segment) %>%
  summarise(
    n_customers       = n(),
    customer_share_pct = round(n() / nrow(active) * 100, 1),
    avg_recency_days  = round(mean(recency_days), 1),
    avg_frequency     = round(mean(frequency), 1),
    avg_monetary_eur  = round(mean(monetary), 0),
    avg_order_value   = round(mean(avg_order_value), 0),
    revenue_share_pct = round(sum(monetary) / sum(active$monetary) * 100, 1),
    .groups = "drop"
  ) %>%
  arrange(desc(n_customers))

write_csv(profile, file.path(OUT_DIR, "segment_profiles.csv"))
cat("Saved:", file.path(OUT_DIR, "segment_profiles.csv"), "\n\n")
print(profile)

# --- 6. Charts (base R, no extra packages) --------------------------------------
png(file.path(OUT_DIR, "segment_customer_share.png"), width = 900, height = 550)
par(mar = c(8, 4, 3, 2))
bp <- barplot(profile$customer_share_pct,
              names.arg = profile$segment, las = 2, col = "steelblue",
              ylab = "% of customers",
              main = "Customer share by segment")
text(bp, profile$customer_share_pct + 0.6,
     labels = profile$customer_share_pct, cex = 0.8)
dev.off()

png(file.path(OUT_DIR, "segment_revenue_share.png"), width = 900, height = 550)
par(mar = c(8, 4, 3, 2))
bp2 <- barplot(profile$revenue_share_pct,
               names.arg = profile$segment, las = 2, col = "darkorange",
               ylab = "% of revenue",
               main = "Revenue share by segment")
text(bp2, profile$revenue_share_pct + 0.6,
     labels = profile$revenue_share_pct, cex = 0.8)
dev.off()

cat("Charts saved to", OUT_DIR, "\n")
