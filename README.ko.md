# claude-code-workflow

> Claude Code를 위한 세션 기억, 에러 학습, Git 통합 프레임워크.

[English README](README.md)

---

## 문제

Claude Code에서 `/clear`하거나 새 세션을 시작하면 **모든 컨텍스트가 사라집니다**. 이전에 뭘 했는지, 어떤 실수가 있었는지, 프로젝트 규칙이 뭔지 전부 잊어버립니다.

## 해결

세션 간 **영구 기억**을 제공하는 3개의 슬래시 명령어:

```
/session-start   →  이전 세션 컨텍스트 복구
(평소처럼 작업)
/session-end     →  모든 내용 저장 + Git 커밋
```

---

## 핵심 기능

### 1. 세션 기억
`/session-start`가 chatlog, 규칙, 에러 방지 규칙을 로딩합니다. `/clear` 후에도 이전 작업을 정확히 이어갈 수 있습니다.

### 2. 에러 학습 시스템
에러 발생 시 `ERR-###`로 기록하고, 예방 규칙 `RUL-###`을 도출합니다. 이 규칙은 다음 세션에서 자동 로딩되며 — **프로젝트 간 공유**도 됩니다.

```
세션 3: ERR-001 — DB 커넥션 풀 미초기화
        → RUL-001: 쿼리 전 풀 초기화 확인 필수

세션 4: Claude가 자동으로 풀 확인 (RUL-001 학습)
```

### 3. Git 커밋 통합
`/session-end`에서 커밋 여부를 물어보고, 세션 요약 기반으로 커밋 메시지를 자동 생성하고, 커밋 해시를 chatlog에 기록합니다.

### 4. 2계층 로깅
- **프로젝트 레벨**: `work_logs/chatlog.md`에 세션별 상세 기록
- **글로벌 레벨** (선택): `~/work_logs/chatlog.md`에 1행 요약 대시보드

---

## 빠른 시작

### 방법 1: 자동 설치

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

### 방법 2: 수동 설치

```bash
cp commands/*.md ~/.claude/commands/
```

프로젝트에서 work_logs 초기화:

```
You: /init-worklog
```

---

## 사용법

### 세션 시작
```
You: /session-start
```
chatlog.md + remind.md + error-rules.md를 로딩하고 컨텍스트 요약을 보여줍니다.

### 세션 종료
```
You: /session-end
```
작업 내용 기록 + 작업일지 생성 + Git 커밋 (선택).

### 새 프로젝트 초기화
```
You: /init-worklog
```
`work_logs/` 디렉토리와 템플릿 파일을 생성합니다.

---

## 파일 구조

`/init-worklog` 실행 후:

```
your-project/
└── work_logs/
    ├── chatlog.md        # 세션 기억 (크로스 세션 컨텍스트)
    ├── remind.md         # 프로젝트 규칙 (매 세션 로딩)
    ├── error_logs.md     # 에러 기록 (ERR-###)
    ├── error-rules.md    # 예방 규칙 (RUL-###)
    └── CHANGELOG.md      # 변경 이력
```

선택사항 글로벌 대시보드:

```
~/work_logs/
├── chatlog.md            # 전체 프로젝트 세션 요약 (1행=1세션)
├── error_logs.md         # 프로젝트 간 에러 인덱스
└── error-rules.md        # 공유 예방 규칙
```

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

---

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 설치
- macOS 또는 Linux
- Git (커밋 통합용)

---

## 라이선스

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — 자유롭게 사용/수정 가능, **상업적 판매 금지**.
