-- =============================================================
-- Walmart Sales Analysis: business questions in MySQL 8
-- Table: walmart_db.walmart (loaded from walmart_clean_data.csv by project.ipynb)
-- Dates in the data are stored as text in dd/mm/yy format, so they are parsed with STR_TO_DATE(date, '%d/%m/%y').
-- =============================================================

USE walmart_db;

-- Data check: rows, branches and categories per year
SELECT
    YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS sales_year,
    COUNT(*)                            AS transactions,
    COUNT(DISTINCT branch)              AS branches,
    COUNT(DISTINCT category)            AS categories
FROM walmart
GROUP BY sales_year
ORDER BY sales_year;
-- Result: 2019 has 6 categories; 2020 to 2023 have only 3, so year-on-year comparisons use 2022 vs 2023.


-- Q1: Transactions and quantity sold by payment method
SELECT
    payment_method,
    COUNT(*)      AS transactions,
    SUM(quantity) AS quantity_sold
FROM walmart
GROUP BY payment_method
ORDER BY transactions DESC;


-- Q2: Highest-rated category in each branch
WITH category_rating AS (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rating_rank
    FROM walmart
    GROUP BY branch, category
)
SELECT branch, category, ROUND(avg_rating, 2) AS avg_rating
FROM category_rating
WHERE rating_rank = 1
ORDER BY branch;


-- Q3: Busiest day of the week for each branch
WITH daily AS (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS day_rank
    FROM walmart
    GROUP BY branch, day_name
)
SELECT branch, day_name, transactions
FROM daily
WHERE day_rank = 1
ORDER BY branch;


-- Q4: Minimum, maximum and average rating of each category in each city
SELECT
    city,
    category,
    MIN(rating)           AS min_rating,
    MAX(rating)           AS max_rating,
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmart
GROUP BY city, category
ORDER BY city, category;


-- Q5: Total profit by category, with each category's share of total profit
-- Profit = unit_price x quantity x profit_margin
SELECT
    category,
    ROUND(SUM(unit_price * quantity * profit_margin), 2) AS total_profit,
    ROUND(100 * SUM(unit_price * quantity * profit_margin)
          / SUM(SUM(unit_price * quantity * profit_margin)) OVER (), 1) AS profit_share_pct
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Q6: Most common payment method in each branch
WITH branch_payments AS (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS payment_rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method, transactions
FROM branch_payments
WHERE payment_rank = 1
ORDER BY branch;


-- Q7: Invoices by shift (Morning before 12:00, Afternoon 12:00 to 17:59, Evening 18:00 on) for each branch
SELECT
    branch,
    CASE
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, invoices DESC;


-- Q8: Five branches with the largest revenue decline from 2022 to 2023
WITH branch_revenue AS (
    SELECT
        branch,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022 THEN total ELSE 0 END) AS revenue_2022,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 THEN total ELSE 0 END) AS revenue_2023
    FROM walmart
    GROUP BY branch
)
SELECT
    branch,
    ROUND(revenue_2022, 2) AS revenue_2022,
    ROUND(revenue_2023, 2) AS revenue_2023,
    ROUND(100 * (revenue_2022 - revenue_2023) / revenue_2022, 2) AS decline_pct
FROM branch_revenue
WHERE revenue_2023 < revenue_2022
ORDER BY decline_pct DESC
LIMIT 5;


-- Q9: Price vs volume variance, 2022 to 2023, by category (FP&A revenue bridge)
-- Volume effect = change in units x 2022 average price
-- Price effect  = change in average price x 2023 units
-- Volume effect + price effect = total revenue change
WITH yearly AS (
    SELECT
        category,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022 THEN quantity ELSE 0 END) AS units_2022,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 THEN quantity ELSE 0 END) AS units_2023,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022 THEN total    ELSE 0 END) AS revenue_2022,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 THEN total    ELSE 0 END) AS revenue_2023
    FROM walmart
    GROUP BY category
    HAVING units_2022 > 0 AND units_2023 > 0
)
SELECT
    category,
    ROUND(revenue_2022, 2) AS revenue_2022,
    ROUND(revenue_2023, 2) AS revenue_2023,
    ROUND((units_2023 - units_2022) * (revenue_2022 / units_2022), 2) AS volume_effect,
    ROUND((revenue_2023 / units_2023 - revenue_2022 / units_2022) * units_2023, 2) AS price_effect,
    ROUND(revenue_2023 - revenue_2022, 2) AS total_change
FROM yearly
ORDER BY total_change DESC;
-- Result: total change +$14,855 = volume +$6,546 and price +$8,309.
