# Huong Dan ETL Tu Staging Sang DWH

Tai lieu nay mo ta thu tu nap du lieu tu schema `staging` sang schema `dwh`, dua tren:

- `sql/Staging/staging_schema.sql`
- `sql/DWH/dwh_design.sql`
- Cac file CSV da nap vao staging tu `data/processed/clean_missing`

Nguyen tac chung:

- Staging giu khoa nguon nhu `customer_id`, `stock_item_id`, `invoice_id`.
- DWH dung surrogate key nhu `customer_key`, `product_key`, `date_key`.
- Dimension phai duoc load truoc fact de fact lookup duoc surrogate key.
- Cac dimension hien tai nen load theo kieu Type 1/upsert bang khoa nguon `source_*_id`.
- Fact chi tiet nen tranh insert trung bang cac cot `source_*_id` unique.
- Aggregate fact nen tranh insert trung bang khoa grain, vi du `period_date_key`
  hoac cap `(customer_key, period_date_key)`.

## Thu Tu Load Tong The

1. Tao schema/table DWH tu `sql/DWH/dwh_design.sql`.
2. Load `dim_date`.
3. Load nhom dia ly theo chuoi phu thuoc:
   `dim_country` -> `dim_state_province` -> `dim_city`.
4. Load cac lookup dimension doc lap:
   `dim_customer_category`, `dim_buying_group`, `dim_delivery_method`,
   `dim_payment_method`, `dim_transaction_type`, `dim_package_type`,
   `dim_stock_group`, `dim_person`.
5. Load cac dimension co join toi dimension khac:
   `dim_supplier`, `dim_customer`, `dim_product`.
6. Load bridge:
   `bridge_product_stock_group`.
7. Load facts:
   `fact_sales_invoice_line`, `fact_order_fulfillment_line`,
   `fact_customer_transaction`.
8. Load aggregate facts:
   `fact_business_kpi_month`, `fact_customer_kpi_month`.

## Load Dimension

### 1. `dwh.dim_date`

Nguon staging:

- `staging.stg_sales_invoices.invoice_date`
- `staging.stg_sales_orders.order_date`
- `staging.stg_sales_orders.expected_delivery_date`
- `staging.stg_sales_order_lines.picking_completed_when`
- `staging.stg_sales_customer_transactions.transaction_date`
- `staging.stg_sales_customer_transactions.finalization_date`

Mapping:

| DWH field | Cach tinh |
|---|---|
| `date_key` | `YYYYMMDD` tu ngay |
| `full_date` | Gia tri ngay |
| `day_of_month` | Ngay trong thang |
| `month_number` | Thang |
| `month_name` | Ten thang |
| `quarter_number` | Quy |
| `year_number` | Nam |
| `day_of_week_number` | Thu trong tuan |
| `day_of_week_name` | Ten thu |
| `is_weekend` | `true` neu la thu bay hoac chu nhat |

Load truoc tat ca fact vi moi fact deu dung `date_key`.

### 2. `dwh.dim_country`

Nguon staging: `staging.stg_application_countries`

Mapping:

| DWH field | Staging field |
|---|---|
| `source_country_id` | `country_id` |
| `country_name` | `country_name` |
| `formal_name` | `formal_name` |
| `iso_alpha3_code` | `iso_alpha3_code` |
| `iso_numeric_code` | `iso_numeric_code` |
| `country_type` | `country_type` |
| `continent` | `continent` |
| `region` | `region` |
| `subregion` | `subregion` |
| `latest_recorded_population` | `latest_recorded_population` |

Khong dua vao DWH: `border`, `last_edited_by`, `valid_from`, `valid_to`.

### 3. `dwh.dim_state_province`

Nguon staging: `staging.stg_application_state_provinces`

Can join:

- `stg_application_state_provinces.country_id`
  -> `dim_country.source_country_id`
  de lay `country_key`.

Mapping:

| DWH field | Staging / lookup field |
|---|---|
| `source_state_province_id` | `state_province_id` |
| `country_key` | `dim_country.country_key` |
| `state_province_code` | `state_province_code` |
| `state_province_name` | `state_province_name` |
| `sales_territory` | `sales_territory` |
| `latest_recorded_population` | `latest_recorded_population` |

