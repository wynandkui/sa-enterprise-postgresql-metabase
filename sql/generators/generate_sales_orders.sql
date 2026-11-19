\set ON_ERROR_STOP on
BEGIN;

WITH parameters AS (
    SELECT
        GREATEST(
            0,
            100000 - (SELECT count(*) FROM public.tbl_sales_orders)
        )::integer AS rows_needed,
        (SELECT array_agg(customer_id ORDER BY customer_id)
         FROM public.tbl_customers) AS customer_ids,
        (SELECT array_agg(employee_id ORDER BY employee_id)
         FROM public.tbl_employees) AS employee_ids
),
generated AS (
    SELECT
        n,
        DATE '2022-01-01' + (n * 1783 / 100000) AS order_date,
        p.customer_ids[
            1 + ((n * 37) % array_length(p.customer_ids, 1))
        ] AS customer_id,
        p.employee_ids[
            1 + ((n * 13) % array_length(p.employee_ids, 1))
        ] AS employee_id
    FROM parameters p
    CROSS JOIN LATERAL
        generate_series(1, p.rows_needed) AS n
)
INSERT INTO public.tbl_sales_orders
    (order_number, customer_id, order_date,
     required_date, status, created_by, notes)
SELECT
    'EXP26-' || lpad(n::text, 8, '0'),
    customer_id,
    order_date,
    order_date + 14,
    'Completed',
    employee_id,
    'Synthetic enterprise demonstration data'
FROM generated
ON CONFLICT (order_number) DO NOTHING;

COMMIT;
