--
-- PostgreSQL database dump
--

\restrict J3qneJeC3x9djG82DzplJFd70sCNtZl5Hqh1AZFiZrFMzjz40ywQDBKNdLv0lmI

-- Dumped from database version 17.12 (Debian 17.12-0+deb13u1)
-- Dumped by pg_dump version 17.12 (Debian 17.12-0+deb13u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tbl_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_assets (
    asset_id bigint NOT NULL,
    asset_code character varying(40) NOT NULL,
    asset_name character varying(200) NOT NULL,
    asset_type character varying(100) NOT NULL,
    location character varying(150) NOT NULL,
    department_id bigint,
    purchase_date date,
    purchase_value numeric(14,2),
    status character varying(30) DEFAULT 'Operational'::character varying NOT NULL,
    CONSTRAINT chk_assets_purchase_value_check CHECK ((purchase_value >= (0)::numeric)),
    CONSTRAINT chk_assets_status_check CHECK (((status)::text = ANY ((ARRAY['Operational'::character varying, 'Under Maintenance'::character varying, 'Out of Service'::character varying, 'Decommissioned'::character varying])::text[])))
);


--
-- Name: assets; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.assets AS
 SELECT asset_id,
    asset_code,
    asset_name,
    asset_type,
    location,
    department_id,
    purchase_date,
    purchase_value,
    status
   FROM public.tbl_assets;


--
-- Name: tbl_customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_customers (
    customer_id bigint NOT NULL,
    customer_name character varying(200) NOT NULL,
    customer_type character varying(30) NOT NULL,
    city character varying(100) NOT NULL,
    province character varying(100) NOT NULL,
    email character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_customers_customer_type_check CHECK (((customer_type)::text = ANY ((ARRAY['Individual'::character varying, 'Business'::character varying])::text[])))
);


--
-- Name: customers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.customers AS
 SELECT customer_id,
    customer_name,
    customer_type,
    city,
    province,
    email,
    created_at
   FROM public.tbl_customers;


--
-- Name: tbl_departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_departments (
    department_id bigint NOT NULL,
    department_name character varying(100) NOT NULL,
    cost_centre character varying(20) NOT NULL
);


--
-- Name: departments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.departments AS
 SELECT department_id,
    department_name,
    cost_centre
   FROM public.tbl_departments;


--
-- Name: tbl_employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_employees (
    employee_id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    job_title character varying(150) NOT NULL,
    department_id bigint NOT NULL,
    hire_date date NOT NULL,
    monthly_salary numeric(12,2) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    CONSTRAINT chk_employees_monthly_salary_check CHECK ((monthly_salary >= (0)::numeric))
);


--
-- Name: employees; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.employees AS
 SELECT employee_id,
    first_name,
    last_name,
    job_title,
    department_id,
    hire_date,
    monthly_salary,
    active
   FROM public.tbl_employees;


--
-- Name: tbl_invoice_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_invoice_items (
    invoice_item_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    product_id bigint NOT NULL,
    description character varying(250) NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0 NOT NULL,
    line_total numeric(14,2) GENERATED ALWAYS AS (round((((quantity)::numeric * unit_price) * ((1)::numeric - (discount_percent / (100)::numeric))), 2)) STORED,
    CONSTRAINT chk_invoice_items_discount_percent_check CHECK (((discount_percent >= (0)::numeric) AND (discount_percent <= (100)::numeric))),
    CONSTRAINT chk_invoice_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT chk_invoice_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: invoice_items; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.invoice_items AS
 SELECT invoice_item_id,
    invoice_id,
    product_id,
    description,
    quantity,
    unit_price,
    discount_percent,
    line_total
   FROM public.tbl_invoice_items;


--
-- Name: tbl_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_invoices (
    invoice_id bigint NOT NULL,
    invoice_number character varying(30) NOT NULL,
    sales_order_id bigint NOT NULL,
    invoice_date date NOT NULL,
    due_date date NOT NULL,
    subtotal numeric(14,2) NOT NULL,
    vat_rate numeric(5,4) DEFAULT 0.1500 NOT NULL,
    vat_amount numeric(14,2) NOT NULL,
    total_amount numeric(14,2) NOT NULL,
    status character varying(30) NOT NULL,
    CONSTRAINT chk_invoices_check CHECK ((due_date >= invoice_date)),
    CONSTRAINT chk_invoices_check1 CHECK ((total_amount = (subtotal + vat_amount))),
    CONSTRAINT chk_invoices_status_check CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Issued'::character varying, 'Partially Paid'::character varying, 'Paid'::character varying, 'Overdue'::character varying, 'Cancelled'::character varying])::text[]))),
    CONSTRAINT chk_invoices_subtotal_check CHECK ((subtotal >= (0)::numeric)),
    CONSTRAINT chk_invoices_total_amount_check CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT chk_invoices_vat_amount_check CHECK ((vat_amount >= (0)::numeric)),
    CONSTRAINT chk_invoices_vat_rate_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (1)::numeric)))
);


