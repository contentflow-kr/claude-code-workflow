# claude-code-workflow

[English](README.md) | [한국어](README.ko.md) | **日本語** | [中文](README.zh.md) | [Français](README.fr.md)

> Claude Code のセッションメモリ、エラー学習、プロジェクトスキャフォールディング、Git 連携。

---

## 問題点

`/clear` するたびに、または新しい Claude Code セッションを開始するたびに、**すべてのコンテキストが失われます**。Claude は何に取り組んでいたか、どんなミスをしたか、プロジェクトがどんなルールに従っているかを忘れてしまいます。複数のプロジェクトを管理していると、さらに深刻になります。

## 解決策

Claude に永続的なメモリ、エラー学習、マルチプロジェクトナビゲーションを与える **5 つの slash command**:

```
/init-worklog      →  記録インフラのセットアップ（プロジェクトごとに一度）
/init-project-v1   →  空のテンプレートで素早くプロジェクトスキャフォールディング
/init-project-v2   →  実際のドキュメントを含むガイド付きセットアップ
/session-start     →  前回のコンテキストを復元
/session-end       →  すべてを保存 + ワークログ + Git コミット
```

---

## クイックスタート

### インストール

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

インストーラーは以下を行います:
1. 5 つの slash command を `~/.claude/commands/` にコピー
2. `~/work-tree.md`（プロジェクトナビゲーションマップ）を作成
3. オプションで `~/work_logs/`（グローバルダッシュボード）を作成
4. オプションで Obsidian 同期を設定

### 初めて使う場合

```
cd your-project
/init-worklog          # work_logs/ のセットアップ（30秒）
# 通常通り作業...
/session-end           # すべてを記録
# 次のセッション:
/session-start         # 前回の続きから再開
```

### 新規プロジェクトの場合

```
cd empty-folder
/init-project-v1       # 素早いスキャフォールディング（5分）
# または
/init-project-v2       # 実際のドキュメントを含む詳細なセットアップ（30分）
```

---

## 仕組み

### セッションライフサイクル

```
┌─────────────────────────────────────────────────┐
│                 /session-start v3                │
│                                                  │
│  0. Load work-tree.md  → Project navigation map  │
│  1. Load remind.md     → Project rules           │
│  2. Load error-rules.md → Error prevention       │
│  3. Load chatlog.md    → Unfinished tasks        │
│  4. Load CHANGELOG.md  → Recent changes          │
│  5. Load ~/work_logs/error-rules.md              │
│     → Global shared rules (cross-project)        │
│                                                  │
│  Output: Context summary + suggested next task   │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│              Normal Work Session                 │
│                                                  │
│  - Write code, fix bugs, add features            │
│  - Errors tracked as ERR-### entries             │
│  - Rules derived as RUL-### entries              │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                /session-end v4                   │
│                                                  │
│  1. Analyze session → extract tasks, decisions   │
│  2. Append session block to chatlog.md           │
│  3. Append 1-line to global dashboard            │
│  4. Log errors + derive prevention rules         │
│  5. Update remind.md + CHANGELOG.md              │
│  6. Create dated worklog file                    │
│  7. [Optional] Sync to Obsidian + CLI            │
│  8. Git commit with auto-generated message       │
│  9. Output: final report + next session tasks    │
└─────────────────────────────────────────────────┘
```

---

## 5 つのコマンド

### `/init-worklog` (v2)

既存のプロジェクトに記録システムを追加します。

**作成されるファイル:**

| ファイル | 用途 |
|------|---------|
| `work_logs/chatlog.md` | セッションメモリ |
| `work_logs/remind.md` | プロジェクトルール |
| `work_logs/error_logs.md` | エラー記録（ERR-###） |
| `work_logs/error-rules.md` | 予防ルール（RUL-###） |
| `work_logs/CHANGELOG.md` | 変更履歴 |

**v2 の追加機能**: クロスプロジェクトナビゲーションのため、`work-tree.md` にプロジェクトを自動登録。

### `/init-project-v1`

素早いプロジェクトスキャフォールディング — 4 つの質問をして空のテンプレートドキュメントを作成。

**作成されるもの**: `CLAUDE.md` + `docs/`（空のテンプレート）+ `work_logs/` + `.gitignore`

最適な用途: ハッカソン、実験、計画が未確定の場合。

### `/init-project-v2`

詳細なプロジェクトセットアップ — 3 ラウンドの質問をして実際のドキュメントを作成。

