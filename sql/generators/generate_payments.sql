\set ON_ERROR_STOP on

BEGIN;

WITH candidates AS (
    SELECT
        i.invoice_id,
        i.invoice_date,
        i.total_amount,
        row_number() OVER (ORDER BY i.invoice_id) AS rn
    FROM public.tbl_invoices i
    JOIN public.tbl_sales_orders so
      ON so.sales_order_id = i.sales_order_id
    WHERE so.order_number LIKE 'EXP26-%'
      AND i.total_amount > 0
      AND NOT EXISTS (
          SELECT 1 FROM public.tbl_payments p
          WHERE p.invoice_id = i.invoice_id
      )
),
selected AS (
    SELECT *
    FROM candidates
    WHERE rn <= GREATEST(
        0,
        80000 - (SELECT count(*) FROM public.tbl_payments)
    )
)
INSERT INTO public.tbl_payments
    (invoice_id, payment_reference, payment_date,
     amount, payment_method)
SELECT
    invoice_id,
    'EXP-PAY-' || lpad(rn::text, 8, '0'),
    LEAST(
        invoice_date + 15,
        CURRENT_DATE
    ),
    CASE
        WHEN rn % 4 = 0
            THEN round(total_amount * 0.50, 2)
        ELSE total_amount
    END,
    CASE
        WHEN rn % 5 = 0 THEN 'Card'
        ELSE 'EFT'
    END
FROM selected
ON CONFLICT (payment_reference) DO NOTHING;

COMMIT;
