# Snowflake UDF Skill

**Name:** snowflake-udf
**Version:** 1.0.0
**Description:** Create and manage Snowflake User-Defined Functions (UDFs) and stored procedures using Snowflake CLI. Build Python UDFs, deploy them to Snowflake, and manage their lifecycle. Use when creating custom functions, deploying UDFs, or managing Snowpark functions and procedures.

## When to Use

- User wants to create a new Python UDF or stored procedure
- User needs to deploy functions to Snowflake
- User wants to list existing functions
- User needs to test or execute a function
- User wants to view function details or drop functions
- User asks about UDF development or Snowpark deployment

## Prerequisites

- `snow` CLI installed and configured
- Snowflake connection set up
- Python environment with snowflake-snowpark-python
- Understanding of UDF requirements (handler function, return types)

## Available Commands

### 1. List Functions

```bash
# すべてのSnowpark関数とプロシージャをリスト表示
snow snowpark list --connection YOUR_CONNECTION

# パターンマッチで関数をフィルタ
snow snowpark list function --like "my%" --connection YOUR_CONNECTION

# データベースとスキーマを指定してリスト表示
snow snowpark list --database YOUR_DATABASE --schema YOUR_SCHEMA --connection YOUR_CONNECTION
```

Lists all available procedures and functions in your Snowflake environment.

### 2. Deploy Function

```bash
# プロジェクトディレクトリから関数をデプロイ
cd my_udf_project
snow snowpark deploy --connection YOUR_CONNECTION

# 特定のデータベース・スキーマにデプロイ
snow snowpark deploy --database YOUR_DATABASE --schema YOUR_SCHEMA --connection YOUR_CONNECTION

# 置き換えモードでデプロイ（既存関数を上書き）
snow snowpark deploy --replace --connection YOUR_CONNECTION
```

Deploys functions defined in your project. Required artifacts are deployed before creating functions or procedures.

Project structure typically includes:
- `app.py` - Python file with function definitions
- `snowflake.yml` - Configuration for deployment
- `requirements.txt` - Python dependencies (optional)

### 3. Execute Function

```bash
# 単純な引数で関数を実行
snow snowpark execute function MY_FUNCTION('test') --connection YOUR_CONNECTION

# 複数の引数で実行
snow snowpark execute function CALCULATE_SCORE(100, 200, 0.5) --connection YOUR_CONNECTION

# データベースとスキーマを指定して実行
snow snowpark execute function YOUR_DATABASE.YOUR_SCHEMA.MY_FUNCTION('arg') --connection YOUR_CONNECTION
```

Executes a function with specified arguments. Useful for testing new or modified functions.

### 4. Describe Function

```bash
# 関数の詳細を表示
snow snowpark describe function MY_FUNCTION --connection YOUR_CONNECTION

# 完全修飾名で指定
snow snowpark describe function YOUR_DATABASE.YOUR_SCHEMA.MY_FUNCTION --connection YOUR_CONNECTION
```

Views details of a function including parameters, return type, and implementation.

### 5. Drop Function

```bash
# 関数を削除
snow snowpark drop function MY_FUNCTION --connection YOUR_CONNECTION

# 完全修飾名で削除
snow snowpark drop function YOUR_DATABASE.YOUR_SCHEMA.MY_FUNCTION --connection YOUR_CONNECTION

# 確認なしで削除
snow snowpark drop function MY_FUNCTION --force --connection YOUR_CONNECTION
```

Deletes a function from Snowflake.

### 6. Build Project

```bash
# プロジェクトをビルド（.zipアーカイブ作成）
snow snowpark build --connection YOUR_CONNECTION

# 出力先を指定してビルド
snow snowpark build --output ./build --connection YOUR_CONNECTION
```

Builds the Snowpark project as a .zip archive before deployment.

### 7. Package Management

```bash
# 依存パッケージのアップロード
snow snowpark package upload --file packages.zip --connection YOUR_CONNECTION

# パッケージのリスト表示
snow snowpark package list --connection YOUR_CONNECTION

# パッケージの削除
snow snowpark package drop PACKAGE_NAME --connection YOUR_CONNECTION
```

Manages Python packages for UDFs.

## Project Configuration

### snowflake.yml Example

```yaml
definition_version: 1
snowpark:
  project_name: my_udf_project
  stage_name: udf_stage
  src: app.py
  functions:
    - name: MY_FUNCTION
      handler: app.my_function_handler
      signature:
        - name: input_text
          type: string
      returns: string
      runtime: "3.11"
```

Key fields:
- `project_name`: Project identifier
- `stage_name`: Snowflake stage for artifacts
- `src`: Python source file
- `functions`: List of function definitions
  - `name`: Function name in Snowflake (uppercase)
  - `handler`: Python function path (module.function)
  - `signature`: Input parameters with types
  - `returns`: Return data type
  - `runtime`: Python version

### app.py Example

```python
from snowflake.snowpark.types import StringType

def my_function_handler(input_text: str) -> str:
    """
    UDF handler function
    """
    return input_text.upper()
```

Important:
- Handler function must match signature in snowflake.yml
- Use appropriate Snowpark data types
- Keep dependencies minimal for faster deployment

### requirements.txt Example

```txt
snowflake-snowpark-python
pandas
numpy
```

## Quick Start Guide

### 最速でUDFを作成・デプロイする方法

