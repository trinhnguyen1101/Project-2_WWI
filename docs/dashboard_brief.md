# Hướng dẫn Thiết kế Dashboard (Dashboard Context & Guidelines)

Tài liệu này tóm tắt toàn bộ bối cảnh dữ liệu (Context) hiện tại của dự án, giải thích các Data Marts đã được xây dựng và gợi ý các bước công việc cụ thể để nhóm triển khai lên Power BI (hoặc Tableau).

---

## 1. Bối Cảnh Dữ Liệu Hiện Tại (Current Context)

- **Trạng thái Kỹ thuật:** Toàn bộ quá trình ETL (trích xuất, biến đổi, nạp) và Trí tuệ Nhân tạo (Machine Learning K-Means) đã **hoàn tất 100%**. Dữ liệu sạch sẽ, không lỗi và đã nằm sẵn trong CSDL PostgreSQL (Schema `datamart`).
- **Đặc thù Dữ liệu (Rất quan trọng):** Dữ liệu của Wide World Importers là một "bản chụp" (snapshot) tính đến cuối tháng **05/2016**.
  - Đối với các năm 2013, 2014, 2015: Tổng dư nợ (`outstanding_amount`) và Số lượng hàng rớt (`unpicked_quantity`) sẽ bằng `0` do các giao dịch lịch sử này đã hoàn tất/thanh toán xong.
  - Phân tích Công nợ & Rớt đơn chỉ nên lọc (Filter) dữ liệu trong khoảng năm 2016.

---

## 2. Cấu Trúc và Ý Nghĩa Của Các Data Marts

Hệ thống Data Warehouse đã tự động tạo ra 5 SQL Views (Data Marts) và 1 Bảng (Table). Mỗi Data Mart là một "Bảng siêu rộng" (Wide-Table) chứa sẵn toàn bộ thông tin (tên sản phẩm, nhóm khách hàng, thời gian...) nhằm triệt tiêu tối đa việc phải viết hàm DAX hay JOIN bảng phức tạp trong Power BI.

| Tên Data Mart | Phân công | Ý nghĩa và Dữ liệu cốt lõi |
| :--- | :--- | :--- |
| **`dm_sales`** | Nguyên | Phục vụ báo cáo **Doanh thu & Lợi nhuận**. Chứa chi tiết từng hóa đơn, bao gồm: Doanh thu (trước/sau thuế), Lợi nhuận gộp, Lợi nhuận trên từng sản phẩm (Profit per Unit), Tên Sản phẩm, Tên Salesperson. |
| **`dm_fulfillment`** | Chiến | Phục vụ báo cáo **Chuỗi cung ứng (Fulfillment)**. Chứa chi tiết giao hàng, bao gồm: Số lượng yêu cầu, Số lượng đã nhặt (picked), Tỷ lệ lấp đầy (Fill Rate), Thời gian lấy hàng (Lead time hours). |
| **`dm_receivables`** | Duy | Phục vụ báo cáo **Tài chính & Công nợ**. Chứa lịch sử giao dịch thanh toán: Số tiền hóa đơn, Số tiền chưa trả (outstanding), Số ngày quá hạn, Trạng thái nợ xấu (is_overdue). |
| **`dm_customer_360`** | Phúc | Phục vụ **Hồ sơ Khách hàng (360 độ)**. Là dữ liệu tổng hợp theo từng tháng của khách hàng: Tổng doanh thu mang lại, Giá trị trung bình đơn (AOV), Số lần mua. |
| **`ml_customer_clusters`**| Phúc | Bảng chứa **Kết quả AI Phân cụm**. Chứa `customer_name` và `segment_name` (Nhãn: Mua nhiều, Rủi ro, Vãng lai...). *Cần nối bảng này với `dm_customer_360` trên Power BI.* |
| **`dm_monthly_business_kpi`**| (Dùng chung)| Bảng **Tổng hợp cấp Công ty**. Đã tính sẵn tổng Doanh thu, Lợi nhuận, Tỷ lệ lấp đầy, DSO (Thời gian thu tiền trung bình) của từng tháng. Dùng để vẽ Trend Line (Xu hướng) cấp tập đoàn. |

---

## 3. Các Công Việc Gợi Ý Cần Thực Hiện Trên Power BI

Để chia việc hiệu quả và tối ưu hóa Dashboard, nhóm nên tuân theo quy trình 4 bước sau:

### Bước 1: Kết nối Nguồn dữ liệu (Data Source)
1. Mở Power BI, chọn **Get Data > PostgreSQL**.
2. Nhập `localhost:5432`, DB `Staging`.
3. Đăng nhập bằng `postgres` / `1101`. Lấy toàn bộ các bảng trong schema `datamart`.

### Bước 2: Mô hình hóa dữ liệu (Data Modeling)
Power BI sẽ tự động tải các bảng rời rạc. Tuy nhiên, Phúc cần vào tab **Model View** để kéo nối (Create Relationship) giữa cột `customer_name` của bảng `dm_customer_360` với cột `customer_name` của bảng `ml_customer_clusters` (Relationship: One-to-Many).

### Bước 3: Viết các chỉ số đo lường nâng cao (DAX Measures)
Dù Data Mart đã tính sẵn rất nhiều, nhóm vẫn nên viết một số DAX cơ bản để biểu đồ tương tác mượt mà hơn. Gợi ý:
- **Nguyên (Sales):** `YTD Revenue = TOTALYTD(SUM(dm_sales[revenue_ex_tax]), dm_sales[invoice_date])`
- **Chiến (Fulfillment):** `Average Fill Rate = AVERAGE(dm_fulfillment[fill_rate])`
- **Duy (Finance):** `Total Bad Debt = CALCULATE(SUM(dm_receivables[outstanding_amount]), dm_receivables[is_overdue] = TRUE)`

### Bước 4: Xây dựng Giao diện (Dashboard Layout & Visuals)
Mỗi thành viên nên tạo 1 Page riêng biệt trên Power BI File chung:

1. **Page 1: Executive Summary (Tổng quan):** Dùng bảng `dm_monthly_business_kpi`. Gợi ý: Line chart xu hướng Doanh thu/Lợi nhuận 3 năm.
2. **Page 2: Sales Performance (Nguyên):** Gợi ý: Bar chart Top 10 Sản phẩm bán chạy; Pie chart Tỷ trọng lợi nhuận theo Nhóm khách hàng.
3. **Page 3: Supply Chain (Chiến):** Gợi ý: Gauge chart hiển thị Average Fill Rate (Mục tiêu > 95%); Scatter chart giữa Lead Time và Rớt hàng.
4. **Page 4: Accounts Receivable (Duy):** Gợi ý: Waterfall chart dòng tiền nợ đọng; Bảng chi tiết những Khách hàng nợ quá hạn lâu nhất.
5. **Page 5: AI Customer Insights (Phúc):** Gợi ý: Treemap/Donut chart tỷ lệ các tệp Khách hàng (từ kết quả Machine Learning); Phân tích hành vi RFM của nhóm "Khách VIP".
