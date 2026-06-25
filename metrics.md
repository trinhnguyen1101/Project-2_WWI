# Sổ tay Chỉ số Kinh doanh và Vận hành (Commercial & Operational Metrics)

Dựa trên cấu trúc Data Warehouse hiện tại (tập trung vào Bán hàng, Giao nhận và Công nợ Phải thu), dưới đây là danh sách các chỉ số (Metrics) được theo dõi và đo lường thông qua các Datamarts.

| Phân loại | Tên chỉ số (Metric) | Ý nghĩa | Công thức / Cách tính trong DWH |
| :--- | :--- | :--- | :--- |
| **Bán hàng & Sinh lời** | Doanh thu thuần (Net Revenue) | Tổng doanh thu bán hàng chưa bao gồm thuế. | `SUM(revenue_ex_tax)` |
| **Bán hàng & Sinh lời** | Lợi nhuận gộp (Gross Profit) | Lợi nhuận thu được sau khi trừ đi giá vốn hàng bán. | `SUM(gross_profit)` |
| **Bán hàng & Sinh lời** | Tỷ suất LN gộp (Gross Margin) | 1 đồng doanh thu tạo ra bao nhiêu đồng lợi nhuận gộp. | `SUM(gross_profit) / SUM(revenue_ex_tax)` |
| **Bán hàng & Sinh lời** | Giá trị đơn hàng trung bình (AOV) | Trung bình mỗi hóa đơn mang lại bao nhiêu doanh thu. | `SUM(revenue_inc_tax) / COUNT(DISTINCT invoice_id)` |
| **Bán hàng & Sinh lời** | Lợi nhuận trên Đơn vị (Profit/Unit) | Mỗi sản phẩm bán ra mang lại bao nhiêu lợi nhuận. | `SUM(gross_profit) / SUM(quantity_sold)` |
| **Kho vận (Fulfillment)** | Tỷ lệ lấp đầy (Fill Rate) | Khả năng đáp ứng ngay lập tức yêu cầu số lượng của khách. | `SUM(picked_quantity) / SUM(ordered_quantity)` |
| **Kho vận (Fulfillment)** | Tỷ lệ thiếu hàng (Backorder Rate) | Tỷ lệ số lượng hàng không đủ giao và phải chờ (Backorder). | `SUM(unpicked_quantity) / SUM(ordered_quantity)` |
| **Kho vận (Fulfillment)** | Thời gian chuẩn bị hàng (Picking Lead Time) | Thời gian trung bình (giờ) để kho nhặt xong hàng từ lúc có đơn. | `AVG(picking_lead_time_hours)` |
| **Công nợ Phải thu (AR)** | Vòng quay khoản phải thu (AR Turnover) | Khả năng thu hồi vốn công nợ trong kỳ. | `Doanh thu / Dư nợ Phải thu bình quân` |
| **Công nợ Phải thu (AR)** | Kỳ thu tiền bình quân (DSO) | Số ngày trung bình cần thiết để thu hồi nợ từ khách hàng. | `365 / AR Turnover` hoặc `AVG(days_to_collect)` |
| **Công nợ Phải thu (AR)** | Tỷ lệ nợ quá hạn (Overdue Rate) | Phản ánh chất lượng khoản phải thu và rủi ro tín dụng. | `SUM(past_due_amount) / SUM(outstanding_amount)` |
| **Hành vi Khách hàng** | Tần suất mua hàng | Số lượng hóa đơn trung bình của một khách hàng trong tháng. | `COUNT(invoice_id) / COUNT(DISTINCT customer_id)` |