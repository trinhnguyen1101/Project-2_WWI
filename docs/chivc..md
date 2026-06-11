Duy: 1. Tao schema/table DWH tu `sql/DWH/dwh_design.sql`.
2. Load `dim_date`.
3. Load nhom dia ly theo chuoi phu thuoc:
   `dim_country` -> `dim_state_province` -> `dim_city`.
4. Load cac lookup dimension doc lap:
   `dim_customer_category`, `dim_buying_group`, `dim_delivery_method`,
   `dim_payment_method`, 


Chiến:     `dim_transaction_type`, `dim_package_type`,
   `dim_stock_group`, `dim_person`.
5. Load cac dimension co join toi dimension khac:
   `dim_supplier`, `dim_customer`, `dim_product`.
6. Load bridge:
   `bridge_product_stock_group`.


-------------------------------

Duy: 7. Load facts:
   `fact_sales_invoice_line`, `fact_order_fulfillment_line`,
   `fact_customer_transaction`.

Chiến : 8.