# Retail Sales Analytics — Azure SQL + Tableau

**Tools:** Azure SQL Database · SQL (T-SQL) · Tableau · Data Modeling  
**Domain:** Retail Analytics · E-Commerce · Sales Operations  
**Cloud:** Microsoft Azure (Azure SQL Database — Free Tier)  
**Author:** [Tai Nguyen](https://www.linkedin.com/in/tain42/) | [Portfolio](https://tainguyen24.netlify.app)

---

## Overview

End-to-end retail sales analytics project simulating a real-world e-commerce data pipeline:

1. **Data stored in Azure SQL Database** — 5 relational tables, 18 products, 40 orders, 6 regions
2. **Analyzed with 10 SQL queries** — revenue trends, product ranking, customer LTV, return rates
3. **Visualized in Tableau** — 5-view dashboard covering monthly trends, regional performance, and customer segments

This project demonstrates the cloud + BI analyst stack commonly required in Data Analyst and BI Analyst roles.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Microsoft Azure                    │
│                                                      │
│   ┌──────────────────────────────────────────────┐  │
│   │         Azure SQL Database                   │  │
│   │         (retail-sales-db)                    │  │
│   │                                              │  │
│   │  orders · order_items · products             │  │
│   │  categories · customers · regions            │  │
│   └──────────────────┬───────────────────────────┘  │
│                      │ SQL (TDS/JDBC)                │
└──────────────────────│──────────────────────────────┘
                       ▼
             ┌──────────────────┐
             │  Tableau Desktop  │
             │  Live Connection  │
             └────────┬─────────┘
                      ▼
             ┌──────────────────┐
             │  Sales Dashboard  │
             │  5 Views · 1 DB   │
             └──────────────────┘
```

---

## Business Questions Answered

| # | Business Question | SQL Skills |
|---|---|---|
| 01 | How is revenue and profit trending month over month? | DATE functions, aggregation, margin calc |
| 02 | Which departments and categories drive the most revenue? | Multi-level GROUP BY, JOIN chain |
| 03 | What are the top 10 products by revenue? | TOP N, multi-table JOIN |
| 04 | Which regions and channels perform best? | Multi-dimension GROUP BY |
| 05 | How does revenue compare across customer segments? | Segment analysis, per-customer metrics |
| 06 | What is the cumulative revenue growth across 2024? | SUM() OVER, LAG() window function |
| 07 | What is the top product in each category? | RANK() OVER (PARTITION BY) |
| 08 | Which categories have the highest return rates? | CASE WHEN, return rate calculation |
| 09 | Who are the highest-value customers by lifetime spend? | CTE, RANK(), customer LTV |
| 10 | Executive dashboard — KPI summary per region | Multi-CTE chain, CASE flags |

---

## Database Schema

```
regions            customers
-------            ---------
region_id     <──  region_id
region_name        customer_id
country            segment
                   customer_since

orders             order_items         products          categories
------             -----------         --------          ----------
order_id      ──>  order_id            product_id   <──  category_id
customer_id        item_id        <──  product_id        category_name
region_id          product_id          unit_price        department
channel            quantity            unit_cost
status             unit_price
discount_pct       unit_cost
                   discount
```

---

## Key Findings

- **Electronics** is the highest-revenue department, led by Laptops and Smartphones
- **Pacific Northwest** (Seattle region) ranks #1 in both total revenue and order volume
- **Premium customers** account for ~35% of customers but ~55% of total revenue
- **Online channel** drives 60%+ of completed orders across all regions
- **Return rate** is highest in Electronics (~15%) vs Clothing (~8%)
- **Month-over-month growth** averaged ~12% across the 8-month period

---

## Project Structure

```
retail-sales-azure/
├── sql/
│   ├── 01_schema_and_data.sql      # Table definitions + seed data (Azure SQL compatible)
│   └── 02_analysis_queries.sql     # 10 business analysis queries (T-SQL)
├── docs/
│   ├── azure_setup_guide.md        # Step-by-step Azure SQL Database setup
│   └── tableau_dashboard_guide.md  # Dashboard build instructions
├── screenshots/
│   └── (add your Tableau screenshots here)
└── README.md
```

---

## How to Run

### Option A — Azure SQL Database (cloud, as designed)
1. Follow `docs/azure_setup_guide.md` to provision a free Azure SQL Database
2. Run `sql/01_schema_and_data.sql` in the Azure Query Editor
3. Connect Tableau Desktop to your Azure SQL Database
4. Run queries from `sql/02_analysis_queries.sql` to validate data

### Option B — Local PostgreSQL (no Azure account needed)
1. Run `sql/01_schema_and_data.sql` in pgAdmin or DB Fiddle (PostgreSQL mode)
2. Replace `FORMAT(date, 'yyyy-MM')` with `TO_CHAR(date, 'YYYY-MM')`
3. Replace `TOP 10` with `LIMIT 10`
4. Connect Tableau to your local PostgreSQL instance

---

## Azure Free Tier Details

This project is designed to run within Azure's free tier:
- **Azure SQL Database** — 32 GB storage, 100K vCore-seconds/month free
- No ongoing cost for a dataset of this size
- Free account: [azure.microsoft.com/free](https://azure.microsoft.com/free)

---

## Skills Demonstrated

**Cloud:** Azure SQL Database provisioning, firewall configuration, Query Editor, connection strings  
**SQL:** T-SQL syntax, DATE functions, window functions (RANK, SUM OVER, LAG), CTEs, CASE WHEN, return rate analysis  
**BI:** Tableau live cloud connection, multi-view dashboard, dual-axis charts, KPI cards  
**Data Modeling:** Star schema design, fact/dimension tables, foreign key relationships  

---

*Connect: [LinkedIn](https://linkedin.com/in/tain42) · [Portfolio](https://tainguyen24.netlify.app) · [GitHub](https://github.com/TaiNguyen42)*
