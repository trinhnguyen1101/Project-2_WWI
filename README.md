# World Wide Importers - Modern Data Warehouse Project

Dự án này xây dựng một hệ thống Kho dữ liệu (Data Warehouse) hoàn chỉnh từ dữ liệu thô (CSV) theo chuẩn kiến trúc dữ liệu hiện đại, bao gồm ETL bằng Apache Hop, mô hình hóa dữ liệu (Datamarts), và ứng dụng Machine Learning để phân cụm khách hàng. Toàn bộ hệ thống được chạy tự động trên Docker.

## 🌟 Kiến trúc hệ thống
1. **PostgreSQL**: Lưu trữ toàn bộ dữ liệu ở 2 phân vùng logic là Schema `staging` và Schema `dwh` (bao gồm các Datamarts).
2. **Apache Hop**: Công cụ ETL kéo thả tự động hóa luồng luân chuyển và biến đổi dữ liệu (Dimensions và Facts).
3. **Machine Learning (Python)**: Chạy K-Means Clustering để phân cụm khách hàng.

## 🚀 Hướng dẫn chạy dự án (End-to-End)

Mở Terminal (hoặc PowerShell) tại thư mục chứa dự án và chạy lần lượt các bước sau:

### Bước 1: Khởi động Hạ tầng
Lệnh này sẽ khởi động Database và giao diện thiết kế Apache Hop Web.
```bash
docker-compose up -d postgres apache-hop-web hop-server
```
*(Tip: Bạn có thể truy cập Hop Web qua `http://localhost:8080`)*

### Bước 2: Tự động khởi tạo và Nạp dữ liệu thô (Staging)
Lệnh này kích hoạt container `init-db`. Container này sẽ đọc các file `*_clean.csv` trong thư mục `data/` và đẩy vào bảng Staging của DB, tự động nạp các khoá Unknown (-1, 0) và tạo các View báo cáo cho Datamart.
```bash
docker-compose up init-db
```
*(Chờ khoảng 1 phút đến khi màn hình báo `init-db exited với code 0`)*

### Bước 3: Chạy tiến trình ETL (Apache Hop)
Lệnh này ép Hop Server chạy ngầm để kéo dữ liệu từ Staging, làm sạch, mapping khoá ngoại và nạp vào Data Warehouse (Chạy Dimensions trước, Facts sau).
```bash
docker-compose run --rm --entrypoint /bin/bash hop-server -c "/opt/hop/hop-run.sh -j local -r local -f /files/projects/local/workflows/wf_duy_dimensions.hwf && /opt/hop/hop-run.sh -j local -r local -f /files/projects/local/workflows/wf_duy_facts.hwf"
```
*(Quá trình nạp Facts khối lượng lớn có thể tốn 5-10 phút tuỳ cấu hình máy)*

### Bước 4: Chạy Mô hình Học máy (Machine Learning)
Phân cụm toàn bộ khách hàng bằng thuật toán AI (K-Means) vào 4 nhóm/phân khúc để phục vụ BI Dashboard. Dùng container Python độc lập để không làm rác máy tính cá nhân.
```bash
docker run --rm --network apache-hop-etl_default -v "%cd%:/app" -w /app python:3.9-slim bash -c "pip install -r ML/requirements.txt && python ML/customer_segmentation.py --host postgres --database Staging --user postgres --password 1101"
```
*(Nếu bạn dùng macOS/Linux, vui lòng đổi `%cd%` thành `$PWD`)*.

---

## 📂 Cấu trúc Thư mục Chính
- `docker-compose.yml` & `.env`: Cấu hình môi trường.
- `data/`: Dữ liệu thô CSV đầu vào.
- `sql/`: Các kịch bản tạo bảng (`staging`, `dwh`) và các báo cáo (`datamarts.sql`).
- `ETL/`: Chứa mã nguồn Python tương tác với DB và toàn bộ dự án Apache Hop (`ETL/hop/projects/local/`).
- `ML/`: Chứa script Machine Learning và kết quả dán nhãn (`customer_segments.csv`).

## 🛠 Xử lý sự cố thường gặp
- **Lỗi kết nối DBeaver (Múi giờ `Asia/Saigon`)**: DBeaver không hỗ trợ múi giờ này. Cách khắc phục: Chuột phải Connection trong DBeaver > Edit Connection > Driver Properties > Thêm hoặc sửa thuộc tính `options` thành `-c TimeZone=Asia/Ho_Chi_Minh`.