# 02 — Synthetic data generation

## Objective
Expand a small South African enterprise demonstration into a relational reporting dataset of **893,758 records** without modifying unrelated databases.

## Sequence used
1. Create a restorable PostgreSQL backup and export schema.
2. Expand suppliers, customers, products, employees and assets.
3. Generate 99,980 additional sales orders (prefix `EXP26-`), yielding 100,000 total.
4. Generate three sales order lines per additional order, reaching 300,000 lines total.
5. Generate 99,980 additional invoices (number prefix `INV-`), reaching 100,000 total.
6. Copy order lines to invoice items, reaching 300,000 invoice lines total.
7. Generate 79,985 additional payments, reaching 80,000 total.
8. Reconcile invoice statuses against aggregated payment totals.

The generated orders span 2022–2026. Generated master records include synthetic customer and product labels and South African geographic references. Do not describe them as authentic transactions.

## Original working directory
`/home/wynand/sa-enterprise-generator/` on the Raspberry Pi. The generator filenames included `generate_master_data.sql` and `generate_payments.sql`. Obtain and review the original files before publishing executable reproductions.

## Safe psql execution
The PostgreSQL system account cannot necessarily traverse the user's home directory. Feed a script over standard input:

```bash
sudo -u postgres psql -X -d sa_enterprise_demo -v ON_ERROR_STOP=1 < /home/wynand/sa-enterprise-generator/FILE.sql
```

Replace `FILE.sql` with a verified file name. Use transactions for related inserts and stop on SQL errors.

## Reconciliation logic
For each invoice, aggregate payments. Set Paid if received >= total; Partially Paid if received > 0 but less than total; Overdue if unpaid and past due; otherwise Issued. In this implementation partially paid past-due invoices remain Partially Paid.

## Validation
- Invoice subtotal equals sum of its line totals.
- No invoice has payments greater than its total.
- Every invoice references an existing sales order.
- Final table counts match the targets above.
- Refresh PostgreSQL planner statistics with `ANALYZE` after large inserts.

**Important:** This guide records the steps performed. It is not a substitute for the original SQL generator sources.
