# Snowflake操作スキル

**Name:** snowflake-operations
**Version:** 2.0.0
**Description:** snow CLIを使用してSnowflake操作を実行します。データベースクエリ、テーブル/ビューの作成、データ管理、接続テストを実行。Snowflakeデータベースと直接やり取りする場合、SQLを実行する場合、またはデータベースオブジェクトを管理する場合に使用します。

## いつ使うか

- ユーザーがSnowflakeに対してSQLクエリを実行したい
- データベースオブジェクト（テーブル、ビュー）を作成/変更する必要がある
- Snowflake接続ステータスを確認したい
- Snowflakeにデータをロードする必要がある
- データベーススキーマやデータの検査について質問がある

## 前提条件

- `snow` CLIがインストールされ、設定されている
- Snowflake接続が設定されている（`snow connection list`）
- 適切なデータベース権限

## Snow CLIコマンド

### 接続確認

常に接続を確認することから始めます：

```bash
snow connection list
```

特定の接続をテスト：

```bash
snow connection test --connection my_connection
```

### SQLクエリの実行

**単一クエリ：**
```bash
snow sql -q "SELECT * FROM DATABASE.SCHEMA.TABLE LIMIT 10" --connection my_connection
```

**ファイルから実行：**
```bash
snow sql -f query.sql --connection my_connection
```

**複数クエリ：**
```bash
snow sql -f script.sql --connection my_connection
```

### 出力フォーマット

**テーブル形式（デフォルト）：**
```bash
snow sql -q "SELECT * FROM TABLE" --connection my_connection
```

**JSON形式：**
```bash
snow sql -q "SELECT * FROM TABLE" --format json --connection my_connection
```

**CSV形式：**
```bash
snow sql -q "SELECT * FROM TABLE" --format csv --connection my_connection
```

## よくある操作

### 1. 接続管理

全ての接続をリスト：
```bash
snow connection list
```

新しい接続を追加：
```bash
snow connection add
```

接続をテスト：
```bash
snow connection test --connection my_connection
```

### 2. データのクエリ

**シンプルなクエリ：**
```bash
snow sql -q "SELECT * FROM DATABASE.SCHEMA.TABLE LIMIT 10" --connection my_connection
```

**ファイルへの出力：**
```bash
snow sql -q "SELECT * FROM TABLE" --format csv > output.csv --connection my_connection
```

**変数付きクエリ：**
```bash
snow sql -q "SELECT * FROM TABLE WHERE DATE > '2025-01-01'" --connection my_connection
```

### 3. テーブルの作成

SQLファイル `create_table.sql` を作成：
```sql
CREATE OR REPLACE TABLE DATABASE.SCHEMA.TABLE_NAME (
  ID VARCHAR(50),
  NAME VARCHAR(100),
  EMAIL VARCHAR(255),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

実行：
```bash
snow sql -f create_table.sql --connection my_connection
```

またはインライン：
```bash
snow sql -q "CREATE OR REPLACE TABLE DATABASE.SCHEMA.TABLE_NAME (
  ID VARCHAR(50),
  NAME VARCHAR(100),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)" --connection my_connection
```

### 4. ビューの作成

```bash
snow sql -q "CREATE OR REPLACE VIEW DATABASE.SCHEMA.VIEW_NAME AS
  SELECT ID, NAME FROM DATABASE.SCHEMA.TABLE_NAME" --connection my_connection
```

### 5. データの挿入

**1行：**
```bash
snow sql -q "INSERT INTO DATABASE.SCHEMA.TABLE (ID, NAME) VALUES ('1', 'Test')" --connection my_connection
```

**複数行：**
```bash
snow sql -q "INSERT INTO TABLE (ID, NAME) VALUES
  ('1', 'User1'),
  ('2', 'User2'),
  ('3', 'User3')" --connection my_connection
```

**CSVファイルから：**
```bash
snow stage copy data.csv @~/ --connection my_connection
snow sql -q "COPY INTO TABLE FROM @~/data.csv FILE_FORMAT = (TYPE = CSV)" --connection my_connection
```

### 6. データの更新

```bash
snow sql -q "UPDATE DATABASE.SCHEMA.TABLE
  SET NAME = 'Updated'
  WHERE ID = '1'" --connection my_connection
