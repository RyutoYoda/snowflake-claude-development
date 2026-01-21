# Notebook Operations Skill

**Name:** notebook-ops
**Version:** 1.0.0
**Description:** Work with Jupyter notebooks for Snowflake data analysis and exploration. Set up notebook environments, connect to Snowflake, execute queries, perform data analysis, and create visualizations. Use for working with Jupyter notebooks, ad-hoc analysis, or interactive exploration of Snowflake data.

## When to Use

- User wants to analyze Snowflake data in a notebook
- Need to create data visualizations
- Want to explore data interactively
- Prototyping queries and transformations
- Questions about Jupyter or notebook setup

## Setup

### Install Required Packages

```python
# In notebook or requirements.txt
snowflake-snowpark-python
pandas
matplotlib
seaborn
jupyter
```

### Snowflake Connection in Notebook

```python
from snowflake.snowpark import Session
import pandas as pd

# Connection parameters
connection_parameters = {
    "account": "your_account",
    "user": "your_user",
    "password": "your_password",
    "role": "your_role",
    "warehouse": "your_warehouse",
    "database": "your_database",
    "schema": "your_schema"
}

# Create session
session = Session.builder.configs(connection_parameters).create()
```

### Alternative: Use SnowSQL Config

```python
from snowflake.snowpark import Session
import configparser
import os

# Read from ~/.snowsql/config
config = configparser.ConfigParser()
config.read(os.path.expanduser('~/.snowsql/config'))

connection_parameters = {
    "account": config['connections']['accountname'],
    "user": config['connections']['username'],
    # ... other parameters
}

session = Session.builder.configs(connection_parameters).create()
```

## Common Operations

### 1. Query Data

```python
# Using Snowpark
df = session.table("SCHEMA.TABLE_NAME").to_pandas()

# Or use SQL directly
df = session.sql("SELECT * FROM SCHEMA.TABLE_NAME LIMIT 100").to_pandas()

# Display
df.head()
```

### 2. Data Exploration

```python
# Shape and info
print(f"Rows: {len(df)}, Columns: {len(df.columns)}")
df.info()

# Statistical summary
df.describe()

# Column types
df.dtypes

# Missing values
df.isnull().sum()

# Unique values
df['column_name'].nunique()
```

### 3. Data Visualization

```python
import matplotlib.pyplot as plt
import seaborn as sns

# Set style
sns.set_style("whitegrid")

# Bar chart
df['column'].value_counts().plot(kind='bar')
plt.title('Distribution')
plt.show()

# Time series
df['date'] = pd.to_datetime(df['date'])
df.set_index('date')['value'].plot()
plt.title('Time Series')
plt.show()

# Histogram
df['numeric_column'].hist(bins=50)
plt.title('Distribution')
plt.show()
```

### 4. Data Transformation

```python
# Filter
filtered = df[df['column'] > 100]

# Group and aggregate
grouped = df.groupby('category')['value'].sum()

# Join
merged = df1.merge(df2, on='key', how='left')

# Pivot
pivot = df.pivot_table(values='value', index='row', columns='col')

# Add calculated column
df['new_col'] = df['col1'] + df['col2']
```

### 5. Write Back to Snowflake

```python
# pandas DataFrame to Snowflake
session.create_dataframe(df).write.mode("overwrite").save_as_table("SCHEMA.TABLE_NAME")

# Append instead of overwrite
session.create_dataframe(df).write.mode("append").save_as_table("SCHEMA.TABLE_NAME")
```

### 6. Execute DDL

```python
# Create table
session.sql("""
    CREATE OR REPLACE TABLE SCHEMA.TABLE_NAME (
        ID VARCHAR(50),
        VALUE NUMBER
    )
""").collect()

# Create view
session.sql("""
    CREATE OR REPLACE VIEW SCHEMA.VIEW_NAME AS
    SELECT * FROM SCHEMA.TABLE_NAME WHERE VALUE > 0
""").collect()
```

## Data Analysis Patterns

### Ad-hoc Query Development

```python
# Start with small sample
sample = session.sql("SELECT * FROM LARGE_TABLE LIMIT 1000").to_pandas()

# Develop transformation logic
transformed = sample.copy()
# ... apply transformations ...

# Once satisfied, apply to full dataset
full_df = session.table("LARGE_TABLE").to_pandas()
final = apply_transformations(full_df)
```

### Load CSV Data

```python
# Read CSV
csv_df = pd.read_csv('file.csv')

# Cleanup and transform
csv_df = csv_df.dropna()
csv_df['date'] = pd.to_datetime(csv_df['date'])

# Upload to Snowflake
session.create_dataframe(csv_df).write.mode("overwrite").save_as_table("SCHEMA.IMPORTED_DATA")
```

### Data Quality Checks

```python
# Check for duplicates
duplicates = df[df.duplicated(subset=['id'], keep=False)]
print(f"Duplicates: {len(duplicates)}")

# Check NULL values
null_counts = df.isnull().sum()
print("NULL values per column:")
print(null_counts[null_counts > 0])

# Check date range
print(f"Date range: {df['date'].min()} to {df['date'].max()}")

# Check value range
print(f"Value range: {df['value'].min()} to {df['value'].max()}")
```

## Best Practices

1. **Start Small**
   - Use LIMIT when developing queries
   - Test with sample data first

2. **Close Sessions**
   - Always close Snowpark session when done
   ```python
   session.close()
   ```

3. **Use Type Conversion**
   - Convert Snowpark DataFrame to pandas for analysis
   - pandas has richer analysis functions

4. **Save Intermediate Results**
   - Write intermediate tables to Snowflake
   - Avoid re-running expensive queries

5. **Document Analysis**
   - Explain logic in markdown cells
   - Add comments for complex transformations

6. **Version Control**
   - Store notebooks in git
   - Track changes to analysis code

## Notes

- Notebooks are for exploration and analysis, not production
- Use Streamlit for production dashboards
- Keep notebooks focused on specific analysis tasks
- Consider converting successful notebook code to production scripts
- Be mindful of data size when converting to pandas