```bash
# 1. プロジェクトディレクトリ作成
mkdir my_first_udf && cd my_first_udf

# 2. app.py作成
cat > app.py << 'EOF'
def hello_udf(name: str) -> str:
    return f"Hello, {name}!"
EOF

# 3. snowflake.yml作成
cat > snowflake.yml << 'EOF'
definition_version: 1
snowpark:
  project_name: my_first_udf
  stage_name: udf_stage
  src: app.py
  functions:
    - name: HELLO_UDF
      handler: app.hello_udf
      signature:
        - name: name
          type: string
      returns: string
      runtime: "3.11"
EOF

# 4. デプロイ
snow snowpark deploy --connection YOUR_CONNECTION

# 5. テスト実行
snow snowpark execute function HELLO_UDF('World') --connection YOUR_CONNECTION
```

期待される出力: `Hello, World!`

## UDF Development Workflow

### 1. Create Project Structure

```bash
mkdir my_udf_project
cd my_udf_project
```

Create:
- `app.py` - UDF implementation
- `snowflake.yml` - Configuration
- `requirements.txt` - Dependencies (if needed)

### 2. Implement UDF

Write handler function in `app.py`:

```python
def process_data(data: str) -> str:
    # Your logic here
    return data.strip().upper()
```

### 3. Configure Deployment

Create `snowflake.yml` with function definition.

### 4. Build and Deploy

```bash
# Build project
snow snowpark build --connection CONNECTION_NAME

# Deploy to Snowflake
snow snowpark deploy --connection CONNECTION_NAME
```

### 5. Test Function

```bash
# Execute function
snow snowpark execute function MY_FUNCTION('test input') --connection CONNECTION_NAME
```

Or test via SQL:
```sql
SELECT MY_FUNCTION('test input');
```

## Common UDF Patterns

### String Processing UDF

```python
def clean_text(text: str) -> str:
    """Remove whitespace and standardize format"""
    if not text:
        return None
    return text.strip().upper()
```

### Data Transformation UDF

```python
import json

def parse_json_field(json_str: str, field: str) -> str:
    """Extract field from JSON string"""
    try:
        data = json.loads(json_str)
        return str(data.get(field, ''))
    except:
        return None
```

### Calculation UDF

```python
def calculate_score(metric1: float, metric2: float, weight: float) -> float:
    """Calculate weighted score"""
    return (metric1 * weight) + (metric2 * (1 - weight))
```

### Table Function (UDTF)

```python
from snowflake.snowpark.types import StructType, StructField, StringType, IntegerType

class SplitToRows:
    def process(self, text: str):
        for word in text.split():
            yield (word, len(word))

# In snowflake.yml:
# table_functions:
#   - name: SPLIT_TO_ROWS
#     handler: app.SplitToRows
#     signature: [{name: text, type: string}]
#     returns:
#       - {name: word, type: string}
#       - {name: length, type: integer}
```

## Using UDFs via MCP

You can also create UDFs using MCP execute_query:

```javascript
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE FUNCTION CLEAN_TEXT(input_text STRING)
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    HANDLER = 'clean_text'
    AS $$
def clean_text(input_text):
    if not input_text:
        return None
    return input_text.strip().upper()
$$
  `
})
```

## Best Practices

1. **Function Naming**
   - Use UPPERCASE for function names in Snowflake
   - Use descriptive names: `CALCULATE_REVENUE` not `CALC1`
   - Follow team naming conventions

2. **Error Handling**
   - Add try-except blocks for robust functions
   - Return None or appropriate default for errors
   - Log errors when appropriate

3. **Performance**
   - Keep UDFs simple and focused
   - Avoid heavy computations in row-by-row UDFs
   - Use vectorized UDFs when processing large datasets
   - Minimize external dependencies

4. **Testing**
   - Test functions locally before deployment
   - Use snow snowpark execute for quick testing
   - Create test cases with edge cases (NULL, empty string, etc.)

5. **Versioning**
   - Use OR REPLACE to update existing functions
   - Document changes in function docstrings
   - Test thoroughly before replacing production functions

6. **Dependencies**
   - Only include necessary packages in requirements.txt
   - Use packages available in Snowflake's conda channel
   - Test that all dependencies are supported

7. **Security**
   - Validate input parameters
   - Avoid SQL injection in UDFs that construct queries
   - Use appropriate permissions for function execution

## Common Errors and Fixes

### Deployment Error: Stage Not Found
```
Error: Stage 'stage_name' does not exist
```
Fix: Create stage first or update stage_name in snowflake.yml

### Handler Not Found Error
```
Error: Handler function not found
```
Fix: Verify handler path matches module.function format in snowflake.yml

### Import Error
```
Error: Module 'xyz' not found
```
Fix: Add missing package to requirements.txt or use Snowflake-supported packages

### Type Mismatch Error
```
Error: Return type doesn't match signature
```
Fix: Ensure return type in code matches return type in snowflake.yml

### Connection Error
```
Error: Connection 'name' does not exist
```
Fix: Verify connection with `snow connection list`

## Notes

- UDFs created via CLI are managed as Snowpark objects
- Functions are deployed to specified stage automatically
- Use `snow snowpark list` to see all deployed functions
- UDFs support Python 3.8, 3.9, 3.10, 3.11
- Scalar UDFs process one row at a time
- Table UDFs (UDTFs) can return multiple rows
- UDFs can use external packages if specified in requirements.txt
- For production, consider using stored procedures for complex workflows

## References

- [Snowflake CLI Snowpark Commands](https://docs.snowflake.com/en/developer-guide/snowflake-cli/command-reference/snowpark-commands/overview)
- [Creating Python UDFs](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-creating)
- [UDF Overview](https://docs.snowflake.com/en/developer-guide/udf/udf-overview)
- [Snowpark Python API](https://docs.snowflake.com/en/developer-guide/snowpark/python/creating-udfs)
