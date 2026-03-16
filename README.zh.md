# claude-code-workflow

[English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | **中文** | [Français](README.fr.md)

> 为 Claude Code 提供会话记忆、错误学习、项目脚手架和 Git 集成。

---

## 问题所在

每次执行 `/clear` 或开启新的 Claude Code 会话时，**所有上下文都会丢失**。Claude 会忘记你做了什么、犯了哪些错误，以及项目遵循哪些规则。管理多个项目时，情况更加糟糕。

## 解决方案

**5 个 slash command**，为 Claude 提供持久记忆、错误学习和多项目导航：

```
/init-worklog      →  初始化记录基础设施（每个项目执行一次）
/init-project-v1   →  使用空白模板快速搭建项目脚手架
/init-project-v2   →  引导式设置并生成真实文档
/session-start     →  恢复上次会话的上下文
/session-end       →  保存所有内容 + 工作日志 + Git 提交
```

---

## 快速开始

### 安装

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

安装程序将会：
1. 将 5 个 slash command 复制到 `~/.claude/commands/`
2. 创建 `~/work-tree.md`（项目导航地图）
3. 可选创建 `~/work_logs/`（全局仪表盘）
4. 可选配置 Obsidian 同步

### 首次使用

```
cd your-project
/init-worklog          # 初始化 work_logs/（约 30 秒）
# 正常工作...
/session-end           # 记录所有内容
# 下次会话：
/session-start         # 从上次中断处继续
```

### 新建项目

```
cd empty-folder
/init-project-v1       # 快速脚手架（约 5 分钟）
# 或
/init-project-v2       # 详细设置并生成真实文档（约 30 分钟）
```

---

## 工作原理

### 会话生命周期

```
┌─────────────────────────────────────────────────┐
│                 /session-start v3                │
│                                                  │
│  0. 加载 work-tree.md  → 项目导航地图             │
│  1. 加载 remind.md     → 项目规则                │
│  2. 加载 error-rules.md → 错误预防               │
│  3. 加载 chatlog.md    → 未完成任务               │
│  4. 加载 CHANGELOG.md  → 近期变更                │
│  5. 加载 ~/work_logs/error-rules.md              │
│     → 全局共享规则（跨项目）                       │
│                                                  │
│  输出：上下文摘要 + 建议的下一步任务               │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                  正常工作会话                     │
│                                                  │
│  - 编写代码、修复 Bug、添加功能                    │
│  - 错误以 ERR-### 条目记录                        │
│  - 从错误中派生出 RUL-### 规则                    │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                /session-end v4                   │
│                                                  │
│  1. 分析会话 → 提取任务和决策                     │
│  2. 将会话块追加到 chatlog.md                     │
│  3. 向全局仪表盘追加 1 行记录                     │
│  4. 记录错误 + 派生预防规则                       │
│  5. 更新 remind.md + CHANGELOG.md                │
│  6. 创建带日期的工作日志文件                      │
│  7. [可选] 同步到 Obsidian + CLI                 │
│  8. 自动生成消息并执行 Git 提交                   │
│  9. 输出：最终报告 + 下次会话任务                 │
└─────────────────────────────────────────────────┘
```

---

## 5 个命令

### `/init-worklog` (v2)

将记录系统添加到任何现有项目中。

**创建的文件：**

| 文件 | 用途 |
|------|---------|
| `work_logs/chatlog.md` | 会话记忆 |
| `work_logs/remind.md` | 项目规则 |
| `work_logs/error_logs.md` | 错误记录（ERR-###） |
| `work_logs/error-rules.md` | 预防规则（RUL-###） |
| `work_logs/CHANGELOG.md` | 变更历史 |

**v2 新增**：自动将项目注册到 `work-tree.md`，支持跨项目导航。

### `/init-project-v1`

快速项目脚手架 —— 提问 4 个问题，创建空白模板文档。

**创建内容**：`CLAUDE.md` + `docs/`（空白模板）+ `work_logs/` + `.gitignore`

适合场景：黑客松、实验性项目、计划尚未确定时。

### `/init-project-v2`

详细项目设置 —— 分 3 轮提问，编写真实文档内容。

**创建内容**：`CLAUDE.md` + `docs/`（真实内容）+ `work_logs/` + `.gitignore`

适合场景：正式项目、长期开发、文档驱动开发。

### `/session-start` (v3)

从上次会话恢复上下文。

**按顺序加载：**
1. `work-tree.md` — 项目导航地图
2. `remind.md` — 项目规则
3. `error-rules.md` — 错误预防（项目级 + 全局）
4. `chatlog.md` — 历史会话和未完成任务
5. `CHANGELOG.md` — 近期变更

**全局模式**：从 `~/` 运行，可扫描所有项目，一次性查看所有未完成任务。

### `/session-end` (v4)

记录当前会话并为下次会话做好准备。

| 步骤 | 操作 |
|------|--------|
| 1-2 | 分析会话，提取任务和决策 |
| 3 | 将会话块追加到 chatlog.md |
| 3.5 | 向全局仪表盘追加 1 行记录 |
| 3.7 | 记录错误（ERR-###）+ 派生规则（RUL-###） |
| 4-5 | 更新 remind.md + CHANGELOG.md |
| 6 | 创建带日期的工作日志 |
| 6.5 | [可选] Obsidian CLI 同步 |
| 7 | Git 提交（需用户确认） |
| 8 | 最终报告 |

---

## 核心特性

### 会话记忆
每次会话均以结构化块的形式记录在 `chatlog.md` 中。下次执行 `/session-start` 时，可精确从上次中断处继续。

### 错误学习
错误以 `ERR-###` 形式记录，并派生出 `RUL-###` 预防规则。项目 A 的规则可通过全局 `~/work_logs/error-rules.md` 防止项目 B 犯同样的错误。

### 多项目导航
`work-tree.md` 汇总所有项目。`/init-worklog` 自动注册新项目。从 `~/` 运行 `/session-start`，可一次性查看所有未完成任务。

### 双层日志
- **项目级**：`chatlog.md` 中的详细会话块
- **全局级**：`~/work_logs/chatlog.md` 中的单行仪表盘

### Git 集成
根据会话摘要自动生成提交消息。敏感文件（.env、credentials 等）自动排除。

### Obsidian 同步（可选）
工作日志自动复制到你的 Obsidian Vault。支持 CLI 集成，可联动 Daily Notes 和任务计数。

---

## 文件结构

```
~/                                    # 全局
├── work-tree.md                      # 项目导航地图
├── work_logs/
│   ├── chatlog.md                    # 所有会话仪表盘
│   ├── error_logs.md                 # 跨项目错误
│   ├── error-rules.md               # 共享预防规则
│   └── remind.md                     # 全局规则
└── .claude/commands/                 # Skill 文件（共 5 个）

{project}/                            # 每个项目
├── work_logs/
│   ├── chatlog.md                    # 会话记录
│   ├── remind.md                     # 项目规则
│   ├── error_logs.md                 # 错误（ERR-###）
│   ├── error-rules.md               # 规则（RUL-###）
│   ├── CHANGELOG.md                  # 变更记录
│   └── YYYY_MM_DD_*_worklog.md       # 带日期的工作日志
└── CLAUDE.md                         # 项目上下文
```

---

## 与 Claude Code `/memory` 的对比

| | `/memory`（内置） | claude-code-workflow |
|---|:---:|:---:|
| **会话历史** | 否 | 是 |
| **未完成任务追踪** | 否 | 是 |
| **错误学习** | 否 | 是（ERR → RUL） |
| **跨项目错误共享** | 否 | 是 |
| **多项目导航** | 否 | 是（work-tree.md） |
| **项目脚手架** | 否 | 是（v1 + v2） |
| **Git 提交集成** | 否 | 是 |
| **Obsidian 同步** | 否 | 是（可选） |

**两者互为补充。** 使用 `/memory` 保存静态偏好，使用 workflow 管理会话生命周期。

---

## 环境要求

- 已安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- macOS 或 Linux
- Git（用于提交集成）

## 许可证

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — 可自由使用和修改，禁止商业销售。
