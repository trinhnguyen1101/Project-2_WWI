# Kiến trúc Hệ thống & Cấu trúc Dự án (System Architecture)

Tài liệu này cung cấp cái nhìn tổng quan về kiến trúc của hệ thống Data Warehouse đang được triển khai cho dự án **"Tối ưu hóa Lợi nhuận, Tồn kho và Vốn Lưu động tại Doanh nghiệp Bán buôn"**.

---

## 1. Cấu trúc Thư mục (Directory Structure)

Dự án được tổ chức chặt chẽ theo các phase của một vòng đời dữ liệu chuẩn:

```text
Project-2_WWI/
├── data/                       # Dữ liệu nguồn (Source Data)
│   └── processed/clean_missing/ # Các file CSV đã được làm sạch, đóng vai trò như CSDL nghiệp vụ.
├── sql/                        # Kịch bản cơ sở dữ liệu (DDL & DML)
│   ├── Staging/                # Script tạo các bảng lưu tạm (staging) để hứng dữ liệu từ CSV.
│   └── DWH/                    # Script thiết kế Data Warehouse (dwh_design.sql) và Data Marts (datamarts.sql).
├── ETL/                        # Logic luân chuyển và biến đổi dữ liệu (Extract - Transform - Load)
│   ├── init_db.py              # Script Python tự động nạp CSV vào Staging và khởi tạo View.
│   ├── load_clean_missing_to_postgres.py # Logic đọc CSV và COPY vào DB cực nhanh.
│   └── hop/                    # Dự án Apache Hop
│       ├── workflows/          # Luồng thực thi cấp cao (Dimensions chạy trước, Facts chạy sau).
│       └── pipelines/          # Các luồng ánh xạ dữ liệu chi tiết (.hpl).
├── ML/                         # Machine Learning & AI
│   ├── customer_segmentation.py# Script Python thuật toán K-Means phân cụm khách hàng.
│   └── requirements.txt        # Thư viện yêu cầu (pandas, scikit-learn).
├── docs/                       # Tài liệu dự án (Metrics, Architecture).
├── docker-compose.yml          # Trái tim của hạ tầng, bọc toàn bộ hệ thống vào container.
└── run_pipeline.bat            # Script chạy tự động (One-click Run) toàn bộ hệ thống.
```

---

## 2. Triết lý Thiết kế: Data Warehouse (Tổng kho) vs Data Mart (Quầy bán lẻ)

Để phục vụ tốt nhất cho các thành viên trong nhóm, kiến trúc dữ liệu được chia làm 2 tầng rõ rệt:

### Tầng 1: Data Warehouse (DWH) - "Tổng kho khổng lồ"
- **Vị trí**: Schema `dwh` trong PostgreSQL.
- **Mục đích**: Chứa **tất cả** dữ liệu thô và đã qua xử lý từ hệ thống bán hàng, kho bãi, và kế toán. Nó là nơi hội tụ chung (Single source of truth) của các bảng Facts khổng lồ như `fact_sales_invoice_line`, `fact_order_fulfillment_line`, `fact_customer_transaction`.

### Tầng 2: Data Marts (DM) - "Các quầy chuyên biệt"
Vì DWH quá lớn và phức tạp để truy vấn nhanh, hệ thống đã tự động cắt DWH ra thành các Data Mart chuyên biệt (được xây dựng dưới dạng SQL View trong Schema `datamart`), tối ưu hóa cho từng nhóm nghiệp vụ:

1. **Sales Data Mart (`dm_sales`)**: Dành riêng cho phân tích Doanh thu & Lợi nhuận (Nguyên).
2. **Fulfillment Data Mart (`dm_fulfillment`)**: Dành riêng cho Chuỗi cung ứng, điều phối kho và thời gian lấy hàng (Chiến).
3. **Finance Data Mart (`dm_receivables`)**: Dành riêng cho Dòng tiền, Công nợ và thời hạn thanh toán (Duy).
4. **Customer 360 DM (`dm_customer_360`)**: Dành riêng cho thuật toán phân cụm khách hàng bằng Machine Learning (Phúc).

Kiến trúc này giúp mỗi thành viên tập trung tối đa vào bài toán của mình mà không bị ngợp bởi dữ liệu của người khác, đồng thời tăng tốc độ truy vấn cho các công cụ BI (Power BI / Tableau) lên gấp nhiều lần.

---

## 3. Luồng luân chuyển dữ liệu (Data Pipeline Flow)

Hệ thống hoạt động hoàn toàn tự động theo thứ tự 5 bước:
1. **Khởi tạo**: Các file `.csv` được nạp thẳng vào Schema `staging` bằng Python (Sử dụng lệnh COPY của Postgres để tối ưu tốc độ).
2. **DWH Dimensions**: Apache Hop đọc dữ liệu từ `staging`, xử lý và đẩy vào các bảng Danh mục (Dimensions) trong Schema `dwh`.
3. **DWH Facts**: Apache Hop tiếp tục dò tìm khoá ngoại (Lookups) từ Dimensions để chuyển hoá dữ liệu giao dịch thành các bảng Sự kiện (Facts) trong Schema `dwh`.
4. **Data Marts**: PostgreSQL tự động tính toán các Metrics (Gross Margin, Fill Rate, DSO,...) và phơi bày ra Schema `datamart`.
5. **Machine Learning**: Script Python K-Means đọc dữ liệu từ `dm_customer_360`, dán nhãn phân cụm khách hàng và lưu ngược kết quả lại vào bảng `datamart.ml_customer_clusters`.
