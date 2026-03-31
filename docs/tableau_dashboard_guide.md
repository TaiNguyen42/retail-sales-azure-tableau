# Tableau Dashboard Guide

## Recommended Dashboard Views

This document describes the 5 dashboard sheets to build in Tableau
using the queries from `sql/02_analysis_queries.sql`.

---

## Sheet 1 — Monthly Revenue & Profit Trend
**Chart type:** Dual-axis line chart
**X-axis:** Order Month
**Y-axis (left):** Gross Revenue
**Y-axis (right):** Profit Margin %
**Color:** Blue for revenue, Orange for margin
**Insight to highlight:** Which month had highest revenue? Where did margin dip?

---

## Sheet 2 — Revenue by Department & Category
**Chart type:** Stacked horizontal bar chart
**Rows:** Department
**Columns:** Revenue
**Color:** Category name
**Sort:** Descending by total revenue
**Insight to highlight:** Electronics dominates — what % of total?

---

## Sheet 3 — Top 10 Products by Revenue
**Chart type:** Horizontal bar chart with labels
**Rows:** Product name (top 10)
**Columns:** Revenue
**Color:** Department
**Add:** Profit as a label on each bar
**Insight to highlight:** Which single product drives the most revenue?

---

## Sheet 4 — Regional Sales Performance Map
**Chart type:** Filled map OR bar chart
**Dimension:** Region name
**Measure:** Revenue (size), Profit margin (color)
**Color scale:** Green (high margin) → Red (low margin)
**Insight to highlight:** Which region has highest revenue vs highest margin?

---

## Sheet 5 — Customer Segment KPI Cards
**Chart type:** KPI summary cards (text table or BANs)
**Rows:** Customer segment (Premium, Regular, New)
**Metrics shown:** Total revenue, Orders, Revenue per customer, Avg order value
**Insight to highlight:** Premium customers represent X% of customers but Y% of revenue

---

## Dashboard Layout (recommended)

```
┌─────────────────────────────────────────────────┐
│  RETAIL SALES ANALYTICS DASHBOARD — 2024         │
│  Data Source: Azure SQL Database                 │
├──────────────────────┬──────────────────────────┤
│  Monthly Revenue     │  Revenue by Category      │
│  & Profit Trend      │  (Bar chart)              │
│  (Line chart)        │                           │
├──────────────────────┴──────────────────────────┤
│          Regional Sales Map / Bar                │
├──────────────────────┬──────────────────────────┤
│  Top 10 Products     │  Customer Segment KPIs    │
│  (Horizontal bar)    │  (KPI cards)              │
└──────────────────────┴──────────────────────────┘
```

---

## Export & GitHub Instructions

1. In Tableau → **Dashboard** menu → **Export as Image**
2. Save as `screenshots/dashboard_overview.png`
3. Save individual sheet screenshots as:
   - `screenshots/revenue_trend.png`
   - `screenshots/category_revenue.png`
   - `screenshots/regional_map.png`
   - `screenshots/top_products.png`
   - `screenshots/customer_segments.png`
4. Add all screenshots to your GitHub repo
5. Reference them in README.md with `![Dashboard](screenshots/dashboard_overview.png)`