Load sau `dim_country`.

### 4. `dwh.dim_city`

Nguon staging: `staging.stg_application_cities`

Can join:

- `stg_application_cities.state_province_id`
  -> `dim_state_province.source_state_province_id`
  de lay `state_province_key`.

Mapping:

| DWH field | Staging / lookup field |
|---|---|
| `source_city_id` | `city_id` |
| `state_province_key` | `dim_state_province.state_province_key` |
| `city_name` | `city_name` |
| `latest_recorded_population` | `latest_recorded_population` |

Load sau `dim_state_province`.

### 5. Lookup Dimensions Doc Lap

Load cac bang nay sau `dim_date` hoac sau nhom dia ly deu duoc, vi chung khong phu thuoc dimension khac.

| DWH dimension | Staging table | Source key | Name field |
|---|---|---|---|
| `dim_customer_category` | `stg_sales_customer_categories` | `customer_category_id` -> `source_customer_category_id` | `customer_category_name` |
| `dim_buying_group` | `stg_sales_buying_groups` | `buying_group_id` -> `source_buying_group_id` | `buying_group_name` |
| `dim_delivery_method` | `stg_application_delivery_methods` | `delivery_method_id` -> `source_delivery_method_id` | `delivery_method_name` |
| `dim_payment_method` | `stg_application_payment_methods` | `payment_method_id` -> `source_payment_method_id` | `payment_method_name` |
| `dim_transaction_type` | `stg_application_transaction_types` | `transaction_type_id` -> `source_transaction_type_id` | `transaction_type_name` |
| `dim_package_type` | `stg_warehouse_package_types` | `package_type_id` -> `source_package_type_id` | `package_type_name` |
| `dim_stock_group` | `stg_warehouse_stock_groups` | `stock_group_id` -> `source_stock_group_id` | `stock_group_name` |

### 6. `dwh.dim_person`

Nguon staging: `staging.stg_application_people`

Mapping:

| DWH field | Staging field |
|---|---|
| `source_person_id` | `person_id` |
| `full_name` | `full_name` |
| `preferred_name` | `preferred_name` |
| `is_employee` | `is_employee` |
| `is_salesperson` | `is_salesperson` |
| `email_address` | `email_address` |

Khong dua vao DWH: login fields, phone/fax, `has_*`, audit fields.

### 7. `dwh.dim_supplier`

Nguon staging:

- Chinh: `staging.stg_purchasing_suppliers`
- Lookup category name: `staging.stg_purchasing_supplier_categories`
- Lookup surrogate keys: `dwh.dim_city`, `dwh.dim_delivery_method`

Can join:

- `supplier_category_id`
  -> `stg_purchasing_supplier_categories.supplier_category_id`
  de lay `supplier_category_name`.
- `delivery_city_id`
  -> `dim_city.source_city_id`
  de lay `delivery_city_key`.
- `postal_city_id`
  -> `dim_city.source_city_id`
  de lay `postal_city_key`.
- `delivery_method_id`
  -> `dim_delivery_method.source_delivery_method_id`
  de lay `delivery_method_key`.

Mapping:

| DWH field | Staging / lookup field |
|---|---|
| `source_supplier_id` | `supplier_id` |
| `supplier_name` | `supplier_name` |
| `supplier_category_name` | `stg_purchasing_supplier_categories.supplier_category_name` |
| `delivery_city_key` | `dim_city.city_key` from `delivery_city_id` |
| `postal_city_key` | `dim_city.city_key` from `postal_city_id` |
| `delivery_method_key` | `dim_delivery_method.delivery_method_key` |
| `payment_days` | `payment_days` |
| `phone_number` | `phone_number` |
| `website_url` | `website_url` |

Load sau `dim_city` va `dim_delivery_method`.

### 8. `dwh.dim_customer`

Nguon staging: `staging.stg_sales_customers`

Can join:

