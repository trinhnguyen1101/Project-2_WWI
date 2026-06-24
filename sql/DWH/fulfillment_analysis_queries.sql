-- Fulfillment analytics for dwh.fact_order_fulfillment_line
-- Source schema: dwh
-- Targets: Fill rate, backorder rate, picker performance, product/region fulfillment, revenue correlation.

-- 1. Fill Rate theo thời gian (ngày và tháng)
SELECT
    d.full_date AS date,
    AVG(f.fill_rate) AS avg_fill_rate,
    SUM(f.picked_quantity) AS total_picked_quantity,
    SUM(f.ordered_quantity) AS total_ordered_quantity,
    CASE WHEN SUM(f.ordered_quantity) = 0 THEN NULL
         ELSE SUM(f.picked_quantity) / NULLIF(SUM(f.ordered_quantity), 0)
    END AS fill_rate_by_qty
FROM dwh.fact_order_fulfillment_line f
JOIN dwh.dim_date d ON f.order_date_key = d.date_key
GROUP BY d.full_date
ORDER BY d.full_date;

-- Monthly fill rate
SELECT
    d.year_number,
    d.month_number,
    d.month_name,
    AVG(f.fill_rate) AS avg_fill_rate,
    SUM(f.picked_quantity) AS total_picked_quantity,
    SUM(f.ordered_quantity) AS total_ordered_quantity,
    CASE WHEN SUM(f.ordered_quantity) = 0 THEN NULL
         ELSE SUM(f.picked_quantity) / NULLIF(SUM(f.ordered_quantity), 0)
    END AS fill_rate_by_qty
FROM dwh.fact_order_fulfillment_line f
JOIN dwh.dim_date d ON f.order_date_key = d.date_key
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number, d.month_number;

-- 2. Backorder Rate theo thời gian
SELECT
    d.full_date AS date,
    COUNT(*) AS lines_count,
    SUM(CASE WHEN f.is_undersupply_backordered THEN 1 ELSE 0 END) AS backorder_lines,
    AVG(CASE WHEN f.is_undersupply_backordered THEN 1.0 ELSE 0.0 END) AS backorder_rate,
    SUM(CASE WHEN f.is_undersupply_backordered THEN f.unpicked_quantity ELSE 0 END) AS backordered_quantity
FROM dwh.fact_order_fulfillment_line f
JOIN dwh.dim_date d ON f.order_date_key = d.date_key
GROUP BY d.full_date
ORDER BY d.full_date;

-- Backorder rate theo tháng
SELECT
    d.year_number,
    d.month_number,
    d.month_name,
    COUNT(*) AS lines_count,
    SUM(CASE WHEN f.is_undersupply_backordered THEN 1 ELSE 0 END) AS backorder_lines,
    AVG(CASE WHEN f.is_undersupply_backordered THEN 1.0 ELSE 0.0 END) AS backorder_rate,
    SUM(CASE WHEN f.is_undersupply_backordered THEN f.unpicked_quantity ELSE 0 END) AS backordered_quantity
FROM dwh.fact_order_fulfillment_line f
JOIN dwh.dim_date d ON f.order_date_key = d.date_key
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number, d.month_number;

-- 3. Sản phẩm hay thiếu hàng
SELECT
    p.product_key,
    p.stock_item_name AS product_name,
    sg.stock_group_name,
    COUNT(*) AS order_lines_count,
    SUM(f.ordered_quantity) AS total_ordered_quantity,
    SUM(f.picked_quantity) AS total_picked_quantity,
    SUM(f.unpicked_quantity) AS total_unpicked_quantity,
    AVG(f.fill_rate) AS avg_fill_rate,
    SUM(CASE WHEN f.is_undersupply_backordered THEN 1 ELSE 0 END) AS backorder_lines,
    AVG(CASE WHEN f.is_undersupply_backordered THEN 1.0 ELSE 0.0 END) AS backorder_rate
