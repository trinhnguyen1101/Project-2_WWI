# DWH Measure Catalog

Tai lieu nay mo ta cac dimension, fact, KPI va bai toan phan tich/ML trong DWH hien tai.

Scope chinh: **phan tich hieu qua ban hang, loi nhuan, fulfillment don hang va chat luong thu tien/cong no khach hang**.

DWH hien co 5 fact:

| Fact | Grain | Vai tro |
|---|---|---|
| `fact_sales_invoice_line` | 1 dong hoa don | Fact chi tiet cho doanh thu, loi nhuan, gross margin |
| `fact_order_fulfillment_line` | 1 dong don hang | Fact chi tiet cho kha nang dap ung don hang, fill rate, backorder |
| `fact_customer_transaction` | 1 giao dich cong no | Fact chi tiet cho thu tien, outstanding, overdue |
| `fact_business_kpi_month` | 1 thang | Aggregate fact KPI tong the theo thang |
| `fact_customer_kpi_month` | 1 khach hang + 1 thang | Aggregate fact KPI khach hang-thang, phu hop cho clustering |

## Nguyen Tac Thiet Ke

- Dimension luu thuoc tinh mo ta: customer, product, supplier, dia ly, lookup.
- Fact chi tiet giu grain goc cua nghiep vu va cac measure tinh duoc o grain do.
- KPI tong hop theo thang khong dua vao fact chi tiet de tranh lap du lieu.
- KPI tong hop duoc luu trong aggregate fact rieng: `fact_business_kpi_month` va `fact_customer_kpi_month`.
- SCD Type 2 chua duoc cai trong DDL hien tai. Neu can lich su thuoc tinh, xu ly them trong ETL va mo rong dimension.

## Dimension Catalog

| Dimension | Y nghia | Dung de phan tich |
|---|---|---|
| `dim_date` | Lich ngay, thang, quy, nam | Xu huong doanh thu, loi nhuan, fulfillment, cong no theo thoi gian |
| `dim_country` | Quoc gia | Phan tich theo vung dia ly lon |
| `dim_state_province` | Tinh/bang, sales territory | Phan tich theo state/province/territory |
| `dim_city` | Thanh pho cua customer/supplier | Phan tich doanh thu, margin, customer theo dia ly |
| `dim_customer_category` | Loai khach hang | So sanh doanh thu, margin, cong no theo loai khach |
| `dim_buying_group` | Nhom mua hang | Phan tich hieu qua theo buying group |
| `dim_delivery_method` | Phuong thuc giao hang | Phan tich fulfillment theo cach giao hang |
| `dim_payment_method` | Phuong thuc thanh toan | Phan tich outstanding va thu tien theo payment method |
| `dim_transaction_type` | Loai giao dich cong no | Phan loai invoice/payment/credit |
| `dim_package_type` | Kieu dong goi | Phan tich sales/fulfillment theo package |
| `dim_stock_group` | Nhom san pham | Roll-up sales, profit, fill rate theo stock group |
| `dim_person` | Nhan su nhu salesperson, picker | Phan tich salesperson/picker performance |
| `dim_supplier` | Nha cung cap | Phan tich loi nhuan va fulfillment theo supplier |
| `dim_customer` | Khach hang | Phan tich customer value, payment quality, credit behavior |
| `dim_product` | San pham | Phan tich san pham ban chay, margin, fill rate |
| `bridge_product_stock_group` | Quan he product-stock group | Ho tro mot product thuoc nhieu stock group |

## Detail Facts

### `fact_sales_invoice_line`

Grain: 1 dong hoa don ban hang.

Nguon chinh:

- `staging.stg_sales_invoice_lines`
- `staging.stg_sales_invoices`

Dimension lien quan:

- `dim_date` qua `invoice_date_key`
- `dim_customer` qua `customer_key`, `bill_to_customer_key`
- `dim_product` qua `product_key`
- `dim_package_type` qua `package_type_key`
- `dim_person` qua `salesperson_key`

Measures:

| Measure | Y nghia | Cong thuc |
|---|---|---|
| `quantity_sold` | So luong ban | `Sales_InvoiceLines.Quantity` |
| `revenue_ex_tax` | Doanh thu chua thue | `ExtendedPrice - TaxAmount` |
| `tax_amount` | Tien thue | `TaxAmount` |
| `revenue_inc_tax` | Doanh thu gom thue | `ExtendedPrice` |
| `gross_profit` | Loi nhuan gop | `LineProfit` |
| `estimated_cogs` | Gia von uoc tinh | `revenue_ex_tax - gross_profit` |
| `gross_margin_pct` | Bien loi nhuan gop | `gross_profit / revenue_ex_tax` |
| `average_selling_price_ex_tax` | Gia ban trung binh chua thue | `revenue_ex_tax / quantity_sold` |
| `profit_per_unit` | Loi nhuan gop moi don vi | `gross_profit / quantity_sold` |