- `customer_category_id`
  -> `dim_customer_category.source_customer_category_id`
  de lay `customer_category_key`.
- `buying_group_id`
  -> `dim_buying_group.source_buying_group_id`
  de lay `buying_group_key`.
- `delivery_method_id`
  -> `dim_delivery_method.source_delivery_method_id`
  de lay `delivery_method_key`.
- `delivery_city_id`
  -> `dim_city.source_city_id`
  de lay `delivery_city_key`.
- `postal_city_id`
  -> `dim_city.source_city_id`
  de lay `postal_city_key`.

Mapping:

| DWH field | Staging / lookup field |
|---|---|
| `source_customer_id` | `customer_id` |
| `customer_name` | `customer_name` |
| `customer_category_key` | `dim_customer_category.customer_category_key` |
| `buying_group_key` | `dim_buying_group.buying_group_key` |
| `delivery_method_key` | `dim_delivery_method.delivery_method_key` |
| `delivery_city_key` | `dim_city.city_key` from `delivery_city_id` |
| `postal_city_key` | `dim_city.city_key` from `postal_city_id` |
| `credit_limit` | `credit_limit` |
| `account_opened_date` | `account_opened_date` |
| `standard_discount_percentage` | `standard_discount_percentage` |
| `is_statement_sent` | `is_statement_sent` |
| `is_on_credit_hold` | `is_on_credit_hold` |
| `payment_days` | `payment_days` |
| `phone_number` | `phone_number` |
| `website_url` | `website_url` |

Load sau `dim_customer_category`, `dim_buying_group`, `dim_delivery_method`, `dim_city`.

### 9. `dwh.dim_product`

Nguon staging:

- Chinh: `staging.stg_warehouse_stock_items`
- Lookup surrogate keys: `dwh.dim_supplier`, `dwh.dim_package_type`

Can join:

- `supplier_id`
  -> `dim_supplier.source_supplier_id`
  de lay `supplier_key`.
- `unit_package_id`
  -> `dim_package_type.source_package_type_id`
  de lay `unit_package_type_key`.
- `outer_package_id`
  -> `dim_package_type.source_package_type_id`
  de lay `outer_package_type_key`.

Mapping:

| DWH field | Staging / lookup field |
|---|---|
| `source_stock_item_id` | `stock_item_id` |
| `stock_item_name` | `stock_item_name` |
| `supplier_key` | `dim_supplier.supplier_key` |
| `color_name` | `color_name_for_analysis` |
| `unit_package_type_key` | `dim_package_type.package_type_key` from `unit_package_id` |
| `outer_package_type_key` | `dim_package_type.package_type_key` from `outer_package_id` |
| `brand` | `brand_for_analysis` |
| `size` | `size_for_analysis` |
| `lead_time_days` | `lead_time_days` |
| `quantity_per_outer` | `quantity_per_outer` |
| `is_chiller_stock` | `is_chiller_stock` |
| `tax_rate` | `tax_rate` |
| `current_unit_price` | `unit_price` |
| `recommended_retail_price` | `recommended_retail_price` |
| `typical_weight_per_unit` | `typical_weight_per_unit` |
| `country_of_manufacture` | `country_of_manufacture` |
| `tags` | `tags_for_analysis` |

Load sau `dim_supplier` va `dim_package_type`.

### 10. `dwh.bridge_product_stock_group`

Nguon staging: `staging.stg_warehouse_stock_item_stock_groups`

Can join:

- `stock_item_id`
  -> `dim_product.source_stock_item_id`
  de lay `product_key`.
- `stock_group_id`
  -> `dim_stock_group.source_stock_group_id`
  de lay `stock_group_key`.

Mapping:

| DWH field | Staging / lookup field |
|---|---|
| `product_key` | `dim_product.product_key` |
| `stock_group_key` | `dim_stock_group.stock_group_key` |

Load sau `dim_product` va `dim_stock_group`.

## Load Fact

### 1. `dwh.fact_sales_invoice_line`

Grain: mot dong hoa don ban hang, tu `staging.stg_sales_invoice_lines`.

Nguon staging:

