# DWH Measure Catalog

## Chủ Đề

Chủ đề chính: **phân tích hiệu quả bán hàng và lợi nhuận theo sản phẩm, khách hàng và khu vực**.

DWH được rút gọn còn 3 fact:

| Fact | Vai trò |
|---|---|
| `fact_sales_invoice_line` | Fact lõi cho doanh thu, lợi nhuận, biên lợi nhuận |
| `fact_order_fulfillment_line` | Fact phụ để đánh giá khả năng đáp ứng đơn hàng |
| `fact_customer_transaction` | Fact phụ để đánh giá chất lượng thu tiền và công nợ |

Các phân tích tồn kho như inventory movement, inventory snapshot, reorder và inventory turnover đã được bỏ khỏi scope này để tránh làm chủ đề quá rộng.

## Nguyên Tắc Thiết Kế

- Dimension lưu thuộc tính mô tả tương đối tĩnh: tên khách hàng, nhóm khách hàng, khu vực, tên sản phẩm, supplier, stock group, payment days, lead time.
- Fact lưu khóa liên kết, mã giao dịch nguồn để truy vết, và các measure/flag phục vụ phân tích.
- SCD Type 2 không được cài trong DDL hiện tại. Nếu cần lưu lịch sử thuộc tính, xử lý ở giai đoạn ETL rồi mở rộng dimension sau.
- Các bảng `_Archive` chưa cần dùng trong scope hiện tại, trừ khi ETL được mở rộng để nạp SCD.

## Fact Sales Invoice Line

Grain: một dòng hóa đơn bán hàng, tương ứng `Sales.InvoiceLines`.

Nguồn chính:

- `Sales_InvoiceLines`
- `Sales_Invoices`
- `Sales_Customers`
- `Warehouse_StockItems`

| Measure | Ý nghĩa | Công thức | Trường nguồn |
|---|---|---|---|
| `quantity_sold` | Số lượng bán ở dòng hóa đơn | `Quantity` | `Sales_InvoiceLines.Quantity` |
| `revenue_ex_tax` | Doanh thu chưa gồm thuế | `ExtendedPrice - TaxAmount` | `ExtendedPrice`, `TaxAmount` |
| `tax_amount` | Thuế của dòng hóa đơn | `TaxAmount` | `TaxAmount` |
| `revenue_inc_tax` | Doanh thu gồm thuế | `ExtendedPrice` | `ExtendedPrice` |
| `gross_profit` | Lợi nhuận gộp dòng hàng | `LineProfit` | `LineProfit` |
| `estimated_cogs` | Giá vốn ước tính | `revenue_ex_tax - gross_profit` | `ExtendedPrice`, `TaxAmount`, `LineProfit` |
| `gross_margin_pct` | Biên lợi nhuận gộp | `gross_profit / revenue_ex_tax` | Measure đã tính |
| `average_selling_price_ex_tax` | Giá bán bình quân chưa thuế | `revenue_ex_tax / quantity_sold` | Measure đã tính |
| `profit_per_unit` | Lợi nhuận gộp trên mỗi đơn vị | `gross_profit / quantity_sold` | Measure đã tính |

Lưu ý: `ExtendedPrice` trong dữ liệu WWI đã bao gồm thuế. Ví dụ dòng đầu tiên có `Quantity * UnitPrice = 2300`, `TaxAmount = 345`, `ExtendedPrice = 2645`.

Phân tích phù hợp:

- Sản phẩm nào tạo doanh thu và lợi nhuận cao nhất.
- Nhóm khách hàng nào có biên lợi nhuận tốt nhất.
- Khu vực nào bán tốt nhưng biên lợi nhuận thấp.
- Supplier hoặc stock group nào đóng góp lợi nhuận tốt.
- Doanh thu, lợi nhuận và biên lợi nhuận theo tháng/quý/năm.

## Fact Order Fulfillment Line

Grain: một dòng đơn hàng, tương ứng `Sales.OrderLines`.

Nguồn chính:

- `Sales_OrderLines`
- `Sales_Orders`
- `Sales_Customers`
- `Warehouse_StockItems`

