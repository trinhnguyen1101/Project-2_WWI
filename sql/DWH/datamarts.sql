CREATE SCHEMA IF NOT EXISTS datamart;

-- A. Doanh thu và lợi nhuận
CREATE OR REPLACE VIEW datamart.dm_sales AS
SELECT
    d.full_date AS invoice_date,
    d.year_number,
    d.month_number,
    d.quarter_number,
    c.customer_name,
    cc.customer_category_name AS customer_category,
    p.stock_item_name AS product_name,
    p.brand,
    p.color_name,
    sp.full_name AS salesperson_name,
    f.quantity_sold,
    f.revenue_ex_tax,
    f.revenue_inc_tax,
    f.gross_profit,
    f.estimated_cogs,
    f.gross_margin_pct,
    f.average_selling_price_ex_tax,
    f.profit_per_unit
FROM dwh.fact_sales_invoice_line f
LEFT JOIN dwh.dim_date d ON f.invoice_date_key = d.date_key
LEFT JOIN dwh.dim_customer c ON f.customer_key = c.customer_key
LEFT JOIN dwh.dim_customer_category cc ON c.customer_category_key = cc.customer_category_key
LEFT JOIN dwh.dim_product p ON f.product_key = p.product_key
LEFT JOIN dwh.dim_person sp ON f.salesperson_key = sp.person_key;

-- B. Fulfillment (Đáp ứng đơn hàng)
CREATE OR REPLACE VIEW datamart.dm_fulfillment AS
SELECT
    d.full_date AS order_date,
    d.year_number,
    d.month_number,
    c.customer_name,
    p.stock_item_name AS product_name,
    pk.full_name AS picker_name,
    f.ordered_quantity,
    f.picked_quantity,
    f.unpicked_quantity,
    f.fill_rate,
    f.picking_lead_time_hours,
    f.expected_delivery_lead_days,
    f.is_undersupply_backordered,
    f.is_fully_picked
FROM dwh.fact_order_fulfillment_line f
LEFT JOIN dwh.dim_date d ON f.order_date_key = d.date_key
LEFT JOIN dwh.dim_customer c ON f.customer_key = c.customer_key
LEFT JOIN dwh.dim_product p ON f.product_key = p.product_key
LEFT JOIN dwh.dim_person pk ON f.picker_key = pk.person_key;

-- C. Công nợ khách hàng
CREATE OR REPLACE VIEW datamart.dm_receivables AS
SELECT
    d.full_date AS transaction_date,
    d.year_number,
    d.month_number,
    c.customer_name,
    pm.payment_method_name,
    tt.transaction_type_name,
    f.receivable_inc_tax,
    f.outstanding_amount,
    f.paid_amount,
    f.outstanding_ratio,
    f.days_to_collect,
    f.collection_age_days,
    f.days_past_due,
    f.current_ar_amount,
    f.past_due_amount,
    f.is_finalized,
    f.is_overdue
FROM dwh.fact_customer_transaction f
LEFT JOIN dwh.dim_date d ON f.transaction_date_key = d.date_key
LEFT JOIN dwh.dim_customer c ON f.customer_key = c.customer_key
LEFT JOIN dwh.dim_payment_method pm ON f.payment_method_key = pm.payment_method_key
LEFT JOIN dwh.dim_transaction_type tt ON f.transaction_type_key = tt.transaction_type_key;

-- D. Customer 360° (Tổng hợp theo tháng)
CREATE OR REPLACE VIEW datamart.dm_customer_360 AS
SELECT
    d.full_date AS period_start_date,
    d.year_number,
    d.month_number,
    c.customer_name,
    cc.customer_category_name AS customer_category,
    c.credit_limit,
    c.payment_days,
    c.is_on_credit_hold,
    f.revenue_ex_tax,
    f.gross_profit,
    f.gross_margin_pct,
    f.quantity_sold,
    f.profit_per_unit,
    f.invoice_count,
    f.average_order_value,
    f.sales_growth_rate,
    f.outstanding_amount,
    f.current_ar_ratio,
    f.average_days_to_collect,
    f.average_days_past_due,
    f.overdue_transaction_rate
FROM dwh.fact_customer_kpi_month f
LEFT JOIN dwh.dim_date d ON f.period_date_key = d.date_key
LEFT JOIN dwh.dim_customer c ON f.customer_key = c.customer_key
LEFT JOIN dwh.dim_customer_category cc ON c.customer_category_key = cc.customer_category_key;

-- E. Monthly Business KPI (Tổng hợp toàn công ty theo tháng)
CREATE OR REPLACE VIEW datamart.dm_monthly_business_kpi AS
SELECT
    d.full_date AS period_start_date,
    d.year_number,
    d.month_number,
    f.revenue_ex_tax AS net_revenue,
    f.gross_profit,
    f.gross_margin_pct,
    f.profit_per_unit,
    f.quantity_sold,
    f.invoice_count,
    f.average_order_value,
    f.sales_growth_rate,
    f.outstanding_amount AS total_ar,
    f.past_due_amount,
    f.receivable_outstanding_ratio,
    f.average_days_to_collect AS dso_days,
    f.overdue_transaction_rate
FROM dwh.fact_business_kpi_month f
LEFT JOIN dwh.dim_date d ON f.period_date_key = d.date_key;