- `staging.stg_sales_invoice_lines` as line
- `staging.stg_sales_invoices` as invoice

Can join staging:

- `line.invoice_id = invoice.invoice_id`

Can join dimension:

| Fact key | Join de lay surrogate key |
|---|---|
| `invoice_date_key` | `invoice.invoice_date` -> `dim_date.full_date` |
| `customer_key` | `invoice.customer_id` -> `dim_customer.source_customer_id` |
| `bill_to_customer_key` | `invoice.bill_to_customer_id` -> `dim_customer.source_customer_id` |
| `product_key` | `line.stock_item_id` -> `dim_product.source_stock_item_id` |
| `package_type_key` | `line.package_type_id` -> `dim_package_type.source_package_type_id` |
| `salesperson_key` | `invoice.salesperson_person_id` -> `dim_person.source_person_id` |

Mapping field:

| DWH field | Cong thuc / source |
|---|---|
| `source_invoice_line_id` | `line.invoice_line_id` |
| `source_invoice_id` | `line.invoice_id` |
| `quantity_sold` | `line.quantity` |
| `revenue_ex_tax` | `line.extended_price - line.tax_amount` |
| `tax_amount` | `line.tax_amount` |
| `revenue_inc_tax` | `line.extended_price` |
| `gross_profit` | `line.line_profit` |
| `estimated_cogs` | `(line.extended_price - line.tax_amount) - line.line_profit` |
| `gross_margin_pct` | `line.line_profit / NULLIF(line.extended_price - line.tax_amount, 0)` |
| `average_selling_price_ex_tax` | `(line.extended_price - line.tax_amount) / NULLIF(line.quantity, 0)` |
| `profit_per_unit` | `line.line_profit / NULLIF(line.quantity, 0)` |

Phu thuoc load truoc:

- `dim_date`
- `dim_customer`
- `dim_product`
- `dim_package_type`
- `dim_person`

### 2. `dwh.fact_order_fulfillment_line`

Grain: mot dong don hang, tu `staging.stg_sales_order_lines`.

Nguon staging:

- `staging.stg_sales_order_lines` as line
- `staging.stg_sales_orders` as orders

Can join staging:

- `line.order_id = orders.order_id`

Can join dimension:

| Fact key | Join de lay surrogate key |
|---|---|
| `order_date_key` | `orders.order_date` -> `dim_date.full_date` |
| `expected_delivery_date_key` | `orders.expected_delivery_date` -> `dim_date.full_date` |
| `picking_completed_date_key` | `DATE(line.picking_completed_when)` -> `dim_date.full_date` |
| `customer_key` | `orders.customer_id` -> `dim_customer.source_customer_id` |
| `product_key` | `line.stock_item_id` -> `dim_product.source_stock_item_id` |
| `package_type_key` | `line.package_type_id` -> `dim_package_type.source_package_type_id` |
| `salesperson_key` | `orders.salesperson_person_id` -> `dim_person.source_person_id` |
| `picker_key` | `orders.picked_by_person_id` -> `dim_person.source_person_id` |

Mapping field:

| DWH field | Cong thuc / source |
|---|---|
| `source_order_line_id` | `line.order_line_id` |
| `source_order_id` | `line.order_id` |
| `ordered_quantity` | `line.quantity` |
| `picked_quantity` | `line.picked_quantity` |
| `unpicked_quantity` | `line.unpicked_quantity` hoac `line.quantity - line.picked_quantity` |
| `fill_rate` | `line.fill_rate` hoac `line.picked_quantity / NULLIF(line.quantity, 0)` |
| `picking_lead_time_hours` | `EXTRACT(EPOCH FROM (line.picking_completed_when - orders.order_date::timestamp)) / 3600` |
| `expected_delivery_lead_days` | `orders.expected_delivery_date - orders.order_date` |
| `is_undersupply_backordered` | `orders.is_undersupply_backordered` |
| `is_fully_picked` | `line.is_fully_picked` |

Phu thuoc load truoc:

- `dim_date`
- `dim_customer`
- `dim_product`
- `dim_package_type`
- `dim_person`

