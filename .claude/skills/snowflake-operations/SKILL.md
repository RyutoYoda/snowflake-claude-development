# Snowflake Operations Skill

**Name:** snowflake-operations
**Version:** 2.0.0
**Description:** Execute Snowflake operations using snow CLI. Perform database queries, create tables/views, manage data, and test connections. Use when interacting with Snowflake database directly, running SQL, or managing database objects.

## When to Use

- User wants to run SQL queries against Snowflake
- User needs to create/modify database objects (tables, views)
- User wants to check Snowflake connection status
- User needs to load data into Snowflake
- User asks about database schema or data inspection

## Prerequisites

- `snow` CLI installed and configured
- Snowflake connection configured (`snow connection list`)
- Appropriate database permissions

## Snow CLI Commands

### Check Connection

Always start by verifying connection:

```bash
snow connection list
```

Or test a specific connection:

```bash
snow connection test --connection my_connection
```

### Execute SQL Query

**Single Query:**
```bash
snow sql -q "SELECT * FROM DATABASE.SCHEMA.TABLE LIMIT 10" --connection my_connection
```

**From File:**
```bash
snow sql -f query.sql --connection my_connection
```

**Multiple Queries:**
```bash
snow sql -f script.sql --connection my_connection
```

### Output Formats

**Table format (default):**
```bash
snow sql -q "SELECT * FROM TABLE" --connection my_connection
```

**JSON format:**
```bash
snow sql -q "SELECT * FROM TABLE" --format json --connection my_connection
```

**CSV format:**
```bash
snow sql -q "SELECT * FROM TABLE" --format csv --connection my_connection
```

## Common Operations

### 1. Connection Management

List all connections:
```bash
snow connection list
```

Add new connection:
```bash
snow connection add
```

Test connection:
```bash
snow connection test --connection my_connection
```

### 2. Query Data

**Simple query:**
```bash
snow sql -q "SELECT * FROM DATABASE.SCHEMA.TABLE LIMIT 10" --connection my_connection
```

**With output to file:**
```bash
snow sql -q "SELECT * FROM TABLE" --format csv > output.csv --connection my_connection
```

### 3. Create Table

```bash
snow sql -q "CREATE OR REPLACE TABLE DATABASE.SCHEMA.TABLE_NAME (
  ID VARCHAR(50),
  NAME VARCHAR(100),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)" --connection my_connection
```

### 4. Create View

```bash
snow sql -q "CREATE OR REPLACE VIEW DATABASE.SCHEMA.VIEW_NAME AS
  SELECT ID, NAME FROM DATABASE.SCHEMA.TABLE_NAME" --connection my_connection
```

### 5. Insert Data

```bash
snow sql -q "INSERT INTO DATABASE.SCHEMA.TABLE (ID, NAME) VALUES ('1', 'Test')" --connection my_connection
```

### 6. Update Data

```bash
snow sql -q "UPDATE DATABASE.SCHEMA.TABLE
  SET NAME = 'Updated'
  WHERE ID = '1'" --connection my_connection
```

### 7. Check Schema

```bash
snow sql -q "DESCRIBE TABLE DATABASE.SCHEMA.TABLE_NAME" --connection my_connection
```

### 8. List Tables

```bash
snow sql -q "SHOW TABLES IN SCHEMA DATABASE.SCHEMA" --connection my_connection
```

## Data Patterns

### View-Based Architecture

Create base tables with metadata columns, expose clean views to applications:

```sql
-- Base table with audit columns
CREATE OR REPLACE TABLE DATABASE.SCHEMA.USERS_BASE (
  ID VARCHAR(50) PRIMARY KEY,
  EMAIL VARCHAR(255) UNIQUE NOT NULL,
  NAME VARCHAR(100),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Application view (clean interface)
CREATE OR REPLACE VIEW DATABASE.SCHEMA.USERS AS
SELECT ID, EMAIL, NAME
FROM DATABASE.SCHEMA.USERS_BASE;
```

**Benefits:**
- Applications use clean view interface
- Audit columns maintained automatically
- Easy schema evolution without app changes
- Centralized access control on views

### Handling NULL Values

When building SQL dynamically:

```python
import subprocess

def execute_snowflake_sql(query, connection="my_connection"):
    cmd = ["snow", "sql", "-q", query, "--connection", connection]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout

def safe_value(value):
    if value is None or value == '' or str(value) == 'None':
        return 'NULL'
    return f"'{str(value).replace(\"'\", \"''\")}'"

query = f"INSERT INTO TABLE (ID, NAME) VALUES ({safe_value('123')}, {safe_value(None)})"
execute_snowflake_sql(query)
```

### Date Formatting

Snowflake requires ISO 8601 format:

```bash
# Correct
snow sql -q "INSERT INTO TABLE (DATE_COL) VALUES ('2025-01-21')" --connection my_connection

# Incorrect (will fail)
snow sql -q "INSERT INTO TABLE (DATE_COL) VALUES ('1/21/2025')" --connection my_connection
```

## Best Practices

1. **Always Use Connection Names**
   ```bash
   snow sql -q "SELECT ..." --connection production
   ```

2. **Use Qualified Object Names**
   ```bash
   snow sql -q "SELECT * FROM MY_DB.MY_SCHEMA.MY_TABLE"
   ```

3. **Use SQL Files for Complex Operations**
   ```bash
   snow sql -f migrations/001_create_tables.sql --connection my_connection
   ```

4. **Escape String Values**
   Always escape user input to prevent SQL injection

5. **Use Transactions for Multiple Operations**
   ```sql
   BEGIN TRANSACTION;
   CREATE TABLE ...;
   CREATE VIEW ...;
   COMMIT;
   ```

## Common Workflows

### Workflow 1: Initial Database Setup

```bash
#!/bin/bash
CONNECTION="my_connection"

snow sql -q "CREATE DATABASE IF NOT EXISTS MY_DATABASE" --connection $CONNECTION
snow sql -q "CREATE SCHEMA IF NOT EXISTS MY_DATABASE.RAW_DATA" --connection $CONNECTION
snow sql -f sql/create_tables.sql --connection $CONNECTION

echo "Database setup complete"
```

### Workflow 2: Data Migration

```bash
#!/bin/bash
CONNECTION="my_connection"

# Backup
snow sql -q "CREATE TABLE BACKUP.SCHEMA.TABLE_BACKUP AS SELECT * FROM PROD.SCHEMA.TABLE" --connection $CONNECTION

# Run migration
snow sql -f migrations/001_add_columns.sql --connection $CONNECTION

# Validate
COUNT=$(snow sql -q "SELECT COUNT(*) FROM PROD.SCHEMA.TABLE" --format json --connection $CONNECTION | jq '.[0].COUNT')

echo "Migration complete. Row count: $COUNT"
```

## Troubleshooting

### Connection Issues

```bash
snow connection test --connection my_connection
snow connection list
```

### Query Timeout

```bash
snow sql -q "ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 3600" --connection my_connection
```

### Permission Errors

```bash
snow sql -q "SELECT CURRENT_ROLE()" --connection my_connection
snow sql -q "SHOW GRANTS TO ROLE MY_ROLE" --connection my_connection
```

## Notes

- All operations are executed immediately
- No automatic rollback unless using explicit transactions
- Query results may contain sensitive data
- Always test SQL syntax before running on production
- Use version control for SQL scripts