Phan tich phu hop:

- San pham nao tao doanh thu va loi nhuan cao nhat.
- Khach hang/nhom khach hang nao co gross margin tot.
- Khu vuc nao ban nhieu nhung margin thap.
- Supplier hoac stock group nao dong gop loi nhuan tot.
- Salesperson nao tao doanh thu/loi nhuan cao.

### `fact_order_fulfillment_line`

Grain: 1 dong don hang.

Nguon chinh:

- `staging.stg_sales_order_lines`
- `staging.stg_sales_orders`

Dimension lien quan:

- `dim_date` qua `order_date_key`, `expected_delivery_date_key`, `picking_completed_date_key`
- `dim_customer` qua `customer_key`
- `dim_product` qua `product_key`
- `dim_package_type` qua `package_type_key`
- `dim_person` qua `salesperson_key`, `picker_key`

Measures:

| Measure | Y nghia | Cong thuc |
|---|---|---|
| `ordered_quantity` | So luong khach dat | `Sales_OrderLines.Quantity` |
| `picked_quantity` | So luong da pick | `Sales_OrderLines.PickedQuantity` |
| `unpicked_quantity` | So luong chua pick | `ordered_quantity - picked_quantity` |
| `fill_rate` | Ty le dap ung dong hang | `picked_quantity / ordered_quantity` |
| `picking_lead_time_hours` | Gio tu ngay dat den luc pick xong | `PickingCompletedWhen - OrderDate` |
| `expected_delivery_lead_days` | So ngay giao du kien | `ExpectedDeliveryDate - OrderDate` |
| `is_undersupply_backordered` | Co backorder do thieu hang | Tu `Sales_Orders.IsUndersupplyBackordered` |
| `is_fully_picked` | Dong hang da pick du | `picked_quantity >= ordered_quantity` |

Phan tich phu hop:

- San pham nao co fill rate thap.
- Stock group nao hay phat sinh backorder.
- Picker/salesperson nao lien quan toi fulfillment cham.
- Fulfillment kem co lien quan toi doanh thu/loi nhuan thap khong.

### `fact_customer_transaction`

Grain: 1 giao dich cong no khach hang.

Nguon chinh:

- `staging.stg_sales_customer_transactions`

Dimension lien quan:

- `dim_date` qua `transaction_date_key`, `finalization_date_key`, `due_date_key`
- `dim_customer` qua `customer_key`
- `dim_payment_method` qua `payment_method_key`
- `dim_transaction_type` qua `transaction_type_key`

Measures:

| Measure | Y nghia | Cong thuc |
|---|---|---|
| `receivable_ex_tax` | Gia tri giao dich chua thue | `AmountExcludingTax` |
| `receivable_tax_amount` | Thue cua giao dich | `TaxAmount` |
| `receivable_inc_tax` | Gia tri giao dich gom thue | `TransactionAmount` |
| `outstanding_amount` | So tien con chua tat toan | `OutstandingBalance` |
| `paid_amount` | So tien da tat toan | `TransactionAmount - OutstandingBalance` |
| `outstanding_ratio` | Ty le con no | `OutstandingBalance / TransactionAmount` |
| `days_to_collect` | So ngay tu giao dich den tat toan | `FinalizationDate - TransactionDate` |
| `collection_age_days` | Tuoi giao dich den ngay ETL/tat toan | `COALESCE(FinalizationDate, CURRENT_DATE) - TransactionDate` |
| `days_past_due` | So ngay qua han | `GREATEST(collection_age_days - payment_days, 0)` |
| `current_ar_amount` | AR con trong han | Outstanding neu chua qua han |
| `past_due_amount` | AR da qua han | Outstanding neu qua han |
| `is_finalized` | Da tat toan hay chua | `IsFinalized` |
| `is_overdue` | Co qua han khong | `days_past_due > 0` |

Phan tich phu hop:

- Khach hang nao con outstanding cao.
- Khach hang nao tra cham/qua han.
- Payment method nao co outstanding ratio cao.
- Loai giao dich nao thu tien cham.
- Chat luong thu tien co lien quan den credit limit/payment days/credit hold khong.

## Aggregate Facts