### 3. `dwh.fact_customer_transaction`

Grain: mot giao dich cong no khach hang, tu `staging.stg_sales_customer_transactions`.

Nguon staging:

- `staging.stg_sales_customer_transactions` as txn

Can join dimension:

| Fact key | Join de lay surrogate key |
|---|---|
| `transaction_date_key` | `txn.transaction_date` -> `dim_date.full_date` |
| `finalization_date_key` | `txn.finalization_date` -> `dim_date.full_date` |
| `due_date_key` | `txn.transaction_date + dim_customer.payment_days` -> `dim_date.full_date` |
| `customer_key` | `txn.customer_id` -> `dim_customer.source_customer_id` |
| `payment_method_key` | `txn.payment_method_id` -> `dim_payment_method.source_payment_method_id` |
| `transaction_type_key` | `txn.transaction_type_id` -> `dim_transaction_type.source_transaction_type_id` |

Mapping field:

| DWH field | Cong thuc / source |
|---|---|
| `source_customer_transaction_id` | `txn.customer_transaction_id` |
| `source_invoice_id` | `txn.invoice_id` |
| `receivable_ex_tax` | `txn.amount_excluding_tax` |
| `receivable_tax_amount` | `txn.tax_amount` |
| `receivable_inc_tax` | `txn.transaction_amount` |
| `outstanding_amount` | `txn.outstanding_balance` |
| `paid_amount` | `txn.paid_amount` hoac `txn.transaction_amount - txn.outstanding_balance` |
| `outstanding_ratio` | `txn.outstanding_ratio` hoac `txn.outstanding_balance / NULLIF(txn.transaction_amount, 0)` |
| `days_to_collect` | `txn.finalization_date - txn.transaction_date` |
| `collection_age_days` | `COALESCE(txn.finalization_date, CURRENT_DATE) - txn.transaction_date` |
| `days_past_due` | `GREATEST(COALESCE(txn.finalization_date, CURRENT_DATE) - (txn.transaction_date + dim_customer.payment_days), 0)` |
| `current_ar_amount` | `CASE WHEN txn.outstanding_balance > 0 AND days_past_due = 0 THEN txn.outstanding_balance ELSE 0 END` |
| `past_due_amount` | `CASE WHEN txn.outstanding_balance > 0 AND days_past_due > 0 THEN txn.outstanding_balance ELSE 0 END` |
| `is_finalized` | `txn.is_finalized_flag` hoac `txn.is_finalized` |
| `is_overdue` | `days_to_collect > dim_customer.payment_days`; voi giao dich chua final, co the dung `CURRENT_DATE - txn.transaction_date > payment_days` |

Phu thuoc load truoc:

- `dim_date`
- `dim_customer`
- `dim_payment_method`
- `dim_transaction_type`

Luu y: cac cot dung `CURRENT_DATE` nhu `collection_age_days`, `days_past_due`,
`current_ar_amount`, `past_due_amount` la snapshot tai thoi diem ETL. Neu can
theo doi lich su cong no theo tung ngay, nen them mot fact snapshot rieng thay
vi chi cap nhat lai fact transaction.

### 4. `dwh.fact_business_kpi_month`

Grain: 1 dong = 1 thang, dung cho dashboard KPI tong the.

Nguon DWH:

- `dwh.fact_sales_invoice_line`
- `dwh.fact_customer_transaction`
- `dwh.dim_date`

Khoa:

| DWH field | Cach tinh |
|---|---|
| `period_date_key` | date key cua ngay dau thang, lay tu `dim_date` |

Nhom sales KPI:

