# Snowflake Task Skill

**Name:** snowflake-task
**Version:** 1.0.0
**Description:** Create and manage Snowflake tasks using Snowflake CLI. Schedule SQL statements, stored procedures, and data pipeline workflows. Build task graphs with dependencies (DAGs). Use when automating data operations, scheduling jobs, or orchestrating data workflows.

## When to Use

- User wants to create a scheduled job or automated task
- User needs to orchestrate data pipelines with dependencies
- User wants to list or manage existing tasks
- User needs to build task graphs (DAGs)
- User wants to schedule periodic data operations
- User asks about task automation or workflow orchestration

## Prerequisites

- `snow` CLI installed and configured
- Snowflake connection set up
- Warehouse for task execution (or serverless compute enabled)
- Understanding of task requirements (SQL statement, schedule)
- Appropriate permissions (EXECUTE TASK privilege)

## Quick Start Guide

### 最速でタスクを作成する方法

```bash
# 1. シンプルなタスクを作成（1時間ごとにテーブル更新）
snow sql --connection YOUR_CONNECTION --query "
CREATE OR REPLACE TASK my_first_task
  WAREHOUSE = YOUR_WAREHOUSE
  SCHEDULE = '60 MINUTE'
AS
  INSERT INTO log_table (message, created_at)
  VALUES ('Task executed', CURRENT_TIMESTAMP());
"

# 2. タスクを有効化
snow sql --connection YOUR_CONNECTION --query "ALTER TASK my_first_task RESUME;"

# 3. タスクの状態確認
snow sql --connection YOUR_CONNECTION --query "SHOW TASKS LIKE 'my_first_task';"

# 4. テスト実行（スケジュールを待たずに即座に実行）
snow sql --connection YOUR_CONNECTION --query "EXECUTE TASK my_first_task;"

# 5. 実行履歴確認
snow sql --connection YOUR_CONNECTION --query "
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME => 'MY_FIRST_TASK'))
ORDER BY SCHEDULED_TIME DESC LIMIT 5;
"
```

## Available Commands

### 1. Create Task

```bash
snow object create task \
  --database DATABASE_NAME \
  --schema SCHEMA_NAME \
  name=TASK_NAME \
  warehouse=WAREHOUSE_NAME \
  schedule="USING CRON 0 9 * * * America/New_York" \
  sql="INSERT INTO target_table SELECT * FROM source_table"
```

Or using JSON format:
```bash
snow object create task \
  --database DATABASE_NAME \
  --schema SCHEMA_NAME \
  '{"name": "TASK_NAME", "warehouse": "WAREHOUSE_NAME", "schedule": "60 MINUTE", "sql": "CALL my_procedure()"}'
```

Creates a new task. Tasks are always created in suspended state.

### 2. List Tasks

```bash
snow object list task \
  --database DATABASE_NAME \
  --schema SCHEMA_NAME \
  --connection CONNECTION_NAME
```

Lists all tasks in the specified schema.

### 3. Describe Task

```bash
snow object describe task TASK_NAME \
  --database DATABASE_NAME \
  --schema SCHEMA_NAME \
  --connection CONNECTION_NAME
```

Shows detailed information about a task including schedule, SQL definition, and dependencies.

### 4. Drop Task

```bash
snow object drop task TASK_NAME \
  --database DATABASE_NAME \
  --schema SCHEMA_NAME \
  --connection CONNECTION_NAME
```

Deletes a task from Snowflake.

## Task Creation via SQL/MCP

You can also create tasks using MCP execute_query for more complex configurations:

### Basic Scheduled Task

