import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from statsmodels.tsa.seasonal import seasonal_decompose
from statsmodels.graphics.tsaplots import plot_acf
import scipy.stats as stats
import warnings
warnings.filterwarnings('ignore')

def main():
    print("Connecting to database...")
    engine = create_engine('postgresql://postgres:1101@localhost:5432/Staging')
    
    # Fetch historical profit data
    query = """
        SELECT period_date_key, gross_profit 
        FROM dwh.fact_business_kpi_month 
        ORDER BY period_date_key
    """
    df = pd.read_sql(query, engine)
    
    df['period_date_key'] = df['period_date_key'].astype(str).str.replace('.0', '', regex=False)
    df['Date'] = pd.to_datetime(df['period_date_key'], format='%Y%m%d')
    df['gross_profit'] = pd.to_numeric(df['gross_profit'])
    
    df.set_index('Date', inplace=True)
    df = df.asfreq('MS')
    ts = df['gross_profit']

    # =========================================================================
    # 1. PHÂN RÃ CHUỖI THỜI GIAN (SEASONAL DECOMPOSITION)
    # =========================================================================
    print("Generating Seasonal Decomposition...")
    decomp = seasonal_decompose(ts, model='additive', period=12)
    fig = decomp.plot()
    fig.set_size_inches(10, 8)
    fig.suptitle('Phân rã chuỗi thời gian Lợi Nhuận Gộp', fontsize=14)
    plt.tight_layout()
    decomp_path = 'c:/Users/phucb/Documents/Code/Project-2_WWI/seasonality_decomposition.png'
    plt.savefig(decomp_path)
    plt.close()

    # =========================================================================
    # 2. HÀM TỰ TƯƠNG QUAN (AUTOCORRELATION FUNCTION - ACF)
    # =========================================================================
    print("Generating ACF Plot...")
    plt.figure(figsize=(10, 5))
    # plot ACF up to 24 lags (2 years)
    plot_acf(ts, lags=24, ax=plt.gca(), title='Hàm Tự Tương Quan (ACF) - Lợi Nhuận Gộp')
    plt.xlabel('Lag (Số tháng trễ)')
    plt.ylabel('Hệ số tương quan')
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.tight_layout()
    acf_path = 'c:/Users/phucb/Documents/Code/Project-2_WWI/seasonality_acf.png'
    plt.savefig(acf_path)
    plt.close()

    # =========================================================================
    # 3. KIỂM ĐỊNH ANOVA THEO THÁNG TRONG NĂM
    # =========================================================================
    print("Running ANOVA for months...")
    df['Month'] = df.index.month
    groups = [df[df['Month'] == i]['gross_profit'] for i in range(1, 13) if len(df[df['Month'] == i]) > 0]
    
    if len(groups) == 12:
        f_stat, p_val = stats.f_oneway(*groups)
        print(f"ANOVA Test for Seasonality (Months): F={f_stat:.4f}, p={p_val:.4f}")

    # =========================================================================
    # 4. FORECASTING (HOLT-WINTERS)
    # =========================================================================
    print("Fitting Holt-Winters Exponential Smoothing model (Seasonal)...")
    model = ExponentialSmoothing(ts, trend='add', seasonal='add', seasonal_periods=12)
    model_fit = model.fit()
    
    forecast_steps = 12
    forecast = model_fit.forecast(forecast_steps)
    forecast_index = pd.date_range(start=ts.index[-1] + pd.DateOffset(months=1), periods=forecast_steps, freq='MS')
    
    plt.figure(figsize=(10, 6))
    plt.plot(ts.index, ts.values, label='Lợi nhuận gộp thực tế (Historical)', color='blue', marker='o')
    plt.plot(forecast_index, forecast.values, label='Dự báo (Forecast - Seasonal)', color='red', marker='x', linestyle='--')
    plt.plot(ts.index, model_fit.fittedvalues, label='Khớp mô hình (Fitted)', color='green', linestyle=':', alpha=0.6)
    
    plt.title('Dự Báo Lợi Nhuận Gộp (Mô hình Holt-Winters có tính chu kỳ)', fontsize=14)
    plt.xlabel('Thời gian', fontsize=12)
    plt.ylabel('Lợi nhuận gộp (USD)', fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend()
    plt.tight_layout()
    
    image_path = 'c:/Users/phucb/Documents/Code/Project-2_WWI/forecast_chart.png'
    plt.savefig(image_path)
    plt.close()
    
    print("Done generating all seasonal evidence and forecast charts.")

if __name__ == '__main__':
    main()
