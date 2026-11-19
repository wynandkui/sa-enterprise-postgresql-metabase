\set ON_ERROR_STOP on

BEGIN;

WITH order_totals AS (
    SELECT
        so.sales_order_id,
        so.order_number,
        so.order_date,
        round(
            sum(
                soi.quantity::numeric *
                soi.unit_price *
                (1 - soi.discount_percent / 100)
            ), 2
        ) AS subtotal
    FROM public.tbl_sales_orders so
    JOIN public.tbl_sales_order_items soi
      ON soi.sales_order_id = so.sales_order_id
    WHERE so.order_number LIKE 'EXP26-%'
      AND NOT EXISTS (
          SELECT 1
          FROM public.tbl_invoices i
          WHERE i.sales_order_id = so.sales_order_id
      )
    GROUP BY
        so.sales_order_id,
        so.order_number,
        so.order_date
),
invoice_values AS (
    SELECT
        sales_order_id,
        'INV-' || order_number AS invoice_number,
        order_date + 1 AS invoice_date,
        subtotal,
        round(subtotal * 0.15, 2) AS vat_amount
    FROM order_totals
)
INSERT INTO public.tbl_invoices (
    invoice_number,
    sales_order_id,
    invoice_date,
    due_date,
    subtotal,
    vat_rate,
    vat_amount,
    total_amount,
    status
)
SELECT
    invoice_number,
    sales_order_id,
    invoice_date,
    invoice_date + 30,
    subtotal,
    0.1500,
    vat_amount,
    subtotal + vat_amount,
    'Issued'
FROM invoice_values
ON CONFLICT (sales_order_id) DO NOTHING;

COMMIT;
