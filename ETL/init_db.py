import os
import sys
from pathlib import Path

try:
    import psycopg2
except ImportError:
    print("Please install psycopg2-binary")
    sys.exit(1)

def main():
    host = os.environ.get("PGHOST", "postgres")
    port = os.environ.get("PGPORT", "5432")
    dbname = os.environ.get("PGDATABASE", "Staging")
    user = os.environ.get("PGUSER", "postgres")
    password = os.environ.get("PGPASSWORD", "1101")

    conn = psycopg2.connect(host=host, port=port, dbname=dbname, user=user, password=password)
    conn.autocommit = True
    cur = conn.cursor()

    # 1. Load DWH Schema
    dwh_schema_path = Path("sql/DWH/dwh_design.sql")
    if dwh_schema_path.exists():
        print("Running dwh_design.sql...")
        cur.execute(dwh_schema_path.read_text(encoding="utf-8"))

    # 2. Insert Unknown Dimension rows
    unknown_dims_sql = """
    -- dim_date doesn't use IDENTITY, we can insert directly
    INSERT INTO dwh.dim_date (date_key, full_date, day_of_month, month_number, month_name, quarter_number, year_number, day_of_week_number, day_of_week_name, is_weekend)
    VALUES (0, '1900-01-01', 1, 1, 'Unknown', 1, 1900, 1, 'Unknown', false)
    ON CONFLICT (date_key) DO NOTHING;

    INSERT INTO dwh.dim_country (country_key, source_country_id, country_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (country_key) DO NOTHING;
    INSERT INTO dwh.dim_state_province (state_province_key, source_state_province_id, country_key, state_province_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 0, 'Unknown') ON CONFLICT (state_province_key) DO NOTHING;
    INSERT INTO dwh.dim_city (city_key, source_city_id, state_province_key, city_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 0, 'Unknown') ON CONFLICT (city_key) DO NOTHING;
    
    INSERT INTO dwh.dim_customer_category (customer_category_key, source_customer_category_id, customer_category_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (customer_category_key) DO NOTHING;
    INSERT INTO dwh.dim_buying_group (buying_group_key, source_buying_group_id, buying_group_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (buying_group_key) DO NOTHING;
    INSERT INTO dwh.dim_delivery_method (delivery_method_key, source_delivery_method_id, delivery_method_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (delivery_method_key) DO NOTHING;
    INSERT INTO dwh.dim_payment_method (payment_method_key, source_payment_method_id, payment_method_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (payment_method_key) DO NOTHING;
    INSERT INTO dwh.dim_transaction_type (transaction_type_key, source_transaction_type_id, transaction_type_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (transaction_type_key) DO NOTHING;
    INSERT INTO dwh.dim_package_type (package_type_key, source_package_type_id, package_type_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (package_type_key) DO NOTHING;
    INSERT INTO dwh.dim_stock_group (stock_group_key, source_stock_group_id, stock_group_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (stock_group_key) DO NOTHING;
    
    INSERT INTO dwh.dim_person (person_key, source_person_id, full_name) OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown') ON CONFLICT (person_key) DO NOTHING;
    
    INSERT INTO dwh.dim_supplier (supplier_key, source_supplier_id, supplier_name, delivery_city_key, postal_city_key, delivery_method_key) 
    OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown', 0, 0, 0) ON CONFLICT (supplier_key) DO NOTHING;
    
    INSERT INTO dwh.dim_customer (customer_key, source_customer_id, customer_name, customer_category_key, buying_group_key, delivery_method_key, delivery_city_key, postal_city_key) 
    OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown', 0, 0, 0, 0, 0) ON CONFLICT (customer_key) DO NOTHING;
    
    INSERT INTO dwh.dim_product (product_key, source_stock_item_id, stock_item_name, supplier_key, unit_package_type_key, outer_package_type_key) 
    OVERRIDING SYSTEM VALUE VALUES (0, 0, 'Unknown', 0, 0, 0) ON CONFLICT (product_key) DO NOTHING;
    """
    print("Inserting Unknown dimension rows...")
    cur.execute(unknown_dims_sql)

    # 3. Load Datamarts Schema
    datamarts_schema_path = Path("sql/DWH/datamarts.sql")
    if datamarts_schema_path.exists():
        print("Running datamarts.sql...")
        cur.execute(datamarts_schema_path.read_text(encoding="utf-8"))

    conn.close()

if __name__ == "__main__":
    main()
