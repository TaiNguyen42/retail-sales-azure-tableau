# Azure SQL Database — Setup Guide

This document explains how to provision and connect to an Azure SQL Database
for this project, and how to connect Tableau to it.

---

## Step 1 — Create Azure SQL Database (Free Tier)

1. Go to [portal.azure.com](https://portal.azure.com) and sign in
2. Click **"Create a resource"** → Search **"SQL Database"** → Click **Create**
3. Fill in the following:

| Field | Value |
|---|---|
| Subscription | Your Azure subscription |
| Resource Group | Create new → `retail-sales-rg` |
| Database name | `retail-sales-db` |
| Server | Create new → name it `tai-retail-server` |
| Location | West US 2 (Seattle region) |
| Compute + Storage | **Free tier** (General Purpose, Serverless) |
| Authentication | SQL authentication |
| Admin login | `sqladmin` |
| Password | Your secure password |

4. Click **Review + Create** → **Create**
5. Deployment takes ~2 minutes

---

## Step 2 — Configure Firewall

1. Go to your new SQL Server resource → **Networking**
2. Under **Firewall rules**, click **"Add your client IPv4 address"**
3. Toggle **"Allow Azure services and resources to access this server"** → On
4. Click **Save**

---

## Step 3 — Load the Data

1. In the Azure Portal, open your database → click **"Query editor (preview)"**
2. Log in with your SQL admin credentials
3. Copy and paste the full contents of `sql/01_schema_and_data.sql`
4. Click **Run** — all 5 tables will be created and populated
5. Verify with: `SELECT COUNT(*) FROM orders` — should return **40**

---

## Step 4 — Connect Tableau to Azure SQL Database

### Get your connection string:
In the Azure Portal → your SQL Database → **"Connection strings"** tab → copy the **JDBC** or **ADO.NET** string.

Your server address will look like:
```
tai-retail-server.database.windows.net
```

### In Tableau Desktop:
1. Open Tableau → **Connect** → **Microsoft SQL Server**
2. Fill in:
   - **Server:** `tai-retail-server.database.windows.net`
   - **Database:** `retail-sales-db`
   - **Authentication:** Use specific username and password
   - **Username:** `sqladmin`
   - **Password:** your password
3. Click **Sign In**
4. Under **Database**, select `retail-sales-db`
5. Drag your tables into the canvas and build relationships

### Recommended data model in Tableau:
```
orders ──────── order_items ──── products ──── categories
   |                                  
customers ── regions              
```

---

## Step 5 — Build Tableau Dashboard (5 recommended views)

| Sheet | Chart Type | Fields |
|---|---|---|
| Monthly Revenue Trend | Line chart | order_month vs gross_revenue |
| Revenue by Category | Bar chart | category_name vs revenue (colored by department) |
| Top 10 Products | Horizontal bar | product_name vs revenue |
| Sales by Region | Map or bar | region_name vs revenue |
| Customer Segment KPIs | KPI cards | segment vs revenue_per_customer |

Combine all 5 sheets into a single **Dashboard** in Tableau.
Export as image → save to `screenshots/` folder for GitHub.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│                   Azure Cloud                        │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │         Azure SQL Database                   │   │
│  │         (retail-sales-db)                    │   │
│  │                                              │   │
│  │  tables: orders, order_items, products,      │   │
│  │          categories, customers, regions      │   │
│  └──────────────────┬───────────────────────────┘   │
│                     │                                │
└─────────────────────│────────────────────────────────┘
                      │ SQL Queries (JDBC/TDS)
                      ▼
            ┌─────────────────┐
            │  Tableau Desktop │
            │  Live Connection │
            └────────┬────────┘
                     │
                     ▼
            ┌─────────────────┐
            │  Sales Dashboard │
            │  (Published)     │
            └─────────────────┘
```

---

## Cost Note

The Azure SQL **Free tier** includes:
- 32 GB storage
- 100,000 vCore-seconds/month free
- No credit card charge for free tier usage

This project runs entirely within free tier limits.
