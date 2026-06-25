import os
import argparse
import pandas as pd
from sqlalchemy import create_engine
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

def get_db_url(args):
    host = args.host or os.environ.get("PGHOST", "localhost")
    port = args.port or os.environ.get("PGPORT", "5432")
    dbname = args.database or os.environ.get("PGDATABASE", "Staging")
    user = args.user or os.environ.get("PGUSER", "postgres")
    password = args.password or os.environ.get("PGPASSWORD", "1101")
    return f"postgresql://{user}:{password}@{host}:{port}/{dbname}"

def main():
    parser = argparse.ArgumentParser(description="Customer Segmentation using K-Means")
    parser.add_argument("--host", default=None)
    parser.add_argument("--port", default=None)
    parser.add_argument("--database", default=None)
    parser.add_argument("--user", default=None)
    parser.add_argument("--password", default=None)
    parser.add_argument("--output", default="customer_segments.csv", help="Output CSV file for the results")
    parser.add_argument("--clusters", default=4, type=int, help="Number of clusters (k)")
    args = parser.parse_args()

    engine = create_engine(get_db_url(args))

    # Query to aggregate customer lifetime value from the monthly KPIs
    query = """
    SELECT 
        customer_name,
        SUM(revenue_ex_tax) AS total_revenue,
        SUM(gross_profit) AS total_profit,
        CASE WHEN SUM(revenue_ex_tax) = 0 THEN 0 ELSE SUM(gross_profit) / SUM(revenue_ex_tax) END AS avg_gross_margin,
        SUM(invoice_count) AS total_invoices,
        CASE WHEN SUM(invoice_count) = 0 THEN 0 ELSE SUM(revenue_ex_tax) / SUM(invoice_count) END AS avg_order_value,
        SUM(quantity_sold) AS total_quantity,
        SUM(outstanding_amount) AS total_outstanding,
        AVG(average_days_to_collect) AS avg_days_to_collect,
        AVG(average_days_past_due) AS avg_days_past_due,
        AVG(overdue_transaction_rate) AS avg_overdue_rate
    FROM datamart.dm_customer_360
    WHERE customer_name IS NOT NULL AND customer_name != 'Unknown'
    GROUP BY customer_name
    """
    
    print("Fetching data from datamart...")
    df = pd.read_sql(query, engine)
    
    # Fill NaN values which might occur due to divisions or missing measures
    df.fillna(0, inplace=True)
    
    print(f"Data fetched: {len(df)} customers found.")
    
    if len(df) == 0:
        print("No data available to cluster.")
        return

    # Select features for clustering
    features = [
        'total_revenue', 'total_profit', 'avg_gross_margin', 
        'total_invoices', 'avg_order_value', 'total_quantity', 
        'total_outstanding', 'avg_days_to_collect', 
        'avg_days_past_due', 'avg_overdue_rate'
    ]
    
    X = df[features]
    
    # Scale features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # K-Means clustering
    k = args.clusters
    print(f"Applying K-Means with k={k}...")
    kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
    df['cluster'] = kmeans.fit_predict(X_scaled)
    
    # Name clusters dynamically (simple heuristic based on revenue and overdue rate)
    # This maps cluster labels to more meaningful business names
    cluster_means = df.groupby('cluster')[['total_revenue', 'avg_overdue_rate']].mean()
    
    # Rank clusters by revenue
    revenue_ranks = cluster_means['total_revenue'].rank(ascending=False)
    overdue_ranks = cluster_means['avg_overdue_rate'].rank(ascending=False)
    
    def assign_segment(row):
        cluster_id = row['cluster']
        rev_rank = revenue_ranks[cluster_id]
        od_rank = overdue_ranks[cluster_id]
        
        if rev_rank == 1 and od_rank > 2:
            return "Khách hàng VIP"
        elif rev_rank <= 2 and od_rank <= 2:
            return "Giá trị cao, Rủi ro công nợ"
        elif df[df['cluster'] == cluster_id]['total_invoices'].mean() > df['total_invoices'].mean():
            return "Khách hàng mua thường xuyên"
        else:
            return "Khách hàng ít hoạt động"
            
    df['segment_name'] = df.apply(assign_segment, axis=1)
    
    # Save to CSV
    output_path = os.path.join(os.path.dirname(__file__), args.output)
    df.to_csv(output_path, index=False, encoding='utf-8-sig')
    print(f"Clustering complete. Results saved to {output_path}")

    # Optionally, write back to database
    try:
        df[['customer_name', 'cluster', 'segment_name']].to_sql(
            'ml_customer_clusters', 
            engine, 
            schema='datamart', 
            if_exists='replace', 
            index=False
        )
        print("Successfully saved cluster results to datamart.ml_customer_clusters table.")
    except Exception as e:
        print(f"Warning: Could not save to DB. Error: {e}")

if __name__ == "__main__":
    main()
