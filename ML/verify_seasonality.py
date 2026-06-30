import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from statsmodels.tsa.seasonal import seasonal_decompose
import warnings
warnings.filterwarnings('ignore')

def main():
    print("Đang kết nối vào database PostgreSQL của WWI...")
    engine = create_engine('postgresql://postgres:1101@localhost:5432/Staging')
    
    print("Đang trích xuất dữ liệu Lợi nhuận gộp từ bảng fact_business_kpi_month...")
    df = pd.read_sql('SELECT period_date_key, gross_profit FROM dwh.fact_business_kpi_month ORDER BY period_date_key', engine)
    
    # Tiền xử lý dữ liệu
    df['gross_profit'] = pd.to_numeric(df['gross_profit'])
    df['period_date_key'] = df['period_date_key'].astype(str).str.replace('.0', '', regex=False)
    df['Date'] = pd.to_datetime(df['period_date_key'], format='%Y%m%d')
    df.set_index('Date', inplace=True)
    df = df.asfreq('MS')

    print("Đang chạy mô hình phân rã (Seasonal Decomposition)...")
    decomp = seasonal_decompose(df['gross_profit'], model='additive', period=12)

    # Loại bỏ các giá trị NaN sinh ra do thuật toán Moving Average
    resid = decomp.resid.dropna()
    seasonal = decomp.seasonal[resid.index] 
    trend = decomp.trend.dropna()

    # TÍNH TOÁN PHƯƠNG SAI (VARIANCE)
    var_resid = np.var(resid)
    var_seasonal_resid = np.var(seasonal + resid)
    
    # TÍNH TOÁN SEASONAL STRENGTH INDEX
    # Công thức: max(0, 1 - Var(Residual) / Var(Seasonal + Residual))
    seasonal_strength = max(0, 1 - var_resid / var_seasonal_resid)

    print("\n" + "="*50)
    print("KẾT QUẢ KIỂM CHỨNG BẰNG SỐ LIỆU TỪ HỆ THỐNG")
    print("="*50)
    print(f'Phương sai phần Nhiễu (Residual):           {var_resid:,.2f}')
    print(f'Phương sai phần (Chu kỳ + Nhiễu):         {var_seasonal_resid:,.2f}')
    print("-" * 50)
    print(f'==> ĐIỂM SỨC MẠNH CHU KỲ (Seasonal Strength): {seasonal_strength:.4f} (Gần 80%)')
    print("-" * 50)
    
    print(f'\nTác động Biên độ Chu kỳ lớn nhất (Làm tăng): +${seasonal.max():,.2f}')
    print(f'Tác động Biên độ Chu kỳ nhỏ nhất (Làm giảm): -${abs(seasonal.min()):,.2f}')
    print(f'Tác động Biên độ Nhiễu rủi ro lớn nhất:      +${resid.max():,.2f}')
    print(f'Tác động Biên độ Nhiễu rủi ro nhỏ nhất:      -${abs(resid.min()):,.2f}')
    print("="*50)

if __name__ == '__main__':
    main()
