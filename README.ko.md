# claude-code-workflow

> Claude Code를 위한 세션 기억, 에러 학습, Git 통합 프레임워크.

[English README](README.md)

---

## 문제

Claude Code에서 `/clear`하거나 새 세션을 시작하면 **모든 컨텍스트가 사라집니다**. 이전에 뭘 했는지, 어떤 실수가 있었는지, 프로젝트 규칙이 뭔지 전부 잊어버립니다. 매 세션을 처음부터 시작하게 됩니다.

## 해결

세션 간 **영구 기억**을 제공하는 3개의 슬래시 명령어:

```
/session-start   →  이전 컨텍스트 로딩 (chatlog + 규칙 + 에러 방지)
(평소처럼 작업)
/session-end     →  모든 내용 저장 + 에러 학습 + Git 커밋
```

`/clear` → `/session-start` 사이클이 컨텍스트 손실이 아닌 **컨텍스트 리프레시**가 됩니다.

---

## 작동 방식

### 세션 라이프사이클

```
┌─────────────────────────────────────────────────┐
│                  /session-start                  │
│                                                  │
│  1. remind.md 읽기       → 프로젝트 규칙         │
│  2. error-rules.md 읽기  → 에러 방지 규칙        │
│  3. chatlog.md 읽기      → 미완료 작업           │
│  4. CHANGELOG.md 읽기    → 최근 변경사항         │
│  5. ~/work_logs/error-rules.md 읽기              │
│     → 글로벌 공유 규칙 (프로젝트 간)             │
│                                                  │
│  출력: 컨텍스트 요약 + 다음 작업 제안            │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                일반 작업 세션                     │
│                                                  │
│  - 코드 작성, 버그 수정, 기능 추가               │
│  - 에러 발생 시 ERR-### 자동 추적                │
│  - 방지 규칙 RUL-### 도출                        │
│  - 모든 컨텍스트 대화에 보존                     │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                  /session-end                    │
│                                                  │
│  1. 세션 분석 → 작업, 결정사항 추출              │
│  2. chatlog.md에 세션 블록 추가                  │
│  3. 글로벌 대시보드에 1행 요약 추가              │
│  4. 에러 기록 (ERR-###) + 규칙 도출 (RUL-###)   │
│  5. remind.md 업데이트 (새 프로젝트 규칙)        │
│  6. CHANGELOG.md 업데이트                        │
│  7. 날짜별 작업일지 파일 생성                    │
│  8. [선택] Obsidian에 작업일지 동기화            │
│  9. Git 커밋 (자동 생성 메시지 + 사용자 확인)    │
│ 10. 출력: 최종 보고서 + 다음 세션 작업           │
└─────────────────────────────────────────────────┘
```

---

## 핵심 기능

### 1. 세션 기억 (`chatlog.md`)

시스템의 핵심. 모든 세션이 구조화된 블록으로 기록됩니다:

```markdown
## Session 3 (2026-03-04) - 인증 버그 수정

### Tasks Completed
- JWT 토큰 만료 처리 수정
- 리프레시 토큰 로테이션 추가

### Files Changed
- `src/auth/token.ts` - 만료 체크 추가
- `src/middleware/auth.ts` - 리프레시 로직 추가

### Unfinished Tasks (next session)
- [ ] 리프레시 엔드포인트에 rate limiting 추가
- [ ] 토큰 로테이션 테스트 작성

### Key Decisions
- 토큰 리프레시에 슬라이딩 윈도우 사용 (고정 간격 아님)

### Git
- Commit: `a1b2c3d` - fix: JWT 토큰 만료 처리
```

다음에 `/session-start`를 실행하면, Claude가 이걸 읽고 미완료 작업, 최근 결정사항, 파일 컨텍스트를 포함해 **정확히 이전 작업을 이어갑니다**.

### 2. 에러 학습 시스템

에러는 `ERR-###` ID로 추적되고, 방지 규칙은 `RUL-###`으로 도출됩니다:

```
세션 3: ERR-001 — DB 커넥션 풀 미초기화
        → RUL-001: 쿼리 전 풀 초기화 확인 필수

세션 4: Claude가 RUL-001을 자동 로딩하고 풀 확인
```

**작동 방식:**

| 파일 | 용도 | 로딩 시점 |
|------|------|-----------|
| `work_logs/error_logs.md` | 에러 기록 (해결 과정 포함) | 참조용 |
| `work_logs/error-rules.md` | 에러에서 도출된 방지 규칙 | 매 `/session-start` |
| `~/work_logs/error-rules.md` | **글로벌** 규칙 (프로젝트 간 공유) | 매 `/session-start` |

규칙은 시간이 지나면서 축적됩니다. **프로젝트 A**에서 발생한 에러가 **프로젝트 B**에서 같은 실수를 방지하는 규칙을 생성합니다.

