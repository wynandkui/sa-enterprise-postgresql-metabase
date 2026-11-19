\set ON_ERROR_STOP on

BEGIN;

-- Suppliers: 500 total
INSERT INTO public.tbl_suppliers
    (supplier_name, city, province, contact_email, active)
SELECT
    'SA Demo Supplier ' || n,
    (ARRAY['Durban','Johannesburg','Cape Town','Pretoria',
           'Gqeberha','Bloemfontein','Polokwane','Mbombela'])[1 + n % 8],
    (ARRAY['KwaZulu-Natal','Gauteng','Western Cape','Gauteng',
           'Eastern Cape','Free State','Limpopo','Mpumalanga'])[1 + n % 8],
    'supplier' || n || '@example.com',
    true
FROM generate_series(
    1,
    GREATEST(0, 500 - (SELECT count(*) FROM public.tbl_suppliers))::integer
) AS n;

-- Customers: 10,000 total
INSERT INTO public.tbl_customers
    (customer_name, customer_type, city, province, email)
SELECT
    'SA Demo Customer ' || n,
    CASE WHEN n % 4 = 0 THEN 'Individual' ELSE 'Business' END,
    (ARRAY['Durban','Johannesburg','Cape Town','Pretoria',
           'Gqeberha','Bloemfontein','Polokwane','Mbombela'])[1 + n % 8],
    (ARRAY['KwaZulu-Natal','Gauteng','Western Cape','Gauteng',
           'Eastern Cape','Free State','Limpopo','Mpumalanga'])[1 + n % 8],
    'customer' || n || '@example.com'
FROM generate_series(
    1,
    GREATEST(0, 10000 - (SELECT count(*) FROM public.tbl_customers))::integer
) AS n;

-- Products: 2,000 total
INSERT INTO public.tbl_products
    (sku, product_name, category, supplier_id,
     unit_cost, selling_price, quantity_on_hand, reorder_level)
SELECT
    'SADEMO-' || lpad(n::text, 6, '0'),
    'Enterprise Product ' || n,
    (ARRAY['Electrical','IT Equipment','HVAC','Mechanical',
           'Office Supplies','Safety Equipment'])[1 + n % 6],
    s.supplier_id,
    (100 + n % 5000)::numeric(12,2),
    round((100 + n % 5000) * 1.35, 2),
    20 + n % 200,
    10
FROM generate_series(
    1,
    GREATEST(0, 2000 - (SELECT count(*) FROM public.tbl_products))::integer
) AS n
CROSS JOIN LATERAL (
    SELECT supplier_id
    FROM public.tbl_suppliers
    ORDER BY supplier_id
    LIMIT 1
) s;

-- Employees: 250 total
INSERT INTO public.tbl_employees
    (first_name, last_name, job_title, department_id,
     hire_date, monthly_salary, active)
SELECT
    'Employee' || n,
    'Demo' || n,
    (ARRAY['Technician','Administrator','Supervisor',
           'Sales Consultant','Manager'])[1 + n % 5],
    d.department_id,
    DATE '2018-01-01' + (n % 2500),
    (12000 + n % 45000)::numeric(12,2),
    true
FROM generate_series(
    1,
    GREATEST(0, 250 - (SELECT count(*) FROM public.tbl_employees))::integer
) AS n
CROSS JOIN LATERAL (
    SELECT department_id
    FROM public.tbl_departments
    ORDER BY department_id
    LIMIT 1
) d;

-- Assets: 1,000 total
INSERT INTO public.tbl_assets
    (asset_code, asset_name, asset_type, location,
     department_id, purchase_date, purchase_value, status)
SELECT
    'SADEMO-AST-' || lpad(n::text, 6, '0'),
    'Enterprise Asset ' || n,
    (ARRAY['Generator','UPS','Computer','Pump',
           'Air Conditioner'])[1 + n % 5],
    (ARRAY['Durban','Johannesburg','Cape Town'])[1 + n % 3],
    d.department_id,
    DATE '2020-01-01' + (n % 2000),
    (5000 + n % 100000)::numeric(14,2),
    'Operational'
FROM generate_series(
    1,
    GREATEST(0, 1000 - (SELECT count(*) FROM public.tbl_assets))::integer
) AS n
CROSS JOIN LATERAL (
    SELECT department_id
    FROM public.tbl_departments
    ORDER BY department_id
    LIMIT 1
) d;

COMMIT;
