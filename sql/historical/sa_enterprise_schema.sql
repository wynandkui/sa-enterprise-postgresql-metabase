--
-- PostgreSQL database dump
--

\restrict hmNPVXpRGWueobZWndRwboSn79AOBFZfuKkk87yR88TSV3uyUfUUq4th9IyUJaL

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
-- Name: assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets (
    asset_id bigint NOT NULL,
    asset_code character varying(40) NOT NULL,
    asset_name character varying(200) NOT NULL,
    asset_type character varying(100) NOT NULL,
    location character varying(150) NOT NULL,
    department_id bigint,
    purchase_date date,
    purchase_value numeric(14,2),
    status character varying(30) DEFAULT 'Operational'::character varying NOT NULL,
    CONSTRAINT assets_purchase_value_check CHECK ((purchase_value >= (0)::numeric)),
    CONSTRAINT assets_status_check CHECK (((status)::text = ANY ((ARRAY['Operational'::character varying, 'Under Maintenance'::character varying, 'Out of Service'::character varying, 'Decommissioned'::character varying])::text[])))
);


--
-- Name: assets_asset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.assets ALTER COLUMN asset_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.assets_asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    customer_id bigint NOT NULL,
    customer_name character varying(200) NOT NULL,
    customer_type character varying(30) NOT NULL,
    city character varying(100) NOT NULL,
    province character varying(100) NOT NULL,
    email character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT customers_customer_type_check CHECK (((customer_type)::text = ANY ((ARRAY['Individual'::character varying, 'Business'::character varying])::text[])))
);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.customers ALTER COLUMN customer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.customers_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    department_id bigint NOT NULL,
    department_name character varying(100) NOT NULL,
    cost_centre character varying(20) NOT NULL
);


--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.departments ALTER COLUMN department_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.departments_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    employee_id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    job_title character varying(150) NOT NULL,
    department_id bigint NOT NULL,
    hire_date date NOT NULL,
    monthly_salary numeric(12,2) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    CONSTRAINT employees_monthly_salary_check CHECK ((monthly_salary >= (0)::numeric))
);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.employees ALTER COLUMN employee_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.employees_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_items (
    invoice_item_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    product_id bigint NOT NULL,
    description character varying(250) NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0 NOT NULL,
    line_total numeric(14,2) GENERATED ALWAYS AS (round((((quantity)::numeric * unit_price) * ((1)::numeric - (discount_percent / (100)::numeric))), 2)) STORED,
    CONSTRAINT invoice_items_discount_percent_check CHECK (((discount_percent >= (0)::numeric) AND (discount_percent <= (100)::numeric))),
    CONSTRAINT invoice_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT invoice_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: invoice_items_invoice_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.invoice_items ALTER COLUMN invoice_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invoice_items_invoice_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
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
    CONSTRAINT invoices_check CHECK ((due_date >= invoice_date)),
    CONSTRAINT invoices_check1 CHECK ((total_amount = (subtotal + vat_amount))),
    CONSTRAINT invoices_status_check CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Issued'::character varying, 'Partially Paid'::character varying, 'Paid'::character varying, 'Overdue'::character varying, 'Cancelled'::character varying])::text[]))),
    CONSTRAINT invoices_subtotal_check CHECK ((subtotal >= (0)::numeric)),
    CONSTRAINT invoices_total_amount_check CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT invoices_vat_amount_check CHECK ((vat_amount >= (0)::numeric)),
    CONSTRAINT invoices_vat_rate_check CHECK (((vat_rate >= (0)::numeric) AND (vat_rate <= (1)::numeric)))
);


--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.invoices ALTER COLUMN invoice_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.invoices_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    payment_reference character varying(50) NOT NULL,
    payment_date date NOT NULL,
    amount numeric(14,2) NOT NULL,
    payment_method character varying(30) NOT NULL,
    CONSTRAINT payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payments_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['EFT'::character varying, 'Card'::character varying, 'Cash'::character varying, 'Bank Deposit'::character varying])::text[])))
);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.payments ALTER COLUMN payment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    product_id bigint NOT NULL,
    sku character varying(40) NOT NULL,
    product_name character varying(200) NOT NULL,
    category character varying(100) NOT NULL,
    supplier_id bigint,
    unit_cost numeric(12,2) NOT NULL,
    selling_price numeric(12,2) NOT NULL,
    quantity_on_hand integer DEFAULT 0 NOT NULL,
    reorder_level integer DEFAULT 10 NOT NULL,
    CONSTRAINT products_quantity_on_hand_check CHECK ((quantity_on_hand >= 0)),
    CONSTRAINT products_reorder_level_check CHECK ((reorder_level >= 0)),
    CONSTRAINT products_selling_price_check CHECK ((selling_price >= (0)::numeric)),
    CONSTRAINT products_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);