```javascript
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE TASK MY_HOURLY_TASK
      WAREHOUSE = YOUR_WAREHOUSE
      SCHEDULE = '60 MINUTE'
    AS
      INSERT INTO summary_table
      SELECT date, COUNT(*) as count
      FROM events_table
      WHERE date = CURRENT_DATE()
      GROUP BY date
  `
})
```

### Task with CRON Schedule

```javascript
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE TASK DAILY_REFRESH_TASK
      WAREHOUSE = YOUR_WAREHOUSE
      SCHEDULE = 'USING CRON 0 2 * * * America/New_York'
      COMMENT = 'Refreshes data daily at 2 AM EST'
    AS
      CALL refresh_data_procedure()
  `
})
```

### Serverless Task

```javascript
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE TASK SERVERLESS_TASK
      USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
      SCHEDULE = '30 MINUTE'
    AS
      UPDATE metrics_table
      SET last_updated = CURRENT_TIMESTAMP()
  `
})
```

### Task with Dependencies (Child Task)

```javascript
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE TASK CHILD_TASK
      WAREHOUSE = YOUR_WAREHOUSE
      AFTER PARENT_TASK
    AS
      INSERT INTO downstream_table
      SELECT * FROM upstream_table
      WHERE processed = FALSE
  `
})
```

## Task Management

### Resume Task (Activate)

```javascript
mcp__snowflake-simple__execute_query({
  "query": "ALTER TASK MY_TASK RESUME"
})
```

Tasks must be resumed to start running on schedule.

### Suspend Task (Deactivate)

```javascript
mcp__snowflake-simple__execute_query({
  "query": "ALTER TASK MY_TASK SUSPEND"
})
```

### Execute Task Immediately (Testing)

```javascript
mcp__snowflake-simple__execute_query({
  "query": "EXECUTE TASK MY_TASK"
})
```

Useful for testing new or modified tasks without waiting for schedule.

### Check Task Status

```javascript
mcp__snowflake-simple__execute_query({
  "query": "SHOW TASKS LIKE 'MY_TASK'"
})
```

### View Task History

```javascript
mcp__snowflake-simple__execute_query({
  "query": `
    SELECT *
    FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
      SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP()),
      TASK_NAME => 'MY_TASK'
    ))
    ORDER BY SCHEDULED_TIME DESC
  `
})
```

## Task Scheduling Options

### 1. Interval Schedule

```sql
SCHEDULE = '60 MINUTE'  -- Every 60 minutes
SCHEDULE = '5 MINUTE'   -- Every 5 minutes
SCHEDULE = '24 HOUR'    -- Once per day
```

Minimum interval: 1 minute

### 2. CRON Schedule

```sql
-- Format: USING CRON <minute> <hour> <day-of-month> <month> <day-of-week> <timezone>

-- Every day at 2 AM EST
SCHEDULE = 'USING CRON 0 2 * * * America/New_York'

-- Every weekday at 9 AM
SCHEDULE = 'USING CRON 0 9 * * 1-5 America/New_York'

-- Every 15 minutes
SCHEDULE = 'USING CRON */15 * * * * UTC'

-- First day of month at midnight
SCHEDULE = 'USING CRON 0 0 1 * * UTC'
```

### 3. Dependency-Based (No Schedule)

For tasks that run after other tasks complete:
```sql
AFTER PARENT_TASK_NAME
```

## Task Graph (DAG) Example

Building a data pipeline with task dependencies:

```javascript
// Root task - runs on schedule
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE TASK EXTRACT_TASK
      WAREHOUSE = YOUR_WAREHOUSE
      SCHEDULE = '60 MINUTE'
    AS
      CALL extract_raw_data()
  `
})

// Child task 1 - runs after extract completes
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE TASK TRANSFORM_TASK
      WAREHOUSE = YOUR_WAREHOUSE
      AFTER EXTRACT_TASK
    AS
      CALL transform_data()
  `
})

// Child task 2 - runs after transform completes
mcp__snowflake-simple__execute_query({
  "query": `
    CREATE OR REPLACE TASK LOAD_TASK
      WAREHOUSE = YOUR_WAREHOUSE
      AFTER TRANSFORM_TASK
    AS
      CALL load_to_target()
  `
})

// Activate tasks (must activate in reverse order - child to parent)
mcp__snowflake-simple__execute_query({
  "query": "ALTER TASK LOAD_TASK RESUME"
})

mcp__snowflake-simple__execute_query({
  "query": "ALTER TASK TRANSFORM_TASK RESUME"
})

mcp__snowflake-simple__execute_query({
  "query": "ALTER TASK EXTRACT_TASK RESUME"
})
```

