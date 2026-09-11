"""
Golden Retail Customer Segmentation - sample data generator
===========================================================
Generates two CSV files that mimic a jewellery retailer's customer and
transaction tables (synthetic data, deterministic random seed):

  * customer_master.csv         - 350 customers (France, multi-channel)
  * customer_transactions.csv   - ~900 orders over 2024-01 .. 2026-08

The data deliberately contains realistic imperfections so the R pipeline
(analysis/01-data-preparation.R) has something to do:

  * duplicated transaction IDs
  * missing / blank channel values
  * a few negative quantities (refunds flagged as "R" in reason_code)
  * a few orphan transactions whose customer_id has no master record
  * some customers with zero transactions (dormant accounts)

Run:  python data/00_generate_sample_data.py
Output: customer_master.csv, customer_transactions.csv (same folder)
"""

import csv
import os
import random
from datetime import date, timedelta

random.seed(42)

# outputs land next to this script, whatever the working directory
OUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------- customers
CITIES = [
    "Paris", "Lyon", "Marseille", "Bordeaux", "Nice",
    "Lille", "Strasbourg", "Nantes", "Toulouse", "Cannes",
]
TIERS = ["Bronze", "Silver", "Gold", "Platinum"]
CHANNELS = ["Boutique", "Online", "Flagship"]

customers = []
n_customers = 350
for i in range(1, n_customers + 1):
    join_date = date(2020, 1, 1) + timedelta(days=random.randint(0, 2000))
    customers.append(
        {
            "customer_id": f"C{i:04d}",
            "gender": random.choice(["F", "M", "F", "F", "M"]),
            "age_group": random.choice(["18-24", "25-34", "35-44", "45-54", "55-64", "65+"]),
            "loyalty_tier": random.choices(TIERS, weights=[40, 30, 20, 10])[0],
            "join_date": join_date.isoformat(),
            "city": random.choice(CITIES),
            "preferred_channel": random.choice(CHANNELS),
        }
    )

# ----------------------------------------------------------- transactions
CATEGORIES = [
    ("Necklace", ["Classic", "Signature", "High Jewelry"]),
    ("Ring", ["Classic", "Signature", "High Jewelry", "Bridal"]),
    ("Bracelet", ["Classic", "Signature", "Limited"]),
    ("Earrings", ["Classic", "Signature"]),
    ("Watch", ["Signature", "Limited"]),
]

transactions = []
n_transactions = 920
txn_id = 10000
for _ in range(n_transactions):
    customer = random.choice(customers)
    category, lines = random.choice(CATEGORIES)
    order_date = date(2024, 1, 1) + timedelta(days=random.randint(0, 970))
    # heavy-tailed unit price: most items are affordable, some are very expensive
    unit_price = round(random.lognormvariate(6.2, 1.1), 2)
    quantity = random.choice([1, 1, 1, 2, 2, 3])
    discount = random.choice([0.0, 0.0, 0.05, 0.10, 0.15, 0.20, 0.30])
    revenue = round(unit_price * quantity * (1 - discount), 2)
    channel = random.choices(CHANNELS, weights=[55, 35, 10])[0]
    transactions.append(
        {
            "transaction_id": f"TXN{txn_id}",
            "customer_id": customer["customer_id"],
            "order_date": order_date.isoformat(),
            "category": category,
            "product_line": random.choice(lines),
            "quantity": quantity,
            "unit_price_eur": unit_price,
            "discount_pct": discount,
            "revenue_eur": revenue,
            "channel": channel,
            "reason_code": "",
        }
    )
    txn_id += 1

# --------------------------------------------------------- inject dirt (deliberate)
# 1) duplicated transactions (same ID twice)
dup = random.sample(transactions, 6)
for row in dup:
    transactions.append(dict(row))

# 2) missing channel on some rows
for row in random.sample(transactions, 14):
    row["channel"] = ""

# 3) refunds -> negative quantity + reason_code "R"
for row in random.sample(transactions, 4):
    row["quantity"] = -row["quantity"]
    row["revenue_eur"] = -abs(row["revenue_eur"])
    row["reason_code"] = "R"

# 4) orphan transactions (customer not present in master)
orphans = []
for _ in range(8):
    category, lines = random.choice(CATEGORIES)
    order_date = date(2024, 1, 1) + timedelta(days=random.randint(0, 970))
    unit_price = round(random.lognormvariate(6.2, 1.1), 2)
    quantity = random.choice([1, 1, 2])
    revenue = round(unit_price * quantity, 2)
    orphans.append(
        {
            "transaction_id": f"TXN{txn_id}",
            "customer_id": f"X{random.randint(9000, 9999)}",
            "order_date": order_date.isoformat(),
            "category": category,
            "product_line": random.choice(lines),
            "quantity": quantity,
            "unit_price_eur": unit_price,
            "discount_pct": 0.0,
            "revenue_eur": revenue,
            "channel": random.choice(CHANNELS),
            "reason_code": "",
        }
    )
    txn_id += 1
transactions.extend(orphans)

# 5) two extra dormant customers with no transactions at all (unique ids)
for i in range(350, 352):
    join_date = date(2020, 1, 1) + timedelta(days=random.randint(0, 2000))
    customers.append(
        {
            "customer_id": f"C{i + 1:04d}",
            "gender": random.choice(["F", "M"]),
            "age_group": random.choice(["25-34", "45-54"]),
            "loyalty_tier": "Bronze",
            "join_date": join_date.isoformat(),
            "city": random.choice(CITIES),
            "preferred_channel": random.choice(CHANNELS),
        }
    )

# ------------------------------------------------------------------- write
master_fields = ["customer_id", "gender", "age_group", "loyalty_tier",
                 "join_date", "city", "preferred_channel"]
txn_fields = ["transaction_id", "customer_id", "order_date", "category",
              "product_line", "quantity", "unit_price_eur", "discount_pct",
              "revenue_eur", "channel", "reason_code"]

# shuffle transaction order so the file does not look sorted
random.shuffle(transactions)

with open(f"{OUT_DIR}/customer_master.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=master_fields)
    writer.writeheader()
    writer.writerows(customers)

with open(f"{OUT_DIR}/customer_transactions.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=txn_fields)
    writer.writeheader()
    writer.writerows(transactions)

print(f"customers : {len(customers)}")
print(f"transactions : {len(transactions)}")
