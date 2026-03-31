import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
import re

def to_snake_case(name):
    # Handle dashed words
    name = name.replace('-', '_')
    # Convert camelCase and PascalCase to snake_case
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    name = re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()
    return name

def main():
    # File path specified by the user
    csv_path = r"C:\Users\jai shree shyam\Desktop\project 2\credit-risk-analytics\data\cs-training.csv"
    
    print(f"Reading CSV from {csv_path}...")
    # 1. Read CSV using pandas
    try:
        df = pd.read_csv(csv_path)
    except FileNotFoundError:
        print(f"Error: The file at {csv_path} was not found.")
        return
    
    print("Cleaning data...")
    # 2. Handle null values in MonthlyIncome and NumberOfDependents by filling with median
    if 'MonthlyIncome' in df.columns:
        df['MonthlyIncome'] = df['MonthlyIncome'].fillna(df['MonthlyIncome'].median())
    if 'NumberOfDependents' in df.columns:
        df['NumberOfDependents'] = df['NumberOfDependents'].fillna(df['NumberOfDependents'].median())
        
    # 3. Remove duplicate rows
    initial_len = len(df)
    df = df.drop_duplicates()
    print(f"Removed {initial_len - len(df)} duplicate rows.")
    
    # 4. Rename columns to snake_case PostgreSQL-friendly names
    df.columns = [to_snake_case(col) for col in df.columns]
    
    # Handle NaN values for PostgreSQL (replace with None so psycopg2 inserts NULL properly)
    df = df.where(pd.notnull(df), None)
    
    # 5. Connect to PostgreSQL using psycopg2
    print("Connecting to PostgreSQL...")
    try:
        conn = psycopg2.connect(
            host="localhost",
            port=5432,
            database="creditrisk",
            user="postgres",
            password="Bhavya@123"
        )
        cur = conn.cursor()
    except Exception as e:
        print(f"Failed to connect to the database: {e}")
        return
    
    # 6. Create a table called customers if it doesn't exist
    print("Creating table if it doesn't exist...")
    
    # Dynamically determine SQL column types based on pandas dtypes
    sql_types = []
    for col, dtype in zip(df.columns, df.dtypes):
        if pd.api.types.is_integer_dtype(dtype):
            sql_types.append(f'"{col}" INTEGER')
        elif pd.api.types.is_float_dtype(dtype):
            sql_types.append(f'"{col}" DOUBLE PRECISION')
        elif pd.api.types.is_bool_dtype(dtype):
            sql_types.append(f'"{col}" BOOLEAN')
        else:
            sql_types.append(f'"{col}" TEXT')
            
    columns_def = ",\n        ".join(sql_types)
    
    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS customers (
        id SERIAL PRIMARY KEY,
        {columns_def}
    );
    """
    
    cur.execute(create_table_query)
    conn.commit()
    
    # 7. Load all cleaned rows into the customers table
    print("Loading data into the database...")
    # Protect column names with double quotes in case any are reserved words
    columns_str = ", ".join([f'"{col}"' for col in df.columns])
    
    # Convert dataframe to list of tuples for insertion
    # Ensure numpy types are converted to native Python types
    values = []
    for row in df.to_numpy():
        native_row = tuple(x.item() if hasattr(x, "item") else x for x in row)
        values.append(native_row)
        
    insert_query = f"INSERT INTO customers ({columns_str}) VALUES %s"
    
    execute_values(cur, insert_query, values)
    conn.commit()
    
    # 8. Print row count on success
    print(f"Success! {len(df)} cleaned rows have been loaded into the 'customers' table.")
    
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