| Measure | Ý nghĩa | Công thức | Trường nguồn |
|---|---|---|---|
| `ordered_quantity` | Số lượng khách đặt | `Quantity` | `Sales_OrderLines.Quantity` |
| `picked_quantity` | Số lượng đã pick | `PickedQuantity` | `Sales_OrderLines.PickedQuantity` |
| `unpicked_quantity` | Số lượng chưa pick | `Quantity - PickedQuantity` | `Quantity`, `PickedQuantity` |
| `fill_rate` | Tỷ lệ đáp ứng dòng hàng | `PickedQuantity / Quantity` | Measure đã tính |
| `picking_lead_time_hours` | Thời gian từ ngày đặt đến lúc pick xong | `PickingCompletedWhen - OrderDate`, quy đổi giờ | `PickingCompletedWhen`, `OrderDate` |
| `expected_delivery_lead_days` | Lead time giao hàng dự kiến | `ExpectedDeliveryDate - OrderDate` | `ExpectedDeliveryDate`, `OrderDate` |
| `is_undersupply_backordered` | Có backorder do thiếu hàng không | `IsUndersupplyBackordered` | `Sales_Orders.IsUndersupplyBackordered` |
| `is_fully_picked` | Dòng hàng đã pick đủ chưa | `PickedQuantity >= Quantity` | `PickedQuantity`, `Quantity` |

Phân tích phù hợp:

- Sản phẩm nào có nhu cầu đặt cao nhưng fill rate thấp.
- Nhóm khách hàng nào thường có đơn hàng chưa được đáp ứng đủ.
- Việc fulfill kém có đi kèm doanh thu/lợi nhuận thấp hơn không.
- Sản phẩm hoặc stock group nào thường phát sinh backorder.

## Fact Customer Transaction

Grain: một giao dịch công nợ khách hàng, tương ứng `Sales.CustomerTransactions`.

Nguồn chính:

- `Sales_CustomerTransactions`
- `Sales_Customers`
- `Application_PaymentMethods`
- `Application_TransactionTypes`

| Measure | Ý nghĩa | Công thức | Trường nguồn |
|---|---|---|---|
| `receivable_ex_tax` | Giá trị giao dịch chưa thuế | `AmountExcludingTax` | `AmountExcludingTax` |
| `receivable_tax_amount` | Thuế của giao dịch | `TaxAmount` | `TaxAmount` |
| `receivable_inc_tax` | Giá trị giao dịch gồm thuế | `TransactionAmount` | `TransactionAmount` |
| `outstanding_amount` | Số tiền còn chưa tất toán | `OutstandingBalance` | `OutstandingBalance` |
| `paid_amount` | Số tiền đã thanh toán/tất toán | `TransactionAmount - OutstandingBalance` | `TransactionAmount`, `OutstandingBalance` |
| `outstanding_ratio` | Tỷ lệ còn nợ | `OutstandingBalance / TransactionAmount` | Measure đã tính |
| `days_to_collect` | Số ngày từ giao dịch đến tất toán | `FinalizationDate - TransactionDate` | `FinalizationDate`, `TransactionDate` |
| `is_finalized` | Giao dịch đã tất toán hay chưa | `IsFinalized` | `IsFinalized` |
| `is_overdue` | Có trả chậm so với điều khoản không | `days_to_collect > dim_customer.payment_days` | Measure + `payment_days` |

Phân tích phù hợp:

- Khách hàng hoặc nhóm khách hàng nào tạo doanh thu cao nhưng trả chậm.
- Nhóm khách hàng nào có tỷ lệ outstanding cao.
- Doanh thu có lợi nhuận tốt nhưng chất lượng thu tiền kém nằm ở đâu.
- Mối liên hệ giữa `payment_days`, `credit_limit`, `is_on_credit_hold` và trả chậm.

## Chỉ Số Tổng Hợp