--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.products ALTER COLUMN product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sales_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_order_items (
    sales_order_item_id bigint NOT NULL,
    sales_order_id bigint NOT NULL,
    product_id bigint NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0 NOT NULL,
    CONSTRAINT sales_order_items_discount_percent_check CHECK (((discount_percent >= (0)::numeric) AND (discount_percent <= (100)::numeric))),
    CONSTRAINT sales_order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT sales_order_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: sales_order_items_sales_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sales_order_items ALTER COLUMN sales_order_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sales_order_items_sales_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sales_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_orders (
    sales_order_id bigint NOT NULL,
    order_number character varying(30) NOT NULL,
    customer_id bigint NOT NULL,
    order_date date NOT NULL,
    required_date date,
    status character varying(30) NOT NULL,
    created_by bigint,
    notes text,
    CONSTRAINT sales_orders_status_check CHECK (((status)::text = ANY ((ARRAY['Draft'::character varying, 'Confirmed'::character varying, 'Processing'::character varying, 'Dispatched'::character varying, 'Completed'::character varying, 'Cancelled'::character varying])::text[])))
);


--
-- Name: sales_orders_sales_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sales_orders ALTER COLUMN sales_order_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sales_orders_sales_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    supplier_id bigint NOT NULL,
    supplier_name character varying(200) NOT NULL,
    city character varying(100) NOT NULL,
    province character varying(100) NOT NULL,
    contact_email character varying(255),
    active boolean DEFAULT true NOT NULL
);


--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.suppliers ALTER COLUMN supplier_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.suppliers_supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_customer_balances; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_customer_balances AS
 WITH payment_totals AS (
         SELECT payments.invoice_id,
            sum(payments.amount) AS amount_paid
           FROM public.payments
          GROUP BY payments.invoice_id
        )
 SELECT c.customer_id,
    c.customer_name,
    c.city,
    c.province,
    count(i.invoice_id) AS invoice_count,
    sum(i.total_amount) AS total_invoiced,
    sum(COALESCE(pt.amount_paid, (0)::numeric)) AS total_paid,
    sum((i.total_amount - COALESCE(pt.amount_paid, (0)::numeric))) AS outstanding_balance
   FROM (((public.customers c
     JOIN public.sales_orders so ON ((so.customer_id = c.customer_id)))
     JOIN public.invoices i ON ((i.sales_order_id = so.sales_order_id)))
     LEFT JOIN payment_totals pt ON ((pt.invoice_id = i.invoice_id)))
  WHERE ((i.status)::text <> 'Cancelled'::text)
  GROUP BY c.customer_id, c.customer_name, c.city, c.province;


--
-- Name: vw_monthly_sales; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_monthly_sales AS
 SELECT (date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date AS sales_month,
    count(*) AS invoice_count,
    sum(subtotal) AS sales_excl_vat,
    sum(vat_amount) AS output_vat,
    sum(total_amount) AS sales_incl_vat
   FROM public.invoices
  WHERE ((status)::text <> 'Cancelled'::text)
  GROUP BY ((date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date);


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
   FROM ((public.products p
     JOIN public.invoice_items ii ON ((ii.product_id = p.product_id)))
     JOIN public.invoices i ON ((i.invoice_id = ii.invoice_id)))
  WHERE ((i.status)::text <> 'Cancelled'::text)
  GROUP BY p.product_id, p.sku, p.product_name, p.category;


--
-- Name: vw_vat_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_vat_summary AS
 SELECT (date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date AS vat_month,
    count(*) AS invoice_count,
    sum(subtotal) AS taxable_sales,
    sum(vat_amount) AS output_vat
   FROM public.invoices
  WHERE ((status)::text <> 'Cancelled'::text)
  GROUP BY ((date_trunc('month'::text, (invoice_date)::timestamp with time zone))::date);


--
-- Name: assets assets_asset_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_asset_code_key UNIQUE (asset_code);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (asset_id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: departments departments_cost_centre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_cost_centre_key UNIQUE (cost_centre);


--
-- Name: departments departments_department_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_department_name_key UNIQUE (department_name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (invoice_item_id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (invoice_id);


--
-- Name: invoices invoices_sales_order_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_sales_order_id_key UNIQUE (sales_order_id);


--
-- Name: payments payments_payment_reference_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_reference_key UNIQUE (payment_reference);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: sales_order_items sales_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_pkey PRIMARY KEY (sales_order_item_id);


--
-- Name: sales_order_items sales_order_items_sales_order_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_sales_order_id_product_id_key UNIQUE (sales_order_id, product_id);


--
-- Name: sales_orders sales_orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_order_number_key UNIQUE (order_number);


--
-- Name: sales_orders sales_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_pkey PRIMARY KEY (sales_order_id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- Name: assets assets_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: employees employees_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id);


--
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id);


--
-- Name: invoice_items invoice_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: invoices invoices_sales_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_sales_order_id_fkey FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(sales_order_id);


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id);


--
-- Name: products products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);


--
-- Name: sales_order_items sales_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id);


--
-- Name: sales_order_items sales_order_items_sales_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_sales_order_id_fkey FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(sales_order_id);


--
-- Name: sales_orders sales_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.employees(employee_id);


--
-- Name: sales_orders sales_orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- PostgreSQL database dump complete
--

\unrestrict hmNPVXpRGWueobZWndRwboSn79AOBFZfuKkk87yR88TSV3uyUfUUq4th9IyUJaL

