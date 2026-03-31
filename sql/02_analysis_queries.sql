-- ============================================================
-- Retail Sales Analytics — Analysis Queries
-- Data Source: Azure SQL Database
-- Author: Tai Nguyen
-- ============================================================


-- ============================================================
-- QUERY 01 — Monthly Revenue & Profit Trend
-- Skill: DATE functions + aggregation + calculated fields
-- Business Q: How is revenue and profit trending month over month?
-- ============================================================
SELECT
    FORMAT(o.order_date, 'yyyy-MM')                         AS order_month,
    COUNT(DISTINCT o.order_id)                              AS total_orders,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount))    AS gross_revenue,
    SUM(oi.quantity * oi.unit_cost)                         AS total_cost,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        - SUM(oi.quantity * oi.unit_cost)                   AS gross_profit,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        - SUM(oi.quantity * oi.unit_cost))
        / NULLIF(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 0) * 100
    , 1)                                                    AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY FORMAT(o.order_date, 'yyyy-MM')
ORDER BY order_month;


-- ============================================================
-- QUERY 02 — Revenue by Product Category & Department
-- Skill: Multi-level GROUP BY + JOIN chain
-- Business Q: Which departments and categories drive the most revenue?
-- ============================================================
SELECT
    c.department,
    c.category_name,
    COUNT(DISTINCT o.order_id)                              AS total_orders,
    SUM(oi.quantity)                                        AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        - SUM(oi.quantity * oi.unit_cost), 2)               AS profit,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        - SUM(oi.quantity * oi.unit_cost))
        / NULLIF(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 0) * 100
    , 1)                                                    AS margin_pct
FROM order_items oi
JOIN orders o       ON oi.order_id    = o.order_id
JOIN products p     ON oi.product_id  = p.product_id
JOIN categories c   ON p.category_id  = c.category_id
WHERE o.status = 'Completed'
GROUP BY c.department, c.category_name
ORDER BY revenue DESC;


-- ============================================================
-- QUERY 03 — Top 10 Products by Revenue
-- Skill: JOIN + aggregation + TOP/LIMIT
-- Business Q: What are the best-selling products by revenue and volume?
-- ============================================================
SELECT TOP 10
    p.product_name,
    c.category_name,
    c.department,
    SUM(oi.quantity)                                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        - SUM(oi.quantity * oi.unit_cost), 2)                  AS profit
FROM order_items oi
JOIN orders o     ON oi.order_id   = o.order_id
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE o.status = 'Completed'
GROUP BY p.product_name, c.category_name, c.department
ORDER BY revenue DESC;


-- ============================================================
-- QUERY 04 — Sales by Region and Channel
-- Skill: GROUP BY + CASE + multi-dimension analysis
-- Business Q: Which regions and sales channels perform best?
-- ============================================================
SELECT
    r.region_name,
    o.channel,
    COUNT(DISTINCT o.order_id)                                  AS orders,
    SUM(oi.quantity)                                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN regions r      ON o.region_id = r.region_id
WHERE o.status = 'Completed'
GROUP BY r.region_name, o.channel
ORDER BY revenue DESC;


-- ============================================================
-- QUERY 05 — Customer Segment Revenue Analysis
-- Skill: JOIN + GROUP BY + segment comparison
-- Business Q: How does revenue compare across customer segments?
-- ============================================================
SELECT
    cu.segment,
    COUNT(DISTINCT cu.customer_id)                              AS customer_count,
    COUNT(DISTINCT o.order_id)                                  AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / COUNT(DISTINCT cu.customer_id), 2)                    AS revenue_per_customer,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / COUNT(DISTINCT o.order_id), 2)                        AS avg_order_value
FROM customers cu
JOIN orders o       ON cu.customer_id = o.customer_id
JOIN order_items oi ON o.order_id     = oi.order_id
WHERE o.status = 'Completed'
GROUP BY cu.segment
ORDER BY total_revenue DESC;