```

### 7. データの削除

```bash
snow sql -q "DELETE FROM DATABASE.SCHEMA.TABLE WHERE ID = '1'" --connection my_connection
```

### 8. スキーマの確認

**テーブルの説明：**
```bash
snow sql -q "DESCRIBE TABLE DATABASE.SCHEMA.TABLE_NAME" --connection my_connection
```

**カラムの表示：**
```bash
snow sql -q "SHOW COLUMNS IN TABLE DATABASE.SCHEMA.TABLE_NAME" --connection my_connection
```

### 9. オブジェクトのリスト

**テーブルのリスト：**
```bash
snow sql -q "SHOW TABLES IN SCHEMA DATABASE.SCHEMA" --connection my_connection
```

**ビューのリスト：**
```bash
snow sql -q "SHOW VIEWS IN SCHEMA DATABASE.SCHEMA" --connection my_connection
```

**データベースのリスト：**
```bash
snow sql -q "SHOW DATABASES" --connection my_connection
```

**スキーマのリスト：**
```bash
snow sql -q "SHOW SCHEMAS IN DATABASE DATABASE_NAME" --connection my_connection
```

### 10. SQLスクリプトの実行

複数のステートメントを含むSQLスクリプトファイルを作成：

`setup.sql`:
```sql
-- ベーステーブルの作成
CREATE OR REPLACE TABLE DATABASE.SCHEMA.DATA_BASE (
  ID VARCHAR(50),
  NAME VARCHAR(100),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- ビューの作成
CREATE OR REPLACE VIEW DATABASE.SCHEMA.DATA AS
SELECT ID, NAME FROM DATABASE.SCHEMA.DATA_BASE;

-- サンプルデータの挿入
INSERT INTO DATABASE.SCHEMA.DATA_BASE (ID, NAME) VALUES
  ('1', 'Sample 1'),
  ('2', 'Sample 2');
```

実行：
```bash
snow sql -f setup.sql --connection my_connection
```

## データパターン

### ビューベースアーキテクチャ

メタデータカラムを含むベーステーブルを作成し、アプリケーションにはクリーンなビューを公開：

`architecture.sql`:
```sql
-- ステップ1: 監査カラム付きベーステーブル
CREATE OR REPLACE TABLE DATABASE.SCHEMA.USERS_BASE (
  ID VARCHAR(50) PRIMARY KEY,
  EMAIL VARCHAR(255) UNIQUE NOT NULL,
  NAME VARCHAR(100),
  CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  CREATED_BY VARCHAR(100),
  UPDATED_BY VARCHAR(100)
);

-- ステップ2: アプリケーションビュー（クリーンなインターフェース）
CREATE OR REPLACE VIEW DATABASE.SCHEMA.USERS AS
SELECT ID, EMAIL, NAME
FROM DATABASE.SCHEMA.USERS_BASE;
```

実行：
```bash
snow sql -f architecture.sql --connection my_connection
```

**利点：**
- アプリケーションはクリーンなビューインターフェースを使用
- 監査カラムは自動的に維持される
- アプリの変更なしにスキーマ進化が容易
- ビューでアクセス制御を一元化

### NULL値の処理

SQLを動的に構築する場合：

**Bashスクリプト例：**
```bash
#!/bin/bash
ID="123"
NAME="John Doe"
EMAIL=""  # 空の値

# NULL処理付きSQLを構築
if [ -z "$EMAIL" ]; then
  EMAIL_VALUE="NULL"
else
  # シングルクォートをエスケープ
  EMAIL_VALUE="'${EMAIL//\'/\'\'}'"
fi

snow sql -q "INSERT INTO TABLE (ID, NAME, EMAIL) VALUES ('$ID', '$NAME', $EMAIL_VALUE)" --connection my_connection
```

**Pythonスクリプト例：**
```python
import subprocess

def execute_snowflake_sql(query, connection="my_connection"):
    cmd = ["snow", "sql", "-q", query, "--connection", connection]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout

# NULL処理付きクエリを構築
def safe_value(value):
    if value is None or value == '' or str(value) == 'None':
        return 'NULL'
    # シングルクォートをエスケープ
    return f"'{str(value).replace(\"'\", \"''\")}'"

# 実行
query = f"INSERT INTO TABLE (ID, NAME) VALUES ({safe_value('123')}, {safe_value(None)})"
execute_snowflake_sql(query)
```

### 日付フォーマット

SnowflakeはISO 8601形式が必要：

```bash
# 正しい
snow sql -q "INSERT INTO TABLE (DATE_COL) VALUES ('2025-01-21')" --connection my_connection

# 間違い（失敗する）
snow sql -q "INSERT INTO TABLE (DATE_COL) VALUES ('1/21/2025')" --connection my_connection
```

**日付を適切にフォーマット：**
```bash
# bashで
DATE=$(date +%Y-%m-%d)
snow sql -q "INSERT INTO TABLE (DATE_COL) VALUES ('$DATE')" --connection my_connection
```

## ベストプラクティス

### 1. 常に接続名を使用

```bash
# 良い
snow sql -q "SELECT ..." --connection production

# 避ける（デフォルト接続を使用）
snow sql -q "SELECT ..."
```

### 2. 完全修飾オブジェクト名を使用

```bash
# 良い - 完全修飾
snow sql -q "SELECT * FROM MY_DB.MY_SCHEMA.MY_TABLE"

# リスク - コンテキストに依存
snow sql -q "SELECT * FROM MY_TABLE"
```

### 3. 複雑な操作にはSQLファイルを使用

```bash
# 良い - バージョン管理、再利用可能
snow sql -f migrations/001_create_tables.sql --connection my_connection

# 避ける - メンテナンスが困難
snow sql -q "CREATE TABLE...; CREATE VIEW...; INSERT..." --connection my_connection
```

### 4. エラーハンドリング

```bash
# 出力をキャプチャしてエラーをチェック
OUTPUT=$(snow sql -q "SELECT * FROM TABLE" --connection my_connection 2>&1)
if [ $? -ne 0 ]; then
  echo "エラー: $OUTPUT"
  exit 1
fi
```

### 5. 文字列値をエスケープ

ユーザー入力は常にエスケープしてSQLインジェクションを防止：

```bash
# 悪い - SQLインジェクションリスク
USER_INPUT="'; DROP TABLE users; --"
snow sql -q "SELECT * FROM users WHERE name = '$USER_INPUT'"

# 良い - エスケープ済み
SAFE_INPUT="${USER_INPUT//\'/\'\'}"
snow sql -q "SELECT * FROM users WHERE name = '$SAFE_INPUT'"
```

### 6. 複数操作にはトランザクションを使用

```sql
-- transaction.sql
BEGIN TRANSACTION;

CREATE TABLE DATABASE.SCHEMA.TABLE1 (...);
CREATE TABLE DATABASE.SCHEMA.TABLE2 (...);
CREATE VIEW DATABASE.SCHEMA.VIEW1 AS SELECT ...;

COMMIT;
```

```bash
snow sql -f transaction.sql --connection my_connection
```

### 7. 実行前にクエリをテスト

```bash
# まずLIMITでテスト
snow sql -q "SELECT * FROM LARGE_TABLE LIMIT 10" --connection my_connection

# その後フルクエリを実行
snow sql -q "SELECT * FROM LARGE_TABLE" --connection my_connection
```

### 8. 出力フォーマットを適切に使用

```bash
# スクリプト/自動化用 - JSON使用
snow sql -q "SELECT COUNT(*) FROM TABLE" --format json --connection my_connection

# 人間のレビュー用 - テーブル形式使用
snow sql -q "SELECT * FROM TABLE LIMIT 10" --connection my_connection

# データエクスポート用 - CSV使用
snow sql -q "SELECT * FROM TABLE" --format csv > export.csv --connection my_connection
```

## よくあるワークフロー

### ワークフロー1: 初期データベースセットアップ

```bash
#!/bin/bash
CONNECTION="my_connection"

# 1. データベースの作成
snow sql -q "CREATE DATABASE IF NOT EXISTS MY_DATABASE" --connection $CONNECTION

# 2. スキーマの作成
snow sql -q "CREATE SCHEMA IF NOT EXISTS MY_DATABASE.RAW_DATA" --connection $CONNECTION
snow sql -q "CREATE SCHEMA IF NOT EXISTS MY_DATABASE.TRANSFORMED" --connection $CONNECTION
snow sql -q "CREATE SCHEMA IF NOT EXISTS MY_DATABASE.ANALYTICS" --connection $CONNECTION

# 3. ベーステーブルの作成
snow sql -f sql/create_tables.sql --connection $CONNECTION

# 4. ビューの作成
snow sql -f sql/create_views.sql --connection $CONNECTION

echo "データベースセットアップ完了"
```

### ワークフロー2: データ移行

```bash
#!/bin/bash
CONNECTION="my_connection"

# 1. 既存テーブルのバックアップ
snow sql -q "CREATE TABLE BACKUP.SCHEMA.TABLE_BACKUP AS SELECT * FROM PROD.SCHEMA.TABLE" --connection $CONNECTION

# 2. マイグレーション実行
snow sql -f migrations/001_add_columns.sql --connection $CONNECTION

# 3. 検証
COUNT=$(snow sql -q "SELECT COUNT(*) FROM PROD.SCHEMA.TABLE" --format json --connection $CONNECTION | jq '.[0].COUNT')

if [ "$COUNT" -gt 0 ]; then
  echo "マイグレーション成功。行数: $COUNT"
else
  echo "マイグレーション失敗。バックアップを復元中..."
  snow sql -q "DROP TABLE PROD.SCHEMA.TABLE" --connection $CONNECTION
  snow sql -q "ALTER TABLE BACKUP.SCHEMA.TABLE_BACKUP RENAME TO PROD.SCHEMA.TABLE" --connection $CONNECTION
fi
```

### ワークフロー3: 日次データロード

```bash
#!/bin/bash
CONNECTION="my_connection"
DATE=$(date +%Y-%m-%d)

# 1. ステージにデータをアップロード
snow stage copy "data_${DATE}.csv" @MY_STAGE/ --connection $CONNECTION

# 2. 一時テーブルにロード
snow sql -q "CREATE OR REPLACE TEMP TABLE TEMP_LOAD AS
  SELECT * FROM @MY_STAGE/data_${DATE}.csv
  (FILE_FORMAT => 'MY_CSV_FORMAT')" --connection $CONNECTION

# 3. データを検証
VALIDATION=$(snow sql -q "SELECT COUNT(*) as count,
  SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) as null_ids
  FROM TEMP_LOAD" --format json --connection $CONNECTION)

# 4. 有効な場合、本番環境にマージ
snow sql -f sql/merge_daily_data.sql --connection $CONNECTION

echo "${DATE}のデータロード完了"
```

## トラブルシューティング

### 接続の問題

```bash
# 接続をテスト
snow connection test --connection my_connection

# 全ての接続をリスト
snow connection list

# 再認証
snow connection add --connection my_connection --connection-name my_connection
```

### クエリタイムアウト

```bash
# クエリタイムアウトを設定（秒単位）
snow sql -q "ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 3600" --connection my_connection

# その後長時間クエリを実行
snow sql -q "SELECT * FROM HUGE_TABLE" --connection my_connection
```

### 権限エラー

```bash
# 現在のロールを確認
snow sql -q "SELECT CURRENT_ROLE()" --connection my_connection

# ロールを切り替え
snow sql -q "USE ROLE ACCOUNTADMIN" --connection my_connection

# 権限を確認
snow sql -q "SHOW GRANTS TO ROLE MY_ROLE" --connection my_connection
```

### 大きな結果セット

```bash
# テスト用にLIMITを使用
snow sql -q "SELECT * FROM LARGE_TABLE LIMIT 100" --connection my_connection

# ターミナルではなくファイルにエクスポート
snow sql -q "SELECT * FROM LARGE_TABLE" --format csv > output.csv --connection my_connection

# または非常に大きなエクスポートにはSnowflakeのCOPY INTOを使用
snow sql -q "COPY INTO @MY_STAGE/export.csv
  FROM (SELECT * FROM LARGE_TABLE)
  FILE_FORMAT = (TYPE = CSV)" --connection my_connection
```

## 注意事項

- 全ての操作は即座に実行されます
- 明示的なトランザクションを使用しない限り、自動ロールバックはありません
- クエリ結果には機密データが含まれる可能性があります
- 本番環境で実行する前に必ずSQL構文をテストしてください
- SQLスクリプトにはバージョン管理を使用してください
- 複雑なクエリにはコメントでドキュメント化してください
- 監査のためにSnowflakeのクエリ履歴の使用を検討してください