| DWH field | Cong thuc |
|---|---|
| `revenue_ex_tax` | `SUM(fact_sales_invoice_line.revenue_ex_tax)` theo thang |
| `revenue_inc_tax` | `SUM(fact_sales_invoice_line.revenue_inc_tax)` theo thang |
| `gross_profit` | `SUM(fact_sales_invoice_line.gross_profit)` theo thang |
| `estimated_cogs` | `SUM(fact_sales_invoice_line.estimated_cogs)` theo thang |
| `quantity_sold` | `SUM(fact_sales_invoice_line.quantity_sold)` theo thang |
| `invoice_count` | `COUNT(DISTINCT fact_sales_invoice_line.source_invoice_id)` theo thang |
| `gross_margin_pct` | `gross_profit / NULLIF(revenue_ex_tax, 0)` |
| `average_selling_price_ex_tax` | `revenue_ex_tax / NULLIF(quantity_sold, 0)` |
| `profit_per_unit` | `gross_profit / NULLIF(quantity_sold, 0)` |
| `average_order_value` | `revenue_ex_tax / NULLIF(invoice_count, 0)` |
| `sales_growth_rate` | `(current_month_revenue - prior_month_revenue) / NULLIF(prior_month_revenue, 0)` |

Nhom receivable KPI:

| DWH field | Cong thuc |
|---|---|
| `receivable_inc_tax` | `SUM(fact_customer_transaction.receivable_inc_tax)` theo thang |
| `outstanding_amount` | `SUM(fact_customer_transaction.outstanding_amount)` theo thang |
| `paid_amount` | `SUM(fact_customer_transaction.paid_amount)` theo thang |
| `current_ar_amount` | `SUM(fact_customer_transaction.current_ar_amount)` theo thang |
| `past_due_amount` | `SUM(fact_customer_transaction.past_due_amount)` theo thang |
| `receivable_outstanding_ratio` | `SUM(outstanding_amount) / NULLIF(SUM(receivable_inc_tax), 0)` |
| `current_ar_ratio` | `SUM(current_ar_amount) / NULLIF(SUM(current_ar_amount) + SUM(past_due_amount), 0)` |
| `average_days_to_collect` | `AVG(days_to_collect)` theo thang, bo qua null |
| `average_collection_age_days` | `AVG(collection_age_days)` theo thang, bo qua null |
| `average_days_past_due` | `AVG(days_past_due)` theo thang, bo qua null |
| `overdue_transaction_rate` | `AVG(CASE WHEN is_overdue THEN 1.0 ELSE 0.0 END)` theo thang |

Load sau 3 fact chi tiet. Fact nay co the truncate va load lai toan bo sau moi batch.

### 5. `dwh.fact_customer_kpi_month`

Grain: 1 dong = 1 khach hang + 1 thang, dung cho dashboard customer performance
va ML phan cum khach hang.

Nguon DWH:

- `dwh.fact_sales_invoice_line`
- `dwh.fact_customer_transaction`
- `dwh.dim_date`
- `dwh.dim_customer`

Khoa:

| DWH field | Cach tinh |
|---|---|
| `customer_key` | `dim_customer.customer_key` |
| `period_date_key` | date key cua ngay dau thang, lay tu `dim_date` |

Nhom sales KPI theo customer-thang:

| DWH field | Cong thuc |
|---|---|
| `revenue_ex_tax` | `SUM(fact_sales_invoice_line.revenue_ex_tax)` theo customer-thang |
| `revenue_inc_tax` | `SUM(fact_sales_invoice_line.revenue_inc_tax)` theo customer-thang |
| `gross_profit` | `SUM(fact_sales_invoice_line.gross_profit)` theo customer-thang |
| `estimated_cogs` | `SUM(fact_sales_invoice_line.estimated_cogs)` theo customer-thang |
| `quantity_sold` | `SUM(fact_sales_invoice_line.quantity_sold)` theo customer-thang |
| `invoice_count` | `COUNT(DISTINCT fact_sales_invoice_line.source_invoice_id)` theo customer-thang |
| `gross_margin_pct` | `gross_profit / NULLIF(revenue_ex_tax, 0)` |
| `average_selling_price_ex_tax` | `revenue_ex_tax / NULLIF(quantity_sold, 0)` |
| `profit_per_unit` | `gross_profit / NULLIF(quantity_sold, 0)` |
| `average_order_value` | `revenue_ex_tax / NULLIF(invoice_count, 0)` |
| `sales_growth_rate` | `(current_customer_month_revenue - prior_customer_month_revenue) / NULLIF(prior_customer_month_revenue, 0)` |