## Common Task Patterns

### 1. Incremental Data Load

```sql
CREATE OR REPLACE TASK INCREMENTAL_LOAD
  WAREHOUSE = YOUR_WAREHOUSE
  SCHEDULE = '30 MINUTE'
AS
  MERGE INTO target_table t
  USING (
    SELECT * FROM source_table
    WHERE updated_at > (SELECT MAX(updated_at) FROM target_table)
  ) s
  ON t.id = s.id
  WHEN MATCHED THEN UPDATE SET t.value = s.value
  WHEN NOT MATCHED THEN INSERT VALUES (s.id, s.value);
```

### 2. Data Quality Check

```sql
CREATE OR REPLACE TASK DATA_QUALITY_CHECK
  WAREHOUSE = YOUR_WAREHOUSE
  SCHEDULE = '60 MINUTE'
AS
  INSERT INTO quality_log
  SELECT
    CURRENT_TIMESTAMP() as check_time,
    'row_count' as metric,
    COUNT(*) as value
  FROM critical_table
  WHERE DATE(created_at) = CURRENT_DATE();
```

### 3. Conditional Task Execution

```sql
CREATE OR REPLACE TASK CONDITIONAL_TASK
  WAREHOUSE = YOUR_WAREHOUSE
  SCHEDULE = '15 MINUTE'
  WHEN
    SYSTEM$STREAM_HAS_DATA('my_stream')
AS
  INSERT INTO target_table
  SELECT * FROM my_stream;
```

Only runs when stream has data.

### 4. Stored Procedure Task

```sql
CREATE OR REPLACE TASK CALL_PROCEDURE_TASK
  WAREHOUSE = YOUR_WAREHOUSE
  SCHEDULE = 'USING CRON 0 0 * * * UTC'
AS
  CALL daily_aggregation_procedure();
```

### 5. Dynamic SQL Task

```sql
CREATE OR REPLACE TASK DYNAMIC_SQL_TASK
  WAREHOUSE = YOUR_WAREHOUSE
  SCHEDULE = '24 HOUR'
AS
BEGIN
  LET table_name := 'events_' || TO_CHAR(CURRENT_DATE(), 'YYYYMMDD');
  EXECUTE IMMEDIATE 'CREATE TABLE IF NOT EXISTS ' || :table_name || ' AS SELECT * FROM events WHERE DATE(ts) = CURRENT_DATE()';
END;
```

### 6. Slack Notification Task

Slackへの自動通知を送信するタスクの作成手順。

#### ステップ1: Webhook URLのSecret作成

```bash
snow sql --connection YOUR_CONNECTION --query "
USE DATABASE YOUR_DB;
USE SCHEMA YOUR_SCHEMA;

CREATE OR REPLACE SECRET slack_webhook_secret
TYPE = GENERIC_STRING
SECRET_STRING = 'YOUR_WEBHOOK_PATH';
"
```

#### ステップ2: Notification Integration作成

```bash
snow sql --connection YOUR_CONNECTION --query "
CREATE OR REPLACE NOTIFICATION INTEGRATION slack_notification
TYPE = WEBHOOK
ENABLED = TRUE
WEBHOOK_URL = 'https://hooks.slack.com/services/YOUR_WEBHOOK_PATH'
WEBHOOK_HEADERS = ('Content-type' = 'application/json');
"
```

#### ステップ3: 通知用ストアドプロシージャ作成

