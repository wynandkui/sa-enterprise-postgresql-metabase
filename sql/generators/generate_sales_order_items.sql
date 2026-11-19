\set ON_ERROR_STOP on

BEGIN;

-- Generate order items until the table reaches 300,000 rows.
-- Existing items remain untouched.
-- Each new order receives up to three distinct products.

WITH product_pool AS MATERIALIZED (
    SELECT
        product_id,
        selling_price,
        row_number() OVER (ORDER BY product_id)::integer AS rn
    FROM public.tbl_products
),
product_count AS (
    SELECT count(*)::integer AS total FROM product_pool
),
needed AS (
    SELECT GREATEST(
        0,
        300000 - (SELECT count(*) FROM public.tbl_sales_order_items)
    )::integer AS remaining
),
candidate_items AS (
    SELECT
        so.sales_order_id,
        pp.product_id,
        pp.selling_price,
        line_no,
        row_number() OVER (
            ORDER BY so.sales_order_id, line_no
        ) AS candidate_number
    FROM public.tbl_sales_orders so
    CROSS JOIN generate_series(1, 3) AS line_no
    CROSS JOIN product_count pc
    JOIN product_pool pp
      ON pp.rn = (
          ((so.sales_order_id * 7 + line_no - 1)
          % pc.total) + 1
      )
    WHERE so.order_number LIKE 'EXP26-%'
      AND NOT EXISTS (
          SELECT 1
          FROM public.tbl_sales_order_items existing
          WHERE existing.sales_order_id = so.sales_order_id
            AND existing.product_id = pp.product_id
      )
)
INSERT INTO public.tbl_sales_order_items
    (sales_order_id, product_id, quantity,
     unit_price, discount_percent)
SELECT
    sales_order_id,
    product_id,
    1 + (sales_order_id % 5)::integer,
    selling_price,
    0
FROM candidate_items
CROSS JOIN needed
WHERE candidate_number <= needed.remaining
ON CONFLICT (sales_order_id, product_id) DO NOTHING;

COMMIT;
