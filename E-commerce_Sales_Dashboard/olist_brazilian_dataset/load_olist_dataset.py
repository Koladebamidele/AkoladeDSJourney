import os
import pandas as pd
from sqlalchemy import create_engine

# ==========================================
# 1. DATABASE CONFIGURATION
# ==========================================
# Choose your platform: 'postgres' or 'mysql'
db_platform = 'postgres'  # Change to 'mysql' if you want to use MySQL instead of PostgreSQL

username = 'postgres'  # Change to your database username
password = 250899
host = 'localhost'
port = '5432' if db_platform == 'postgres' else '3306'
db_name = 'Olist_Brazilian'  # Ensure this database is already created in your SQL client

# Create the connection engine based on your platform choice
if db_platform == 'postgres':
    engine = create_engine(f'postgresql://{username}:{password}@{host}:{port}/{db_name}')
elif db_platform == 'mysql':
    engine = create_engine(f'mysql+pymysql://{username}:{password}@{host}:{port}/{db_name}')

# ==========================================
# 2. AUTOMATIC SCANNING & LOADING LOOP
# ==========================================
# Scan the current folder for all CSV files
csv_files = [f for f in os.listdir('.') if f.endswith('.csv')]

print(f"Found {len(csv_files)} CSV files. Starting automatic database import...")

for file in csv_files:
    # 1. Clean the filename to create a professional SQL table name
    table_name = file.replace('.csv', '').replace('_dataset', '')
    print(f"\nProcessing table: '{table_name}' from file '{file}'...")
    
    # 2. Read the CSV file into Python memory
    # We load it as chunks or strings first to let pandas auto-detect columns and types
    df = pd.read_csv(file, low_memory=False)
    
    # 3. CONVERT DATE COLUMNS AUTOMATICALLY
    # If a column name has 'timestamp' or 'date' in it, convert it to an actual datetime data type
    for col in df.columns:
        if 'date' in col.lower() or 'timestamp' in col.lower():
            df[col] = pd.to_datetime(df[col], errors='coerce')
            
    print(f"→ Detected headers: {list(df.columns)}")
    
    # 4. Create table and push data to SQL
    # if_exists='replace' deletes an old table if it exists, creates it with matching headers, and loads data
    df.to_sql(name=table_name, con=engine, if_exists='replace', index=False, chunksize=5000)
    print(f"✅ Successfully created and loaded table '{table_name}' with {len(df)} rows.")

print("\n🚀 All tables successfully loaded without writing a single column header name!")
