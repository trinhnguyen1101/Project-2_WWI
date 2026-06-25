@echo off
echo ===================================================
echo   WORLD WIDE IMPORTERS - DATA WAREHOUSE PIPELINE
echo ===================================================

echo.
echo [1/5] Khoi dong co so ha tang (PostgreSQL, Apache Hop)...
docker-compose up -d postgres apache-hop-web hop-server
timeout /t 5 /nobreak > NUL

echo.
echo [2/5] Khoi tao Database, Schema va Nap du lieu Staging...
docker-compose up init-db

echo.
echo [3/5] Chay luong ETL: Nhan ban Dimensions vao Data Warehouse...
docker-compose run --rm --entrypoint /bin/bash hop-server -c "/opt/hop/hop-run.sh -j local -r local -f /files/projects/local/workflows/wf_duy_dimensions.hwf"

echo.
echo [4/5] Chay luong ETL: Nhan ban Facts vao Data Warehouse (Vui long doi)...
docker-compose run --rm --entrypoint /bin/bash hop-server -c "/opt/hop/hop-run.sh -j local -r local -f /files/projects/local/workflows/wf_duy_facts.hwf"

echo.
echo [5/5] Chay thuat toan Machine Learning: Phan cum Khach hang...
docker run --rm --network apache-hop-etl_default -v "%cd%:/app" -w /app python:3.9-slim bash -c "pip install -r ML/requirements.txt && python ML/customer_segmentation.py --host postgres --database Staging --user postgres --password 1101"

echo.
echo ===================================================
echo PIPELINE DA HOAN TAT! 
echo Du lieu san sang trong schema 'datamart' de len PowerBI.
echo ===================================================
pause