```sql
CREATE OR REPLACE PROCEDURE send_slack_notification()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  CALL SYSTEM$SEND_SNOWFLAKE_NOTIFICATION(
    SNOWFLAKE.NOTIFICATION.APPLICATION_JSON(
      SELECT
        OBJECT_CONSTRUCT(
          'channel', 'your-channel-name',
          'text', 'Daily Report',
          'attachments', ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT(
              'color', 'good',
              'fields', ARRAY_CONSTRUCT(
                OBJECT_CONSTRUCT(
                  'title', 'タイトル1',
                  'value', 'データ1'
                ),
                OBJECT_CONSTRUCT(
                  'title', 'タイトル2',
                  'value', 'データ2'
                ),
                OBJECT_CONSTRUCT(
                  'title', '日時',
                  'value', TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYY-MM-DD HH24:MI:SS')
                )
              )
            )
          )
        )::STRING
    ),
    SNOWFLAKE.NOTIFICATION.INTEGRATION('slack_notification')
  );

  RETURN 'Notification sent successfully';
END;
$$;
```

#### ステップ4: タスク作成と有効化

```bash
snow sql --connection YOUR_CONNECTION --query "
CREATE OR REPLACE TASK daily_slack_notification
  WAREHOUSE = YOUR_WAREHOUSE
  SCHEDULE = 'USING CRON 0 9 * * * UTC'  -- 毎日 UTC 9:00 (JST 18:00)
AS
  CALL send_slack_notification();

ALTER TASK daily_slack_notification RESUME;
"
```

#### テスト実行

```bash
# ストアドプロシージャ単体テスト
snow sql --connection YOUR_CONNECTION --query "CALL send_slack_notification();"

# タスク即時実行
snow sql --connection YOUR_CONNECTION --query "EXECUTE TASK daily_slack_notification;"
```

#### カスタマイズ例

```sql
-- データベースから値を取得してSlackに送信
CREATE OR REPLACE PROCEDURE send_data_summary()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  row_count INTEGER;
  latest_date DATE;
BEGIN
  -- データ取得
  SELECT COUNT(*), MAX(DATE(created_at))
  INTO row_count, latest_date
  FROM your_table
  WHERE DATE(created_at) = CURRENT_DATE();

  -- Slack通知
  CALL SYSTEM$SEND_SNOWFLAKE_NOTIFICATION(
    SNOWFLAKE.NOTIFICATION.APPLICATION_JSON(
      SELECT
        OBJECT_CONSTRUCT(
          'channel', 'data-alerts',
          'text', 'Daily Data Summary',
          'attachments', ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT(
              'color', CASE WHEN row_count > 1000 THEN 'good' ELSE 'warning' END,
              'fields', ARRAY_CONSTRUCT(
                OBJECT_CONSTRUCT('title', '処理件数', 'value', row_count || ' 件'),
                OBJECT_CONSTRUCT('title', '最新日付', 'value', TO_VARCHAR(latest_date, 'YYYY-MM-DD'))
              )
            )
          )
        )::STRING
    ),
    SNOWFLAKE.NOTIFICATION.INTEGRATION('slack_notification')
  );

  RETURN 'Summary sent: ' || row_count || ' rows';
END;
$$;
```

## Task Monitoring

### View Running Tasks

```sql
SHOW TASKS IN SCHEMA;
```

### Check Task Graph

```sql
SELECT
  name,
  state,
  schedule,
  predecessors,
  warehouse
FROM TABLE(INFORMATION_SCHEMA.TASK_DEPENDENTS(
  TASK_NAME => 'ROOT_TASK'
));
```

### Monitor Task Execution

```sql
SELECT
  name,
  state,
  scheduled_time,
  completed_time,
  DATEDIFF('second', scheduled_time, completed_time) as duration_sec,
  error_code,
  error_message
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name = 'MY_TASK'
ORDER BY scheduled_time DESC
LIMIT 100;
```

## Best Practices