-- ============================================================
-- QUERY 06 — Running Revenue Total by Month (Window Function)
-- Skill: SUM() OVER (ORDER BY) — cumulative analysis
-- Business Q: What is the cumulative revenue growth across 2024?
-- ============================================================
WITH monthly AS (
    SELECT
        FORMAT(o.order_date, 'yyyy-MM')                             AS order_month,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY FORMAT(o.order_date, 'yyyy-MM')
)
SELECT
    order_month,
    monthly_revenue,
    SUM(monthly_revenue)
        OVER (ORDER BY order_month
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
    ROUND(monthly_revenue
        / LAG(monthly_revenue, 1) OVER (ORDER BY order_month) * 100 - 100, 1)
                                                                AS mom_growth_pct
FROM monthly
ORDER BY order_month;


-- ============================================================
-- QUERY 07 — Product Rank by Revenue within Category (Window)
-- Skill: RANK() OVER (PARTITION BY) — category-level ranking
-- Business Q: What is the top product in each category?
-- ============================================================
WITH product_revenue AS (
    SELECT
        p.product_name,
        c.category_name,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue
    FROM order_items oi
    JOIN orders o     ON oi.order_id   = o.order_id
    JOIN products p   ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_name, c.category_name
)
SELECT
    category_name,
    product_name,
    revenue,
    RANK() OVER (
        PARTITION BY category_name
        ORDER BY revenue DESC
    ) AS rank_in_category
FROM product_revenue
ORDER BY category_name, rank_in_category;


-- ============================================================
-- QUERY 08 — Return Rate by Category
-- Skill: CASE + aggregation + percentage calculation
-- Business Q: Which categories have the highest return rates?
-- ============================================================
SELECT
    c.category_name,
    c.department,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    SUM(CASE WHEN o.status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        SUM(CASE WHEN o.status = 'Returned' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0)
    , 1)                                                AS return_rate_pct
FROM orders o
JOIN order_items oi ON o.order_id   = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
JOIN categories c   ON p.category_id = c.category_id
GROUP BY c.category_name, c.department
ORDER BY return_rate_pct DESC;


-- ============================================================
-- QUERY 09 — Customer Lifetime Value (LTV) Ranking
-- Skill: CTE + aggregation + RANK() window function
-- Business Q: Who are the highest-value customers by total spend?
-- ============================================================
WITH customer_ltv AS (
    SELECT
        cu.customer_id,
        cu.first_name + ' ' + cu.last_name              AS customer_name,
        cu.segment,
        r.region_name,
        COUNT(DISTINCT o.order_id)                      AS total_orders,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS lifetime_value,
        MIN(o.order_date)                               AS first_order,
        MAX(o.order_date)                               AS last_order
    FROM customers cu
    JOIN orders o       ON cu.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id     = oi.order_id
    JOIN regions r      ON cu.region_id   = r.region_id
    WHERE o.status = 'Completed'
    GROUP BY cu.customer_id, cu.first_name, cu.last_name, cu.segment, r.region_name
)
SELECT
    customer_name,
    segment,
    region_name,
    total_orders,
    lifetime_value,
    first_order,
    last_order,
    RANK() OVER (ORDER BY lifetime_value DESC) AS ltv_rank
FROM customer_ltv
ORDER BY ltv_rank;


-- ============================================================
-- QUERY 10 — Executive Sales Dashboard View (Multi-CTE)
-- Skill: Chained CTEs + CASE flags — boardroom-ready summary
-- Business Q: Give a single KPI summary row per region with
--             revenue, profit, top channel, and performance flag.
-- ============================================================
WITH region_sales AS (
    SELECT
        r.region_name,
        o.channel,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
            - SUM(oi.quantity * oi.unit_cost), 2)                       AS profit,
        COUNT(DISTINCT o.order_id)                                      AS orders
    FROM orders o
    JOIN order_items oi ON o.order_id  = oi.order_id
    JOIN regions r      ON o.region_id = r.region_id
    WHERE o.status = 'Completed'
    GROUP BY r.region_name, o.channel
),
region_totals AS (
    SELECT
        region_name,
        SUM(revenue)    AS total_revenue,
        SUM(profit)     AS total_profit,
        SUM(orders)     AS total_orders,
        ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 1) AS margin_pct
    FROM region_sales
    GROUP BY region_name
),
top_channel AS (
    SELECT region_name, channel AS top_channel
    FROM (
        SELECT region_name, channel,
               RANK() OVER (PARTITION BY region_name ORDER BY revenue DESC) AS rk
        FROM region_sales
    ) ranked
    WHERE rk = 1
)
SELECT
    rt.region_name,
    rt.total_revenue,
    rt.total_profit,
    rt.margin_pct,
    rt.total_orders,
    tc.top_channel,
    CASE
        WHEN rt.margin_pct >= 45 AND rt.total_orders >= 10 THEN 'High Performer'
        WHEN rt.margin_pct >= 38                           THEN 'On Track'
        ELSE                                                    'Needs Attention'
    END AS performance_flag
FROM region_totals rt
JOIN top_channel tc ON rt.region_name = tc.region_name
ORDER BY total_revenue DESC;
