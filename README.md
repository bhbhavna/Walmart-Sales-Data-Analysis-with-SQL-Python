# Walmart Sales Analysis — Python + SQL

End-to-end analysis of **9,969 Walmart retail transactions** across **100 branches in 98 US cities (2019–2023)**. I cleaned the raw data in Python, loaded it into MySQL, and answered nine business questions with SQL.

Part of my portfolio → **[bhbhavna.github.io](https://bhbhavna.github.io)**

---

## Key findings

| # | Finding | Why it matters |
|---|---------|----------------|
| 1 | **Two categories earn ~81% of profit.** Fashion accessories ($192K) and Home & lifestyle ($192K) produce $385K of $476K total profit — yet they are the top-rated category in only **5 of 100** branches. | The profit engine is not where customers are happiest; improving satisfaction in these two categories protects most of the profit. |
| 2 | **Digital payments dominate.** Credit card (43%) and e-wallet (39%) make up 82% of transactions; e-wallet is the most-used method in **75 of 100** branches, cash in only 2. | Payment-processing costs and e-wallet partnerships matter more than cash handling. |
| 3 | **Afternoons are peak.** 47% of invoices fall between 12:00 and 17:59; mornings carry only 21%. | Shift staffing can follow the afternoon peak. |
| 4 | **Growth is uneven.** Total revenue rose 6.8% from 2022 to 2023 ($217K → $232K), but **42 of 100 branches declined** — the worst five (WALM045, WALM047, WALM098, WALM033, WALM081) fell 51–63%. | Company-level growth hides a large group of under-performing branches worth a closer review. |

*Figures are the results of the queries in [`MY SQL.sql`](MY%20SQL.sql), run on [`walmart_clean_data.csv`](walmart_clean_data.csv). Profit = unit price × quantity × profit margin.*

---

## Approach

1. **Data** — [Walmart 10K sales dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets) from Kaggle.
2. **Cleaning (pandas)** — removed duplicates and rows with missing values, stripped `$` from `unit_price` and converted it to a number, added `total = unit_price × quantity`, and standardised column names. Output: `walmart_clean_data.csv`.
3. **Loading** — wrote the cleaned data to MySQL with SQLAlchemy + PyMySQL.
4. **Analysis (MySQL 8)** — CTEs, `RANK() OVER (PARTITION BY …)` window functions, `CASE` time-of-day buckets and date parsing with `STR_TO_DATE`.

## Business questions answered

1. Transactions and quantity sold by payment method
2. Highest-rated category in each branch
3. Busiest day of the week for each branch
4. Total quantity sold per payment method
5. Min / max / average rating by category and city
6. Total profit by category
7. Most common payment method per branch
8. Sales by shift (morning / afternoon / evening)
9. The five branches with the largest revenue decline, 2022 → 2023

## Files

| File | What it is |
|------|------------|
| `project.ipynb` | Data exploration, cleaning and loading into MySQL |
| `MY SQL.sql` | All nine business queries |
| `walmart_clean_data.csv` | Cleaned dataset (9,969 rows) |
| `Walmart.csv`, `walmart-10k-sales-datasets.zip` | Raw data |
| `Requirements.txt` | Python dependencies |

## Run it yourself

```bash
pip install -r Requirements.txt
# set your local MySQL password as an environment variable (never hard-code it)
set MYSQL_PASSWORD=your_password        # Windows
export MYSQL_PASSWORD=your_password     # macOS / Linux
```

Open `project.ipynb` and run all cells to load the data into a `walmart_db` database, then run the queries in `MY SQL.sql`.

---

**Tools:** Python (pandas, SQLAlchemy, PyMySQL) · MySQL 8 · Jupyter · VS Code