1. **Task Activation Order**
   - Always resume child tasks before parent tasks
   - For task graphs, activate from leaf to root
   - Prevents orphaned executions

2. **Testing**
   - Create tasks in SUSPENDED state (automatic)
   - Test with EXECUTE TASK before scheduling
   - Monitor task history after activation
   - Start with longer intervals, optimize later

3. **Error Handling**
   - Add error logging to task SQL
   - Monitor TASK_HISTORY for failures
   - Set up alerts for failed tasks
   - Use TRY/CATCH in stored procedures called by tasks

4. **Performance**
   - Use appropriate warehouse size for workload
   - Consider serverless for variable workloads
   - Avoid overlapping task executions
   - Use SYSTEM$STREAM_HAS_DATA for stream-based tasks

5. **Dependencies**
   - Keep task graphs simple when possible
   - Document dependencies clearly
   - Use meaningful task names
   - Avoid circular dependencies

6. **Scheduling**
   - Use CRON for specific time requirements
   - Use intervals for regular processing
   - Consider timezone for CRON schedules
   - Align schedule with data availability

7. **Security**
   - Grant EXECUTE TASK privilege carefully
   - Use separate warehouses for task workloads
   - Audit task executions regularly
   - Use role-based access for task management

8. **Resource Management**
   - Set warehouse size appropriately
   - Use AUTO_SUSPEND for task warehouses
   - Monitor credit consumption
   - Consider serverless for unpredictable loads

## Common Errors and Fixes

### Task Creation Error: Insufficient Privileges
```
Error: Insufficient privileges to operate on task
```
Fix: Grant EXECUTE TASK privilege: `GRANT EXECUTE TASK ON ACCOUNT TO ROLE role_name`

### Task Won't Run: Not Resumed
```
Task exists but doesn't execute
```
Fix: Resume the task: `ALTER TASK task_name RESUME`

### Child Task Not Running
```
Parent task runs but child doesn't
```
Fix: Resume child task first, then parent

### Schedule Format Error
```
Error: Invalid schedule format
```
Fix: Use valid format - '60 MINUTE' or 'USING CRON ...'

### Warehouse Not Found
```
Error: Warehouse does not exist
```
Fix: Verify warehouse name or create warehouse

### Circular Dependency Error
```
Error: Circular dependency detected
```
Fix: Review task graph, remove circular references

## Task Lifecycle Commands

```sql
-- Create (always suspended)
CREATE TASK my_task ...

-- Test execution
EXECUTE TASK my_task;

-- Activate
ALTER TASK my_task RESUME;

-- Modify schedule
ALTER TASK my_task SET SCHEDULE = '30 MINUTE';

-- Modify SQL
ALTER TASK my_task MODIFY AS <new_sql>;

-- Deactivate
ALTER TASK my_task SUSPEND;

-- Remove
DROP TASK my_task;
```

## Notes

- Tasks are created in SUSPENDED state by default
- ACCOUNTADMIN or EXECUTE TASK privilege required
- Tasks can call stored procedures for complex logic
- Use task graphs (DAGs) for orchestration
- Monitor credit usage - tasks consume warehouse credits
- Serverless tasks automatically scale compute
- Maximum task execution time: 24 hours (can be configured)
- Failed tasks don't retry automatically (use error handling in SQL)
- Task history retained for 7 days (in TASK_HISTORY)
- Root task must have schedule; child tasks use AFTER clause

## References

- [Introduction to Tasks](https://docs.snowflake.com/en/user-guide/tasks-intro)
- [CREATE TASK](https://docs.snowflake.com/en/sql-reference/sql/create-task)
- [Snowflake CLI Object Commands](https://docs.snowflake.com/en/developer-guide/snowflake-cli/command-reference/object-commands/overview)
- [Task History](https://docs.snowflake.com/en/sql-reference/functions/task_history)
- [Definitive Guide to Snowflake Tasks](https://select.dev/posts/snowflake-tasks)
