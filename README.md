# Snowflake Claude開発環境

Claude CodeでSnowflake開発を加速するためのプロダクションレディなスキル集です。Snowflake、Streamlit、データエンジニアリングのワークフローをAIアシスタンスで効率化します。

## 概要

このリポジトリには、Snowflakeプロジェクト向けのAI駆動開発を可能にする、Claude Code専用のスキルが含まれています。これらのスキルは、よくあるSnowflake開発タスクの構造化されたワークフロー、ベストプラクティス、自動化パターンを提供します。

## 含まれるもの

### スキル（`.claude/skills/`）

- **snowflake-operations** - snow CLIを使用したSnowflakeデータベース操作
- **streamlit-deploy** - Streamlitアプリのデプロイと設定
- **notebook-ops** - データ分析用Jupyterノートブックパターン

## クイックスタート

### 1. Claude Codeのインストール

```bash
# Claude Code CLIをインストール
npm install -g @anthropic/claude-code

# またはhttps://claude.ai/downloadを参照
```

### 2. プロジェクトにスキルをコピー

**オプションA: プロジェクト固有（推奨）**

```bash
# Snowflakeプロジェクトにコピー
cp -r .claude your-snowflake-project/
```

**オプションB: グローバル（全プロジェクト）**

```bash
# ホームディレクトリにコピー
cp -r .claude ~/.claude/
```

### 3. Claude Codeの使用を開始

```bash
cd your-snowflake-project
claude

# 以下のように質問してみてください：
# - "Streamlitアプリをデプロイして"
# - "ユーザーテーブルをクエリして"
# - "テーブル用のビューベースアーキテクチャを作成して"
```

## スキルドキュメント

### Snowflakeオペレーションスキル

snow CLIを使用してSnowflake操作を直接実行します。

**使用場面：**
- SQLクエリの実行
- テーブル/ビューの作成・変更
- データのロード
- データベーススキーマの検査

**主な機能：**
- Snowflake接続のテスト
- あらゆるSQL操作の実行
- ビューベースアーキテクチャパターン
- 適切なNULL処理と日付フォーマット
- SQLインジェクション防止

**例：**
```
ユーザー: "IDとEMAILカラムを持つUSERSという新しいテーブルを作成して"
Claude: Snowflakeオペレーションスキルを使用して適切なSQLでテーブルを作成
```

### Streamlitデプロイスキル

Snowflake上でStreamlitアプリをデプロイ・管理します。

**使用場面：**
- 新規Streamlitアプリのデプロイ
- 既存アプリの更新
- デプロイエラーのトラブルシューティング
- 設定ファイルの検証

**主な機能：**
- `snowflake.yml` と `environment.yml` の検証
- 一般的なデプロイエラーの処理
- デプロイのベストプラクティス提供
- デプロイ後の検証

**よくある問題の解決：**
- Pythonバージョンのワイルドカード（`python=3.11.*`）
- パッケージの末尾イコール（`pandas=`）
- `pages_dir`設定エラー

### Notebookオペレーションスキル

Snowflakeデータ分析用のJupyterノートブックパターン。

**使用場面：**
- Snowflakeデータの分析
- データ可視化の作成
- 探索的データ分析の実行
- 結果のSnowflakeへの書き戻し

**主な機能：**
- Snowpark接続パターン
- データクエリと変換
- pandas統合
- 可視化例

## プロジェクト構造

```
your-snowflake-project/
├── .claude/
│   └── skills/
│       ├── snowflake-operations/
│       │   └── SKILL.md
│       ├── streamlit-deploy/
│       │   └── SKILL.md
│       └── notebook-ops/
│           └── SKILL.md
├── Streamlit/
│   └── your-app/
│       ├── streamlit_app.py
│       ├── snowflake.yml
│       └── environment.yml
├── notebooks/
│   └── analysis.ipynb
└── README.md
```

## ベストプラクティス

### データベース操作

1. **完全修飾名を使用**
   ```sql
   -- 良い
   SELECT * FROM DATABASE.SCHEMA.TABLE

   -- 避ける
   SELECT * FROM TABLE
   ```