**作成されるもの**: `CLAUDE.md` + `docs/`（実際のコンテンツ）+ `work_logs/` + `.gitignore`

最適な用途: 本格的なプロジェクト、長期開発、ドキュメント駆動開発。

### `/session-start` (v3)

前回のセッションからコンテキストを復元します。

**ロード順序:**
1. `work-tree.md` — プロジェクトナビゲーションマップ
2. `remind.md` — プロジェクトルール
3. `error-rules.md` — エラー予防（プロジェクト + グローバル）
4. `chatlog.md` — 過去のセッションと未完了タスク
5. `CHANGELOG.md` — 最近の変更

**グローバルモード**: `~/` から実行すると、すべてのプロジェクトをスキャンして未完了タスクを一覧表示。

### `/session-end` (v4)

現在のセッションを記録し、次のセッションに備えます。

| ステップ | アクション |
|------|--------|
| 1-2 | セッションを分析し、タスク・決定事項を抽出 |
| 3 | chatlog.md にセッションブロックを追記 |
| 3.5 | グローバルダッシュボードに 1 行追記 |
| 3.7 | エラーを記録（ERR-###）+ ルールを導出（RUL-###） |
| 4-5 | remind.md + CHANGELOG.md を更新 |
| 6 | 日付付きワークログを作成 |
| 6.5 | [オプション] Obsidian CLI 同期 |
| 7 | Git コミット（ユーザー確認あり） |
| 8 | 最終レポート |

---

## 主な機能

### セッションメモリ
すべてのセッションが `chatlog.md` に構造化されたブロックとして記録されます。次の `/session-start` で正確に前回の続きから再開できます。

### エラー学習
エラーは `ERR-###` として追跡され、予防ルールが `RUL-###` として導出されます。プロジェクト A のルールが、グローバルな `~/work_logs/error-rules.md` を通じてプロジェクト B での同じミスを防ぎます。

### マルチプロジェクトナビゲーション
`work-tree.md` がすべてのプロジェクトをマッピングします。`/init-worklog` が新しいプロジェクトを自動登録します。`~/` から `/session-start` を実行すると、すべての未完了タスクを一度に確認できます。

### 2 層ロギング
- **プロジェクトレベル**: `chatlog.md` の詳細なセッションブロック
- **グローバルレベル**: `~/work_logs/chatlog.md` の 1 行ダッシュボード

### Git 連携
セッションサマリーから自動生成されるコミットメッセージ。機密ファイル（.env、認証情報）は自動的に除外されます。

### Obsidian 同期（オプション）
ワークログが Obsidian vault に自動コピーされます。Daily Notes とタスク数の CLI 連携。

---

## ファイル構成

```
~/                                    # グローバル
├── work-tree.md                      # プロジェクトナビゲーションマップ
├── work_logs/
│   ├── chatlog.md                    # 全セッションダッシュボード
│   ├── error_logs.md                 # クロスプロジェクトエラー
│   ├── error-rules.md               # 共有予防ルール
│   └── remind.md                     # グローバルルール
└── .claude/commands/                 # スキルファイル（5つ）

{project}/                            # プロジェクトごと
├── work_logs/
│   ├── chatlog.md                    # セッション記録
│   ├── remind.md                     # プロジェクトルール
│   ├── error_logs.md                 # エラー（ERR-###）
│   ├── error-rules.md               # ルール（RUL-###）
│   ├── CHANGELOG.md                  # 変更履歴
│   └── YYYY_MM_DD_*_worklog.md       # 日付付きワークログ
└── CLAUDE.md                         # プロジェクトコンテキスト
```

---

## Claude Code `/memory` との比較

| | `/memory`（組み込み） | claude-code-workflow |
|---|:---:|:---:|
| **セッション履歴** | なし | あり |
| **未完了タスクの追跡** | なし | あり |
| **エラー学習** | なし | あり（ERR → RUL） |
| **クロスプロジェクトのエラー共有** | なし | あり |
| **マルチプロジェクトナビゲーション** | なし | あり（work-tree.md） |
| **プロジェクトスキャフォールディング** | なし | あり（v1 + v2） |
| **Git コミット連携** | なし | あり |
| **Obsidian 同期** | なし | あり（オプション） |

**両者は補完的です。** 静的な設定には `/memory` を、セッションライフサイクルにはこのワークフローを使用してください。

---

## 動作要件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストール済み
- macOS または Linux
- Git（コミット連携のため）

## ライセンス

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — 使用・改変は自由、商業販売は禁止。
