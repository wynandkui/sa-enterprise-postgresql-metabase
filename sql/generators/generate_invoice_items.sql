\set ON_ERROR_STOP on

BEGIN;

INSERT INTO public.tbl_invoice_items
    (invoice_id, product_id, description,
     quantity, unit_price, discount_percent)
SELECT
    i.invoice_id,
    soi.product_id,
    p.product_name,
    soi.quantity,
    soi.unit_price,
    soi.discount_percent
FROM public.tbl_invoices i
JOIN public.tbl_sales_orders so
    ON so.sales_order_id = i.sales_order_id
JOIN public.tbl_sales_order_items soi
    ON soi.sales_order_id = so.sales_order_id
JOIN public.tbl_products p
    ON p.product_id = soi.product_id
WHERE so.order_number LIKE 'EXP26-%'
  AND NOT EXISTS (
      SELECT 1
      FROM public.tbl_invoice_items ii
      WHERE ii.invoice_id = i.invoice_id
        AND ii.product_id = soi.product_id
  );

-- Ensure invoice subtotals match their generated line items.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM public.tbl_invoices i
        JOIN public.tbl_sales_orders so
          ON so.sales_order_id = i.sales_order_id
        LEFT JOIN (
            SELECT invoice_id, SUM(line_total) AS line_sum
            FROM public.tbl_invoice_items
            GROUP BY invoice_id
        ) x ON x.invoice_id = i.invoice_id
        WHERE so.order_number LIKE 'EXP26-%'
          AND i.subtotal <> COALESCE(x.line_sum, 0)
    ) THEN
        RAISE EXCEPTION 'Invoice line totals do not match invoice subtotals';
    END IF;
END $$;

COMMIT;