Aggregate fact duoc tao tu fact chi tiet sau khi da load xong detail facts. Muc tieu la giu KPI tong hop o grain rieng, tranh lap du lieu tren invoice line/transaction.

### `fact_business_kpi_month`

Grain: 1 dong = 1 thang.

Muc dich:

- Dashboard KPI tong the theo thang.
- Theo doi trend doanh thu, loi nhuan, gross margin, cong no, overdue.
- Khong phu thuoc customer cu the.

Khoa:

| Field | Y nghia |
|---|---|
| `period_date_key` | Date key cua ngay dau thang |

Sales KPIs:

| KPI | Cong thuc |
|---|---|
| `revenue_ex_tax` | `SUM(fact_sales_invoice_line.revenue_ex_tax)` |
| `revenue_inc_tax` | `SUM(fact_sales_invoice_line.revenue_inc_tax)` |
| `gross_profit` | `SUM(fact_sales_invoice_line.gross_profit)` |
| `estimated_cogs` | `SUM(fact_sales_invoice_line.estimated_cogs)` |
| `quantity_sold` | `SUM(fact_sales_invoice_line.quantity_sold)` |
| `invoice_count` | `COUNT(DISTINCT source_invoice_id)` |
| `gross_margin_pct` | `gross_profit / revenue_ex_tax` |
| `average_selling_price_ex_tax` | `revenue_ex_tax / quantity_sold` |
| `profit_per_unit` | `gross_profit / quantity_sold` |
| `average_order_value` | `revenue_ex_tax / invoice_count` |
| `sales_growth_rate` | `(current_month_revenue - prior_month_revenue) / prior_month_revenue` |

Receivable KPIs:

| KPI | Cong thuc |
|---|---|
| `receivable_inc_tax` | `SUM(fact_customer_transaction.receivable_inc_tax)` |
| `outstanding_amount` | `SUM(fact_customer_transaction.outstanding_amount)` |
| `paid_amount` | `SUM(fact_customer_transaction.paid_amount)` |
| `current_ar_amount` | `SUM(fact_customer_transaction.current_ar_amount)` |
| `past_due_amount` | `SUM(fact_customer_transaction.past_due_amount)` |
| `receivable_outstanding_ratio` | `SUM(outstanding_amount) / SUM(receivable_inc_tax)` |
| `current_ar_ratio` | `SUM(current_ar_amount) / (SUM(current_ar_amount) + SUM(past_due_amount))` |
| `average_days_to_collect` | `AVG(days_to_collect)` |
| `average_collection_age_days` | `AVG(collection_age_days)` |
| `average_days_past_due` | `AVG(days_past_due)` |
| `overdue_transaction_rate` | `AVG(CASE WHEN is_overdue THEN 1 ELSE 0 END)` |

### `fact_customer_kpi_month`

Grain: 1 dong = 1 khach hang + 1 thang.

Muc dich:

- Dashboard customer performance.
- Feature table cho ML phan cum khach hang.
- So sanh customer theo gia tri, loi nhuan, cong no va hanh vi tra tien.

Khoa:

| Field | Y nghia |
|---|---|
| `customer_key` | Khach hang trong `dim_customer` |
| `period_date_key` | Date key cua ngay dau thang |

KPIs:

| KPI | Y nghia |
|---|---|
| `revenue_ex_tax`, `revenue_inc_tax` | Doanh thu cua customer trong thang |
| `gross_profit`, `gross_margin_pct` | Loi nhuan va bien loi nhuan cua customer |
| `estimated_cogs` | Gia von uoc tinh |
| `quantity_sold` | Tong so luong mua |
| `invoice_count` | So hoa don phat sinh |
| `average_order_value` | Gia tri trung binh moi hoa don |
| `sales_growth_rate` | Tang truong doanh thu customer so voi thang truoc |
| `outstanding_amount` | Tong cong no con lai |
| `current_ar_amount` | Cong no con trong han |
| `past_due_amount` | Cong no qua han |
| `receivable_outstanding_ratio` | Ty le cong no con lai tren receivable |
| `current_ar_ratio` | Ty le AR trong han |
| `average_days_to_collect` | So ngay thu tien trung binh |
| `average_days_past_due` | So ngay qua han trung binh |
| `overdue_transaction_rate` | Ty le giao dich qua han |

## KPI Tu METRICS.docx Co The Dung

