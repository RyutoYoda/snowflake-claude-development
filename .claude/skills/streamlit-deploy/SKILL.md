# Streamlitデプロイスキル

**Name:** streamlit-deploy
**Version:** 1.0.0
**Description:** StreamlitアプリケーションをSnowflakeにデプロイします。設定ファイル（snowflake.yml、environment.yml）の検証、一般的なデプロイエラーのチェック、snow CLIを使用したデプロイの実行。Snowflake上のStreamlitアプリのデプロイ、更新、トラブルシューティングに使用します。

## いつ使うか

- ユーザーがStreamlitアプリをSnowflakeにデプロイしたい
- 既存のStreamlitアプリを更新する必要がある
- デプロイエラーが発生している
- デプロイ前に設定を検証したい
- Streamlitデプロイコマンドや設定について質問がある

## 前提条件

- `snow` CLIがインストールされ、設定されている
- Snowflake接続が設定されている
- プロジェクトディレクトリに有効な snowflake.yml と environment.yml がある

## ワークフロー

### 1. 設定ファイルの検証

snowflake.yml を確認：
```yaml
definition_version: 1
streamlit:
  name: app_name
  stage: streamlit
  query_warehouse: COMPUTE_WH
  main_file: streamlit_app.py
  title: "App Title"
```

重要事項：
- `pages_dir` パラメータは含めないこと
- 有効なウェアハウス名を使用すること
- main_file のパスが正しいことを確認すること

environment.yml を確認：
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

重要事項：
- Pythonバージョンは `.*` ワイルドカードを使用すること：`python=3.11.*`
- パッケージ名は `=` で終わること：`pandas=` であって `pandas` ではない
- Snowflake conda チャネルで利用可能なパッケージのみを使用すること

### 2. デプロイ前チェック

```bash
# 現在の接続を確認
snow connection list

# 既存のStreamlitアプリをリスト
snow streamlit list

# snow CLIのバージョンを確認
snow --version
```

### 3. デプロイコマンド

```bash
cd /path/to/project
snow streamlit deploy --connection CONNECTION_NAME --replace
```

既存のアプリを更新するには `--replace` フラグを使用します。

### 4. デプロイ後

```bash
# アプリURLを取得
snow streamlit get-url APP_NAME

# Snowflake UIでデプロイステータスを確認
```

## よくあるエラーと修正方法

### Pythonバージョンエラー
```
Error: Packages not found: python==3.11
```
修正：environment.yml で `python=3.11.*` に変更

### パッケージが見つからないエラー
```
Error: Packages not found: pandas
```
修正：パッケージ名の末尾に `=` を追加：`pandas=`

### pages_dir エラー
```
Error: Provided file null does not exist
```
修正：snowflake.yml から `pages_dir: null` を削除

### 接続エラー
```
Error: Connection 'name' does not exist
```
修正：`snow connection list` で接続を確認

## Streamlitコードパターン

### 基本セットアップ
```python
import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()
```

### テーブルからの読み取り
```python
df = session.table("SCHEMA.TABLE_NAME").to_pandas()
```

### 編集可能なテーブル
```python
edited_df = st.data_editor(df, num_rows="dynamic")
```

### テーブルへの保存
```python
if st.button("保存"):
    session.create_dataframe(edited_df).write.mode("overwrite").save_as_table("TABLE_NAME")
```

### クエリの実行
```python
result = session.sql("SELECT * FROM TABLE").to_pandas()
```

## 注意事項

- デプロイ前に必ず設定ファイルを検証すること
- 可能であればSnowflakeにデプロイする前にローカルでテストすること
- 既存アプリの更新には `--replace` フラグを使用すること
- 詳細なデプロイログはSnowflake UIで確認すること
- Snowflake上のStreamlitアプリはSnowparkセッションを使用し、従来のデータベース接続は使用しない
