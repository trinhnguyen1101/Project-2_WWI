CREATE SCHEMA IF NOT EXISTS staging;

-- Staging tables for the current DWH scope.
-- Keep source identifiers and relationship columns so ETL can validate joins
-- before loading surrogate keys into the DWH layer.
-- Archive tables and out-of-scope operational tables are intentionally omitted.

CREATE TABLE IF NOT EXISTS staging.stg_application_countries (
    country_id integer PRIMARY KEY,
    country_name varchar(60) NOT NULL,
    formal_name varchar(60) NOT NULL,
    iso_alpha3_code varchar(3),
    iso_numeric_code integer,
    country_type varchar(20),
    latest_recorded_population bigint,
    continent varchar(30) NOT NULL,
    region varchar(30) NOT NULL,
    subregion varchar(30) NOT NULL,
    border text,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_application_state_provinces (
    state_province_id integer PRIMARY KEY,
    state_province_code varchar(5) NOT NULL,
    state_province_name varchar(50) NOT NULL,
    country_id integer NOT NULL,
    sales_territory varchar(50) NOT NULL,
    border text,
    latest_recorded_population bigint,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_application_cities (
    city_id integer PRIMARY KEY,
    city_name varchar(50) NOT NULL,
    state_province_id integer NOT NULL,
    location text,
    latest_recorded_population bigint,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_application_delivery_methods (
    delivery_method_id integer PRIMARY KEY,
    delivery_method_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_application_payment_methods (
    payment_method_id integer PRIMARY KEY,
    payment_method_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_application_transaction_types (
    transaction_type_id integer PRIMARY KEY,
    transaction_type_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_application_people (
    person_id integer PRIMARY KEY,
    full_name varchar(50) NOT NULL,
    preferred_name varchar(50) NOT NULL,
    search_name varchar(101) NOT NULL,
    is_permitted_to_logon boolean,
    logon_name varchar(50),
    is_external_logon_provider boolean,
    hashed_password bytea,
    is_system_user boolean,
    is_employee boolean,
    is_salesperson boolean,
    user_preferences text,
    phone_number varchar(20),
    fax_number varchar(20),
    email_address varchar(256),
    photo bytea,
    custom_fields text,
    other_languages text,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_customer_categories (
    customer_category_id integer PRIMARY KEY,
    customer_category_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_buying_groups (
    buying_group_id integer PRIMARY KEY,
    buying_group_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_customers (
    customer_id integer PRIMARY KEY,
    customer_name varchar(100) NOT NULL,
    bill_to_customer_id integer NOT NULL,
    customer_category_id integer NOT NULL,
    buying_group_id integer,
    primary_contact_person_id integer NOT NULL,
    alternate_contact_person_id integer,
    delivery_method_id integer NOT NULL,
    delivery_city_id integer NOT NULL,
    postal_city_id integer NOT NULL,
    credit_limit numeric(18, 2),
    account_opened_date date NOT NULL,
    standard_discount_percentage numeric(18, 3) NOT NULL,
    is_statement_sent boolean NOT NULL,
    is_on_credit_hold boolean NOT NULL,
    payment_days integer NOT NULL,
    phone_number varchar(20) NOT NULL,
    fax_number varchar(20) NOT NULL,
    delivery_run varchar(5),
    run_position varchar(5),
    website_url varchar(256) NOT NULL,
    delivery_address_line1 varchar(60) NOT NULL,
    delivery_address_line2 varchar(60),
    delivery_postal_code varchar(10) NOT NULL,
    delivery_location text,
    postal_address_line1 varchar(60) NOT NULL,
    postal_address_line2 varchar(60),
    postal_postal_code varchar(10) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_invoices (
    invoice_id integer PRIMARY KEY,
    customer_id integer NOT NULL,
    bill_to_customer_id integer NOT NULL,
    order_id integer,
    delivery_method_id integer NOT NULL,
    contact_person_id integer NOT NULL,
    accounts_person_id integer NOT NULL,
    salesperson_person_id integer NOT NULL,
    packed_by_person_id integer NOT NULL,
    invoice_date date NOT NULL,
    customer_purchase_order_number varchar(20),
    is_credit_note boolean NOT NULL,
    credit_note_reason text,
    comments text,
    delivery_instructions text,
    internal_comments text,
    total_dry_items integer NOT NULL,
    total_chiller_items integer NOT NULL,
    delivery_run varchar(5),
    run_position varchar(5),
    returned_delivery_data text,
    confirmed_delivery_time timestamp(6),
    confirmed_received_by text,
    last_edited_by integer,
    last_edited_when timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_invoice_lines (
    invoice_line_id integer PRIMARY KEY,
    invoice_id integer NOT NULL,
    stock_item_id integer NOT NULL,
    description varchar(100) NOT NULL,
    package_type_id integer NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(18, 2),
    tax_rate numeric(18, 3) NOT NULL,
    tax_amount numeric(18, 2) NOT NULL,
    line_profit numeric(18, 2) NOT NULL,
    extended_price numeric(18, 2) NOT NULL,
    last_edited_by integer,
    last_edited_when timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_orders (
    order_id integer PRIMARY KEY,
    customer_id integer NOT NULL,
    salesperson_person_id integer NOT NULL,
    picked_by_person_id integer,
    contact_person_id integer NOT NULL,
    backorder_order_id integer,
    order_date date NOT NULL,
    expected_delivery_date date NOT NULL,
    customer_purchase_order_number varchar(20),
    is_undersupply_backordered boolean NOT NULL,
    comments text,
    delivery_instructions text,
    internal_comments text,
    picking_completed_when timestamp(6),
    last_edited_by integer,
    last_edited_when timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_order_lines (
    order_line_id integer PRIMARY KEY,
    order_id integer NOT NULL,
    stock_item_id integer NOT NULL,
    description varchar(100) NOT NULL,
    package_type_id integer NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(18, 2),
    tax_rate numeric(18, 3) NOT NULL,
    picked_quantity integer NOT NULL,
    picking_completed_when timestamp(6),
    last_edited_by integer,
    last_edited_when timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_sales_customer_transactions (
    customer_transaction_id integer PRIMARY KEY,
    customer_id integer NOT NULL,
    transaction_type_id integer NOT NULL,
    invoice_id integer,
    payment_method_id integer,
    transaction_date date NOT NULL,
    amount_excluding_tax numeric(18, 2) NOT NULL,
    tax_amount numeric(18, 2) NOT NULL,
    transaction_amount numeric(18, 2) NOT NULL,
    outstanding_balance numeric(18, 2) NOT NULL,
    finalization_date date,
    is_finalized boolean,
    last_edited_by integer,
    last_edited_when timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_purchasing_supplier_categories (
    supplier_category_id integer PRIMARY KEY,
    supplier_category_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_purchasing_suppliers (
    supplier_id integer PRIMARY KEY,
    supplier_name varchar(100) NOT NULL,
    supplier_category_id integer NOT NULL,
    primary_contact_person_id integer NOT NULL,
    alternate_contact_person_id integer NOT NULL,
    delivery_method_id integer,
    delivery_city_id integer NOT NULL,
    postal_city_id integer NOT NULL,
    supplier_reference varchar(20),
    bank_account_name varchar(50),
    bank_account_branch varchar(50),
    bank_account_code varchar(20),
    bank_account_number varchar(20),
    bank_international_code varchar(20),
    payment_days integer NOT NULL,
    internal_comments text,
    phone_number varchar(20) NOT NULL,
    fax_number varchar(20) NOT NULL,
    website_url varchar(256) NOT NULL,
    delivery_address_line1 varchar(60) NOT NULL,
    delivery_address_line2 varchar(60),
    delivery_postal_code varchar(10) NOT NULL,
    delivery_location text,
    postal_address_line1 varchar(60) NOT NULL,
    postal_address_line2 varchar(60),
    postal_postal_code varchar(10) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_warehouse_colors (
    color_id integer PRIMARY KEY,
    color_name varchar(20) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_warehouse_package_types (
    package_type_id integer PRIMARY KEY,
    package_type_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_warehouse_stock_groups (
    stock_group_id integer PRIMARY KEY,
    stock_group_name varchar(50) NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_warehouse_stock_items (
    stock_item_id integer PRIMARY KEY,
    stock_item_name varchar(100) NOT NULL,
    supplier_id integer NOT NULL,
    color_id integer,
    unit_package_id integer NOT NULL,
    outer_package_id integer NOT NULL,
    brand varchar(50),
    size varchar(20),
    lead_time_days integer NOT NULL,
    quantity_per_outer integer NOT NULL,
    is_chiller_stock boolean NOT NULL,
    barcode varchar(50),
    tax_rate numeric(18, 3) NOT NULL,
    unit_price numeric(18, 2) NOT NULL,
    recommended_retail_price numeric(18, 2),
    typical_weight_per_unit numeric(18, 3) NOT NULL,
    marketing_comments text,
    internal_comments text,
    photo bytea,
    custom_fields text,
    tags text,
    search_details text NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.stg_warehouse_stock_item_stock_groups (
    stock_item_stock_group_id integer PRIMARY KEY,
    stock_item_id integer NOT NULL,
    stock_group_id integer NOT NULL,
    last_edited_by integer,
    valid_from timestamp(6),
    valid_to timestamp(6),
    source_file_name text,
    loaded_at timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Relationship-support indexes for validation and DWH loading.

CREATE INDEX IF NOT EXISTS idx_stg_state_provinces_country
    ON staging.stg_application_state_provinces(country_id);
CREATE INDEX IF NOT EXISTS idx_stg_cities_state_province
    ON staging.stg_application_cities(state_province_id);

CREATE INDEX IF NOT EXISTS idx_stg_customers_category
    ON staging.stg_sales_customers(customer_category_id);
CREATE INDEX IF NOT EXISTS idx_stg_customers_buying_group
    ON staging.stg_sales_customers(buying_group_id);
CREATE INDEX IF NOT EXISTS idx_stg_customers_delivery_method
    ON staging.stg_sales_customers(delivery_method_id);
CREATE INDEX IF NOT EXISTS idx_stg_customers_delivery_city
    ON staging.stg_sales_customers(delivery_city_id);
CREATE INDEX IF NOT EXISTS idx_stg_customers_postal_city
    ON staging.stg_sales_customers(postal_city_id);
CREATE INDEX IF NOT EXISTS idx_stg_customers_bill_to_customer
    ON staging.stg_sales_customers(bill_to_customer_id);

CREATE INDEX IF NOT EXISTS idx_stg_invoices_customer
    ON staging.stg_sales_invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_stg_invoices_bill_to_customer
    ON staging.stg_sales_invoices(bill_to_customer_id);
CREATE INDEX IF NOT EXISTS idx_stg_invoices_order
    ON staging.stg_sales_invoices(order_id);
CREATE INDEX IF NOT EXISTS idx_stg_invoices_invoice_date
    ON staging.stg_sales_invoices(invoice_date);
CREATE INDEX IF NOT EXISTS idx_stg_invoices_salesperson
    ON staging.stg_sales_invoices(salesperson_person_id);

CREATE INDEX IF NOT EXISTS idx_stg_invoice_lines_invoice
    ON staging.stg_sales_invoice_lines(invoice_id);
CREATE INDEX IF NOT EXISTS idx_stg_invoice_lines_stock_item
    ON staging.stg_sales_invoice_lines(stock_item_id);
CREATE INDEX IF NOT EXISTS idx_stg_invoice_lines_package_type
    ON staging.stg_sales_invoice_lines(package_type_id);

CREATE INDEX IF NOT EXISTS idx_stg_orders_customer
    ON staging.stg_sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_stg_orders_order_date
    ON staging.stg_sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_stg_orders_salesperson
    ON staging.stg_sales_orders(salesperson_person_id);
CREATE INDEX IF NOT EXISTS idx_stg_orders_picker
    ON staging.stg_sales_orders(picked_by_person_id);

CREATE INDEX IF NOT EXISTS idx_stg_order_lines_order
    ON staging.stg_sales_order_lines(order_id);
CREATE INDEX IF NOT EXISTS idx_stg_order_lines_stock_item
    ON staging.stg_sales_order_lines(stock_item_id);
CREATE INDEX IF NOT EXISTS idx_stg_order_lines_package_type
    ON staging.stg_sales_order_lines(package_type_id);

CREATE INDEX IF NOT EXISTS idx_stg_customer_transactions_customer
    ON staging.stg_sales_customer_transactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_stg_customer_transactions_invoice
    ON staging.stg_sales_customer_transactions(invoice_id);
CREATE INDEX IF NOT EXISTS idx_stg_customer_transactions_payment_method
    ON staging.stg_sales_customer_transactions(payment_method_id);
CREATE INDEX IF NOT EXISTS idx_stg_customer_transactions_transaction_type
    ON staging.stg_sales_customer_transactions(transaction_type_id);
CREATE INDEX IF NOT EXISTS idx_stg_customer_transactions_transaction_date
    ON staging.stg_sales_customer_transactions(transaction_date);

CREATE INDEX IF NOT EXISTS idx_stg_suppliers_category
    ON staging.stg_purchasing_suppliers(supplier_category_id);
CREATE INDEX IF NOT EXISTS idx_stg_suppliers_delivery_method
    ON staging.stg_purchasing_suppliers(delivery_method_id);
CREATE INDEX IF NOT EXISTS idx_stg_suppliers_delivery_city
    ON staging.stg_purchasing_suppliers(delivery_city_id);
CREATE INDEX IF NOT EXISTS idx_stg_suppliers_postal_city
    ON staging.stg_purchasing_suppliers(postal_city_id);

CREATE INDEX IF NOT EXISTS idx_stg_stock_items_supplier
    ON staging.stg_warehouse_stock_items(supplier_id);
CREATE INDEX IF NOT EXISTS idx_stg_stock_items_color
    ON staging.stg_warehouse_stock_items(color_id);
CREATE INDEX IF NOT EXISTS idx_stg_stock_items_unit_package
    ON staging.stg_warehouse_stock_items(unit_package_id);
CREATE INDEX IF NOT EXISTS idx_stg_stock_items_outer_package
    ON staging.stg_warehouse_stock_items(outer_package_id);

CREATE INDEX IF NOT EXISTS idx_stg_stock_item_stock_groups_stock_item
    ON staging.stg_warehouse_stock_item_stock_groups(stock_item_id);
CREATE INDEX IF NOT EXISTS idx_stg_stock_item_stock_groups_stock_group
    ON staging.stg_warehouse_stock_item_stock_groups(stock_group_id);