FROM dwh.fact_order_fulfillment_line f
JOIN dwh.dim_product p ON f.product_key = p.product_key
LEFT JOIN dwh.bridge_product_stock_group bpg ON p.product_key = bpg.product_key
LEFT JOIN dwh.dim_stock_group sg ON bpg.stock_group_key = sg.stock_group_key
GROUP BY p.product_key, p.stock_item_name, sg.stock_group_name
ORDER BY backorder_rate DESC NULLS LAST, avg_fill_rate ASC NULLS LAST, total_unpicked_quantity DESC
LIMIT 50;

-- 4. Khu vực hay thiếu hàng (dựa trên khu vực giao hàng của khách hàng)
SELECT
    COALESCE(sp.sales_territory, st.city_name, 'Unknown') AS region_name,
    COUNT(*) AS order_lines_count,
    SUM(f.ordered_quantity) AS total_ordered_quantity,
    SUM(f.picked_quantity) AS total_picked_quantity,
    SUM(f.unpicked_quantity) AS total_unpicked_quantity,
    AVG(f.fill_rate) AS avg_fill_rate,
    SUM(CASE WHEN f.is_undersupply_backordered THEN 1 ELSE 0 END) AS backorder_lines,
    AVG(CASE WHEN f.is_undersupply_backordered THEN 1.0 ELSE 0.0 END) AS backorder_rate
FROM dwh.fact_order_fulfillment_line f
JOIN dwh.dim_customer c ON f.customer_key = c.customer_key
LEFT JOIN dwh.dim_city st ON c.delivery_city_key = st.city_key
LEFT JOIN dwh.dim_state_province sp ON st.state_province_key = sp.state_province_key
GROUP BY COALESCE(sp.sales_territory, st.city_name, 'Unknown')
ORDER BY backorder_rate DESC NULLS LAST, avg_fill_rate ASC NULLS LAST, total_unpicked_quantity DESC
LIMIT 50;

-- 5. Hiệu suất picker
SELECT
    pi.person_key AS picker_key,
    pi.full_name AS picker_name,
    COUNT(*) AS order_lines_count,
    SUM(f.ordered_quantity) AS total_ordered_quantity,
    SUM(f.picked_quantity) AS total_picked_quantity,
    SUM(f.unpicked_quantity) AS total_unpicked_quantity,
    AVG(f.fill_rate) AS avg_fill_rate,
    AVG(f.picking_lead_time_hours) AS avg_picking_lead_time_hours,
    SUM(CASE WHEN f.is_fully_picked THEN 1 ELSE 0 END) AS fully_picked_lines,
    AVG(CASE WHEN f.is_fully_picked THEN 1.0 ELSE 0.0 END) AS pct_fully_picked
FROM dwh.fact_order_fulfillment_line f
LEFT JOIN dwh.dim_person pi ON f.picker_key = pi.person_key
GROUP BY pi.person_key, pi.full_name
ORDER BY avg_fill_rate ASC NULLS LAST, avg_picking_lead_time_hours DESC NULLS LAST
LIMIT 50;

-- 6. Fulfillment theo sản phẩm/khu vực kết hợp doanh thu
-- 6.1 Mối liên hệ Fulfillment và doanh thu theo sản phẩm
WITH product_fulfillment AS (
    SELECT
        f.product_key,
        AVG(f.fill_rate) AS avg_fill_rate,
        AVG(f.picking_lead_time_hours) AS avg_picking_lead_time_hours,
        SUM(f.ordered_quantity) AS ordered_quantity,
        SUM(f.unpicked_quantity) AS unpicked_quantity,
        SUM(CASE WHEN f.is_undersupply_backordered THEN 1 ELSE 0 END) AS backorder_lines,
        AVG(CASE WHEN f.is_undersupply_backordered THEN 1.0 ELSE 0.0 END) AS backorder_rate
    FROM dwh.fact_order_fulfillment_line f
    GROUP BY f.product_key
),
product_revenue AS (
    SELECT
        s.product_key,
        SUM(s.revenue_ex_tax) AS total_revenue_ex_tax,
        SUM(s.revenue_inc_tax) AS total_revenue_inc_tax,
        SUM(s.quantity_sold) AS total_quantity_sold
    FROM dwh.fact_sales_invoice_line s
    GROUP BY s.product_key
)
SELECT
    p.product_key,
    p.stock_item_name AS product_name,
    pf.avg_fill_rate,
    pf.avg_picking_lead_time_hours,
    pf.ordered_quantity,
    pf.unpicked_quantity,
    pf.backorder_lines,
    pf.backorder_rate,
    pr.total_revenue_ex_tax,
    pr.total_revenue_inc_tax,
    pr.total_quantity_sold,
    COALESCE(pr.total_revenue_ex_tax, 0) / NULLIF(pf.ordered_quantity, 0) AS revenue_per_ordered_qty