--
-- Name: invoices; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.invoices AS
 SELECT invoice_id,
    invoice_number,
    sales_order_id,
    invoice_date,
    due_date,
    subtotal,
    vat_rate,
    vat_amount,
    total_amount,
    status
   FROM public.tbl_invoices;


--
-- Name: tbl_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_payments (
    payment_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    payment_reference character varying(50) NOT NULL,
    payment_date date NOT NULL,
    amount numeric(14,2) NOT NULL,
    payment_method character varying(30) NOT NULL,
    CONSTRAINT chk_payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT chk_payments_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['EFT'::character varying, 'Card'::character varying, 'Cash'::character varying, 'Bank Deposit'::character varying])::text[])))
);


--
-- Name: payments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.payments AS
 SELECT payment_id,
    invoice_id,
    payment_reference,
    payment_date,
    amount,
    payment_method
   FROM public.tbl_payments;


--
-- Name: tbl_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_products (
    product_id bigint NOT NULL,
    sku character varying(40) NOT NULL,
    product_name character varying(200) NOT NULL,
    category character varying(100) NOT NULL,
    supplier_id bigint,
    unit_cost numeric(12,2) NOT NULL,
    selling_price numeric(12,2) NOT NULL,
    quantity_on_hand integer DEFAULT 0 NOT NULL,
    reorder_level integer DEFAULT 10 NOT NULL,
    CONSTRAINT chk_products_quantity_on_hand_check CHECK ((quantity_on_hand >= 0)),
    CONSTRAINT chk_products_reorder_level_check CHECK ((reorder_level >= 0)),
    CONSTRAINT chk_products_selling_price_check CHECK ((selling_price >= (0)::numeric)),
    CONSTRAINT chk_products_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);


--
-- Name: products; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.products AS
 SELECT product_id,
    sku,
    product_name,
    category,
    supplier_id,
    unit_cost,
    selling_price,
    quantity_on_hand,
    reorder_level
   FROM public.tbl_products;


