import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import scipy.stats as stats
import warnings
warnings.filterwarnings('ignore')

def main():
    print("Đang kết nối vào database PostgreSQL của WWI...")
    engine = create_engine('postgresql://postgres:1101@localhost:5432/Staging')
    
    print("\n" + "="*70)
    print("KIỂM CHỨNG 1: Tần suất mua hàng vs AOV")
    print("="*70)
    df_h1 = pd.read_sql("SELECT invoice_count, average_order_value FROM dwh.fact_customer_kpi_month WHERE average_order_value IS NOT NULL", engine).dropna()
    df_h1['invoice_count'] = pd.to_numeric(df_h1['invoice_count'])
    df_h1['average_order_value'] = pd.to_numeric(df_h1['average_order_value'])
    corr1, p_val1 = stats.pearsonr(df_h1['invoice_count'], df_h1['average_order_value'])
    print(f"Số lượng mẫu quan sát (N) : {len(df_h1):,}")
    print(f"Hệ số tương quan (r)      : {corr1:.4f}")
    print(f"P-value                   : {p_val1:.4e}")

    print("\n" + "="*70)
    print("KIỂM CHỨNG 2: AOV vs Tỷ suất lợi nhuận gộp")
    print("="*70)
    df_h2 = pd.read_sql("SELECT average_order_value, gross_margin_pct FROM dwh.fact_customer_kpi_month WHERE average_order_value IS NOT NULL AND gross_margin_pct IS NOT NULL", engine).dropna()
    df_h2['average_order_value'] = pd.to_numeric(df_h2['average_order_value'])
    df_h2['gross_margin_pct'] = pd.to_numeric(df_h2['gross_margin_pct'])
    corr2, p_val2 = stats.pearsonr(df_h2['average_order_value'], df_h2['gross_margin_pct'])
    print(f"Số lượng mẫu quan sát (N) : {len(df_h2):,}")
    print(f"Hệ số tương quan (r)      : {corr2:.4f}")
    print(f"P-value                   : {p_val2:.4e}")

    print("\n" + "="*70)
    print("KIỂM CHỨNG 3: Thời gian chuẩn bị hàng vs Tỷ lệ lấp đầy")
    print("="*70)
    df_h3 = pd.read_sql("""
        SELECT AVG(picking_lead_time_hours) as avg_pick, SUM(picked_quantity)/NULLIF(SUM(ordered_quantity), 0) as fill_rate
        FROM dwh.fact_order_fulfillment_line GROUP BY order_date_key
    """, engine).dropna()
    corr3, p_val3 = stats.pearsonr(df_h3['avg_pick'], df_h3['fill_rate'])
    print(f"Số lượng mẫu (N - Ngày)   : {len(df_h3):,}")
    print(f"Hệ số tương quan (r)      : {corr3:.4f}")
    print(f"P-value                   : {p_val3:.4f}")

    print("\n" + "="*70)
    print("KIỂM CHỨNG 4: Phân tích Tỷ suất LN theo Nhóm Khách Hàng (ANOVA)")
    print("="*70)
    df_h4 = pd.read_sql("""
        SELECT cc.customer_category_name, k.gross_margin_pct 
        FROM dwh.fact_customer_kpi_month k 
        JOIN dwh.dim_customer c ON k.customer_key = c.customer_key 
        JOIN dwh.dim_customer_category cc ON c.customer_category_key = cc.customer_category_key 
        WHERE k.gross_margin_pct IS NOT NULL
    """, engine)
    df_h4['gross_margin_pct'] = pd.to_numeric(df_h4['gross_margin_pct'])
    categories = df_h4['customer_category_name'].unique()
    groups = [df_h4[df_h4['customer_category_name'] == cat]['gross_margin_pct'].dropna() for cat in categories if len(df_h4[df_h4['customer_category_name'] == cat]['gross_margin_pct'].dropna()) > 0]
    f_stat, p_val4 = stats.f_oneway(*groups)
    print(f"Số nhóm khách hàng (k)    : {len(groups)}")
    print(f"Trị số F (F-statistic)    : {f_stat:.4f}")
    print(f"P-value                   : {p_val4:.4f}")

    print("\n" + "="*70)
    print("KIỂM CHỨNG 5: Hàng Đông Lạnh (Chiller Stock) vs Lợi Nhuận")
    print("="*70)
    df_h5 = pd.read_sql("""
        SELECT p.is_chiller_stock, sil.gross_profit / NULLIF(sil.revenue_ex_tax, 0) as gross_margin_pct
        FROM dwh.fact_sales_invoice_line sil
        JOIN dwh.dim_product p ON sil.product_key = p.product_key
        WHERE sil.revenue_ex_tax > 0
    """, engine).dropna()
    g1 = df_h5[df_h5['is_chiller_stock'] == True]['gross_margin_pct']
    g2 = df_h5[df_h5['is_chiller_stock'] == False]['gross_margin_pct']
    t_stat, p_val5 = stats.ttest_ind(g1, g2, equal_var=False)
    print(f"Mức LN Hàng Lạnh (Chiller) : {g1.mean()*100:.2f}%")
    print(f"Mức LN Hàng Thường (Normal): {g2.mean()*100:.2f}%")
    print(f"Trị số T (T-stat)          : {t_stat:.4f}")
    print(f"P-value                    : {p_val5:.4e}")
    print("="*70 + "\n")

if __name__ == '__main__':
    main()