### 3. 2계층 로깅

**프로젝트 레벨** — `work_logs/chatlog.md`에 상세 세션 블록:
- 전체 작업 목록, 파일 변경, 결정사항, Git 해시
- 작업 이어가기를 위한 완전한 컨텍스트

**글로벌 레벨** (선택) — `~/work_logs/chatlog.md`에 1행=1세션 대시보드:
- 전체 프로젝트 빠른 조회
- `>>` append 사용 (동시 세션 안전)

```markdown
# Global Session Dashboard

| Date | Project | Session | Summary | Status |
|------|---------|---------|---------|--------|
| 2026-03-04 | my-app | Session 5 | 인증 수정 + 테스트 추가 | 완료 |
| 2026-03-04 | api-server | Session 12 | PostgreSQL 마이그레이션 | 진행중 |
```

### 4. Git 커밋 통합

각 세션 종료 시 `/session-end`가 변경사항 커밋을 제안합니다:

1. `git status`와 `git diff --stat` 확인
2. 변경사항이 있으면 질문:
   - **전체 커밋** (권장) — 모든 변경 파일 스테이징 후 커밋
   - **선택 커밋** — 커밋할 파일 선택
   - **건너뛰기** — 이번엔 커밋하지 않음
3. 세션 요약 기반으로 커밋 메시지 자동 생성
4. 커밋 해시를 chatlog.md에 기록
5. **푸시는 하지 않음** — 푸시 타이밍은 사용자가 결정

민감한 파일(`.env`, credentials, `.key`)은 자동으로 감지되어 제외됩니다.

### 5. 프로젝트 규칙 (`remind.md`)

프로젝트별로 Claude가 반드시 따라야 할 규칙. 매 세션 시작 시 로딩됩니다:

```markdown
## Absolute Rules (MUST)
- TypeScript strict 모드 항상 사용
- 마이그레이션 파일 직접 수정 금지

## Coding Conventions
- 변수는 camelCase, 타입은 PascalCase
- 모든 API 응답은 ApiResponse<T> 래퍼 사용

## Warnings
- 레거시 auth 모듈은 deprecated — v2 사용
```

작업 중 발견된 새 규칙은 세션 종료 시 `remind.md`에 자동 추가됩니다.

---

## 빠른 시작

### 방법 1: 자동 설치

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

설치 스크립트가:
1. `~/.claude/commands/`에 슬래시 명령어 복사
2. (선택) 글로벌 대시보드용 `~/work_logs/` 생성
3. (선택) Obsidian 동기화 경로 설정

### 방법 2: 수동 설치

```bash
cp commands/*.md ~/.claude/commands/
```

프로젝트에서 work_logs 초기화:

```
You: /init-worklog
```

---

## 명령어 상세

### `/init-worklog`

현재 프로젝트에 `work_logs/` 디렉토리 구조를 생성합니다.

**생성되는 파일:**

| 파일 | 용도 |
|------|------|
| `chatlog.md` | 세션 기억 — 크로스 세션 컨텍스트 |
| `remind.md` | 프로젝트 규칙 — 매 세션 로딩 |
| `error_logs.md` | 에러 기록 (`ERR-###` 형식) |
| `error-rules.md` | 방지 규칙 (`RUL-###` 형식) |
| `CHANGELOG.md` | 변경 이력 |

기존 파일은 **절대 덮어쓰지 않음** — 없는 파일만 생성합니다.

### `/session-start`

이전 세션의 컨텍스트를 복구합니다.

**로딩 순서:**
1. `remind.md` — 프로젝트 규칙
2. `error-rules.md` — 에러 방지 규칙 (프로젝트 레벨)
3. `chatlog.md` — 이전 세션 + 미완료 작업
4. `CHANGELOG.md` — 최근 변경사항
5. `~/work_logs/error-rules.md` — 글로벌 공유 규칙 (있는 경우)

**출력 내용:**
- 이전 세션 요약
- 미완료 작업 (건수 포함)
- 활성 프로젝트 규칙
- 에러 방지 규칙
- 다음 작업 제안

### `/session-end`

현재 세션을 기록하고 다음 세션을 준비합니다.

**실행 순서:**

| 단계 | 동작 | 파일 |
|------|------|------|
| 1 | 세션 번호 계산 | `chatlog.md` |
| 2 | 대화 분석 | — |
| 3 | 세션 블록 추가 | `chatlog.md` |
| 3.5 | 글로벌 대시보드에 1행 추가 | `~/work_logs/chatlog.md` |
| 3.7 | 에러 기록 + 규칙 도출 | `error_logs.md` + `error-rules.md` |
| 4 | 프로젝트 규칙 업데이트 | `remind.md` |
| 5 | 변경 이력 업데이트 | `CHANGELOG.md` |
| 6 | 날짜별 작업일지 생성 | `work_logs/YYYY_MM_DD_*.md` |
| 7 | Git 커밋 (사용자 확인 후) | — |
| 8 | 최종 보고서 출력 | — |