--
-- Name: tbl_sales_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_sales_order_items (
    sales_order_item_id bigint NOT NULL,
    sales_order_id bigint NOT NULL,
    product_id bigint NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0 NOT NULL,
    CONSTRAINT chk_sales_order_items_discount_percent_check CHECK (((discount_percent >= (0)::numeric) AND (discount_percent <= (100)::numeric))),
    CONSTRAINT chk_sales_order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT chk_sales_order_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: sales_order_items; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sales_order_items AS
 SELECT sales_order_item_id,
    sales_order_id,
    product_id,
    quantity,
    unit_price,
    discount_percent
   FROM public.tbl_sales_order_items;


--
-- Name: tbl_sales_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_sales_orders (
    sales_order_id bigint NOT NULL,
    order_number character varying(30) NOT NULL,
    customer_id bigint NOT NULL,
    order_date date NOT NULL,
    required_date date,
    status character varying(30) NOT NULL,
    created_by bigint,
    notes text,
    CONSTRAINT chk_sales_orders_status_check CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Confirmed'::character varying, 'Processing'::character varying, 'Dispatched'::character varying, 'Completed'::character varying, 'Cancelled'::character varying])::text[])))
);


--
-- Name: sales_orders; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sales_orders AS
 SELECT sales_order_id,
    order_number,
    customer_id,
    order_date,
    required_date,
    status,
    created_by,
    notes
   FROM public.tbl_sales_orders;


--
-- Name: seq_assets_asset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_assets ALTER COLUMN asset_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_assets_asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_customers ALTER COLUMN customer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_customers_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_departments ALTER COLUMN department_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_departments_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_employees ALTER COLUMN employee_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_employees_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_invoice_items_invoice_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_invoice_items ALTER COLUMN invoice_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_invoice_items_invoice_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_invoices_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_invoices ALTER COLUMN invoice_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_invoices_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_payments ALTER COLUMN payment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_products ALTER COLUMN product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_sales_order_items_sales_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_sales_order_items ALTER COLUMN sales_order_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_sales_order_items_sales_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: seq_sales_orders_sales_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_sales_orders ALTER COLUMN sales_order_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_sales_orders_sales_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbl_suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbl_suppliers (
    supplier_id bigint NOT NULL,
    supplier_name character varying(200) NOT NULL,
    city character varying(100) NOT NULL,
    province character varying(100) NOT NULL,
    contact_email character varying(255),
    active boolean DEFAULT true NOT NULL
);


--
-- Name: seq_suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbl_suppliers ALTER COLUMN supplier_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.seq_suppliers_supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: suppliers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.suppliers AS
 SELECT supplier_id,
    supplier_name,
    city,
    province,
    contact_email,
    active
   FROM public.tbl_suppliers;


--
-- Name: vw_customer_balances; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_customer_balances AS
 WITH payment_totals AS (
         SELECT tbl_payments.invoice_id,
            sum(tbl_payments.amount) AS amount_paid
           FROM public.tbl_payments
          GROUP BY tbl_payments.invoice_id
        )
 SELECT c.customer_id,
    c.customer_name,
    c.city,
    c.province,
    count(i.invoice_id) AS invoice_count,
    sum(i.total_amount) AS total_invoiced,
    sum(COALESCE(pt.amount_paid, (0)::numeric)) AS total_paid,
    sum((i.total_amount - COALESCE(pt.amount_paid, (0)::numeric))) AS outstanding_balance
   FROM (((public.tbl_customers c
     JOIN public.tbl_sales_orders so ON ((so.customer_id = c.customer_id)))
     JOIN public.tbl_invoices i ON ((i.sales_order_id = so.sales_order_id)))
     LEFT JOIN payment_totals pt ON ((pt.invoice_id = i.invoice_id)))
  WHERE ((i.status)::text <> 'Cancelled'::text)
  GROUP BY c.customer_id, c.customer_name, c.city, c.province;


--
-- Name: view_customer_balances; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_customer_balances AS
 SELECT customer_id,
    customer_name,
    city,
    province,
    invoice_count,
    total_invoiced,
    total_paid,
    outstanding_balance
   FROM public.vw_customer_balances;


--
-- Name: vw_monthly_sales; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_monthly_sales AS
 SELECT (date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date AS sales_month,
    count(*) AS invoice_count,
    sum(subtotal) AS sales_excl_vat,
    sum(vat_amount) AS output_vat,
    sum(total_amount) AS sales_incl_vat
   FROM public.tbl_invoices
  WHERE ((status)::text <> 'Cancelled'::text)
  GROUP BY ((date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date);


--
-- Name: view_monthly_sales; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_monthly_sales AS
 SELECT sales_month,
    invoice_count,
    sales_excl_vat,
    output_vat,
    sales_incl_vat
   FROM public.vw_monthly_sales;


--
-- Name: vw_product_sales; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_product_sales AS
 SELECT p.product_id,
    p.sku,
    p.product_name,
    p.category,
    sum(ii.quantity) AS units_sold,
    sum(ii.line_total) AS revenue_excl_vat,
    sum(((ii.quantity)::numeric * p.unit_cost)) AS estimated_cost,
    sum((ii.line_total - ((ii.quantity)::numeric * p.unit_cost))) AS estimated_gross_profit
   FROM ((public.tbl_products p
     JOIN public.tbl_invoice_items ii ON ((ii.product_id = p.product_id)))
     JOIN public.tbl_invoices i ON ((i.invoice_id = ii.invoice_id)))
  WHERE ((i.status)::text <> 'Cancelled'::text)
  GROUP BY p.product_id, p.sku, p.product_name, p.category;


--
-- Name: view_product_sales; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_product_sales AS
 SELECT product_id,
    sku,
    product_name,
    category,
    units_sold,
    revenue_excl_vat,
    estimated_cost,
    estimated_gross_profit
   FROM public.vw_product_sales;


--
-- Name: vw_vat_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_vat_summary AS
 SELECT (date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date AS vat_month,
    count(*) AS invoice_count,
    sum(subtotal) AS taxable_sales,
    sum(vat_amount) AS output_vat
   FROM public.tbl_invoices
  WHERE ((status)::text <> 'Cancelled'::text)
  GROUP BY ((date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date);


--
-- Name: view_vat_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_vat_summary AS
 SELECT vat_month,
    invoice_count,
    taxable_sales,
    output_vat
   FROM public.vw_vat_summary;


--
-- Name: tbl_assets pk_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_assets
    ADD CONSTRAINT pk_assets_pkey PRIMARY KEY (asset_id);


--
-- Name: tbl_customers pk_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_customers
    ADD CONSTRAINT pk_customers_pkey PRIMARY KEY (customer_id);


--
-- Name: tbl_departments pk_departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_departments
    ADD CONSTRAINT pk_departments_pkey PRIMARY KEY (department_id);


--
-- Name: tbl_employees pk_employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_employees
    ADD CONSTRAINT pk_employees_pkey PRIMARY KEY (employee_id);


--
-- Name: tbl_invoice_items pk_invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_invoice_items
    ADD CONSTRAINT pk_invoice_items_pkey PRIMARY KEY (invoice_item_id);


--
-- Name: tbl_invoices pk_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_invoices
    ADD CONSTRAINT pk_invoices_pkey PRIMARY KEY (invoice_id);


--
-- Name: tbl_payments pk_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_payments
    ADD CONSTRAINT pk_payments_pkey PRIMARY KEY (payment_id);


--
-- Name: tbl_products pk_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_products
    ADD CONSTRAINT pk_products_pkey PRIMARY KEY (product_id);


--
-- Name: tbl_sales_order_items pk_sales_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_order_items
    ADD CONSTRAINT pk_sales_order_items_pkey PRIMARY KEY (sales_order_item_id);


--
-- Name: tbl_sales_orders pk_sales_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_orders
    ADD CONSTRAINT pk_sales_orders_pkey PRIMARY KEY (sales_order_id);


--
-- Name: tbl_suppliers pk_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_suppliers
    ADD CONSTRAINT pk_suppliers_pkey PRIMARY KEY (supplier_id);


--
-- Name: tbl_assets uq_assets_asset_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_assets
    ADD CONSTRAINT uq_assets_asset_code_key UNIQUE (asset_code);


--
-- Name: tbl_departments uq_departments_cost_centre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_departments
    ADD CONSTRAINT uq_departments_cost_centre_key UNIQUE (cost_centre);


--
-- Name: tbl_departments uq_departments_department_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_departments
    ADD CONSTRAINT uq_departments_department_name_key UNIQUE (department_name);


--
-- Name: tbl_invoices uq_invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_invoices
    ADD CONSTRAINT uq_invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: tbl_invoices uq_invoices_sales_order_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_invoices
    ADD CONSTRAINT uq_invoices_sales_order_id_key UNIQUE (sales_order_id);


--
-- Name: tbl_payments uq_payments_payment_reference_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_payments
    ADD CONSTRAINT uq_payments_payment_reference_key UNIQUE (payment_reference);


--
-- Name: tbl_products uq_products_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_products
    ADD CONSTRAINT uq_products_sku_key UNIQUE (sku);


--
-- Name: tbl_sales_order_items uq_sales_order_items_sales_order_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_order_items
    ADD CONSTRAINT uq_sales_order_items_sales_order_id_product_id_key UNIQUE (sales_order_id, product_id);


--
-- Name: tbl_sales_orders uq_sales_orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_orders
    ADD CONSTRAINT uq_sales_orders_order_number_key UNIQUE (order_number);


--
-- Name: tbl_assets fk_assets_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_assets
    ADD CONSTRAINT fk_assets_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.tbl_departments(department_id);


--
-- Name: tbl_employees fk_employees_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_employees
    ADD CONSTRAINT fk_employees_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.tbl_departments(department_id);


--
-- Name: tbl_invoice_items fk_invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_invoice_items
    ADD CONSTRAINT fk_invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.tbl_invoices(invoice_id);


--
-- Name: tbl_invoice_items fk_invoice_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_invoice_items
    ADD CONSTRAINT fk_invoice_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.tbl_products(product_id);


--
-- Name: tbl_invoices fk_invoices_sales_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_invoices
    ADD CONSTRAINT fk_invoices_sales_order_id_fkey FOREIGN KEY (sales_order_id) REFERENCES public.tbl_sales_orders(sales_order_id);


--
-- Name: tbl_payments fk_payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_payments
    ADD CONSTRAINT fk_payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.tbl_invoices(invoice_id);


--
-- Name: tbl_products fk_products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_products
    ADD CONSTRAINT fk_products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.tbl_suppliers(supplier_id);


--
-- Name: tbl_sales_order_items fk_sales_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_order_items
    ADD CONSTRAINT fk_sales_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.tbl_products(product_id);


--
-- Name: tbl_sales_order_items fk_sales_order_items_sales_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_order_items
    ADD CONSTRAINT fk_sales_order_items_sales_order_id_fkey FOREIGN KEY (sales_order_id) REFERENCES public.tbl_sales_orders(sales_order_id);


--
-- Name: tbl_sales_orders fk_sales_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_orders
    ADD CONSTRAINT fk_sales_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.tbl_employees(employee_id);


--
-- Name: tbl_sales_orders fk_sales_orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbl_sales_orders
    ADD CONSTRAINT fk_sales_orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.tbl_customers(customer_id);


--
-- PostgreSQL database dump complete
--

\unrestrict J3qneJeC3x9djG82DzplJFd70sCNtZl5Hqh1AZFiZrFMzjz40ywQDBKNdLv0lmI

