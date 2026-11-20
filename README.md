# Walmart Sales Analysis: Python + SQL

End-to-end analysis of **9,969 Walmart retail transactions** across **100 branches in 98 US cities (2019 to 2023)**. I cleaned the raw data in Python, checked what the data really covers, loaded it into MySQL, answered nine business questions with SQL, including an FP&A style price vs volume bridge that explains revenue growth.

Part of my portfolio → **[bhbhavna.github.io](https://bhbhavna.github.io)**

---

## Key findings

| # | Finding | Why it matters |
|---|---------|----------------|
| 1 | **Revenue grew 6.8% from 2022 to 2023 ($217.4K → $232.3K), and price did more of the work than volume.** About 56% of the increase ($8.3K) came from higher average prices and 44% ($6.5K) from more units. Invoices were flat (2,228 vs 2,227). | Growth came from bigger, pricier baskets, not more customer visits. If prices stop rising, growth slows unless footfall improves. |
| 2 | **Company growth hides weak branches.** 42 of 100 branches declined from 2022 to 2023; the worst five (WALM045, WALM047, WALM098, WALM033, WALM081) fell 51% to 63%. | A total that looks healthy can hide a large group of under-performing branches worth a closer review. |
| 3 | **Two categories earn ~81% of profit.** Fashion accessories ($192K) and Home and lifestyle ($192K) produce $385K of $476K total profit. | Read with the data check below: these two are also the only large categories sold after 2019, so the share partly reflects coverage, not just performance. |
| 4 | **Digital payments dominate.** Credit card (43%) and e-wallet (39%) make up 82% of transactions; e-wallet is the most used method in **75 of 100** branches, cash in only 2. | Payment processing costs and e-wallet partnerships matter more than cash handling. |
| 5 | **Afternoons are peak.** 47% of invoices fall between 12:00 and 17:59; mornings carry only 21%. | Shift staffing can follow the afternoon peak. |

### Data check: read this before comparing years

| Category | 2019 | 2020 | 2021 | 2022 | 2023 |
|---|---|---|---|---|---|
| Fashion accessories | 178 | 1,095 | 1,107 | 1,079 | 1,079 |
| Home and lifestyle | 160 | 1,052 | 1,141 | 1,086 | 1,081 |
| Electronic accessories | 170 | 64 | 55 | 63 | 67 |
| Food and beverages | 174 | 0 | 0 | 0 | 0 |
| Health and beauty | 152 | 0 | 0 | 0 | 0 |
| Sports and travel | 166 | 0 | 0 | 0 | 0 |

Three categories appear **only in 2019**. That is why 2019 revenue ($308K) looks much higher than later years, and why year-on-year analysis here uses **2022 vs 2023**, where the category list is the same. Checking coverage first is the same habit as reconciling a ledger before trusting the totals.

*Figures are the results of the queries in [`MY SQL.sql`](MY%20SQL.sql) and the notebook, run on [`walmart_clean_data.csv`](walmart_clean_data.csv). Profit = unit price × quantity × profit margin.*

---

## Approach

1. **Data:** [Walmart 10K sales dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets) from Kaggle.
2. **Cleaning (pandas):** removed 51 duplicate rows and 31 rows with a missing price or quantity, stripped `$` from `unit_price` and converted it to a number, added `total = unit_price × quantity`, and standardised column names. Output: `walmart_clean_data.csv`.
3. **Data check:** counted transactions per category per year and found three categories that exist only in 2019.
4. **Visuals (matplotlib):** revenue by year, invoices by shift, and a 2022 to 2023 revenue bridge.
5. **Price vs volume variance:** split the revenue change into a volume effect and a price effect, with a check that the two add up to the total change.
6. **Loading:** wrote the cleaned data to MySQL with SQLAlchemy + PyMySQL (password read from an environment variable).
7. **Analysis (MySQL 8):** CTEs, `RANK() OVER (PARTITION BY …)` window functions, conditional aggregation with `CASE`, and date parsing with `STR_TO_DATE`.

## Business questions answered in SQL

1. Transactions and quantity sold by payment method
2. Highest-rated category in each branch
3. Busiest day of the week for each branch
4. Min / max / average rating by category and city
5. Total profit and profit share by category
6. Most common payment method per branch
7. Invoices by shift (morning / afternoon / evening)
8. The five branches with the largest revenue decline, 2022 → 2023
9. Price vs volume revenue bridge by category, 2022 → 2023

## Files

| File | What it is |
|------|------------|
| `project.ipynb` | Cleaning, data check, charts, price vs volume bridge, and loading into MySQL |
| `MY SQL.sql` | Data check query and all nine business queries |
| `walmart_clean_data.csv` | Cleaned dataset (9,969 rows) |
| `Walmart.csv`, `walmart-10k-sales-datasets.zip` | Raw data |
| `Requirements.txt` | Python dependencies |

## Run it yourself

```bash
pip install -r Requirements.txt
# optional: set your local MySQL password as an environment variable (never hard-code it)
set MYSQL_PASSWORD=your_password        # Windows
export MYSQL_PASSWORD=your_password     # macOS / Linux
```

Open `project.ipynb` and run all cells. Without `MYSQL_PASSWORD` the analysis still runs and only the MySQL load is skipped. With it, the data is loaded into a `walmart_db` database; then run the queries in `MY SQL.sql`.

---

**Tools:** Python (pandas, matplotlib, SQLAlchemy, PyMySQL) · MySQL 8 · Jupyter · VS Code