FROM product_fulfillment pf
JOIN dwh.dim_product p ON pf.product_key = p.product_key
LEFT JOIN product_revenue pr ON pf.product_key = pr.product_key
ORDER BY pf.avg_fill_rate ASC NULLS LAST, pr.total_revenue_ex_tax DESC NULLS LAST
LIMIT 100;

-- 6.2 Mối liên hệ Fulfillment và doanh thu theo khách hàng
WITH customer_fulfillment AS (
    SELECT
        f.customer_key,
        AVG(f.fill_rate) AS avg_fill_rate,
        AVG(f.picking_lead_time_hours) AS avg_picking_lead_time_hours,
        SUM(f.ordered_quantity) AS ordered_quantity,
        SUM(f.unpicked_quantity) AS unpicked_quantity,
        SUM(CASE WHEN f.is_undersupply_backordered THEN 1 ELSE 0 END) AS backorder_lines,
        AVG(CASE WHEN f.is_undersupply_backordered THEN 1.0 ELSE 0.0 END) AS backorder_rate
    FROM dwh.fact_order_fulfillment_line f
    GROUP BY f.customer_key
),
customer_revenue AS (
    SELECT
        s.customer_key,
        SUM(s.revenue_ex_tax) AS total_revenue_ex_tax,
        SUM(s.revenue_inc_tax) AS total_revenue_inc_tax,
        SUM(s.quantity_sold) AS total_quantity_sold
    FROM dwh.fact_sales_invoice_line s
    GROUP BY s.customer_key
)
SELECT
    c.customer_key,
    c.customer_name,
    cf.avg_fill_rate,
    cf.avg_picking_lead_time_hours,
    cf.ordered_quantity,
    cf.unpicked_quantity,
    cf.backorder_lines,
    cf.backorder_rate,
    cr.total_revenue_ex_tax,
    cr.total_revenue_inc_tax,
    cr.total_quantity_sold,
    COALESCE(cr.total_revenue_ex_tax, 0) / NULLIF(cf.ordered_quantity, 0) AS revenue_per_ordered_qty
FROM customer_fulfillment cf
JOIN dwh.dim_customer c ON cf.customer_key = c.customer_key
LEFT JOIN customer_revenue cr ON cf.customer_key = cr.customer_key
ORDER BY cf.avg_fill_rate ASC NULLS LAST, cr.total_revenue_ex_tax DESC NULLS LAST
LIMIT 100;

-- 7. Dashboard fulfillment: metric summary cho KPI chính
SELECT
    SUM(f.ordered_quantity) AS total_ordered_quantity,
    SUM(f.picked_quantity) AS total_picked_quantity,
    SUM(f.unpicked_quantity) AS total_unpicked_quantity,
    AVG(f.fill_rate) AS overall_fill_rate,
    AVG(f.picking_lead_time_hours) AS overall_avg_picking_lead_time_hours,
    AVG(CASE WHEN f.is_undersupply_backordered THEN 1.0 ELSE 0.0 END) AS overall_backorder_rate,
    AVG(CASE WHEN f.is_fully_picked THEN 1.0 ELSE 0.0 END) AS overall_fully_picked_rate
FROM dwh.fact_order_fulfillment_line f;
