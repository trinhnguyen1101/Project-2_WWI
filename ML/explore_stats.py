import pandas as pd
from sqlalchemy import create_engine
import scipy.stats as stats
import warnings
warnings.filterwarnings('ignore')

def main():
    engine = create_engine('postgresql://postgres:1101@localhost:5432/Staging')
    
    # Check H1_new: Delivery Method vs Quantity Sold (T-test for top 2 delivery methods)
    print("\n--- H1_new: Delivery Method vs Quantity Sold (T-test) ---")
    query_h1 = """
        SELECT dm.delivery_method_name, s.quantity_sold
        FROM dwh.fact_sales_invoice_line s
        JOIN dwh.dim_customer c ON s.customer_key = c.customer_key
        JOIN dwh.dim_delivery_method dm ON c.delivery_method_key = dm.delivery_method_key
    """
    df_h1 = pd.read_sql(query_h1, engine)
    counts = df_h1['delivery_method_name'].value_counts()
    print("Delivery Methods:\n", counts)
    if len(counts) >= 2:
        top1, top2 = counts.index[0], counts.index[1]
        g1 = df_h1[df_h1['delivery_method_name'] == top1]['quantity_sold']
        g2 = df_h1[df_h1['delivery_method_name'] == top2]['quantity_sold']
        t_stat, p_val = stats.ttest_ind(g1, g2, equal_var=False)
        print(f"Top 1 '{top1}' mean: {g1.mean():.2f}")
        print(f"Top 2 '{top2}' mean: {g2.mean():.2f}")
        print(f"T-test: T={t_stat:.4f}, p={p_val:.4f}")
        
    # Check H3_new: Pearson correlation between quantity_sold and average_selling_price_ex_tax
    print("\n--- H3_new: Quantity Sold vs Average Selling Price ---")
    query_h3 = """
        SELECT quantity_sold, average_selling_price_ex_tax
        FROM dwh.fact_sales_invoice_line
        WHERE quantity_sold > 0 AND average_selling_price_ex_tax IS NOT NULL
    """
    df_h3 = pd.read_sql(query_h3, engine)
    
    df_h3['quantity_sold'] = pd.to_numeric(df_h3['quantity_sold'], errors='coerce')
    df_h3['average_selling_price_ex_tax'] = pd.to_numeric(df_h3['average_selling_price_ex_tax'], errors='coerce')
    df_h3 = df_h3.dropna()
    
    if len(df_h3) > 0:
        corr, p_val3 = stats.pearsonr(df_h3['quantity_sold'], df_h3['average_selling_price_ex_tax'])
        print(f"N = {len(df_h3)}")
        print(f"Correlation: r = {corr:.4f}, p = {p_val3:.4f}")

if __name__ == '__main__':
    main()
