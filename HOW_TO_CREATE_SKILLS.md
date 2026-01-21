# Claude Code 完全ガイド - プロダクションレディな設定を作る

このガイドは、[Anthropic Hackathon優勝リポジトリ](https://github.com/affaan-m/everything-claude-code)を参考に作成されました。Claude Codeを最大限に活用するための包括的な設定方法を説明します。

## 目次

1. [全体像](#全体像)
2. [ディレクトリ構造](#ディレクトリ構造)
3. [Skills - ワークフロー定義](#skills---ワークフロー定義)
4. [Commands - スラッシュコマンド](#commands---スラッシュコマンド)
5. [Rules - 常に従うガイドライン](#rules---常に従うガイドライン)
6. [Agents - サブエージェント](#agents---サブエージェント)
7. [Hooks - イベント駆動自動化](#hooks---イベント駆動自動化)
8. [実践例](#実践例)
9. [パフォーマンス最適化](#パフォーマンス最適化)

---

## 全体像

Claude Codeの設定は、**5つの主要コンポーネント**で構成されます：

| コンポーネント | 役割 | 例 |
|------------|------|-----|
| **Skills** | ワークフロー定義・ドメイン知識 | TDD workflow, コーディング標準 |
| **Commands** | スラッシュコマンドで即座に実行 | `/tdd`, `/plan`, `/code-review` |
| **Rules** | 常に従うべきガイドライン | セキュリティ、テスト、Gitフロー |
| **Agents** | 特定タスクの専門サブエージェント | Planner, Architect, Security Reviewer |
| **Hooks** | イベントトリガーで自動実行 | ツール実行前後の自動化 |

**重要な概念の違い:**
- **Skills** = **ワークフロー定義**（"何をどの順序で行うか"）
- **Rules** = **制約条件**（"常に守るべきこと"）
- **Commands** = **トリガー**（"Skillsを素早く実行する方法"）

---

## ディレクトリ構造

### プロジェクトレベル設定

プロジェクト固有の設定は、プロジェクトルートの `.claude/` に配置：

```
your-project/
├── .claude/
│   ├── skills/               # プロジェクト固有のワークフロー
│   │   ├── deployment/
│   │   │   └── SKILL.md
│   │   └── testing/
│   │       └── SKILL.md
│   ├── commands/             # カスタムスラッシュコマンド
│   │   ├── deploy.md
│   │   └── test.md
│   ├── rules/                # プロジェクト固有のルール
│   │   ├── security.md
│   │   └── coding-style.md
│   ├── agents/               # 専門サブエージェント
│   │   ├── architect.md
│   │   └── reviewer.md
│   ├── settings.json         # Hooks設定
│   └── CLAUDE.md             # プロジェクト説明（Claudeへの指示）
├── src/
└── package.json
```

### ユーザーレベル設定（グローバル）

全プロジェクトで共有する設定は `~/.claude/` に配置：

```
~/.claude/
├── skills/                   # 汎用的なワークフロー
│   ├── tdd-workflow/
│   │   └── SKILL.md
│   ├── coding-standards.md
│   ├── backend-patterns.md
│   └── frontend-patterns.md
├── commands/                 # 汎用コマンド
│   ├── tdd.md
│   ├── plan.md
│   ├── code-review.md
│   └── refactor-clean.md
├── rules/                    # 汎用ルール
│   ├── security.md
│   ├── testing.md
│   ├── git-workflow.md
│   └── performance.md
├── agents/                   # 汎用エージェント
│   ├── planner.md
│   ├── architect.md
│   ├── code-reviewer.md
│   └── security-reviewer.md
└── settings.json             # グローバルHooks
```

### 設定の優先順位

```
プロジェクト設定 (.claude/) > ユーザー設定 (~/.claude/)
```

プロジェクト固有の `.claude/` がある場合、そちらが優先されます。

---

## Skills - ワークフロー定義

Skillsは**ワークフロー定義**であり、単なる技術知識ではありません。「何をどの順序で行うか」を定義します。

### Skillsの種類

**1. プロセスSkills（ワークフロー）**
- TDD workflow - テスト駆動開発の手順
- Code review process - レビュー手順
- Deployment process - デプロイフロー
- Debug workflow - デバッグ手順

**2. 標準Skills（コーディング基準）**
- Coding standards - コーディング規約
- Backend patterns - バックエンドパターン
- Frontend patterns - フロントエンドパターン
- API design - API設計原則

**3. ドメインSkills（技術スタック）**
- AWS operations - AWS操作手順
- Docker workflow - Docker操作フロー
- Database management - DB管理手順
- CI/CD pipeline - CI/CDフロー

### SKILL.mdの構造

```markdown
# [ワークフロー名] Skill

**Name:** workflow-name
**Version:** 1.0.0
**Description:** このSkillが何を達成するのか、いつ使うべきかを1-2行で説明

## Purpose

このワークフローの目的と達成すべきゴールを明確に記述

## Core Principles

このワークフローの核となる原則（3-5個）

## Workflow Steps

ステップバイステップの手順を記述

### Step 1: [ステップ名]

**目的**: なぜこのステップが必要か
**アクション**: 具体的に何をするか
**成果物**: このステップで得られるもの

\```bash
# 実行するコマンド例
command --option value
\```

### Step 2: [次のステップ]

...

## Success Criteria

このワークフローが成功したと言える基準

## Anti-Patterns

避けるべきパターン・やってはいけないこと

## Examples

実際の使用例

## Notes

追加の重要な注意事項
```

### 例：TDD Workflow Skill

```markdown
# TDD Workflow Skill

**Name:** tdd-workflow
**Version:** 1.0.0
**Description:** Test-Driven Development workflow for writing new features, fixing bugs, or refactoring code with 80%+ test coverage

## Purpose

実装前にテストを書くことで、要件を明確化し、バグを早期発見し、リファクタリングを安全に行えるようにする。

## Core Principles

1. **Test First**: コード実装前にテストを作成
2. **Coverage Requirements**: 80%以上のカバレッジを確保
3. **RED-GREEN-REFACTOR**: この順序を必ず守る
4. **Comprehensive Testing**: エッジケース、エラーシナリオ、境界条件をカバー

## Workflow Steps

### Step 1: Define Interfaces (INTERFACE)

**目的**: 入出力の型を明確にする
**アクション**:
- 関数のシグネチャを定義
- 入力パラメータの型を定義
- 戻り値の型を定義
- エラーケースを特定

**成果物**: TypeScript interfaces / types

\```typescript
interface UserInput {
  email: string;
  password: string;
}

interface AuthResult {
  success: boolean;
  token?: string;
  error?: string;
}

function authenticateUser(input: UserInput): Promise<AuthResult>
\```

### Step 2: Write Failing Tests (RED)

**目的**: テストが実際に失敗することを確認
**アクション**:
- 期待する動作を記述するテストを作成
- エッジケースのテストも作成
- エラーケースのテストも作成

**成果物**: 失敗するテストスイート

\```typescript
describe('authenticateUser', () => {
  it('should return success with valid credentials', async () => {
    const result = await authenticateUser({
      email: 'test@example.com',
      password: 'password123'
    });
    expect(result.success).toBe(true);
    expect(result.token).toBeDefined();
  });

  it('should return error with invalid password', async () => {
    const result = await authenticateUser({
      email: 'test@example.com',
      password: 'wrong'
    });
    expect(result.success).toBe(false);
    expect(result.error).toBeDefined();
  });
});
\```

**重要**: テストを実行して失敗することを確認！

### Step 3: Implement Minimal Code (GREEN)

**目的**: テストを通すだけの最小限のコード
**アクション**:
- テストを通すための最小実装
- 最適化はまだしない
- 全テストが通ることを確認

**成果物**: テストが通る実装

\```typescript
async function authenticateUser(input: UserInput): Promise<AuthResult> {
  // 最小限の実装
  if (input.password === 'password123') {
    return { success: true, token: 'dummy-token' };
  }
  return { success: false, error: 'Invalid credentials' };
}
\```

### Step 4: Refactor (REFACTOR)

**目的**: コード品質を向上させる
**アクション**:
- 重複を排除
- 変数名を改善
- 関数を分割
- パフォーマンスを最適化
- **テストが引き続き通ることを確認しながら**

**成果物**: クリーンで保守性の高いコード

### Step 5: Verify Coverage (COVERAGE)

**目的**: テストカバレッジを確認
**アクション**:
- カバレッジレポートを生成
- 80%以上を確保
- 不足している部分にテストを追加

\```bash
npm run test:coverage
# または
vitest run --coverage
\```

**成果物**: 80%以上のカバレッジレポート

## Success Criteria

- - 全テストが通る
- - カバレッジ80%以上
- - ユニット・統合・E2Eテストがある
- - エッジケースがカバーされている
- - テスト実行速度が速い（ユニット: <50ms, 統合: <200ms）

## Anti-Patterns

- **REDフェーズをスキップ**: 必ずテストが失敗することを確認する
- **実装の詳細をテスト**: 公開APIのみをテストする
- **テスト間の依存**: 各テストは独立して実行可能
- **脆いセレクタ**: テストIDを使用、CSSクラスは避ける
- **過度なモック**: 必要最小限のモックに留める

## Test Types

### Unit Tests
\```typescript
// 個別関数のテスト
describe('calculateTotal', () => {
  it('should sum prices correctly', () => {
    expect(calculateTotal([10, 20, 30])).toBe(60);
  });
});
\```

### Integration Tests
\```typescript
// APIエンドポイントのテスト
describe('POST /api/auth', () => {
  it('should authenticate and return token', async () => {
    const response = await request(app)
      .post('/api/auth')
      .send({ email: 'test@example.com', password: 'pass' });
    expect(response.status).toBe(200);
    expect(response.body.token).toBeDefined();
  });
});
\```

### E2E Tests (Playwright)
\```typescript
// ユーザーフローのテスト
test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.fill('[data-testid="password"]', 'password');
  await page.click('[data-testid="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
\```

## Notes

- TDDは最初は遅く感じるが、長期的には開発速度が向上する
- リファクタリングが安全にできることが最大の利点
- テストは仕様書の役割も果たす
- カバレッジは目的ではなく手段
```

---

## Commands - スラッシュコマンド

Commandsは、Skillsを素早く実行するためのトリガーです。`/tdd` や `/plan` のように使います。

### Commandの役割

- Skillsワークフローを即座に開始
- 複雑なタスクを1コマンドで実行
- チーム全体で共通の言語を確立

### Commandファイルの構造

```markdown
# /command-name

[このコマンドが何をするかの簡潔な説明]

## Instructions

[Claudeへの具体的な指示]

## Process

[実行するステップの詳細]

## Reference

- Skill: [関連するSkill名]
- Related: [関連するコマンド]
```

### 例：/tdd Command

`.claude/commands/tdd.md`:

```markdown
# /tdd

Test-Driven Development workflow を実行します。RED → GREEN → REFACTOR のサイクルに従ってコードを書きます。

## Instructions

TDD Workflow Skillに従って開発を進めてください：

1. **INTERFACE**: まず型定義・インターフェースを作成
2. **RED**: テストを書いて失敗することを確認
3. **GREEN**: テストを通す最小限の実装
4. **REFACTOR**: テストを保ちながらコード改善
5. **COVERAGE**: 80%以上のカバレッジを確認

## Process

1. ユーザーに実装する機能を確認
2. 関数シグネチャと型を定義
3. テストケースを生成（正常系、異常系、エッジケース）
4. テストを実行して失敗を確認（REDフェーズ）
5. 最小限の実装を追加（GREENフェーズ）
6. リファクタリング（REFACTORフェーズ）
7. カバレッジレポートを確認

## Important Rules

- **必ずREDフェーズを経由**すること（テストが失敗することを確認）
- テスト実行コマンドを明示的に実行
- カバレッジが80%未満の場合は追加テストを作成
- リファクタリング中もテストを実行し続ける

## Reference

- Skill: tdd-workflow
- Related: /test-coverage, /refactor-clean
```

### 例：/plan Command

`.claude/commands/plan.md`:

```markdown
# /plan

新機能や大きなリファクタリングの実装計画を作成します。

## Instructions

以下の手順で計画を立ててください：

1. 要件を明確化（質問があれば聞く）
2. 既存コードベースを調査
3. 影響範囲を特定
4. 段階的な実装ステップに分解
5. 潜在的なリスクを特定
6. テスト戦略を定義

## Process

### 1. Understand Requirements

ユーザーに以下を確認：
- 何を達成したいか
- 制約条件（時間、リソース）
- 成功基準

### 2. Analyze Codebase

\```bash
# 関連ファイルを検索
grep -r "関連キーワード" src/
\```

- 既存の類似機能を確認
- 依存関係を把握
- アーキテクチャを理解

### 3. Create Implementation Plan

\```markdown
## 実装計画

### Phase 1: 準備
- [ ] 依存パッケージのインストール
- [ ] 型定義の作成

### Phase 2: コア機能
- [ ] 基本ロジックの実装
- [ ] ユニットテスト作成

### Phase 3: 統合
- [ ] 既存システムとの統合
- [ ] 統合テスト作成

### Phase 4: 完成
- [ ] E2Eテスト
- [ ] ドキュメント更新
\```

### 4. Identify Risks

- パフォーマンスへの影響
- セキュリティリスク
- 後方互換性の問題
- データ移行の必要性

## Output Format

プランを以下の形式で出力：

\```markdown
# 実装計画: [機能名]

## 概要
[1-2文で説明]

## 目標
- [目標1]
- [目標2]

## 実装ステップ

### Step 1: [ステップ名]
- 作業内容
- 必要なファイル
- 見積もり時間

## リスクと対策
- リスク: [具体的なリスク]
  対策: [具体的な対策]

## テスト戦略
- ユニットテスト: [何をテストするか]
- 統合テスト: [何をテストするか]
- E2Eテスト: [何をテストするか]
\```

## Reference

- Agent: planner
- Related: /tdd, /code-review
```

### よく使うCommandsの例

| Command | 用途 | 関連Skill |
|---------|------|----------|
| `/tdd` | TDD開発 | tdd-workflow |
| `/plan` | 実装計画作成 | planning-workflow |
| `/code-review` | コードレビュー | code-review-process |
| `/refactor-clean` | リファクタリング | refactoring-patterns |
| `/e2e` | E2Eテスト作成 | testing-workflow |
| `/test-coverage` | カバレッジ確認 | testing-standards |
| `/deploy` | デプロイ実行 | deployment-workflow |
| `/security-check` | セキュリティチェック | security-review |

---

## Rules - 常に従うガイドライン

Rulesは、Claudeが**常に従うべき制約条件**です。Skillsがワークフローなら、Rulesは守るべき原則です。

### Rulesの種類

**1. セキュリティルール**
- 認証・認可の実装方法
- 機密情報の扱い
- XSS/CSRF/SQLインジェクション対策

**2. コーディングスタイル**
- 命名規則
- ファイル構成
- イミュータビリティ原則

**3. テストルール**
- カバレッジ要件
- テストの書き方
- モックの使い方

**4. Gitワークフロー**
- ブランチ戦略
- コミットメッセージ規約
- PRの作り方

### Ruleファイルの構造

```markdown
# [カテゴリ] Rules

このルールの目的と重要性を説明

## Critical Rules (絶対に守る)

### Rule 1: [ルール名]

**Why**: なぜこのルールが重要か
**What**: 具体的に何をすべきか
**How**: どのように実装するか

- Good:
\```
良い例のコード
\```

- Bad:
\```
悪い例のコード
\```

## Important Rules (推奨)

...

## Notes

例外条件や追加の注意事項
```

### 例：Security Rules

`.claude/rules/security.md`:

```markdown
# Security Rules

アプリケーションのセキュリティを確保するための必須ルール

## Critical Rules

### Rule 1: Never Store Secrets in Code

**Why**: ソースコードにシークレットを含めると、Gitリポジトリに記録され、流出リスクが高まる

**What**:
- API keys
- Database passwords
- JWT secrets
- OAuth credentials

これらは**絶対にコードに含めない**

**How**:
- 環境変数を使用
- `.env` ファイル（`.gitignore` に追加）
- Secrets manager（AWS Secrets Manager, Vault等）

- Good:
\```typescript
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error('API_KEY is not set');
}
\```

- Bad:
\```typescript
const apiKey = 'sk-1234567890abcdef'; // NG!
\```

### Rule 2: Always Validate Input

**Why**: ユーザー入力は信頼できない。XSS、SQLインジェクション、コマンドインジェクションを防ぐ

**What**: すべての外部入力（リクエストボディ、クエリパラメータ、ヘッダー）をバリデート

**How**: Zodなどのバリデーションライブラリを使用

- Good:
\```typescript
import { z } from 'zod';

const UserSchema = z.object({
  email: z.string().email(),
  age: z.number().min(0).max(150),
});

app.post('/api/user', (req, res) => {
  const result = UserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ error: result.error });
  }
  // result.data は型安全
});
\```

- Bad:
\```typescript
app.post('/api/user', (req, res) => {
  const { email, age } = req.body; // バリデーションなし
  // XSS, インジェクションのリスク
});
\```

### Rule 3: Use Parameterized Queries

**Why**: SQLインジェクションを防ぐ

**What**: 文字列連結でSQLを構築しない

**How**: ORMまたはパラメータ化クエリを使用

- Good:
\```typescript
// ORMを使用（Prisma例）
const user = await prisma.user.findUnique({
  where: { email: userEmail }
});

// パラメータ化クエリ
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [userEmail]
);
\```

- Bad:
\```typescript
const user = await db.query(
  `SELECT * FROM users WHERE email = '${userEmail}'`
); // SQLインジェクション脆弱性！
\```

### Rule 4: Implement Authentication & Authorization

**Why**: リソースへの不正アクセスを防ぐ

**What**:
- **Authentication**: ユーザーが誰かを確認
- **Authorization**: ユーザーが何をできるかを制御

**How**:

\```typescript
// 認証ミドルウェア
const requireAuth = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const user = await verifyToken(token);
    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// 認可チェック
const requireRole = (role: string) => {
  return (req, res, next) => {
    if (req.user.role !== role) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
};

// 使用例
app.delete('/api/users/:id',
  requireAuth,
  requireRole('admin'),
  deleteUser
);
\```

### Rule 5: Rate Limiting

**Why**: DDoS攻撃やブルートフォース攻撃を防ぐ

**How**:

\```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分
  max: 100, // 最大100リクエスト
  message: 'Too many requests'
});

app.use('/api/', limiter);
\```

## Important Rules

### Rule 6: Use HTTPS

本番環境では必ずHTTPSを使用

### Rule 7: Set Security Headers

\```typescript
app.use(helmet()); // セキュリティヘッダーを設定
\```

### Rule 8: Sanitize Output

XSS対策としてHTMLをエスケープ

### Rule 9: Keep Dependencies Updated

定期的に `npm audit` を実行し、脆弱性を修正

### Rule 10: Log Security Events

認証失敗、不正アクセス試行をログに記録

## Checklist

コードをコミットする前に確認：

- [ ] シークレットがコードに含まれていない
- [ ] すべての入力がバリデートされている
- [ ] SQLインジェクションのリスクがない
- [ ] 認証・認可が適切に実装されている
- [ ] Rate limitingが設定されている
- [ ] セキュリティヘッダーが設定されている
- [ ] HTTPSを使用している（本番）
- [ ] 依存パッケージに既知の脆弱性がない

## Notes

- セキュリティは後から追加するものではなく、最初から組み込むもの
- 不明な点があれば必ずセキュリティエキスパートに相談
- OWASP Top 10を定期的にレビュー
```
```

---

## Agents - サブエージェント

Agentsは、特定のタスクに特化したサブエージェントです。複雑なタスクを専門家に委譲できます。

### Agentの役割

- 特定ドメインの専門知識を持つ
- 複雑なタスクを分解・実行
- 一貫した出力形式を提供

### よく使うAgents

| Agent | 役割 | 使用場面 |
|-------|------|---------|
| **planner** | 実装計画を作成 | 大きな機能追加前 |
| **architect** | アーキテクチャ設計 | システム設計・リファクタリング |
| **code-reviewer** | コードレビュー | PR作成時 |
| **security-reviewer** | セキュリティチェック | セキュリティ監査 |
| **test-writer** | テスト作成 | テストカバレッジ向上 |
| **documenter** | ドキュメント作成 | API仕様書・README作成 |

### Agentファイルの構造

`.claude/agents/code-reviewer.md`:

```markdown
# Code Reviewer Agent

コードレビューを実行し、改善提案を提供する専門エージェント

## Role

あなたは経験豊富なシニアエンジニアとして、コードレビューを行います。

## Responsibilities

1. コード品質の評価
2. バグ・脆弱性の検出
3. ベストプラクティスの適用確認
4. パフォーマンス問題の指摘
5. 改善提案の提供

## Review Checklist

### Code Quality
- [ ] 可読性（命名、構造）
- [ ] DRY原則の遵守
- [ ] SOLID原則の遵守
- [ ] 適切なエラーハンドリング

### Security
- [ ] 入力バリデーション
- [ ] SQLインジェクション対策
- [ ] XSS対策
- [ ] 認証・認可の確認

### Performance
- [ ] 不要なループ・計算
- [ ] N+1クエリ問題
- [ ] メモリリーク
- [ ] キャッシング機会

### Testing
- [ ] テストカバレッジ
- [ ] エッジケースのカバー
- [ ] モックの適切な使用

## Output Format

レビュー結果を以下の形式で出力：

\```markdown
# Code Review: [ファイル名/機能名]

## Summary
[全体的な評価を2-3文で]

## Critical Issues (Must Fix)
1. **[問題]** (Line X)
   - Why: [なぜ問題か]
   - Fix: [どう修正すべきか]
   \```typescript
   // 修正案
   \```

## Important Issues (Should Fix)
...

## Suggestions (Nice to Have)
...

## Positive Points
- [良かった点1]
- [良かった点2]

## Overall Score: X/10
\```

## Rules to Follow

- 建設的なフィードバックを提供
- 具体的な修正案を示す
- 良い点も必ず指摘
- 優先順位を明確に（Critical / Important / Suggestion）
```

---

## Hooks - イベント駆動自動化

Hooksは、特定のイベント（ツール実行前後）で自動的に実行されるスクリプトです。

### Hooksの種類

- **PreToolUse**: ツール実行前に実行
- **PostToolUse**: ツール実行後に実行
- **Stop**: セッション終了時に実行

### settings.jsonでの設定

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "name": "lint-before-write",
        "event": {
          "tool": "Write"
        },
        "command": "npm run lint:fix"
      }
    ],
    "PostToolUse": [
      {
        "name": "test-after-edit",
        "event": {
          "tool": "Edit",
          "pattern": "src/**/*.ts"
        },
        "command": "npm test -- --related ${file}"
      },
      {
        "name": "type-check-after-changes",
        "event": {
          "tool": ["Write", "Edit"],
          "pattern": "**/*.{ts,tsx}"
        },
        "command": "npm run type-check"
      }
    ]
  }
}
```

### よく使うHooks例

**1. コード変更後に自動テスト**

```json
{
  "name": "auto-test",
  "event": {
    "tool": ["Write", "Edit"],
    "pattern": "src/**/*.{ts,tsx,js,jsx}"
  },
  "command": "npm test"
}
```

**2. 書き込み前にフォーマット**

```json
{
  "name": "auto-format",
  "event": {
    "tool": "Write"
  },
  "command": "npx prettier --write ${file}"
}
```

**3. Git commit前にリント**

```json
{
  "name": "pre-commit-lint",
  "event": {
    "tool": "Bash",
    "pattern": "git commit*"
  },
  "command": "npm run lint"
}
```

---

## 実践例

### 例1: AWS Snowflake プロジェクトの設定

実際のSnowflakeプロジェクト向けの設定例：

```
snow-cli/
├── .claude/
│   ├── skills/
│   │   ├── snowflake-mcp/
│   │   │   └── SKILL.md         # Snowflake操作手順
│   │   ├── streamlit-deploy/
│   │   │   └── SKILL.md         # Streamlitデプロイ手順
│   │   └── data-analysis/
│   │       └── SKILL.md         # データ分析パターン
│   ├── commands/
│   │   ├── deploy-streamlit.md # /deploy-streamlit
│   │   ├── query-snowflake.md  # /query-snowflake
│   │   └── analyze-data.md     # /analyze-data
│   ├── rules/
│   │   ├── sql-style.md        # SQL命名規則
│   │   └── snowflake-best-practices.md
│   ├── settings.json
│   └── CLAUDE.md
└── Streamlit/
    └── my-app/
```

#### `.claude/commands/deploy-streamlit.md`

```markdown
# /deploy-streamlit

Streamlitアプリをsnowflake にデプロイします

## Instructions

1. snowflake.yml と environment.yml を検証
2. snow CLI でデプロイ実行
3. エラーがあれば修正
4. デプロイ後のURLを取得

## Process

\```bash
# 1. 設定ファイル確認
cat snowflake.yml
cat environment.yml

# 2. デプロイ
snow streamlit deploy --connection my_connection --replace

# 3. URL取得
snow streamlit get-url app-name
\```

## Reference

- Skill: streamlit-deploy
```

### 例2: Web API プロジェクトの設定

```
api-project/
├── .claude/
│   ├── skills/
│   │   ├── tdd-workflow/
│   │   ├── api-design/
│   │   └── backend-patterns.md
│   ├── commands/
│   │   ├── tdd.md
│   │   ├── api-create.md
│   │   └── code-review.md
│   ├── rules/
│   │   ├── security.md
│   │   ├── testing.md
│   │   └── api-standards.md
│   ├── agents/
│   │   ├── api-designer.md
│   │   └── security-reviewer.md
│   ├── settings.json
│   └── CLAUDE.md
└── src/
```

#### `.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "name": "test-after-code-change",
        "event": {
          "tool": ["Write", "Edit"],
          "pattern": "src/**/*.ts"
        },
        "command": "npm test -- --related ${file}"
      },
      {
        "name": "lint-check",
        "event": {
          "tool": ["Write", "Edit"]
        },
        "command": "npm run lint"
      }
    ]
  },
  "mcp": {
    "enabled": ["github", "postgres", "supabase"]
  }
}
```

---

## パフォーマンス最適化

### コンテキストウィンドウの管理

**重要**: MCPサーバーを有効にしすぎると、コンテキストウィンドウが縮小します。

- デフォルト: 200k tokens
- 多すぎるMCP（20-30個有効）: 70k tokensに縮小

**ベストプラクティス:**

1. **必要最小限のMCPのみ有効化**
   - 常時20-30個のMCPを設定
   - プロジェクトごとに10個以下を有効化

2. **プロジェクト別に設定を分ける**
   ```
   ~/.claude/           # グローバル設定
   project-a/.claude/   # プロジェクトA用（MCPはA関連のみ）
   project-b/.claude/   # プロジェクトB用（MCPはB関連のみ）
   ```

3. **不要なSkills/Rulesは削除**
   - 使わないSkillsは削除またはコメントアウト
   - プロジェクト固有のものだけを残す

### MCPサーバーの選択

プロジェクトタイプ別の推奨MCP：

**Snowflakeプロジェクト:**
- - snowflake-simple
- - dbt (if using dbt)
- - postgres, mysql（使わないものは無効化）

**Webアプリプロジェクト:**
- - github
- - supabase or postgres
- - vercel or railway
- - snowflake（使わないものは無効化）

**データ分析プロジェクト:**
- - snowflake or postgres
- - dbt
- - jupyter
- - vercel, railway（使わないものは無効化）

---

## まとめ

### セットアップチェックリスト

- [ ] ディレクトリ構造を作成（`.claude/` または `~/.claude/`）
- [ ] Skills を配置（ワークフロー定義）
- [ ] Commands を配置（スラッシュコマンド）
- [ ] Rules を配置（常に従うガイドライン）
- [ ] Agents を配置（必要に応じて）
- [ ] Hooks を設定（`settings.json`）
- [ ] MCPサーバーを選択・有効化（必要最小限）
- [ ] CLAUDE.md を作成（プロジェクト説明）

### 効果的な使い方

1. **段階的に導入**
   - 最初はSkillsとCommandsから
   - 慣れたらRules、Agents、Hooksを追加

2. **チームで共有**
   - リポジトリに`.claude/`をコミット
   - チーム全体で一貫した開発体験

3. **定期的にメンテナンス**
   - 使わないSkillsは削除
   - 新しいパターンを追加
   - MCPの有効化状況を見直し

4. **コンテキストウィンドウを意識**
   - MCPは10個以下に抑える
   - Skillsは本当に必要なものだけ

### 参考リソース

- [優勝リポジトリ](https://github.com/affaan-m/everything-claude-code) - プロダクションレディな設定例
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code) - 公式ドキュメント
- OWASP Top 10 - セキュリティベストプラクティス

---

**このガイドを使って、あなたのプロジェクトに最適なClaude Code設定を作りましょう！**
