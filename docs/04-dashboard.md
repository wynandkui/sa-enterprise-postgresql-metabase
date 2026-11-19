# 04 — Executive dashboard

Dashboard: **South African Enterprise — Executive Dashboard**

## KPI cards
1. Total Sales Revenue Excl VAT — ZAR.
2. Total Customer Outstanding — ZAR.
3. Total Output VAT — ZAR.
4. Total Invoices Issued.

## Visualizations
- Monthly Sales Revenue — Excluding VAT (ZAR): line chart using `vw_monthly_sales`.
- Monthly Output VAT — South Africa (ZAR): line chart using `vw_vat_summary`.
- Customer Outstanding Balances — ZAR: bar chart using `vw_customer_balances`.
- Top 10 Products by Revenue — ZAR: bar chart using `vw_product_sales`.
- Customer Distribution by Province — South Africa: custom SQL grouped by customer province.

## Reporting-period filter
The dashboard filter was configured for monthly sales and VAT date fields. In the observed configuration, it was **not applied uniformly to every KPI**. The dashboard displayed a filter from 1 January to 30 September 2026 while total invoice count still showed **100,000** and other KPIs reflected all-time totals. This is a scope issue, not necessarily a database defect.

To make a truly period-specific dashboard, connect each card to a corresponding date field or build period-aware SQL questions.

## Observed snapshot
After expansion and repairs, the dashboard showed approximately R1.3 billion sales excluding VAT, R461.18 million customer outstanding, R200.08 million output VAT, and 100,000 invoices. These are rounded display values from synthetic data, not audited financial statements.

## Visualization note
A saved question can produce valid rows in table mode but fail in chart mode if the visualization references an inactive field or has an incompatible axis configuration. Repair the saved question's source and chart settings, then save it.
