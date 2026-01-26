# Snowflake Claude開発環境

Claude CodeでSnowflake開発を加速するスキル集。Snowflake CLI操作、UDF作成、タスクスケジューリング、Slack通知を自然言語で実行できます。

## Claudeとの開発について

このリポジトリのスキルを使うと、Claude Codeが自動的にSnowflake開発のベストプラクティスを適用します。「UDFを作って」「タスクをスケジュールして」「Slackに通知して」と話しかけるだけで、適切なコマンドと設定を提案します。

## 構成

### Skills
- **snowflake-udf** - UDF作成
- **snowflake-task** - タスクスケジューリング
- **snowflake-cli-operations** - SQL実行
- **streamlit-deploy** - Streamlitデプロイ
- **notebook-ops** - データ分析

### Commands
- **/deploy** - Streamlitデプロイガードレール
- **/prod-check** - 本番操作確認

### Agents
- **Security Reviewer** - セキュリティレビュー（SQLインジェクション、権限過多、PII露出）

### Rules
- **snowflake-best-practices** - 命名、セキュリティ、パフォーマンス
- **deployment** - デプロイルール

### Hooks
- **hooks.json** - イベント自動化

## クイックスタート

### 1. Snowflake CLIのインストール

```bash
pip install snowflake-cli-labs
# または
brew install snowflake-cli
```

### 2. 接続設定

`~/.snowflake/config.toml`:
```toml
[connections.my_connection]
account = "YOUR_ACCOUNT"
user = "YOUR_USERNAME"
authenticator = "externalbrowser"
role = "YOUR_ROLE"
warehouse = "YOUR_WAREHOUSE"
database = "YOUR_DATABASE"
schema = "YOUR_SCHEMA"
```

### 3. Claude Codeで使用

```bash
cd your-project
claude

# 例：
# "売上データを集計するUDFを作って"
# "毎日9時にデータ更新するタスクを作って"
# "エラーが発生したらSlackに通知して"
```

## 使用例

### UDF作成

```
ユーザー: 文字列を大文字に変換するUDFを作って
Claude: snowflake-udfスキルを使って、プロジェクト作成からデプロイまで実行
```

### タスクスケジューリング

```
ユーザー: 毎時データをリフレッシュするタスクを作って
Claude: snowflake-taskスキルで、タスク作成・スケジュール設定・有効化
```

### Slack通知

```
ユーザー: データ更新が完了したらSlackに通知して
Claude: Webhook設定・Integration作成・通知ストアドプロシージャ作成
```

## スキルドキュメント

詳細は各スキルの`SKILL.md`を参照：
- [snowflake-udf](skills/snowflake-udf/SKILL.md)
- [snowflake-task](skills/snowflake-task/SKILL.md)
- [snowflake-cli-operations](skills/snowflake-cli-operations/SKILL.md)
- [streamlit-deploy](skills/streamlit-deploy/SKILL.md)
- [notebook-ops](skills/notebook-ops/SKILL.md)

## プロジェクト構造

```
your-project/
├── .claude/
│   └── skills/          # Claude Codeスキル
├── my-udf/              # UDFプロジェクト
├── streamlit-app/       # Streamlitアプリ
└── README.md
```

## リソース

- [Claude Code](https://claude.ai/claude-code)
- [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli)
- [Snowflake Tasks](https://docs.snowflake.com/en/user-guide/tasks-intro)

## ライセンス

MIT License - 自由に使用・変更してください。
