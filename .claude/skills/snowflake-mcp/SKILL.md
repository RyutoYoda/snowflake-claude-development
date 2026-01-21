# Snowflake MCP Skill

**Name:** snowflake-mcp
**Version:** 1.0.0
**Description:** Execute Snowflake operations using Model Context Protocol (MCP). Perform database queries, create tables/views, manage data, and test connections. Use when interacting with Snowflake database directly, running SQL, or managing database objects without deploying applications.

## When to Use

- User wants to run SQL queries against Snowflake
- User needs to create/modify database objects (tables, views)
- User wants to check Snowflake connection status
- User needs to load data into Snowflake
- User asks about database schema or data inspection

## MCP Tools Available

### Test Connection
```javascript
mcp__snowflake-simple__test_connection()
```

Use to verify Snowflake connection is working.

### Execute Query
```javascript
mcp__snowflake-simple__execute_query({
  "query": "YOUR_SQL_HERE"
})
```

Use for any SQL operation: SELECT, CREATE, INSERT, UPDATE, DELETE.

## Common Operations

### 1. Connection Check

Always start by testing connection:
```javascript
mcp__snowflake-simple__test_connection()
```

### 2. Query Data

```javascript
mcp__snowflake-simple__execute_query({
  "query": "SELECT * FROM SCHEMA.TABLE_NAME LIMIT 10"
})
```

### 3. Create Table

```javascript
mcp__snowflake-simple__execute_query({
  "query": "CREATE OR REPLACE TABLE SCHEMA.TABLE_NAME (
    ID VARCHAR(50),
    NAME VARCHAR(100),
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
  )"
})
```

### 4. Create View

```javascript
mcp__snowflake-simple__execute_query({
  "query": "CREATE OR REPLACE VIEW SCHEMA.VIEW_NAME AS
    SELECT ID, NAME FROM SCHEMA.TABLE_NAME"
})
```

### 5. Insert Data

```javascript
mcp__snowflake-simple__execute_query({
  "query": "INSERT INTO SCHEMA.TABLE_NAME (ID, NAME)
    VALUES ('1', 'Test')"
})
```

### 6. Update Data

```javascript
mcp__snowflake-simple__execute_query({
  "query": "UPDATE SCHEMA.TABLE_NAME
    SET NAME = 'Updated'
    WHERE ID = '1'"
})
```

### 7. Check Schema

```javascript
mcp__snowflake-simple__execute_query({
  "query": "DESCRIBE TABLE SCHEMA.TABLE_NAME"
})
```

### 8. List Tables

```javascript
mcp__snowflake-simple__execute_query({
  "query": "SHOW TABLES IN SCHEMA SCHEMA_NAME"
})
```

## Data Patterns

### View-Based Architecture

Create base tables with CREATED_AT, expose views without it:

```sql
-- Base table with timestamp
CREATE OR REPLACE TABLE SCHEMA.TABLE_BASE (
  ID VARCHAR(50),
  NAME VARCHAR(100),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- View for applications (no timestamp)
CREATE OR REPLACE VIEW SCHEMA.TABLE_VIEW AS
SELECT ID, NAME FROM SCHEMA.TABLE_BASE;
```

Benefits:
- Applications work with clean view interface
- Timestamp tracking maintained in base table
- Easy to add audit columns without changing app code

### Handling NULL Values

When building SQL with dynamic values:

```python
# Python example for building SQL
if pd.notna(value) and str(value) != '' and str(value) != 'None':
    sql_value = f"'{value.replace("'", "''")}'"  # Escape quotes
else:
    sql_value = 'NULL'

query = f"INSERT INTO TABLE (COL) VALUES ({sql_value})"
```

### Date Formatting

Snowflake requires ISO format for dates:
- Correct: `'2025-01-19'`
- Incorrect: `'2025/1/19'` or `'1/19/2025'`

## Best Practices

1. **Always Test Connection First**
   - Verify MCP connection before running queries
   - Saves time debugging later

2. **Use Qualified Names**
   - Always use `DATABASE.SCHEMA.TABLE` format
   - Avoids ambiguity with current context

3. **Handle Errors Gracefully**
   - Check query results for errors
   - Provide clear error messages to user

4. **Escape String Values**
   - Replace single quotes: `value.replace("'", "''")`
   - Prevents SQL injection and syntax errors

5. **Use Transactions for Multiple Operations**
   - When creating related objects, consider transaction safety
   - Create base tables before dependent views

6. **Validate Data Types**
   - Ensure data matches column types
   - Convert dates to proper format before INSERT

## Notes

- MCP operations are direct database operations
- Changes are immediate and permanent
- No automatic rollback unless in explicit transaction
- Query results may contain sensitive data
- Always verify SQL syntax before execution