2. **ビューベースアーキテクチャ**
   ```sql
   -- メタデータ付きベーステーブル
   CREATE TABLE SCHEMA.DATA_BASE (
     ID VARCHAR(50),
     NAME VARCHAR(100),
     CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
   );

   -- アプリケーションビュー（クリーンインターフェース）
   CREATE VIEW SCHEMA.DATA AS
   SELECT ID, NAME FROM SCHEMA.DATA_BASE;
   ```

3. **文字列値のエスケープ**
   ```python
   # 常にシングルクォートをエスケープ
   safe_value = user_input.replace("'", "''")
   query = f"INSERT INTO TABLE (COL) VALUES ('{safe_value}')"
   ```

### Streamlitデプロイ

1. **Pythonバージョン**
   ```yaml
   # 常にワイルドカードを使用
   dependencies:
     - python=3.11.*
   ```

2. **パッケージ形式**
   ```yaml
   # 常に=で終わる
   dependencies:
     - pandas=
     - streamlit=
   ```

3. **よくあるエラーを避ける**
   - `snowflake.yml` から `pages_dir: null` を削除
   - Snowflake conda チャネルのパッケージのみを使用
   - デプロイ前にローカルでテスト

## 使用例

### 例1: テーブルの作成とクエリ

```
ユーザー: ID、NAME、EMAILカラムを持つCUSTOMERSテーブルを作成して、
         3つのサンプルレコードを挿入してクエリして。

Claude:
1. Snowflake操作でテーブルを作成
2. サンプルデータを挿入
3. クエリして結果を表示
```

### 例2: Streamlitアプリのデプロイ

```
ユーザー: StreamlitアプリをSnowflakeにデプロイして

Claude:
1. snowflake.yml と environment.yml を検証
2. よくある設定エラーをチェック
3. snow CLIでデプロイを実行
4. アプリURLを提供
```

### 例3: データ分析

```
ユーザー: 過去30日間の売上データを分析して可視化して

Claude:
1. Snowflakeから売上データをクエリ
2. 集計と分析を実行
3. pandas/matplotlibで可視化を作成
4. オプションで結果をSnowflakeに保存
```

## カスタマイズ

### 独自のスキルを追加

1. `.claude/skills/` に新しいディレクトリを作成
2. ワークフローを記述した `SKILL.md` ファイルを追加
3. 既存スキルのフォーマットに従う

### プロジェクト固有の設定

プロジェクトに `.claude/CLAUDE.md` を作成：

```markdown
# プロジェクト名

プロジェクトの説明とClaude向けのコンテキスト

## データベース情報

- データベース: YOUR_DATABASE
- スキーマ: YOUR_SCHEMA
- 主要テーブル: LIST_YOUR_TABLES

## プロジェクト固有のルール

- 特定の命名規則を使用
- 会社のセキュリティポリシーに従う
- など
```

## トラブルシューティング

### Snowflake接続の問題

```bash
# 接続をテスト
snow connection test --connection my_connection

# 接続をリスト
snow connection list

# 接続を追加
snow connection add
```

### Streamlitデプロイエラー

よくある修正：
1. Pythonバージョン: `python=3.11.*` に変更
2. パッケージ: 末尾に `=` を追加（例：`pandas=`）
3. `snowflake.yml` から `pages_dir` を削除
4. 接続を確認：`snow connection list`

### Claudeがスキルを使用しない

1. スキルが `.claude/skills/` ディレクトリにあることを確認
2. ファイル名が `SKILL.md` であることを確認
3. Claude Codeを再起動
4. タスクを明示的に言及してみる（例：「Streamlitアプリをデプロイ」）

## 貢献

貢献を歓迎します！以下をお願いします：

1. 既存のスキル形式に従う
2. 提出前にスキルをテスト
3. 会社固有または機密情報を削除
4. 新しいスキルでREADMEを更新

## リソース

- [Claude Codeドキュメント](https://docs.anthropic.com/claude/docs/claude-code)
- [Snowflake CLIドキュメント](https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/index)
- [Streamlit on Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)

## ライセンス

MIT License - プロジェクトで自由に使用・変更してください。

---

**Happy Snowflake AI開発！**
