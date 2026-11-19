# 05 — Migration and troubleshooting

## View naming
The live database contained both `view_*` and `vw_*` reporting views:
- customer_balances
- monthly_sales
- product_sales
- vat_summary

These are distinct PostgreSQL objects. Saved Metabase questions sometimes referenced inactive metadata for `view_monthly_sales` or `vw_customer_balances`.

## Symptoms and resolutions

### “Table … is inactive”
The view existed in PostgreSQL, but Metabase's metadata reference was inactive. Sync the database schema and reselect the **active** view in the question editor. Save the repaired question.

### “Permission denied for view customers”
A native SQL question failed with a PostgreSQL permission error. Restore the Metabase reader's SELECT access to the required relation(s) and schema USAGE. On 19 November 2026, a permission check confirmed access for `customers`, `tbl_customers` and `vw_monthly_sales`.

### KPI displays a date instead of a number
The saved question was visualizing the wrong column. Use an aggregation (SUM/COUNT), ensure one scalar result, and choose the Number visualization.

### Dashboard chart fails but question returns rows
Inspect the chart's selected X/Y columns, saved visualization settings, source relation, and any dashboard filter mappings. The sales view returned 59 monthly rows in a successful question run.

## Retired database
An earlier database named `enterprise_demo` was deliberately deleted after backup/expansion work. The surviving business database is `sa_enterprise_demo`. Do not recreate or delete databases automatically while following this documentation.

## Minimal diagnosis
Check the failing card's error first; then inspect its saved question source, PostgreSQL grants and Metabase metadata. Avoid repeatedly restarting services when only a question or grant is defective.