| Chỉ số | Ý nghĩa | Công thức DWH |
|---|---|---|
| Total Revenue Ex Tax | Tổng doanh thu chưa thuế | `SUM(revenue_ex_tax)` |
| Total Gross Profit | Tổng lợi nhuận gộp | `SUM(gross_profit)` |
| Gross Margin | Biên lợi nhuận gộp | `SUM(gross_profit) / SUM(revenue_ex_tax)` |
| Estimated COGS | Giá vốn ước tính | `SUM(estimated_cogs)` |
| Average Selling Price | Giá bán bình quân | `SUM(revenue_ex_tax) / SUM(quantity_sold)` |
| Profit Per Unit | Lợi nhuận bình quân mỗi đơn vị | `SUM(gross_profit) / SUM(quantity_sold)` |
| Average Order Value | Giá trị trung bình mỗi hóa đơn | `SUM(revenue_ex_tax) / COUNT(DISTINCT source_invoice_id)` |
| Fill Rate | Tỷ lệ đáp ứng đơn hàng | `SUM(picked_quantity) / SUM(ordered_quantity)` |
| Backorder Rate | Tỷ lệ dòng đơn có backorder | `AVG(CASE WHEN is_undersupply_backordered THEN 1 ELSE 0 END)` |
| Receivable Outstanding Ratio | Tỷ lệ công nợ còn lại | `SUM(outstanding_amount) / SUM(receivable_inc_tax)` |
| Average Days To Collect | Số ngày thu tiền trung bình | `AVG(days_to_collect)` |

## Giả Định Có Thể Kiểm Định

| Giả định | Cách kiểm định | Dữ liệu/measure |
|---|---|---|
| Nhóm sản phẩm có `gross_margin_pct` cao tạo lợi nhuận ổn định hơn nhóm margin thấp | So sánh `gross_profit`, `quantity_sold`, `revenue_ex_tax` theo stock group/product | `fact_sales_invoice_line`, `dim_product`, `dim_stock_group` |
| Khu vực có doanh thu cao chưa chắc có biên lợi nhuận cao | So sánh `revenue_ex_tax` và `gross_margin_pct` theo city/state/country | `fact_sales_invoice_line`, `dim_city` |
| Sản phẩm có fill rate thấp làm giảm doanh thu thực nhận hoặc lợi nhuận | So sánh `fill_rate` với `revenue_ex_tax`, `gross_profit` theo product/stock group | `fact_order_fulfillment_line`, `fact_sales_invoice_line` |
| Khách hàng có doanh thu/lợi nhuận cao chưa chắc có chất lượng thu tiền tốt | So sánh `gross_profit`, `days_to_collect`, `outstanding_ratio` theo customer/category | `fact_sales_invoice_line`, `fact_customer_transaction` |
| Khách hàng có `payment_days` dài hoặc `is_on_credit_hold = true` dễ trả chậm hơn | Logistic regression hoặc chi-square với label `is_overdue` | `fact_customer_transaction`, `dim_customer` |

## ML Phù Hợp Với Scope Này

1. Dự báo doanh thu hoặc số lượng bán theo sản phẩm-tháng.
   - Target: `SUM(quantity_sold)` hoặc `SUM(revenue_ex_tax)` kỳ tiếp theo.
   - Feature: lịch sử bán, stock group, supplier, unit price, gross margin, tháng/quý.

2. Phân cụm khách hàng theo giá trị và chất lượng thu tiền.
   - Feature: total revenue, gross profit, gross margin, số hóa đơn, average order value, days to collect, outstanding ratio.

3. Dự đoán giao dịch/khách hàng có nguy cơ trả chậm.
   - Target: `is_overdue`.
   - Feature: payment days, credit limit, customer category, buying group, lịch sử outstanding ratio, lịch sử days to collect.

## Thứ Tự Triển Khai ETL

1. Nạp `dim_date`.
2. Nạp các dimension lookup: country, state province, city, customer category, buying group, delivery method, payment method, transaction type, package type, stock group, person.
3. Nạp `dim_supplier`, `dim_customer`, `dim_product`, `bridge_product_stock_group`.
4. Nạp `fact_sales_invoice_line`.
5. Nạp `fact_order_fulfillment_line`.
6. Nạp `fact_customer_transaction`.