Nhom receivable KPI theo customer-thang:

| DWH field | Cong thuc |
|---|---|
| `receivable_inc_tax` | `SUM(fact_customer_transaction.receivable_inc_tax)` theo customer-thang |
| `outstanding_amount` | `SUM(fact_customer_transaction.outstanding_amount)` theo customer-thang |
| `paid_amount` | `SUM(fact_customer_transaction.paid_amount)` theo customer-thang |
| `current_ar_amount` | `SUM(fact_customer_transaction.current_ar_amount)` theo customer-thang |
| `past_due_amount` | `SUM(fact_customer_transaction.past_due_amount)` theo customer-thang |
| `receivable_outstanding_ratio` | `SUM(outstanding_amount) / NULLIF(SUM(receivable_inc_tax), 0)` |
| `current_ar_ratio` | `SUM(current_ar_amount) / NULLIF(SUM(current_ar_amount) + SUM(past_due_amount), 0)` |
| `average_days_to_collect` | `AVG(days_to_collect)` theo customer-thang, bo qua null |
| `average_collection_age_days` | `AVG(collection_age_days)` theo customer-thang, bo qua null |
| `average_days_past_due` | `AVG(days_past_due)` theo customer-thang, bo qua null |
| `overdue_transaction_rate` | `AVG(CASE WHEN is_overdue THEN 1.0 ELSE 0.0 END)` theo customer-thang |

Load sau 3 fact chi tiet va `dim_customer`. Day la bang nen dung khi export feature
cho clustering, vi moi dong da dung grain khach hang-thang va khong lap theo
invoice line/transaction.

## Kiem Tra Chat Luong Truoc Khi Load Fact

Truoc khi insert fact, nen chay cac anti-join de dam bao khong bi mat surrogate key.

### Check invoice line thieu dimension

```sql
SELECT COUNT(*) AS missing_product
FROM staging.stg_sales_invoice_lines l
LEFT JOIN dwh.dim_product p
  ON p.source_stock_item_id = l.stock_item_id
WHERE p.product_key IS NULL;
```

### Check order line thieu order header

```sql
SELECT COUNT(*) AS missing_order_header
FROM staging.stg_sales_order_lines l
LEFT JOIN staging.stg_sales_orders o
  ON o.order_id = l.order_id
WHERE o.order_id IS NULL;
```

### Check customer transaction thieu customer

```sql
SELECT COUNT(*) AS missing_customer
FROM staging.stg_sales_customer_transactions t
LEFT JOIN dwh.dim_customer c
  ON c.source_customer_id = t.customer_id
WHERE c.customer_key IS NULL;
```

## Goi Y Upsert

Voi dimension co cot `source_*_id UNIQUE`, co the dung mau:

```sql
INSERT INTO dwh.dim_xxx (source_xxx_id, name_col)
SELECT source_id, name_col
FROM staging.some_table
ON CONFLICT (source_xxx_id)
DO UPDATE SET
  name_col = EXCLUDED.name_col;
```

Voi fact chi tiet co cot `source_*_id UNIQUE`, co the:

- `TRUNCATE` fact roi load lai neu day la bai tap/batch full refresh.
- Hoac `ON CONFLICT (source_*_id) DO UPDATE` neu muon incremental/upsert.

Voi aggregate fact:

- `fact_business_kpi_month`: upsert theo `period_date_key`.
- `fact_customer_kpi_month`: upsert theo `(customer_key, period_date_key)`.

Thu tu truncate khi full refresh nen nguoc voi thu tu load:

1. Aggregate facts: `fact_business_kpi_month`, `fact_customer_kpi_month`.
2. Detail facts: `fact_sales_invoice_line`, `fact_order_fulfillment_line`, `fact_customer_transaction`.
3. Bridge: `bridge_product_stock_group`.
4. `dim_product`, `dim_customer`, `dim_supplier`.
5. Lookup dimensions va geography dimensions.
6. `dim_date` neu muon tao lai lich.
