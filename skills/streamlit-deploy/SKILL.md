# Streamlit Deploy Skill

**Name:** streamlit-deploy
**Version:** 1.0.0
**Description:** Deploy Streamlit applications to Snowflake. Validate configuration files (snowflake.yml, environment.yml), check for common deployment errors, and execute deployment using snow CLI. Use for deploying, updating, and troubleshooting Streamlit apps on Snowflake.

## When to Use

- User wants to deploy a Streamlit app to Snowflake
- Need to update an existing Streamlit app
- Encountering deployment errors
- Want to validate configuration before deployment
- Questions about Streamlit deployment commands or configuration

## Prerequisites

- `snow` CLI installed and configured
- Snowflake connection configured
- Valid snowflake.yml and environment.yml in project directory

## Workflow

### 1. Validate Configuration Files

Check snowflake.yml:
```yaml
definition_version: 1
streamlit:
  name: app_name
  stage: streamlit
  query_warehouse: COMPUTE_WH
  main_file: streamlit_app.py
  title: "App Title"
```

Important:
- Do NOT include `pages_dir` parameter
- Use valid warehouse name
- Ensure main_file path is correct

Check environment.yml:
```yaml
name: app_environment
channels:
  - snowflake
dependencies:
  - python=3.11.*
  - snowflake-snowpark-python=
  - streamlit=
  - pandas=
```

Important:
- Python version must use `.*` wildcard: `python=3.11.*`
- Package names must end with `=`: `pandas=` not `pandas`
- Only use packages available in Snowflake conda channel

### 2. Pre-Deployment Checks

```bash
# Check current connection
snow connection list

# List existing Streamlit apps
snow streamlit list

# Check snow CLI version
snow --version
```

### 3. Deploy Command

```bash
cd /path/to/project
snow streamlit deploy --connection CONNECTION_NAME --replace
```

Use `--replace` flag to update existing app.

### 4. Post-Deployment

```bash
# Get app URL
snow streamlit get-url APP_NAME

# Check deployment status in Snowflake UI
```

## Common Errors and Fixes

### Python Version Error
```
Error: Packages not found: python==3.11
```
Fix: Change to `python=3.11.*` in environment.yml

### Package Not Found Error
```
Error: Packages not found: pandas
```
Fix: Add `=` at end of package name: `pandas=`

### pages_dir Error
```
Error: Provided file null does not exist
```
Fix: Remove `pages_dir: null` from snowflake.yml

### Connection Error
```
Error: Connection 'name' does not exist
```
Fix: Check connection with `snow connection list`

## Streamlit Code Patterns

### Basic Setup
```python
import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()
```

### Read from Table
```python
df = session.table("SCHEMA.TABLE_NAME").to_pandas()
```

### Editable Table
```python
edited_df = st.data_editor(df, num_rows="dynamic")
```

### Save to Table
```python
if st.button("Save"):
    session.create_dataframe(edited_df).write.mode("overwrite").save_as_table("TABLE_NAME")
```

### Execute Query
```python
result = session.sql("SELECT * FROM TABLE").to_pandas()
```

## Notes

- Always validate configuration files before deployment
- Test locally before deploying to Snowflake if possible
- Use `--replace` flag to update existing apps
- Check detailed deployment logs in Snowflake UI
- Streamlit apps on Snowflake use Snowpark session, not traditional database connections