---

## 파일 구조

`/init-worklog` 실행 후:

```
your-project/
└── work_logs/
    ├── chatlog.md             # 세션 기억 (크로스 세션 컨텍스트)
    ├── remind.md              # 프로젝트 규칙 (매 세션 로딩)
    ├── error_logs.md          # 에러 기록 (ERR-###)
    ├── error-rules.md         # 방지 규칙 (RUL-###)
    ├── CHANGELOG.md           # 변경 이력
    └── 2026_03_04_auth_fix_worklog.md  # 날짜별 작업일지
```

선택사항 글로벌 대시보드:

```
~/work_logs/
├── chatlog.md                 # 전체 프로젝트 세션 요약 (1행=1세션)
├── error_logs.md              # 프로젝트 간 에러 인덱스
└── error-rules.md             # 공유 방지 규칙
```

---

## Claude Code `/memory`와의 차이

Claude Code에는 내장 `/memory` 명령어가 있어 `MEMORY.md`에 메모를 저장합니다. 영구 메모장으로 유용하지만, 워크플로우 시스템은 아닙니다.

| | `/memory` (내장) | claude-code-workflow |
|---|:---:|:---:|
| **저장 내용** | 비구조적 메모 | 구조화된 세션 블록 |
| **세션 기록** | X | O (Session 1, 2, 3...) |
| **미완료 작업 추적** | X | O (다음 세션에서 자동 로딩) |
| **에러 학습** | X | O (ERR-### → RUL-###) |
| **프로젝트 간 에러 공유** | X | O (글로벌 error-rules.md) |
| **프로젝트 규칙** | X | O (remind.md) |
| **Git 커밋 통합** | X | O |
| **글로벌 대시보드** | X | O (전체 프로젝트 한 테이블) |
| **날짜별 작업일지** | X | O |
| **변경 이력** | X | O |

**경쟁이 아니라 보완 관계입니다.** `/memory`는 정적 선호사항("항상 bun 사용", "API 키는 .env.local")에, claude-code-workflow는 세션 라이프사이클 관리(뭘 했고, 뭘 실수했고, 다음에 뭘 해야 하는지)에 사용하세요.

---

## 비교

| 기능 | claude-code-workflow | [claude-sessions](https://github.com/iannuttall/claude-sessions) | [Claude Diary](https://rlancemartin.github.io/2025/12/01/claude_diary/) |
|------|:-------------------:|:---------------:|:------------:|
| 세션 시작/종료 명령어 | O | O | 종료만 |
| 크로스세션 chatlog | O | 일부 | X |
| 프로젝트 규칙 (remind.md) | O | X | X |
| 에러 학습 (ERR/RUL) | O | X | X |
| 2계층 로깅 | O | X | X |
| Git 커밋 통합 | O | X | X |
| Obsidian 동기화 (선택) | O | X | X |
| MCP 의존 없음 | O | O | O |

---

## 선택 기능

### 글로벌 대시보드

모든 프로젝트의 세션을 한 테이블에서 추적. 설치 시 선택하거나 수동으로 `~/work_logs/` 생성.

### Obsidian 동기화

작업일지를 Obsidian 볼트에 자동 작성. 설정 방법은 [config.example.md](config.example.md) 참조.

**참고**: Write 도구를 사용합니다 (`cp` 아님 — 클라우드 동기화 디렉토리(iCloud, Dropbox)에서 `cp`가 실패할 수 있음).

---

## 템플릿

`templates/` 디렉토리에 시작 파일 포함:
- **CLAUDE.md** — 워크플로우 규칙과 커밋 컨벤션이 포함된 프로젝트 설정 템플릿
- **chatlog.md, remind.md, error_logs.md, error-rules.md** — 작업 로그 템플릿

---

## 커스터마이징

### 커밋 메시지 형식

기본 형식:

```
Session {N}: {주제 요약}

- {작업 1}
- {작업 2}

Co-Authored-By: Claude <noreply@anthropic.com>
```

프로젝트 `CLAUDE.md`에서 커스터마이징 가능. Git 컨벤션(feat/fix/docs/refactor/test/chore/style) 포함 예시는 `templates/CLAUDE.md` 참조.

### 작업일지 파일명

기본: `YYYY_MM_DD_[작업명]_worklog.md`

작업명은 세션 주제에서 자동 도출됩니다 (2-5 단어, kebab-case).

---

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 설치
- macOS 또는 Linux
- Git (커밋 통합용)

---

## 라이선스

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — 자유롭게 사용/수정 가능, **상업적 판매 금지**.
