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
    print("KIỂM CHỨNG GIẢ THUYẾT 1: Hàng Đông Lạnh (Chiller Stock) vs Lợi Nhuận")
    print("="*70)
    query_h1 = """
        SELECT p.is_chiller_stock, sil.gross_profit / NULLIF(sil.revenue_ex_tax, 0) as gross_margin_pct
        FROM dwh.fact_sales_invoice_line sil
        JOIN dwh.dim_product p ON sil.product_key = p.product_key
        WHERE sil.revenue_ex_tax > 0
    """
    df_h1 = pd.read_sql(query_h1, engine).dropna()
    g1 = df_h1[df_h1['is_chiller_stock'] == True]['gross_margin_pct']
    g2 = df_h1[df_h1['is_chiller_stock'] == False]['gross_margin_pct']
    t_stat, p_val1 = stats.ttest_ind(g1, g2, equal_var=False)
    
    print(f"Mức LN Hàng Lạnh (Chiller) : {g1.mean()*100:.2f}% (N={len(g1):,})")
    print(f"Mức LN Hàng Thường (Normal): {g2.mean()*100:.2f}% (N={len(g2):,})")
    print(f"Trị số T (T-stat)          : {t_stat:.4f}")
    print(f"P-value                    : {p_val1:.4e}")
    if p_val1 < 0.05:
        print("=> Kết luận: CÓ Ý NGHĨA THỐNG KÊ (Bác bỏ H0). Hàng lạnh có lợi nhuận thấp hơn.")
    else:
        print("=> Kết luận: KHÔNG CÓ Ý NGHĨA THỐNG KÊ.")

    print("\n" + "="*70)
    print("KIỂM CHỨNG GIẢ THUYẾT 2: Đơn giá sản phẩm vs Số lượng mua")
    print("="*70)
    query_h2 = """
        SELECT sil.quantity_sold, sil.revenue_ex_tax / NULLIF(sil.quantity_sold, 0) as unit_price
        FROM dwh.fact_sales_invoice_line sil
        WHERE sil.revenue_ex_tax > 0 AND sil.quantity_sold > 0
    """
    df_h2 = pd.read_sql(query_h2, engine).dropna()
    corr2, p_val2 = stats.pearsonr(df_h2['quantity_sold'], df_h2['unit_price'])
    
    print(f"Số lượng mẫu quan sát (N) : {len(df_h2):,}")
    print(f"Hệ số tương quan (r)      : {corr2:.4f}")
    print(f"P-value                   : {p_val2:.4e}")
    if p_val2 < 0.05:
        print("=> Kết luận: CÓ Ý NGHĨA THỐNG KÊ (Bác bỏ H0). Tương quan nghịch biến.")
    else:
        print("=> Kết luận: KHÔNG CÓ Ý NGHĨA THỐNG KÊ.")

    print("\n" + "="*70)
    print("KIỂM CHỨNG GIẢ THUYẾT 3: Phân tích Tỷ suất LN theo Nhóm Khách Hàng (ANOVA)")
    print("="*70)
    query_h3 = """
        SELECT cc.customer_category_name, k.gross_margin_pct 
        FROM dwh.fact_customer_kpi_month k 
        JOIN dwh.dim_customer c ON k.customer_key = c.customer_key 
        JOIN dwh.dim_customer_category cc ON c.customer_category_key = cc.customer_category_key 
        WHERE k.gross_margin_pct IS NOT NULL
    """
    df_h3 = pd.read_sql(query_h3, engine)
    df_h3['gross_margin_pct'] = pd.to_numeric(df_h3['gross_margin_pct'])
    
    categories = df_h3['customer_category_name'].unique()
    groups = [df_h3[df_h3['customer_category_name'] == cat]['gross_margin_pct'].dropna() for cat in categories if len(df_h3[df_h3['customer_category_name'] == cat]['gross_margin_pct'].dropna()) > 0]
    f_stat, p_val3 = stats.f_oneway(*groups)
    
    print(f"Số nhóm khách hàng (k)    : {len(groups)}")
    print(f"Trị số F (F-statistic)    : {f_stat:.4f}")
    print(f"P-value                   : {p_val3:.4f}")
    print("-" * 30)
    print("Chi tiết trung bình từng nhóm:")
    for cat in categories:
        grp = df_h3[df_h3['customer_category_name'] == cat]['gross_margin_pct'].dropna()
        print(f" - {cat.ljust(20)}: {grp.mean()*100:.2f}% (N={len(grp):,})")
    
    print("-" * 30)
    if p_val3 <= 0.055:
        print("=> Kết luận: CÓ SỰ KHÁC BIỆT MANG Ý NGHĨA THỐNG KÊ GIỮA CÁC NHÓM.")
    else:
        print("=> Kết luận: KHÔNG CÓ SỰ KHÁC BIỆT ĐÁNG KỂ.")
    print("="*70 + "\n")

if __name__ == '__main__':
    main()
