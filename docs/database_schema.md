# Từ điển Dữ liệu và Kiến trúc PostgreSQL (Data Dictionary & DB Architecture)

Dự án sử dụng hệ quản trị cơ sở dữ liệu **PostgreSQL**. Tuy chúng ta chỉ dùng chung 1 Database vật lý (tên là `Staging` để tiện cấu hình Docker), nhưng về mặt logic, kiến trúc dữ liệu được cô lập nghiêm ngặt thành 3 **Schemas** (lược đồ) đại diện cho 3 giai đoạn của quá trình ETL.

---

## 1. Schema `staging` (Vùng dữ liệu thô)
**Mục đích:** Nơi tiếp nhận trực tiếp dữ liệu từ các file CSV đầu vào. Dữ liệu ở đây có cấu trúc y hệt file gốc (Source System), không có khoá ngoại (Foreign Key) phức tạp, chủ yếu dùng kiểu dữ liệu cơ bản (Varchar, Numeric).
**Các bảng chính:**
- **Sales:** `stg_sales_orders`, `stg_sales_order_lines`, `stg_sales_invoices`, `stg_sales_invoice_lines`, `stg_sales_customer_transactions`, `stg_sales_customers`, `stg_sales_customercategories`, `stg_sales_buyinggroups`
- **Warehouse:** `stg_warehouse_stockitems`, `stg_warehouse_stockgroups`, `stg_warehouse_colors`, `stg_warehouse_packagetypes`
- **Purchasing:** `stg_purchasing_suppliers`, `stg_purchasing_suppliercategories`
- **Application (Hệ thống):** `stg_application_people`, `stg_application_cities`, `stg_application_countries`, `stg_application_deliverymethods`, v.v.

---

## 2. Schema `dwh` (Data Warehouse - Kho dữ liệu trung tâm)
**Mục đích:** Là "Trái tim" của hệ thống, được thiết kế theo mô hình **Star/Snowflake Schema**. Dữ liệu ở đây đã được Apache Hop làm sạch, ép kiểu (Data Types), nối khoá ngoại (Surrogate Keys) và xử lý lịch sử.

### Bảng Danh mục (Dimensions / Dim)
Chứa thông tin tra cứu (Ai, Cái gì, Ở đâu, Khi nào).
- `dim_date`: Bảng thời gian chuẩn (chứa ngày, tháng, quý, năm, weekend).
- `dim_customer`: Thông tin khách hàng (hạn mức tín dụng, phương thức giao hàng...).
- `dim_product`: Thông tin sản phẩm (tên, giá, cân nặng, thương hiệu).
- `dim_person`: Nhân viên kinh doanh, người nhặt hàng (Pickers).
- `dim_supplier`, `dim_city`, `dim_country`, `dim_state_province`,...

### Bảng Sự kiện (Facts)
Chứa các con số giao dịch, đo lường (Bao nhiêu, Giá trị gì).
- `fact_sales_invoice_line`: Giao dịch bán hàng (Số lượng, Doanh thu, Lợi nhuận gộp).
- `fact_order_fulfillment_line`: Chi tiết thực thi kho vận (Slg yêu cầu, Slg đáp ứng, Fill rate, Lead time).
- `fact_customer_transaction`: Lịch sử thanh toán công nợ khách hàng (Tiền nợ, Số ngày quá hạn).
- `fact_business_kpi_month`: Bảng Fact dạng Aggregated (Tổng hợp sẵn) các KPI toàn công ty theo tháng.
- `fact_customer_kpi_month`: Bảng Fact dạng Aggregated tổng hợp KPI theo tháng cho từng khách hàng.

---

## 3. Schema `datamart` (Lớp Trình diễn - Presentation Layer)
**Mục đích:** Là nơi các công cụ BI (Power BI, Tableau) hoặc Machine Learning kết nối vào để lấy dữ liệu. Schema này hoàn toàn là các **SQL Views** (trừ kết quả ML), đã được `JOIN` sẵn Dimension và Fact để ra thành những bảng Rộng (Wide-Tables), triệt tiêu các câu lệnh SQL phức tạp cho End-user.

### Báo cáo và Dashboard (Views)
- **`dm_sales`**: Giao cho Bộ phận Kinh Doanh (Tập trung Doanh thu, Margin, Profit/Unit).
- **`dm_fulfillment`**: Giao cho Bộ phận Kho vận / Supply Chain (Tập trung Tỷ lệ lấp đầy, Tỷ lệ rớt đơn).
- **`dm_receivables`**: Giao cho Bộ phận Tài chính / Kế toán (DSO, Nợ đọng, Overdue).
- **`dm_customer_360`**: Góc nhìn 360 độ về một khách hàng trong tháng (Tần suất mua, Dư nợ trung bình, Doanh thu mang lại).
- **`dm_monthly_business_kpi`**: Tổng quan hiệu suất toàn công ty theo các tháng để vẽ biểu đồ Line/Trend.

### Kết quả Trí tuệ Nhân tạo (Machine Learning)
- **`ml_customer_clusters`**: (Physical Table) Đây là bảng kết quả sinh ra từ thuật toán K-Means (Python), chứa mã khách hàng và "Nhãn phân cụm" (VD: Khách hàng VIP, Khách mua thường xuyên, Rủi ro công nợ). Bảng này có thể được JOIN ngược lại vào các Datamarts để BI filter theo từng cụm khách hàng.
