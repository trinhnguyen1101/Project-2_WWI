CREATE SCHEMA IF NOT EXISTS dwh;

-- Scope:
-- Sales and profitability analysis, with two supporting processes:
-- order fulfillment and customer payment quality.
--
-- Design principle:
-- Dimensions keep descriptive/static attributes.
-- Facts keep keys, source transaction identifiers, and analytical measures/flags.
-- SCD handling is intentionally left to the ETL phase.

CREATE TABLE IF NOT EXISTS dwh.dim_date (
    date_key integer PRIMARY KEY,                 -- yyyymmdd
    full_date date NOT NULL UNIQUE,
    day_of_month smallint NOT NULL,
    month_number smallint NOT NULL,
    month_name varchar(20) NOT NULL,
    quarter_number smallint NOT NULL,
    year_number smallint NOT NULL,
    day_of_week_number smallint NOT NULL,
    day_of_week_name varchar(20) NOT NULL,
    is_weekend boolean NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_country (
    country_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_country_id integer NOT NULL UNIQUE,
    country_name varchar(60) NOT NULL,
    formal_name varchar(60),
    iso_alpha3_code varchar(3),
    iso_numeric_code integer,
    country_type varchar(20),
    continent varchar(30),
    region varchar(30),
    subregion varchar(30),
    latest_recorded_population bigint
);

CREATE TABLE IF NOT EXISTS dwh.dim_state_province (
    state_province_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_state_province_id integer NOT NULL UNIQUE,
    country_key bigint REFERENCES dwh.dim_country(country_key),
    state_province_code varchar(5),
    state_province_name varchar(50) NOT NULL,
    sales_territory varchar(50),
    latest_recorded_population bigint
);

CREATE TABLE IF NOT EXISTS dwh.dim_city (
    city_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_city_id integer NOT NULL UNIQUE,
    state_province_key bigint REFERENCES dwh.dim_state_province(state_province_key),
    city_name varchar(50) NOT NULL,
    latest_recorded_population bigint
);

CREATE TABLE IF NOT EXISTS dwh.dim_customer_category (
    customer_category_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_customer_category_id integer NOT NULL UNIQUE,
    customer_category_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_buying_group (
    buying_group_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_buying_group_id integer NOT NULL UNIQUE,
    buying_group_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_delivery_method (
    delivery_method_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_delivery_method_id integer NOT NULL UNIQUE,
    delivery_method_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_payment_method (
    payment_method_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_payment_method_id integer NOT NULL UNIQUE,
    payment_method_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_transaction_type (
    transaction_type_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_transaction_type_id integer NOT NULL UNIQUE,
    transaction_type_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_package_type (
    package_type_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_package_type_id integer NOT NULL UNIQUE,
    package_type_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_stock_group (
    stock_group_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_stock_group_id integer NOT NULL UNIQUE,
    stock_group_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_person (
    person_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_person_id integer NOT NULL UNIQUE,
    full_name varchar(50) NOT NULL,
    preferred_name varchar(50),
    is_employee boolean,
    is_salesperson boolean,
    email_address varchar(256)
);

CREATE TABLE IF NOT EXISTS dwh.dim_supplier (
    supplier_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_supplier_id integer NOT NULL UNIQUE,
    supplier_name varchar(100) NOT NULL,
    supplier_category_name varchar(50),
    delivery_city_key bigint REFERENCES dwh.dim_city(city_key),
    postal_city_key bigint REFERENCES dwh.dim_city(city_key),
    delivery_method_key bigint REFERENCES dwh.dim_delivery_method(delivery_method_key),
    payment_days integer,
    phone_number varchar(20),
    website_url varchar(256)
);

CREATE TABLE IF NOT EXISTS dwh.dim_customer (
    customer_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_customer_id integer NOT NULL UNIQUE,
    customer_name varchar(100) NOT NULL,
    customer_category_key bigint REFERENCES dwh.dim_customer_category(customer_category_key),
    buying_group_key bigint REFERENCES dwh.dim_buying_group(buying_group_key),
    delivery_method_key bigint REFERENCES dwh.dim_delivery_method(delivery_method_key),
    delivery_city_key bigint REFERENCES dwh.dim_city(city_key),
    postal_city_key bigint REFERENCES dwh.dim_city(city_key),
    credit_limit numeric(18, 2),
    account_opened_date date,
    standard_discount_percentage numeric(18, 3),
    is_statement_sent boolean,
    is_on_credit_hold boolean,
    payment_days integer,
    phone_number varchar(20),
    website_url varchar(256)
);

CREATE TABLE IF NOT EXISTS dwh.dim_product (
    product_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_stock_item_id integer NOT NULL UNIQUE,
    stock_item_name varchar(100) NOT NULL,
    supplier_key bigint REFERENCES dwh.dim_supplier(supplier_key),
    color_name varchar(20),
    unit_package_type_key bigint REFERENCES dwh.dim_package_type(package_type_key),
    outer_package_type_key bigint REFERENCES dwh.dim_package_type(package_type_key),
    brand varchar(50),
    size varchar(20),
    lead_time_days integer,
    quantity_per_outer integer,
    is_chiller_stock boolean,
    tax_rate numeric(18, 3),
    current_unit_price numeric(18, 2),
    recommended_retail_price numeric(18, 2),
    typical_weight_per_unit numeric(18, 3),
    country_of_manufacture varchar(100),
    tags text
);

CREATE TABLE IF NOT EXISTS dwh.bridge_product_stock_group (
    product_key bigint NOT NULL REFERENCES dwh.dim_product(product_key),
    stock_group_key bigint NOT NULL REFERENCES dwh.dim_stock_group(stock_group_key),
    PRIMARY KEY (product_key, stock_group_key)
);

CREATE TABLE IF NOT EXISTS dwh.fact_sales_invoice_line (
    sales_invoice_line_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_invoice_line_id integer NOT NULL UNIQUE,
    source_invoice_id integer NOT NULL,
    invoice_date_key integer NOT NULL REFERENCES dwh.dim_date(date_key),
    customer_key bigint NOT NULL REFERENCES dwh.dim_customer(customer_key),
    bill_to_customer_key bigint REFERENCES dwh.dim_customer(customer_key),
    product_key bigint NOT NULL REFERENCES dwh.dim_product(product_key),
    package_type_key bigint REFERENCES dwh.dim_package_type(package_type_key),
    salesperson_key bigint REFERENCES dwh.dim_person(person_key),

    quantity_sold numeric(18, 3) NOT NULL,
    revenue_ex_tax numeric(18, 2) NOT NULL,
    tax_amount numeric(18, 2) NOT NULL,
    revenue_inc_tax numeric(18, 2) NOT NULL,
    gross_profit numeric(18, 2) NOT NULL,
    estimated_cogs numeric(18, 2) NOT NULL,
    gross_margin_pct numeric(18, 6),
    average_selling_price_ex_tax numeric(18, 6),
    profit_per_unit numeric(18, 6),

    CONSTRAINT ck_fact_sales_invoice_line_quantity
        CHECK (quantity_sold >= 0),
    CONSTRAINT ck_fact_sales_invoice_line_margin
        CHECK (gross_margin_pct IS NULL OR gross_margin_pct BETWEEN -10 AND 10)
);

CREATE TABLE IF NOT EXISTS dwh.fact_order_fulfillment_line (
    order_fulfillment_line_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_order_line_id integer NOT NULL UNIQUE,
    source_order_id integer NOT NULL,
    order_date_key integer NOT NULL REFERENCES dwh.dim_date(date_key),
    expected_delivery_date_key integer REFERENCES dwh.dim_date(date_key),
    picking_completed_date_key integer REFERENCES dwh.dim_date(date_key),
    customer_key bigint NOT NULL REFERENCES dwh.dim_customer(customer_key),
    product_key bigint NOT NULL REFERENCES dwh.dim_product(product_key),
    package_type_key bigint REFERENCES dwh.dim_package_type(package_type_key),
    salesperson_key bigint REFERENCES dwh.dim_person(person_key),
    picker_key bigint REFERENCES dwh.dim_person(person_key),

    ordered_quantity numeric(18, 3) NOT NULL,
    picked_quantity numeric(18, 3) NOT NULL,
    unpicked_quantity numeric(18, 3) NOT NULL,
    fill_rate numeric(18, 6),
    picking_lead_time_hours numeric(18, 6),
    expected_delivery_lead_days integer,
    is_undersupply_backordered boolean,
    is_fully_picked boolean,

    CONSTRAINT ck_fact_order_fulfillment_line_quantities
        CHECK (ordered_quantity >= 0 AND picked_quantity >= 0 AND unpicked_quantity >= 0),
    CONSTRAINT ck_fact_order_fulfillment_line_fill_rate
        CHECK (fill_rate IS NULL OR fill_rate BETWEEN 0 AND 1)
);

CREATE TABLE IF NOT EXISTS dwh.fact_customer_transaction (
    customer_transaction_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_customer_transaction_id integer NOT NULL UNIQUE,
    source_invoice_id integer,
    transaction_date_key integer NOT NULL REFERENCES dwh.dim_date(date_key),
    finalization_date_key integer REFERENCES dwh.dim_date(date_key),
    due_date_key integer REFERENCES dwh.dim_date(date_key),
    customer_key bigint NOT NULL REFERENCES dwh.dim_customer(customer_key),
    payment_method_key bigint REFERENCES dwh.dim_payment_method(payment_method_key),
    transaction_type_key bigint REFERENCES dwh.dim_transaction_type(transaction_type_key),

    receivable_ex_tax numeric(18, 2) NOT NULL,
    receivable_tax_amount numeric(18, 2) NOT NULL,
    receivable_inc_tax numeric(18, 2) NOT NULL,
    outstanding_amount numeric(18, 2) NOT NULL,
    paid_amount numeric(18, 2) NOT NULL,
    outstanding_ratio numeric(18, 6),
    days_to_collect integer,
    collection_age_days integer,
    days_past_due integer,
    current_ar_amount numeric(18, 2) NOT NULL,
    past_due_amount numeric(18, 2) NOT NULL,
    is_finalized boolean NOT NULL,
    is_overdue boolean,

    CONSTRAINT ck_fact_customer_transaction_ratio
        CHECK (outstanding_ratio IS NULL OR outstanding_ratio BETWEEN -10 AND 10)
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_invoice_line_date
    ON dwh.fact_sales_invoice_line(invoice_date_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_invoice_line_customer
    ON dwh.fact_sales_invoice_line(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_sales_invoice_line_product
    ON dwh.fact_sales_invoice_line(product_key);

CREATE INDEX IF NOT EXISTS idx_fact_order_fulfillment_line_date
    ON dwh.fact_order_fulfillment_line(order_date_key);
CREATE INDEX IF NOT EXISTS idx_fact_order_fulfillment_line_customer
    ON dwh.fact_order_fulfillment_line(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_order_fulfillment_line_product
    ON dwh.fact_order_fulfillment_line(product_key);

CREATE INDEX IF NOT EXISTS idx_fact_customer_transaction_date
    ON dwh.fact_customer_transaction(transaction_date_key);
CREATE INDEX IF NOT EXISTS idx_fact_customer_transaction_customer
    ON dwh.fact_customer_transaction(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_customer_transaction_due_date
    ON dwh.fact_customer_transaction(due_date_key);

CREATE TABLE IF NOT EXISTS dwh.fact_business_kpi_month (
    period_date_key integer PRIMARY KEY REFERENCES dwh.dim_date(date_key),

    revenue_ex_tax numeric(18, 2),
    revenue_inc_tax numeric(18, 2),
    gross_profit numeric(18, 2),
    estimated_cogs numeric(18, 2),
    quantity_sold numeric(18, 3),
    invoice_count integer,
    gross_margin_pct numeric(18, 6),
    average_selling_price_ex_tax numeric(18, 6),
    profit_per_unit numeric(18, 6),
    average_order_value numeric(18, 6),
    sales_growth_rate numeric(18, 6),

    receivable_inc_tax numeric(18, 2),
    outstanding_amount numeric(18, 2),
    paid_amount numeric(18, 2),
    current_ar_amount numeric(18, 2),
    past_due_amount numeric(18, 2),
    receivable_outstanding_ratio numeric(18, 6),
    current_ar_ratio numeric(18, 6),
    average_days_to_collect numeric(18, 6),
    average_collection_age_days numeric(18, 6),
    average_days_past_due numeric(18, 6),
    overdue_transaction_rate numeric(18, 6)
);

CREATE TABLE IF NOT EXISTS dwh.fact_customer_kpi_month (
    customer_key bigint NOT NULL REFERENCES dwh.dim_customer(customer_key),
    period_date_key integer NOT NULL REFERENCES dwh.dim_date(date_key),

    revenue_ex_tax numeric(18, 2),
    revenue_inc_tax numeric(18, 2),
    gross_profit numeric(18, 2),
    estimated_cogs numeric(18, 2),
    quantity_sold numeric(18, 3),
    invoice_count integer,
    gross_margin_pct numeric(18, 6),
    average_selling_price_ex_tax numeric(18, 6),
    profit_per_unit numeric(18, 6),
    average_order_value numeric(18, 6),
    sales_growth_rate numeric(18, 6),

    receivable_inc_tax numeric(18, 2),
    outstanding_amount numeric(18, 2),
    paid_amount numeric(18, 2),
    current_ar_amount numeric(18, 2),
    past_due_amount numeric(18, 2),
    receivable_outstanding_ratio numeric(18, 6),
    current_ar_ratio numeric(18, 6),
    average_days_to_collect numeric(18, 6),
    average_collection_age_days numeric(18, 6),
    average_days_past_due numeric(18, 6),
    overdue_transaction_rate numeric(18, 6),

    PRIMARY KEY (customer_key, period_date_key)
);

CREATE INDEX IF NOT EXISTS idx_fact_customer_kpi_month_period
    ON dwh.fact_customer_kpi_month(period_date_key);