| KPI | Trang thai | Noi dung trong DWH |
|---|---|---|
| Gross Profit Margin | Dung duoc | `gross_margin_pct` trong sales fact va aggregate facts |
| Sales Growth Rate | Dung duoc | `sales_growth_rate` trong aggregate facts |
| Accounts Receivable / Current AR Ratio | Dung duoc dang proxy | `current_ar_ratio`, `current_ar_amount`, `past_due_amount` |
| AR Turnover | Dung duoc dang proxy | Co sales va outstanding, nhung khong co AR binh quan chuan dau/cuoi ky |
| DSO / Average Days To Collect | Dung duoc | `average_days_to_collect`, `days_to_collect` |
| Inventory Turnover / DIO | Chua du | Thieu inventory balance binh quan trong DWH hien tai |
| Cash Conversion Cycle | Chua du | Thieu DIO va DPO |
| Current Ratio / Quick Ratio / Cash Ratio | Khong du | Thieu current assets, liabilities, cash |
| Net Profit Margin / ROA / ROE / EPS / P/E / P/B | Khong du | Thieu bao cao tai chinh, net income, equity, shares, market price |
| AP Turnover / DPO | Khong du | Chua co payable fact trong scope |

## Chi So Tong Hop Nen Dung

| Chi so | Cong thuc DWH |
|---|---|
| Total Revenue Ex Tax | `SUM(revenue_ex_tax)` |
| Total Gross Profit | `SUM(gross_profit)` |
| Gross Margin | `SUM(gross_profit) / SUM(revenue_ex_tax)` |
| Estimated COGS | `SUM(estimated_cogs)` |
| Average Selling Price | `SUM(revenue_ex_tax) / SUM(quantity_sold)` |
| Profit Per Unit | `SUM(gross_profit) / SUM(quantity_sold)` |
| Average Order Value | `SUM(revenue_ex_tax) / COUNT(DISTINCT source_invoice_id)` |
| Fill Rate | `SUM(picked_quantity) / SUM(ordered_quantity)` |
| Backorder Rate | `AVG(CASE WHEN is_undersupply_backordered THEN 1 ELSE 0 END)` |
| Receivable Outstanding Ratio | `SUM(outstanding_amount) / SUM(receivable_inc_tax)` |
| Current AR Ratio | `SUM(current_ar_amount) / (SUM(current_ar_amount) + SUM(past_due_amount))` |
| Average Days To Collect | `AVG(days_to_collect)` |
| Overdue Transaction Rate | `AVG(CASE WHEN is_overdue THEN 1 ELSE 0 END)` |

## ML Phu Hop Voi Scope Nay

### 1. Phan cum khach hang

Nguon nen dung: `fact_customer_kpi_month` join voi `dim_customer`, `dim_customer_category`, `dim_buying_group`, `dim_city`.

Feature goi y:

- `revenue_ex_tax`
- `gross_profit`
- `gross_margin_pct`
- `invoice_count`
- `average_order_value`
- `quantity_sold`
- `outstanding_amount`
- `receivable_outstanding_ratio`
- `current_ar_ratio`
- `average_days_to_collect`
- `average_days_past_due`
- `overdue_transaction_rate`
- `credit_limit`
- `payment_days`
- `is_on_credit_hold`

Cum co the dien giai:

- High value, good payer.
- High value, high overdue risk.
- Low revenue, high margin.
- Frequent buyer, low average order value.
- Dormant/low activity customer.

### 2. Du doan khach hang/giao dich co nguy co qua han

Target goi y: `is_overdue` trong `fact_customer_transaction`.

Feature:

- `payment_days`, `credit_limit`, `is_on_credit_hold`
- Customer category, buying group, city
- Lich su outstanding ratio, days to collect, overdue rate
- Payment method, transaction type

### 3. Du bao doanh thu theo thang

Nguon nen dung: `fact_business_kpi_month` hoac aggregate tu `fact_sales_invoice_line`.

Target:

- `revenue_ex_tax` thang tiep theo
- Hoac `quantity_sold` thang tiep theo

Feature:

- Revenue lag theo thang
- Quantity lag theo thang
- Gross margin
- Invoice count
- Month/quarter/year

## Thu Tu Trien Khai ETL

1. Load `dim_date`.
2. Load geography dimensions: `dim_country`, `dim_state_province`, `dim_city`.
3. Load lookup dimensions: customer category, buying group, delivery method, payment method, transaction type, package type, stock group, person.
4. Load `dim_supplier`, `dim_customer`, `dim_product`.
5. Load `bridge_product_stock_group`.
6. Load detail facts: `fact_sales_invoice_line`, `fact_order_fulfillment_line`, `fact_customer_transaction`.
7. Load aggregate facts: `fact_business_kpi_month`, `fact_customer_kpi_month`.

