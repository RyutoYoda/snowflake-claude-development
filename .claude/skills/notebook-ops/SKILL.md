# Notebookオペレーションスキル

**Name:** notebook-ops
**Version:** 1.0.0
**Description:** SnowflakeデータAnalysisと探索のためのJupyterノートブックを扱います。ノートブック環境のセットアップ、Snowflakeへの接続、クエリの実行、データ分析、可視化の作成。Jupyterノートブックの使用、アドホック分析、またはSnowflakeデータのインタラクティブな探索に使用します。

## いつ使うか

- ユーザーがノートブックでSnowflakeデータを分析したい
- データ可視化を作成する必要がある
- インタラクティブにデータを探索したい
- クエリや変換をプロトタイピングしている
- JupyterまたはノートブックのセットアップAbout質問がある

## セットアップ

### 必要なパッケージのインストール

```python
# ノートブックまたはrequirements.txtで
snowflake-snowpark-python
pandas
matplotlib
seaborn
jupyter
```

### ノートブックでのSnowflake接続

```python
from snowflake.snowpark import Session
import pandas as pd

# 接続パラメータ
connection_parameters = {
    "account": "your_account",
    "user": "your_user",
    "password": "your_password",
    "role": "your_role",
    "warehouse": "your_warehouse",
    "database": "your_database",
    "schema": "your_schema"
}

# セッションを作成
session = Session.builder.configs(connection_parameters).create()
```

### 代替方法：SnowSQL設定を使用

```python
from snowflake.snowpark import Session
import configparser
import os

# ~/.snowsql/config から読み込み
config = configparser.ConfigParser()
config.read(os.path.expanduser('~/.snowsql/config'))

connection_parameters = {
    "account": config['connections']['accountname'],
    "user": config['connections']['username'],
    # ... 他のパラメータ
}

session = Session.builder.configs(connection_parameters).create()
```

## よくある操作

### 1. データのクエリ

```python
# Snowparkを使用
df = session.table("SCHEMA.TABLE_NAME").to_pandas()

# またはSQLを直接使用
df = session.sql("SELECT * FROM SCHEMA.TABLE_NAME LIMIT 100").to_pandas()

# 表示
df.head()
```

### 2. データ探索

```python
# 形状と情報
print(f"行数: {len(df)}, カラム数: {len(df.columns)}")
df.info()

# 統計サマリー
df.describe()

# カラムタイプ
df.dtypes

# 欠損値
df.isnull().sum()

# ユニーク値
df['column_name'].nunique()
```

### 3. データ可視化

```python
import matplotlib.pyplot as plt
import seaborn as sns

# スタイルを設定
sns.set_style("whitegrid")

# 棒グラフ
df['column'].value_counts().plot(kind='bar')
plt.title('分布')
plt.show()

# 時系列
df['date'] = pd.to_datetime(df['date'])
df.set_index('date')['value'].plot()
plt.title('時系列')
plt.show()

# ヒストグラム
df['numeric_column'].hist(bins=50)
plt.title('分布')
plt.show()
```

### 4. データ変換

```python
# フィルター
filtered = df[df['column'] > 100]

# グループ化と集計
grouped = df.groupby('category')['value'].sum()

# 結合
merged = df1.merge(df2, on='key', how='left')

# ピボット
pivot = df.pivot_table(values='value', index='row', columns='col')

# 計算カラムの追加
df['new_col'] = df['col1'] + df['col2']
```

### 5. Snowflakeへの書き戻し

```python
# pandas DataFrameからSnowflakeへ
session.create_dataframe(df).write.mode("overwrite").save_as_table("SCHEMA.TABLE_NAME")

# 上書きではなく追加
session.create_dataframe(df).write.mode("append").save_as_table("SCHEMA.TABLE_NAME")
```

### 6. DDLの実行

```python
# テーブルの作成
session.sql("""
    CREATE OR REPLACE TABLE SCHEMA.TABLE_NAME (
        ID VARCHAR(50),
        VALUE NUMBER
    )
""").collect()

# ビューの作成
session.sql("""
    CREATE OR REPLACE VIEW SCHEMA.VIEW_NAME AS
    SELECT * FROM SCHEMA.TABLE_NAME WHERE VALUE > 0
""").collect()
```

## データ分析パターン

### アドホッククエリ開発

```python
# 小さなサンプルから始める
sample = session.sql("SELECT * FROM LARGE_TABLE LIMIT 1000").to_pandas()

# 変換ロジックを開発
transformed = sample.copy()
# ... 変換を適用 ...

# 満足したら、フルデータセットに適用
full_df = session.table("LARGE_TABLE").to_pandas()
final = apply_transformations(full_df)
```

### CSVデータの読み込み

```python
# CSVを読み込み
csv_df = pd.read_csv('file.csv')

# クリーンアップと変換
csv_df = csv_df.dropna()
csv_df['date'] = pd.to_datetime(csv_df['date'])

# Snowflakeにアップロード
session.create_dataframe(csv_df).write.mode("overwrite").save_as_table("SCHEMA.IMPORTED_DATA")
```

### データ品質チェック

```python
# 重複をチェック
duplicates = df[df.duplicated(subset=['id'], keep=False)]
print(f"重複: {len(duplicates)}")

# NULL値をチェック
null_counts = df.isnull().sum()
print("カラムごとのNULL値:")
print(null_counts[null_counts > 0])

# 日付範囲をチェック
print(f"日付範囲: {df['date'].min()} から {df['date'].max()}")

# 値の範囲をチェック
print(f"値の範囲: {df['value'].min()} から {df['value'].max()}")
```

## ベストプラクティス

1. **小さく始める**
   - クエリ開発時はLIMITを使用
   - まずサンプルデータでテスト

2. **セッションを閉じる**
   - 完了時は必ずSnowparkセッションを閉じる
   ```python
   session.close()
   ```

3. **型変換を使用**
   - 分析のためにSnowpark DataFrameをpandasに変換
   - pandasの方が分析関数が豊富

4. **中間結果を保存**
   - 中間テーブルをSnowflakeに書き込む
   - 高コストなクエリの再実行を避ける

5. **分析を文書化**
   - markdownセルでロジックを説明
   - 複雑な変換にはコメントを追加

6. **バージョン管理**
   - ノートブックをgitに保存
   - 分析コードの変更を追跡

## 注意事項

- ノートブックは探索と分析用であり、本番用ではありません
- 本番ダッシュボードにはStreamlitを使用してください
- ノートブックは特定の分析タスクに焦点を当ててください
- 成功したノートブックコードは本番スクリプトへの変換を検討してください
- pandasへの変換時はデータサイズに注意してください
